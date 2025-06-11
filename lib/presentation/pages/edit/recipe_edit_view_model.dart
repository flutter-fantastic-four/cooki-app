import 'package:cooki/domain/entity/recipe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many items max to allow in either list
const int recipeListMaxItems = 30;

class RecipeEditState {
  final int ingredientsCount;
  final int stepsCount;
  const RecipeEditState({
    required this.ingredientsCount,
    required this.stepsCount,
  });
  RecipeEditState copyWith({
    int? ingredientsCount,
    int? stepsCount,
  }) =>
      RecipeEditState(
        ingredientsCount: ingredientsCount ?? this.ingredientsCount,
        stepsCount: stepsCount ?? this.stepsCount,
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
    );
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
