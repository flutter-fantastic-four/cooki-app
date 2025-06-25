import 'dart:developer';
import 'package:cooki/core/utils/logger.dart';
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
    );
  }

  bool get hasActiveFilters => selectedCuisines.isNotEmpty || selectedSort.isNotEmpty || searchQuery.isNotEmpty;

  List<Recipe> get filteredRecipes {
    if (searchQuery.isEmpty) return recipes;

    final query = searchQuery.toLowerCase();
    return recipes.where((recipe) {
      return recipe.recipeName.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query) ||
          recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(query)) ||
          recipe.steps.any((step) => step.toLowerCase().contains(query));
    }).toList();
  }
}

class SavedRecipesViewModel extends AutoDisposeFamilyNotifier<SavedRecipesState, AppLocalizations> {
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
        return;
      }

      final repository = ref.read(recipeRepositoryProvider);

      final selectedCategory = state.selectedCategory;

      RecipeSortType? sortType;
      if (state.selectedSort == arg.sortByRating) {
        sortType = RecipeSortType.ratingDescending;
      } else if (state.selectedSort == arg.sortByCookTime) {
        sortType = RecipeSortType.cookTimeAscending;
      }

      List<Recipe> recipes;

      if (selectedCategory == arg.recipeTabAll) {
        recipes = await repository.getMyRecipes(currentUser.id, sortType: sortType ?? RecipeSortType.createdAtDescending);
      } else if (selectedCategory == arg.recipeTabCreated) {
        recipes = await repository.getMyRecipes(currentUser.id, isPublic: false, sortType: sortType ?? RecipeSortType.createdAtDescending);
      } else if (selectedCategory == arg.recipeTabShared) {
        recipes = await repository.getMyRecipes(currentUser.id, isPublic: true, sortType: sortType ?? RecipeSortType.createdAtDescending);
      } else if (selectedCategory == arg.recipeTabSaved) {
        recipes = await repository.getUserSavedRecipes(currentUser.id, sortType: sortType ?? RecipeSortType.createdAtDescending);
      } else {
        recipes = [];
      }

      if (state.selectedCuisines.isNotEmpty) {
        recipes = recipes.where((r) => state.selectedCuisines.contains(r.category)).toList();
      }

      state = state.copyWith(isLoading: false, recipes: recipes);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, error: e.toString());
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
    state = state.copyWith(isSearchActive: !state.isSearchActive, searchQuery: !state.isSearchActive ? state.searchQuery : '');
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', isSearchActive: false);
  }
}

final savedRecipesViewModelProvider = NotifierProvider.autoDispose.family<SavedRecipesViewModel, SavedRecipesState, AppLocalizations>(
  SavedRecipesViewModel.new,
);
