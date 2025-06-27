import 'dart:convert';
import 'dart:developer';
import 'package:cooki/data/dto/generated_recipe_dto.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import '../../app/constants/app_constants.dart';
import '../dto/validation_dto.dart';

abstract class RecipeGenerationDataSource {
  Future<ValidationDto> validateUserInput(String textInput);

  Future<GeneratedRecipeDto> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    Set<String>? preferences,
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  });
}

class GeminiRecipeGenerationDataSource implements RecipeGenerationDataSource {
  final GenerativeModel _validationModel;
  final GenerativeModel _recipeGenerationModel;

  GeminiRecipeGenerationDataSource(FirebaseAI googleAI)
    : _validationModel = googleAI.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {'isValid': Schema.boolean()},
          ),
        ),
      ),
      _recipeGenerationModel = googleAI.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'recipeName': Schema.string(),
              'ingredients': Schema.array(items: Schema.string()),
              'steps': Schema.array(items: Schema.string()),
              'cookTime': Schema.integer(),
              'calories': Schema.integer(),
              'category': Schema.string(),
              'tags': Schema.array(items: Schema.string()),
            },
            propertyOrdering: [
              'recipeName',
              'ingredients',
              'steps',
              'cookTime',
              'calories',
              'category',
              'tags',
            ],
          ),
        ),
      );

  @override
  Future<ValidationDto> validateUserInput(String textInput) async {
    final String promptTemplate = await rootBundle.loadString(
      AppConstants.validationPromptPath,
    );
    final prompt = promptTemplate.replaceAll(
      AppConstants.textInputPlaceholder,
      textInput,
    );
    final content = Content.text(prompt);
    final response = await _validationModel.generateContent([content]);

    final stats = await printGeminiFreeTierUsageStats(
      content: content,
      model: _validationModel,
      estimatedOutputTokens: 5,
    );
    log('\n검증 프롬프트 토큰 통계:\n$stats');

    final jsonResponse = json.decode(response.text ?? '{"isValid": false}');
    return ValidationDto.fromJson(jsonResponse);
  }

  @override
  Future<GeneratedRecipeDto> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    Set<String>? preferences,
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  }) async {
    final prompt = await _buildRecipePrompt(
      textInput: textInput,
      preferences: preferences,
      hasImage: imageBytes != null,
      textOnlyRecipePromptPath: textOnlyRecipePromptPath,
      imageRecipePromptPath: imageRecipePromptPath,
    );
    final content = <Content>[];

    if (imageBytes != null) {
      // Image (with or without text)
      content.add(
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ]),
      );
    } else if (textInput != null) {
      // Only text
      content.add(Content.text(prompt));
    } else {
      throw ArgumentError('Either textInput or imageBytes must be provided');
    }

    final stats = await printGeminiFreeTierUsageStats(
      content: content.first,
      model: _recipeGenerationModel,
    );
    log('\n레시피 생성 프롬프트 토큰 통계:\n$stats');

    final response = await _recipeGenerationModel.generateContent(content);
    final jsonResponse = json.decode(response.text ?? '{}');
    return GeneratedRecipeDto.fromJson(jsonResponse);
  }

  Future<String> _buildRecipePrompt({
    String? textInput,
    Set<String>? preferences,
    required bool hasImage,
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  }) async {
    if (hasImage) {
      String imagePrompt = await rootBundle.loadString(
        'assets/prompts/$imageRecipePromptPath',
      );

      String textContextSection = '';
      if (textInput?.isNotEmpty == true) {
        final textContextTemplate = await rootBundle.loadString(
          AppConstants.textContextTemplatePath,
        );
        textContextSection = textContextTemplate.replaceAll(
          AppConstants.textInputPlaceholder,
          textInput!,
        );
      }

      final preferencesSection = await _buildPreferencesSection(preferences);

      return imagePrompt
          .replaceAll(
            AppConstants.textContextSectionPlaceholder,
            textContextSection,
          )
          .replaceAll(
            AppConstants.preferencesSectionPlaceholder,
            preferencesSection,
          );
    } else {
      String textOnlyPrompt = await rootBundle.loadString(
        'assets/prompts/$textOnlyRecipePromptPath',
      );

      final preferencesSection = await _buildPreferencesSection(preferences);

      return textOnlyPrompt
          .replaceAll(AppConstants.textInputPlaceholder, textInput!)
          .replaceAll(
            AppConstants.preferencesSectionPlaceholder,
            preferencesSection,
          );
    }
  }

  Future<String> _buildPreferencesSection(Set<String>? preferences) async {
    if (preferences?.isNotEmpty == true) {
      final preferencesTemplate = await rootBundle.loadString(
        AppConstants.preferencesTemplatePath,
      );
      return preferencesTemplate.replaceAll(
        AppConstants.preferencesListPlaceholder,
        preferences!.join(', '),
      );
    }
    return '';
  }

  Future<String> printGeminiFreeTierUsageStats({
    required Content content,
    required GenerativeModel model,
    int estimatedOutputTokens = 500,
  }) async {
    // Gemini 2.0 Flash (PAID) pricing per 1M tokens
    const double inputPricePerMillion = 0.10;
    const double outputPricePerMillion = 0.40;

    int textTokens = 0;
    int imageTokens = 0;
    int? billableChars;
    final List<Part> parts = content.parts;

    for (final part in parts) {
      final singlePartContent = Content.multi([part]);
      final count = await model.countTokens([singlePartContent]);

      if (part is TextPart) {
        textTokens += count.totalTokens;
      } else if (part is InlineDataPart) {
        imageTokens += count.totalTokens;
      }
      if (count.totalBillableCharacters != null) {
        billableChars = (billableChars ?? 0) + count.totalBillableCharacters!;
      }
    }

    final int totalInputTokens = textTokens + imageTokens;
    final int totalTokens = totalInputTokens + estimatedOutputTokens;

    // Cost calculation
    final double inputCostUSD =
        (totalInputTokens / 1000000) * inputPricePerMillion;
    final double outputCostUSD =
        (estimatedOutputTokens / 1000000) * outputPricePerMillion;
    final double totalCostUSD = inputCostUSD + outputCostUSD;

    final double usdToKrw = 1389.44;
    final double inputCostKRW = inputCostUSD * usdToKrw;
    final double outputCostKRW = outputCostUSD * usdToKrw;
    final double totalCostKRW = totalCostUSD * usdToKrw;

    return '''
프롬프트 내용:
- 과금 대상 문자 수 (현재 해당 없음): $billableChars
- 텍스트 입력 토큰 수: $textTokens
- 이미지 입력 토큰 수: $imageTokens
- 실제 입력 토큰 수 (합계): $totalInputTokens
- 예상 출력 토큰 수: $estimatedOutputTokens
- 총 예상 토큰 수: $totalTokens

💰 예상 과금 (Gemini 2.0 Flash 기준):
- 입력 토큰 요금 (@\$0.10/M): \$${inputCostUSD.toStringAsFixed(6)} / 원으로 ₩${inputCostKRW.toStringAsFixed(2)}
- 출력 토큰 요금 (@\$0.40/M): \$${outputCostUSD.toStringAsFixed(6)} / 원으로 ₩${outputCostKRW.toStringAsFixed(2)}
- ✅ 총 예상 비용: \$${totalCostUSD.toStringAsFixed(6)} / 원으로 ₩${totalCostKRW.toStringAsFixed(2)}
''';
  }
}
