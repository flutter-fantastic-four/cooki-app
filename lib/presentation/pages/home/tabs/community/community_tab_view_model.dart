import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/utils/category_mapper.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';

import '../../../../../gen/l10n/app_localizations.dart';

class CommunityState {
  final bool isLoading;
  final List<Recipe> recipes;
  final String? error;
  final List<String> selectedCuisines;
  final String selectedSort;
  final String searchQuery;
  final bool isSearchActive;
  final Map<String, double> actualAverageRatings;

  const CommunityState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
    this.selectedCuisines = const [],
    this.selectedSort = '',
    this.searchQuery = '',
    this.isSearchActive = false,
    this.actualAverageRatings = const {},
  });

  CommunityState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    String? error,
    bool clearError = false,
    List<String>? selectedCuisines,
    String? selectedSort,
    String? searchQuery,
    bool? isSearchActive,
    Map<String, double>? actualAverageRatings,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: clearError ? null : error ?? this.error,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedSort: selectedSort ?? this.selectedSort,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      actualAverageRatings: actualAverageRatings ?? this.actualAverageRatings,
    );
  }

  List<Recipe> getFilteredRecipes(BuildContext context) {
    List<Recipe> filtered = recipes;

    // Apply search filter first
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((recipe) {
            final translatedCategory =
                CategoryMapper.translateCategoryToAppLanguage(
                  context,
                  recipe.category,
                );
            return recipe.recipeName.toLowerCase().contains(query) ||
                recipe.category.toLowerCase().contains(query) ||
                translatedCategory.toLowerCase().contains(query) ||
                recipe.ingredients.any(
                  (ingredient) => ingredient.toLowerCase().contains(query),
                ) ||
                recipe.steps.any((step) => step.toLowerCase().contains(query));
          }).toList();
    }

    // Filter by cuisine categories if any selected
    if (selectedCuisines.isNotEmpty) {
      filtered =
          filtered.where((recipe) {
            return selectedCuisines.any(
              (selectedCuisine) => CategoryMapper.doesCategoryMatch(
                recipe.category,
                selectedCuisine,
              ),
            );
          }).toList();
    }

    // Apply sort option if selected
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      if (selectedSort == localizations.sortByRating) {
        // Ensure a consistent base order before sorting by rating
        filtered.sort((a, b) {
          final dateCmp = b.createdAt.compareTo(a.createdAt);
          if (dateCmp != 0) return dateCmp;
          return a.id.compareTo(b.id);
        });
        // Now sort by rating (stable, with secondary/tertiary keys)
        filtered.sort((a, b) {
          final aRating = actualAverageRatings[a.id] ?? 0.0;
          final bRating = actualAverageRatings[b.id] ?? 0.0;
          final cmp = bRating.compareTo(aRating);
          if (cmp != 0) return cmp;
          // Secondary: createdAt descending
          final dateCmp = b.createdAt.compareTo(a.createdAt);
          if (dateCmp != 0) return dateCmp;
          // Tertiary: recipeName ascending
          return a.recipeName.compareTo(b.recipeName);
        });
      } else if (selectedSort == localizations.sortByCookTime) {
        filtered.sort((a, b) => a.cookTime.compareTo(b.cookTime));
      }
    }

    return filtered;
  }

  bool get hasActiveFilters =>
      selectedCuisines.isNotEmpty ||
      selectedSort.isNotEmpty ||
      searchQuery.isNotEmpty;
}

class CommunityViewModel extends AutoDisposeNotifier<CommunityState> {
  @override
  CommunityState build() {
    Future.microtask(() => loadRecipes());
    return const CommunityState();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipes = await repository.getCommunityRecipes(
        ref.read(userGlobalViewModelProvider)?.id,
      );
      state = state.copyWith(isLoading: false, recipes: recipes);

      // Load actual average ratings for all recipes
      await _loadActualAverageRatings(recipes);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadActualAverageRatings(List<Recipe> recipes) async {
    try {
      final reviewRepository = ref.read(reviewRepositoryProvider);
      final Map<String, double> ratings = {};

      for (final recipe in recipes) {
        try {
          final reviews = await reviewRepository.getReviewsByRecipeId(
            recipe.id,
          );
          if (reviews.isEmpty) {
            ratings[recipe.id] = 0.0;
          } else {
            final totalRating = reviews.fold<int>(
              0,
              (total, review) => total + review.rating,
            );
            ratings[recipe.id] = totalRating / reviews.length;
          }
        } catch (e) {
          // If there's an error getting reviews for this recipe, set rating to 0
          ratings[recipe.id] = 0.0;
        }
      }

      state = state.copyWith(actualAverageRatings: ratings);
    } catch (e, stack) {
      logError(e, stack);
      // Don't fail the whole operation if ratings can't be loaded
    }
  }

  void updateSelectedCuisines(List<String> cuisines) {
    state = state.copyWith(selectedCuisines: cuisines);
  }

  void updateSelectedSort(String sort) {
    state = state.copyWith(selectedSort: sort);
  }

  void removeCuisine(String cuisine) {
    final updatedCuisines = List<String>.from(state.selectedCuisines);
    updatedCuisines.remove(cuisine);
    state = state.copyWith(selectedCuisines: updatedCuisines);
  }

  void clearSort() {
    state = state.copyWith(selectedSort: '');
  }

  void resetFilters() {
    state = state.copyWith(selectedSort: '', selectedCuisines: []);
  }

  Future<void> refreshRecipes() async {
    await loadRecipes();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void toggleSearch() {
    state = state.copyWith(
      isSearchActive: !state.isSearchActive,
      searchQuery: !state.isSearchActive ? state.searchQuery : '',
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', isSearchActive: false);
  }
}

final communityViewModelProvider =
    NotifierProvider.autoDispose<CommunityViewModel, CommunityState>(
      CommunityViewModel.new,
    );
