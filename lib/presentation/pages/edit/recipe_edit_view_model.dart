import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../data/repository/providers.dart';

/// How many items max to allow in either list
const int recipeListMaxItems = 30;

class RecipeEditState {
  final String? selectedCategory;
  final bool isPublic;
  final bool isSaving;
  final SaveRecipeErrorKey? errorKey;
  final bool isEditingTitle;
  final String? currentTitle;

  const RecipeEditState({
    this.selectedCategory,
    this.isPublic = false,
    this.isSaving = false,
    this.errorKey,
    this.isEditingTitle = false,
    this.currentTitle,
  });

  RecipeEditState copyWith({
    String? selectedCategory,
    bool? isPublic,
    bool? isSaving,
    SaveRecipeErrorKey? errorKey,
    bool clearErrorKey = false,
    bool? isEditingTitle,
    String? currentTitle,
  }) => RecipeEditState(
    selectedCategory: selectedCategory ?? this.selectedCategory,
    isPublic: isPublic ?? this.isPublic,
    isSaving: isSaving ?? this.isSaving,
    errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
    isEditingTitle: isEditingTitle ?? this.isEditingTitle,
    currentTitle: currentTitle ?? this.currentTitle,
  );
}

class RecipeEditViewModel extends AutoDisposeFamilyNotifier<RecipeEditState, Recipe?> {
  @override
  RecipeEditState build(Recipe? arg) {
    return RecipeEditState(selectedCategory: arg?.category, isPublic: arg?.isPublic ?? false, currentTitle: arg?.recipeName);
  }

  Future<void> saveRecipe({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    required int cookTime,
    required int calories,
    required AppUser? user,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      if (state.selectedCategory == null) {
        state = state.copyWith(errorKey: SaveRecipeErrorKey.categoryEmpty);
        return;
      }

      final recipe = Recipe(
        id: arg?.id ?? '',
        recipeName: title,
        ingredients: ingredients,
        steps: steps,
        cookTime: cookTime,
        calories: calories,
        category: state.selectedCategory!,
        isPublic: state.isPublic,
        // TO-DO(optional) Allow editing image
        imageUrl: arg?.imageUrl,
        // TO-DO(optional): Allow editing tags
        tags: arg?.tags ?? [],
        createdAt: arg?.createdAt,
        updatedAt: DateTime.now(),
        userId: arg?.userId ?? user!.id,
        userName: arg?.userName ?? user!.name,
        userProfileImage: arg?.userProfileImage ?? user!.profileImage,
        ratingCount: arg?.ratingCount,
        ratingSum: arg?.ratingSum,
      );

      if (arg != null) {
        await ref.read(recipeRepositoryProvider).editRecipe(recipe);
      } else {
        await ref.read(recipeRepositoryProvider).saveRecipe(recipe);
      }
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: SaveRecipeErrorKey.saveFailed);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setIsPublic(bool isPublic) {
    state = state.copyWith(isPublic: isPublic);
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }

  void startTitleEdit() {
    state = state.copyWith(isEditingTitle: true);
  }

  void cancelTitleEdit() {
    state = state.copyWith(isEditingTitle: false);
  }

  void confirmTitleEdit(String newTitle) {
    state = state.copyWith(isEditingTitle: false, currentTitle: newTitle);
  }
}

final recipeEditViewModelProvider = NotifierProvider.autoDispose.family<RecipeEditViewModel, RecipeEditState, Recipe?>(RecipeEditViewModel.new);
