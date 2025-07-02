import 'dart:developer';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/core/utils/category_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/data_source/recipe_data_source.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../user_global_view_model.dart';

class SavedRecipesState {
  final bool isLoading;
  final List<Recipe> recipes;
  final String? error;
  final String selectedCategory;
  final List<String> selectedCuisines;
  final String selectedSort;
  final bool showTabBorder;
  final String searchQuery;
  final bool isSearchActive;
  final Map<String, int?> userRatings; // Map of recipe ID to user's rating
  final Map<String, double>
  actualAverageRatings; // Map of recipe ID to actual average rating

  const SavedRecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
    this.selectedCategory = '',
    this.selectedCuisines = const [],
    this.selectedSort = '',
    this.showTabBorder = false,
    this.searchQuery = '',
    this.isSearchActive = false,
    this.userRatings = const {},
    this.actualAverageRatings = const {},
  });

  SavedRecipesState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    String? error,
    bool clearError = false,
    String? selectedCategory,
    List<String>? selectedCuisines,
    String? selectedSort,
    bool? showTabBorder,
    String? searchQuery,
    bool? isSearchActive,
    Map<String, int?>? userRatings,
    Map<String, double>? actualAverageRatings,
  }) {
    return SavedRecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: clearError ? null : error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedSort: selectedSort ?? this.selectedSort,
      showTabBorder: showTabBorder ?? this.showTabBorder,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      userRatings: userRatings ?? this.userRatings,
      actualAverageRatings: actualAverageRatings ?? this.actualAverageRatings,
    );
  }

  bool get hasActiveFilters =>
      selectedCuisines.isNotEmpty || selectedSort.isNotEmpty;

  List<Recipe> get filteredRecipes {
    if (searchQuery.isEmpty) return recipes;

    final query = searchQuery.toLowerCase();
    return recipes.where((recipe) {
      return recipe.recipeName.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(query),
          ) ||
          recipe.steps.any((step) => step.toLowerCase().contains(query));
    }).toList();
  }
}

