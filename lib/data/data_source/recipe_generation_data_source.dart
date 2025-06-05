import 'dart:convert';
import 'dart:typed_data';
import 'package:cooki/core/utils/prompt_util.dart';
import 'package:cooki/data/dto/generated_recipe_dto.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../dto/validation_dto.dart';

abstract class RecipeGenerationDataSource {
  Future<ValidationDto> validateUserInput(String textInput);

  Future<GeneratedRecipeDto> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    List<String>? preferences,
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
    final String prompt = PromptUtil.buildValidatePrompt(textInput);

    final response = await _validationModel.generateContent([
      Content.text(prompt),
    ]);

    final jsonResponse = json.decode(response.text ?? '{"isValid": false}');
    return ValidationDto.fromJson(jsonResponse);
  }

  @override
  Future<GeneratedRecipeDto> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    List<String>? preferences,
  }) async {
    final prompt = PromptUtil.buildRecipePrompt(
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

    final response = await _recipeGenerationModel.generateContent(content);
    final jsonResponse = json.decode(response.text ?? '{}');
    return GeneratedRecipeDto.fromJson(jsonResponse);
  }
}
