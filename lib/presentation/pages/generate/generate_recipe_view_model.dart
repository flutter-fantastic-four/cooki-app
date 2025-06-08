import 'dart:typed_data';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/generated_recipe.dart';

enum GenerateRecipeErrorKey { invalidUserInput, invalidImage, generationFailed }

class GenerateRecipeState {
  final bool isGenerating;
  final bool isLoadingImage;
  final GenerateRecipeErrorKey? errorKey;
  final Uint8List? selectedImageBytes;
  final String textInput;
  final Set<String> selectedPreferences;
  final GeneratedRecipe? generatedRecipe;

  const GenerateRecipeState({
    this.isGenerating = false,
    this.isLoadingImage = false,
    this.errorKey,
    this.selectedImageBytes,
    this.textInput = '',
    this.selectedPreferences = const {},
    this.generatedRecipe,
  });

  GenerateRecipeState copyWith({
    bool? isGenerating,
    bool? isLoadingImage,
    GenerateRecipeErrorKey? errorKey,
    bool clearErrorKey = false,
    Uint8List? selectedImageBytes,
    bool clearSelectedImageBytes = false,
    String? textInput,
    Set<String>? selectedPreferences,
    GeneratedRecipe? generatedRecipe,
  }) {
    return GenerateRecipeState(
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingImage: isLoadingImage ?? this.isLoadingImage,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
      selectedImageBytes:
          clearSelectedImageBytes
              ? null
              : selectedImageBytes ?? this.selectedImageBytes,
      textInput: textInput ?? this.textInput,
      selectedPreferences: selectedPreferences ?? this.selectedPreferences,
      generatedRecipe: generatedRecipe ?? this.generatedRecipe,
    );
  }

  bool get canGenerate =>
      (textInput.trim().isNotEmpty || selectedImageBytes != null) &&
      !isGenerating;

  bool get hasImage => selectedImageBytes != null;
}

class GenerateRecipeViewModel extends AutoDisposeNotifier<GenerateRecipeState> {
  @override
  GenerateRecipeState build() {
    return const GenerateRecipeState();
  }

  Future<void> generateRecipe() async {
    if (!state.canGenerate) return;

    state = state.copyWith(isGenerating: true);
    try {
      // Validate input first if text is provided
      if (state.textInput.trim().isNotEmpty) {
        final validationResult = await ref
            .read(recipeGenerationRepositoryProvider)
            .validateUserInput(state.textInput);

        if (!validationResult.isValid) {
          state = state.copyWith(
            isGenerating: false,
            errorKey: GenerateRecipeErrorKey.invalidUserInput,
          );
          return;
        }
      }

      final compressedImageBytes = await GeneralUtil.compressImageBytes(
        state.selectedImageBytes,
      );
      final generatedRecipe = await ref
          .read(recipeGenerationRepositoryProvider)
          .generateRecipe(
            textInput:
                state.textInput.trim().isNotEmpty ? state.textInput : null,
            imageBytes: compressedImageBytes,
            preferences:
                state.selectedPreferences.isNotEmpty
                    ? state.selectedPreferences
                    : null,
          );
      if (generatedRecipe.isError) {
        state = state.copyWith(
          isGenerating: false,
          errorKey:
              state.selectedImageBytes != null
                  ? GenerateRecipeErrorKey.invalidImage
                  : GenerateRecipeErrorKey.generationFailed,
        );
      } else {
        state = state.copyWith(
          isGenerating: false,
          generatedRecipe: generatedRecipe,
        );
      }
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(
        isGenerating: false,
        errorKey: GenerateRecipeErrorKey.generationFailed,
      );
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
