import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../core/utils/general_util.dart';

class SavedRecipesState {
  final bool isLoading;
  final List<Recipe> recipes;
  final String? error;
  final String selectedCategory;
  final List<String> selectedCuisines;
  final String selectedSort;
  final bool showTabBorder;

  const SavedRecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
    this.selectedCategory = '',
    this.selectedCuisines = const [],
    this.selectedSort = '',
    this.showTabBorder = false,
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
  }) {
    return SavedRecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: clearError ? null : error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedSort: selectedSort ?? this.selectedSort,
      showTabBorder: showTabBorder ?? this.showTabBorder,
    );
  }

  List<Recipe> getFilteredRecipes(BuildContext context) {
    List<Recipe> filtered = recipes;

    // Filter by selected tab category
    if (selectedCategory == strings(context).recipeTabAll) {
      // Show all recipes - no additional filtering needed
    } else if (selectedCategory == strings(context).recipeTabCreated) {
      // Show only generated recipes (recipes with 'generated' tag)
      filtered = filtered.where((r) => r.tags.contains('generated')).toList();
    } else if (selectedCategory == strings(context).recipeTabSaved) {
      // Show only saved recipes (recipes without 'generated' tag and not public)
      filtered =
          filtered
              .where((r) => !r.tags.contains('generated') && !r.isPublic)
              .toList();
    } else if (selectedCategory == strings(context).recipeTabShared) {
      // Show only shared recipes (public recipes)
      filtered = filtered.where((r) => r.isPublic).toList();
    }

    // Filter by cuisine categories if any selected
    if (selectedCuisines.isNotEmpty) {
      filtered =
          filtered.where((r) => selectedCuisines.contains(r.category)).toList();
    }

    // Apply sort option if selected
    if (selectedSort == strings(context).sortByRating) {
      // Sort by rating
      filtered.sort((a, b) => b.ratingSum.compareTo(a.ratingSum));
    } else if (selectedSort == strings(context).sortByCookTime) {
      filtered.sort((a, b) => a.cookTime.compareTo(b.cookTime));
    }

    return filtered;
  }

  bool get hasActiveFilters =>
      selectedCuisines.isNotEmpty || selectedSort.isNotEmpty;
}

class SavedRecipesViewModel extends AutoDisposeNotifier<SavedRecipesState> {
  @override
  SavedRecipesState build() {
    loadRecipes();
    return const SavedRecipesState();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipes = await repository.getAllRecipes();
      state = state.copyWith(isLoading: false, recipes: recipes);
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(error: 'Failed to update recipe sharing status');
    }
  }

  Future<void> refreshRecipes() async {
    await loadRecipes();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final savedRecipesViewModelProvider =
    NotifierProvider.autoDispose<SavedRecipesViewModel, SavedRecipesState>(
      SavedRecipesViewModel.new,
    );