class SavedRecipesViewModel
    extends AutoDisposeFamilyNotifier<SavedRecipesState, AppLocalizations> {
  @override
  SavedRecipesState build(AppLocalizations arg) {
    Future.microtask(() => loadRecipes());
    return const SavedRecipesState();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUser = ref.read(userGlobalViewModelProvider);
      if (currentUser == null) {
        state = state.copyWith(isLoading: false);
        state = state.copyWith(isLoading: false);
        return;
      }

      final repository = ref.read(recipeRepositoryProvider);

      final selectedCategory = state.selectedCategory;

      // Determine sort type - only use database sorting for non-rating sorts
      RecipeSortType? sortType;
      if (state.selectedSort == arg.sortByCookTime) {
        sortType = RecipeSortType.cookTimeAscending;
      } else {
        // For rating sort or no sort, use default created date ordering
        // We'll handle rating sort in-memory after loading actual ratings
        sortType = RecipeSortType.createdAtDescending;
      }

      List<Recipe> recipes;

      if (selectedCategory == arg.recipeTabAll) {
        // For "All" tab, combine user's created recipes AND saved recipes
        final myRecipesFuture = repository.getMyRecipes(
          currentUser.id,
          sortType: sortType,
        );
        final savedRecipesFuture = repository.getUserSavedRecipes(
          currentUser.id,
          sortType: sortType,
        );

        final results = await Future.wait([
          myRecipesFuture,
          savedRecipesFuture,
        ]);
        final myRecipes = results[0];
        final savedRecipes = results[1];

        // Combine and remove duplicates (in case a recipe is both created and saved)
        final allRecipesMap = <String, Recipe>{};
        for (final recipe in myRecipes) {
          allRecipesMap[recipe.id] = recipe;
        }
        for (final recipe in savedRecipes) {
          allRecipesMap[recipe.id] = recipe;
        }
        recipes = allRecipesMap.values.toList();

        // Re-sort the combined list since we lost the original sorting
        if (state.selectedSort == arg.sortByCookTime) {
          recipes.sort((a, b) => a.cookTime.compareTo(b.cookTime));
        } else {
          // Default to creation date descending (rating sort will be applied later)
          recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      } else if (selectedCategory == arg.recipeTabCreated) {
        recipes = await repository.getMyRecipes(
          currentUser.id,
          isPublic: false,
          sortType: sortType,
        );
      } else if (selectedCategory == arg.recipeTabShared) {
        recipes = await repository.getMyRecipes(
          currentUser.id,
          isPublic: true,
          sortType: sortType,
        );
      } else if (selectedCategory == arg.recipeTabSaved) {
        recipes = await repository.getUserSavedRecipes(
          currentUser.id,
          sortType: sortType,
        );
      } else {
        recipes = [];
      }

      // Apply cuisine filter
      if (state.selectedCuisines.isNotEmpty) {
        recipes = await _filterRecipesBySelectedCuisines(recipes);
      }

      // Load actual average ratings for all recipes and get the ratings map
      final actualRatings = await _calculateActualAverageRatings(recipes);

      // Apply rating sort in-memory if selected
      if (state.selectedSort == arg.sortByRating) {
        recipes.sort((a, b) {
          double aRating;
          double bRating;
          if (a.userId == currentUser.id) {
            aRating = a.userRating.toDouble();
          } else {
            aRating = actualRatings[a.id] ?? 0.0;
          }
          if (b.userId == currentUser.id) {
            bRating = b.userRating.toDouble();
          } else {
            bRating = actualRatings[b.id] ?? 0.0;
          }
          return bRating.compareTo(aRating); // Descending order
        });
      }

      state = state.copyWith(
        isLoading: false,
        recipes: recipes,
        actualAverageRatings: actualRatings,
      );

      // Load user ratings for the recipes
      await _loadUserRatings(recipes);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, double>> _calculateActualAverageRatings(
    List<Recipe> recipes,
  ) async {
    try {
      final reviewRepository = ref.read(reviewRepositoryProvider);
      final Map<String, double> ratings = {};

      for (final recipe in recipes) {
        try {
          if (recipe.isPublic) {
            // For public recipes, calculate average from reviews
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
          } else {
            // For private recipes, use the userRating as the "average"
            ratings[recipe.id] = recipe.userRating.toDouble();
          }
        } catch (e) {
          // If there's an error getting reviews for this recipe, set rating to 0
          ratings[recipe.id] = 0.0;
        }
      }

      return ratings;
    } catch (e, stack) {
      logError(e, stack);
      // Don't fail the whole operation if ratings can't be loaded
      return {};
    }
  }

  Future<List<Recipe>> _filterRecipesBySelectedCuisines(
    List<Recipe> recipes,
  ) async {
    final filteredRecipes = <Recipe>[];

    for (final recipe in recipes) {
      for (final selectedCuisine in state.selectedCuisines) {
        // Check if recipe category matches any selected cuisine in any language
        final recipeLanguage = await GeneralUtil.detectCategoryLanguage(
          recipe.category,
        );
        if (recipeLanguage != null) {
          // Convert selected cuisine to recipe's language for comparison
          final cuisineInRecipeLanguage =
              await GeneralUtil.convertFromCurrentLanguage(
                categInCurrLang: selectedCuisine,
                strings: arg,
                targetLanguage: recipeLanguage,
              );

          if (cuisineInRecipeLanguage == recipe.category) {
            filteredRecipes.add(recipe);
            break; // Found a match, no need to check other cuisines for this recipe
          }
        } else {
          // Fallback to direct string comparison if language detection fails
          if (recipe.category == selectedCuisine) {
            filteredRecipes.add(recipe);
            break;
          }
        }
      }
    }

    return filteredRecipes;
  }

  Future<void> _loadUserRatings(List<Recipe> recipes) async {
    try {
      final currentUser = ref.read(userGlobalViewModelProvider);
      if (currentUser == null) return;

      final reviewRepository = ref.read(reviewRepositoryProvider);
      final Map<String, int?> userRatings = {};

      for (final recipe in recipes) {
        try {
          if (recipe.isPublic) {
            // For public recipes, get rating from reviews
            final userReview = await reviewRepository.getUserReviewForRecipe(
              recipeId: recipe.id,
              userId: currentUser.id,
            );
            userRatings[recipe.id] = userReview?.rating;
          } else {
            // For private recipes, use recipe's userRating field directly
            userRatings[recipe.id] =
                recipe.userRating > 0 ? recipe.userRating : null;
          }
        } catch (e) {
          // If there's an error getting the rating for this recipe, just set it to null
          userRatings[recipe.id] = null;
        }
      }

      state = state.copyWith(userRatings: userRatings);
    } catch (e, stack) {
      logError(e, stack);
      // Don't fail the whole operation if ratings can't be loaded
    }
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
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

  void setShowTabBorder(bool show) {
    state = state.copyWith(showTabBorder: show);
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (recipeId.isEmpty) {
      state = state.copyWith(error: 'Invalid recipe ID');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('recipes').doc(recipeId).delete();

      // Refresh the recipe list
      await loadRecipes();

      // Set success message
      state = state.copyWith(error: 'delete_success');
    } catch (e, stack) {
      logError(e, stack);
      log('Delete error: $e');
      state = state.copyWith(error: 'Failed to delete recipe');
    }
  }

  Future<void> toggleCommunityPost(Recipe recipe) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.toggleRecipeShare(recipe.id, !recipe.isPublic);

      // Refresh the recipe list
      await loadRecipes();
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(error: 'Failed to update recipe sharing status');
    }
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

  int? getUserRatingForRecipe(String recipeId) {
    return state.userRatings[recipeId];
  }

  /// Get filtered recipes with category translation support
  List<Recipe> getFilteredRecipes(BuildContext context) {
    if (state.searchQuery.isEmpty) return state.recipes;

    final query = state.searchQuery.toLowerCase();
    return state.recipes.where((recipe) {
      final translatedCategory = CategoryMapper.translateCategoryToAppLanguage(
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
}

final savedRecipesViewModelProvider = NotifierProvider.autoDispose
    .family<SavedRecipesViewModel, SavedRecipesState, AppLocalizations>(
      SavedRecipesViewModel.new,
    );
