import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cooki/data/dto/generated_recipe_dto.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../../app/constants/app_constants.dart';
import '../dto/validation_dto.dart';

abstract class RecipeGenerationDataSource {
  Future<ValidationDto> validateUserInput(String textInput);

  Future<GeneratedRecipeDto> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    Set<String>? preferences,
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
    final String prompt = AppConstants.validationPrompt.replaceAll(
      AppConstants.textInputPlaceholder,
      textInput,
    );
    final content = Content.text(prompt);
    final response = await _validationModel.generateContent([content]);

    final stats = await printGeminiFreeTierUsageStats(
      content: content,
      model: _validationModel,
      estimatedOutputTokens: 5
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
  }) async {
    final prompt = _buildRecipePrompt(
      textInput: textInput,
      preferences: preferences,
      hasImage: imageBytes != null,
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

  String _buildRecipePrompt({
    String? textInput,
    Set<String>? preferences,
    required bool hasImage,
  }) {
    if (hasImage) {
      String imagePrompt = AppConstants.imageRecipePrompt;

      final textContextSection =
          textInput?.isNotEmpty == true
              ? AppConstants.textContextTemplate.replaceAll(
                AppConstants.textInputPlaceholder,
                textInput!,
              )
              : '';
      imagePrompt = imagePrompt.replaceAll(
        AppConstants.textContextSectionPlaceholder,
        textContextSection,
      );
      final preferencesSection = _buildPreferencesSection(preferences);
      imagePrompt = imagePrompt.replaceAll(
        AppConstants.preferencesSectionPlaceholder,
        preferencesSection,
      );

      return imagePrompt;
    } else {
      String textOnlyPrompt = AppConstants.textOnlyRecipePrompt;

      textOnlyPrompt = textOnlyPrompt.replaceAll(
        AppConstants.textInputPlaceholder,
        textInput!,
      );
      final preferencesSection = _buildPreferencesSection(preferences);
      textOnlyPrompt = textOnlyPrompt.replaceAll(
        AppConstants.preferencesSectionPlaceholder,
        preferencesSection,
      );

      return textOnlyPrompt;
    }
  }

  String _buildPreferencesSection(Set<String>? preferences) {
    if (preferences?.isNotEmpty == true) {
      return AppConstants.preferencesTemplate.replaceAll(
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
    const int dailyTokenLimit = 1000000;
    const int dailyRequestLimit = 1500;
    const int maxRequestsPerMinute = 15;

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
    final double percentOfDailyLimit = (totalTokens / dailyTokenLimit) * 100;
    final int maxRequestsPerDayByTokens = (dailyTokenLimit / totalTokens).floor();

    return '''
프롬프트 내용:
- 과금 대상 문자 수 (현재 해당 없음): $billableChars
- 텍스트 입력 토큰 수: $textTokens
- 이미지 입력 토큰 수: $imageTokens
- 실제 입력 토큰 수 (합계): $totalInputTokens
- 예상 출력 토큰 수: $estimatedOutputTokens
- 총 예상 토큰 수: $totalTokens

무료 등급의 하루 토큰 한도: 1,000,000 토큰
이 프롬프트가 사용하는 하루 토큰 한도 비율: ${percentOfDailyLimit.toStringAsFixed(2)}%
이 요청을 하루에 보낼 수 있는 최대 횟수 (토큰 기준): $maxRequestsPerDayByTokens 회

무료 등급의 하루 요청 한도: $dailyRequestLimit 회
분당 요청 한도: 분당 $maxRequestsPerMinute 회
''';
  }
}
