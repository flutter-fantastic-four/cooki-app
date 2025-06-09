import 'dart:typed_data';
import 'package:cooki/data/data_source/recipe_generation_data_source.dart';
import 'package:cooki/domain/entity/generated_recipe.dart';

import '../../domain/entity/validation_result.dart';

abstract class RecipeGenerationRepository {
  Future<ValidationResult> validateUserInput(String textInput);

  Future<GeneratedRecipe> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    Set<String>? preferences,
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  });
}

class RecipeGenerationRepositoryImpl implements RecipeGenerationRepository {
  final RecipeGenerationDataSource _recipeGenerationDataSource;

  RecipeGenerationRepositoryImpl(this._recipeGenerationDataSource);

  @override
  Future<ValidationResult> validateUserInput(String textInput) async {
    final dto = await _recipeGenerationDataSource.validateUserInput(textInput);
    return dto.toEntity();
  }

  @override
  Future<GeneratedRecipe> generateRecipe({
    String? textInput,
    Uint8List? imageBytes,
    Set<String>? preferences,
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  }) async {
    final dto = await _recipeGenerationDataSource.generateRecipe(
      textInput: textInput,
      imageBytes: imageBytes,
      preferences: preferences,
      textOnlyRecipePromptPath: textOnlyRecipePromptPath,
      imageRecipePromptPath: imageRecipePromptPath
    );
    return dto.toEntity();
  }
}
