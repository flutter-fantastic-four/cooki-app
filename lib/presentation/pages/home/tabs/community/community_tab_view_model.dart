import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../core/utils/general_util.dart';

class CommunityState {
  final bool isLoading;
  final List<Recipe> recipes;
  final String? error;
  final List<String> selectedCuisines;
  final String selectedSort;
  final String searchQuery;
  final bool isSearchActive;

  const CommunityState({
    this.isLoading = false,
    this.recipes = const [],
    this.error,
    this.selectedCuisines = const [],
    this.selectedSort = '',
    this.searchQuery = '',
    this.isSearchActive = false,
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
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      error: clearError ? null : error ?? this.error,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedSort: selectedSort ?? this.selectedSort,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }

  List<Recipe> getFilteredRecipes(BuildContext context) {
    List<Recipe> filtered = recipes;

    // Apply search filter first
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((recipe) {
            return recipe.recipeName.toLowerCase().contains(query) ||
                recipe.category.toLowerCase().contains(query) ||
                recipe.ingredients.any(
                  (ingredient) => ingredient.toLowerCase().contains(query),
                ) ||
                recipe.steps.any((step) => step.toLowerCase().contains(query));
          }).toList();
    }

    // Filter by cuisine categories if any selected
    if (selectedCuisines.isNotEmpty) {
      filtered =
          filtered.where((r) => selectedCuisines.contains(r.category)).toList();
    }

    // Apply sort option if selected
    if (selectedSort == strings(context).sortByRating) {
      filtered.sort((a, b) => b.ratingSum.compareTo(a.ratingSum));
    } else if (selectedSort == strings(context).sortByCookTime) {
      filtered.sort((a, b) => a.cookTime.compareTo(b.cookTime));
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
        ref.read(userGlobalViewModelProvider)!.id,
      );
      state = state.copyWith(isLoading: false, recipes: recipes);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, error: e.toString());
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
