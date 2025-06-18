import 'dart:typed_data';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/generated_recipe.dart';
import '../../../domain/entity/recipe.dart';

class GenerateRecipeState {
  final bool isGeneratingAndSaving;
  final bool isLoadingImage;
  final SaveRecipeErrorKey? errorKey;
  final Uint8List? selectedImageBytes;
  final String textInput;
  final Set<String> selectedPreferences;

  const GenerateRecipeState({
    this.isGeneratingAndSaving = false,
    this.isLoadingImage = false,
    this.errorKey,
    this.selectedImageBytes,
    this.textInput = '',
    this.selectedPreferences = const {},
  });

  GenerateRecipeState copyWith({
    bool? isGeneratingAndSaving,
    bool? isLoadingImage,
    SaveRecipeErrorKey? errorKey,
    bool clearErrorKey = false,
    Uint8List? selectedImageBytes,
    bool clearSelectedImageBytes = false,
    String? textInput,
    Set<String>? selectedPreferences,
  }) {
    return GenerateRecipeState(
      isGeneratingAndSaving:
          isGeneratingAndSaving ?? this.isGeneratingAndSaving,
      isLoadingImage: isLoadingImage ?? this.isLoadingImage,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
      selectedImageBytes:
          clearSelectedImageBytes
              ? null
              : selectedImageBytes ?? this.selectedImageBytes,
      textInput: textInput ?? this.textInput,
      selectedPreferences: selectedPreferences ?? this.selectedPreferences,
    );
  }

  bool get canGenerate =>
      (textInput.isNotEmpty || selectedImageBytes != null) &&
      !isGeneratingAndSaving;

  bool get hasImage => selectedImageBytes != null;
}

class GenerateRecipeViewModel extends AutoDisposeNotifier<GenerateRecipeState> {
  @override
  GenerateRecipeState build() {
    return const GenerateRecipeState();
  }

  Future<Recipe?> generateAndSaveRecipe({
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
    required AppUser user,
  }) async {
    state = state.copyWith(isGeneratingAndSaving: true);

    try {
      final generated = await _generateRecipe(
        textOnlyRecipePromptPath: textOnlyRecipePromptPath,
        imageRecipePromptPath: imageRecipePromptPath,
      );
      if (generated == null) return null;

      final saved = await _saveRecipe(generatedRecipe: generated, user: user);
      if (saved == null) return null;

      return saved;
    } finally {
      state = state.copyWith(isGeneratingAndSaving: false);
    }
  }

  Future<GeneratedRecipe?> _generateRecipe({
    required String textOnlyRecipePromptPath,
    required String imageRecipePromptPath,
  }) async {
    try {
      if (state.textInput.isNotEmpty) {
        final validationResult = await ref
            .read(recipeGenerationRepositoryProvider)
            .validateUserInput(state.textInput);

        if (!validationResult.isValid) {
          state = state.copyWith(errorKey: SaveRecipeErrorKey.invalidUserInput);
          return null;
        }
      }

      final compressedImageBytes = await GeneralUtil.compressImageBytes(
        state.selectedImageBytes,
      );

      var generatedRecipe = await ref
          .read(recipeGenerationRepositoryProvider)
          .generateRecipe(
            textInput: state.textInput.isNotEmpty ? state.textInput : null,
            imageBytes: compressedImageBytes,
            preferences:
                state.selectedPreferences.isNotEmpty
                    ? state.selectedPreferences
                    : null,
            textOnlyRecipePromptPath: textOnlyRecipePromptPath,
            imageRecipePromptPath: imageRecipePromptPath,
          );

      if (generatedRecipe.isError) {
        state = state.copyWith(
          errorKey:
              state.selectedImageBytes != null
                  ? SaveRecipeErrorKey.invalidImage
                  : SaveRecipeErrorKey.generationFailed,
        );
        return null;
      }
      return generatedRecipe.copyWith(imageBytes: state.selectedImageBytes);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: SaveRecipeErrorKey.generationFailed);
      return null;
    }
  }

  Future<Recipe?> _saveRecipe({
    required GeneratedRecipe generatedRecipe,
    required AppUser user,
  }) async {
    try {
      String? imageUrl;
      if (state.selectedImageBytes != null) {
        imageUrl = await ref
            .read(recipeRepositoryProvider)
            .uploadImageBytes(state.selectedImageBytes!, user.id);
      }

      final buffer =
          StringBuffer()
            ..writeln('[Text Input]')
            ..writeln(state.textInput.trim())
            ..writeln()
            ..writeln('[Preferences]')
            ..writeln(state.selectedPreferences.join(', '));
      final promptInputFormatted = buffer.toString();

      final recipe = Recipe(
        id: '',
        // Firestore will generate
        recipeName: generatedRecipe.recipeName,
        ingredients: generatedRecipe.ingredients,
        steps: generatedRecipe.steps,
        cookTime: generatedRecipe.cookTime,
        calories: generatedRecipe.calories,
        category: generatedRecipe.category,
        tags: generatedRecipe.tags,
        userId: user.id,
        userName: user.name,
        userProfileImage: user.profileImage,
        isPublic: false,
        imageUrl: imageUrl,
        promptInput: promptInputFormatted,
      );

      final recipeId = await ref
          .read(recipeRepositoryProvider)
          .saveRecipe(recipe);
      return recipe.copyWith(id: recipeId);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: SaveRecipeErrorKey.saveFailed);
      return null;
    }
  }

  void togglePreference(String preference) {
    final currentPreferences = Set<String>.from(state.selectedPreferences);

    if (currentPreferences.contains(preference)) {
      currentPreferences.remove(preference);
    } else {
      currentPreferences.add(preference);
    }

    state = state.copyWith(selectedPreferences: currentPreferences);
  }

  void updateTextInput(String text) {
    state = state.copyWith(textInput: text);
  }

  void setImageBytes(Uint8List? imageBytes) {
    state = state.copyWith(selectedImageBytes: imageBytes);
  }

  void setImageLoading(bool isLoading) {
    state = state.copyWith(isLoadingImage: isLoading);
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }

  void removeImage() {
    state = state.copyWith(clearSelectedImageBytes: true);
  }
}

final generateRecipeViewModelProvider =
    NotifierProvider.autoDispose<GenerateRecipeViewModel, GenerateRecipeState>(
      GenerateRecipeViewModel.new,
    );
