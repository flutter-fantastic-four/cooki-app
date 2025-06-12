import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../data/repository/providers.dart';

/// How many items max to allow in either list
const int recipeListMaxItems = 30;

class RecipeEditState {
  final int ingredientsCount;
  final int stepsCount;
  final String? selectedCategory;
  final bool isPublic;
  final bool isSaving;
  final SaveRecipeErrorKey? errorKey;

  const RecipeEditState({
    required this.ingredientsCount,
    required this.stepsCount,
    this.selectedCategory,
    this.isPublic = false,
    this.isSaving = false,
    this.errorKey,
  });

  RecipeEditState copyWith({
    int? ingredientsCount,
    int? stepsCount,
    String? selectedCategory,
    bool? isPublic,
    bool? isSaving,
    SaveRecipeErrorKey? errorKey,
    bool clearErrorKey = false,
  }) => RecipeEditState(
    ingredientsCount: ingredientsCount ?? this.ingredientsCount,
    stepsCount: stepsCount ?? this.stepsCount,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    isPublic: isPublic ?? this.isPublic,
    isSaving: isSaving ?? this.isSaving,
    errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
  );
}

class RecipeEditViewModel
    extends AutoDisposeFamilyNotifier<RecipeEditState, Recipe?> {
  @override
  RecipeEditState build(Recipe? arg) {
    final ing = arg?.ingredients.length ?? 1;
    final stp = arg?.steps.length ?? 1;
    return RecipeEditState(
      ingredientsCount: ing.clamp(1, recipeListMaxItems),
      stepsCount: stp.clamp(1, recipeListMaxItems),
      selectedCategory: arg?.category,
      isPublic: arg?.isPublic ?? false,
    );
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

  void addIngredient() {
    if (state.ingredientsCount < recipeListMaxItems) {
      state = state.copyWith(ingredientsCount: state.ingredientsCount + 1);
    }
  }

  void removeIngredient(int index) {
    if (state.ingredientsCount > 1) {
      state = state.copyWith(ingredientsCount: state.ingredientsCount - 1);
    }
  }

  void addStep() {
    if (state.stepsCount < recipeListMaxItems) {
      state = state.copyWith(stepsCount: state.stepsCount + 1);
    }
  }

  void removeStep(int index) {
    if (state.stepsCount > 1) {
      state = state.copyWith(stepsCount: state.stepsCount - 1);
    }
  }
}

final recipeEditViewModelProvider = NotifierProvider.autoDispose
    .family<RecipeEditViewModel, RecipeEditState, Recipe?>(
      RecipeEditViewModel.new,
    );
