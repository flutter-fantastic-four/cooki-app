// NEW FILE: recipe_detail_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:cooki/presentation/user_global_view_model.dart';

class RecipeDetailState {
  final Recipe? recipe;
  final int? userRating;
  final bool isLoading;

  const RecipeDetailState({
    this.recipe,
    this.userRating,
    this.isLoading = false,
  });

  RecipeDetailState copyWith({
    Recipe? recipe,
    int? userRating,
    bool clearUserRating = false,
    bool? isLoading,
  }) {
    return RecipeDetailState(
      recipe: recipe ?? this.recipe,
      userRating: clearUserRating ? null : (userRating ?? this.userRating),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RecipeDetailViewModel
    extends AutoDisposeFamilyNotifier<RecipeDetailState, String> {
  @override
  RecipeDetailState build(String arg) {
    Future.microtask(() => refreshRecipeData());
    return RecipeDetailState();
  }

  Future<void> refreshRecipeData() async {
    state = state.copyWith(isLoading: true);

    final recipeRepository = ref.read(recipeRepositoryProvider);
    final updatedRecipe = await recipeRepository.getRecipeById(arg);

    if (updatedRecipe != null) {
      state = state.copyWith(recipe: updatedRecipe, isLoading: false);
      await _loadUserRating();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadUserRating() async {
    final currentUser = ref.read(userGlobalViewModelProvider);
    if (currentUser == null) return;

    int? rating;

    if (state.recipe!.isPublic) {
      final reviewRepository = ref.read(reviewRepositoryProvider);
      final userReview = await reviewRepository.getUserReviewForRecipe(
        recipeId: arg,
        userId: currentUser.id,
      );
      rating = userReview?.rating;
    } else {
      rating = state.recipe!.userRating > 0 ? state.recipe!.userRating : null;
    }

    if (rating == null) {
      state = state.copyWith(clearUserRating: true);
    } else {
      state = state.copyWith(userRating: rating);
    }
  }
}

final recipeDetailViewModelProvider = NotifierProvider.autoDispose
    .family<RecipeDetailViewModel, RecipeDetailState, String>(
      RecipeDetailViewModel.new,
    );
