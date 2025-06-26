import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/detailed_recipe/detailed_recipe_page.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/widget/no_recipe_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../core/utils/general_util.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../../presentation/widgets/recipe_options_modal.dart';
import '../../../../../core/utils/snackbar_util.dart';
import '../../../../user_global_view_model.dart';
import 'saved_recipes_tab_view_model.dart';

// Constants for modal styling
class _ModalConstants {
  static const handleWidth = 36.0;
  static const handleHeight = 4.0;
  static const sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const filterChipSpacing = 8.0;
}

class MyRecipesPage extends ConsumerStatefulWidget {
  const MyRecipesPage({super.key});

  @override
  ConsumerState<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends ConsumerState<MyRecipesPage> {
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final defaultCategory = strings(context).recipeTabAll;

    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(
        savedRecipesViewModelProvider(strings(context)).notifier,
      );
      viewModel.setSelectedCategory(defaultCategory);
      // Ensure recipes are refreshed when tab is first loaded
      viewModel.refreshRecipes();
    });

    _pageController = PageController(
      initialPage: AppConstants.recipeTabCategories(
        context,
      ).indexOf(defaultCategory),
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final shouldShow = notification.metrics.pixels > 0;
      final viewModel = ref.read(
        savedRecipesViewModelProvider(strings(context)).notifier,
      );
      viewModel.setShowTabBorder(shouldShow);
    }
    return false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedRecipesViewModelProvider(strings(context)));
    final user = ref.watch(userGlobalViewModelProvider);
    final viewModel = ref.read(savedRecipesViewModelProvider(strings(context)).notifier);
    // Show error snackbar if there's an error
    ref.listen(savedRecipesViewModelProvider(strings(context)), (
      previous,
      next,
    ) {
      if (next.error != null) {
        if (next.error == 'delete_success') {
          SnackbarUtil.showSnackBar(
            context,
            strings(context).deleteSuccess,
            showIcon: true,
          );
        } else {
          SnackbarUtil.showSnackBar(context, next.error!);
        }
        viewModel.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          state.isSearchActive
              ? _buildSearchAppBar(context, state, viewModel)
              : _buildNormalAppBar(context, state, viewModel),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Category tabs
          SizedBox(
            height: 38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          AppConstants.recipeTabCategories(
                            context,
                          ).asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final isSelected =
                                state.selectedCategory == category;
                            final isLastTab =
                                index ==
                                AppConstants.recipeTabCategories(
                                      context,
                                    ).length -
                                    1;
                            return Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 16 : 0,
                                right: isLastTab ? 16 : 8,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    AppConstants.recipeTabCategories(
                                      context,
                                    ).indexOf(category),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 26,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          color:
                                              isSelected
                                                  ? AppColors.primary700
                                                  : AppColors.greyScale800,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: 0,
                                        left: 4,
                                        right: 4,
                                        child: Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.greyScale50,
                ),
              ],
            ),
          ),
          // Active filters
          if (state.hasActiveFilters)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...state.selectedCuisines.map(
                      (cuisine) => _FilterChip(
                        label: cuisine,
                        onDeleted: () async {
                          viewModel.removeCuisine(cuisine);
                          await viewModel.loadRecipes();
                        },
                        isModalChip: false,
                      ),
                    ),
                    if (state.selectedSort.isNotEmpty)
                      _FilterChip(
                        label: state.selectedSort,
                        onDeleted: () async {
                          viewModel.clearSort();
                          await viewModel.loadRecipes();
                        },
                        isModalChip: false,
                        isSelected: true,
                      ),
                  ],
                ),
              ),
            ),
          // Recipe grid
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                final category =
                    AppConstants.recipeTabCategories(context)[index];
                viewModel.setSelectedCategory(category);
                await viewModel.loadRecipes();
              },
              itemCount: AppConstants.recipeTabCategories(context).length,
              itemBuilder: (context, index) {
                if (user == null || state.recipes.isEmpty) {
                  final category = AppConstants.recipeTabCategories(context)[index];
                  return NoRecipeNotice(category: category);
                }
                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshRecipes(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child:
                        state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : state.filteredRecipes.isEmpty &&
                                state.searchQuery.isNotEmpty
                            ? _buildNoResultsView()
                            : CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16.0,
                                    16.0,
                                    16.0,
                                    0,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 16,
                                          childAspectRatio:
                                              160 / 184, // 160x184 card size
                                        ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, recipeIndex) {
                                        final filteredRecipes =
                                            state.filteredRecipes;
                                        final recipe =
                                            filteredRecipes[recipeIndex];
                                        return _RecipeCard(
                                          recipe: recipe,
                                          onOptionsTap:
                                              () => RecipeOptionsModal.show(
                                                context: context,
                                                ref: ref,
                                                recipe: recipe,
                                                onRecipeDeleted: () {
                                                  viewModel.refreshRecipes();
                                                },
                                                onRecipeUpdated: () {
                                                  viewModel.refreshRecipes();
                                                },
                                              ),
                                          category: state.selectedCategory,
                                          viewModel: viewModel,
                                        );
                                      },
                                      childCount: state.filteredRecipes.length,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 100),
                                ),
                              ],
                            ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    BuildContext context,
    SavedRecipesState state,
    SavedRecipesViewModel viewModel,
  ) {
    return AppBar(
      titleSpacing: 20,
      title: Text(
        strings(context).myRecipesTitle,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: FilterIconWithDot(showDot: state.hasActiveFilters),
          onPressed: () => _showFilterModal(context),
        ),
        IconButton(
          icon: const Icon(
            CupertinoIcons.search,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => viewModel.toggleSearch(),
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    );
  }

  PreferredSizeWidget _buildSearchAppBar(
    BuildContext context,
    SavedRecipesState state,
    SavedRecipesViewModel viewModel,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 56, // 20 + 24 + 12
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black, size: 24),
          onPressed: () {
            _searchController.clear();
            viewModel.clearSearch();
          },
        ),
      ),
      titleSpacing: 12,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (query) => viewModel.updateSearchQuery(query),
        decoration: InputDecoration(
          hintText: strings(context).searchPlaceholder,
          hintStyle: TextStyle(color: AppColors.greyScale400, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      actions: [
        if (state.searchQuery.isNotEmpty) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.cancel,
              color: AppColors.greyScale500,
              size: 18,
            ),
            onPressed: () {
              _searchController.clear();
              viewModel.updateSearchQuery('');
            },
          ),
        ] else
          const SizedBox(width: 28), // 8 + 20 when no clear button
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, size: 64, color: AppColors.greyScale400),
          const SizedBox(height: 16),
          Text(
            strings(context).noRecipes,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.greyScale600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings(context).noSearchResult,
            style: const TextStyle(fontSize: 14, color: AppColors.greyScale500),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final state = ref.read(savedRecipesViewModelProvider(strings(context)));
    final viewModel = ref.read(
      savedRecipesViewModelProvider(strings(context)).notifier,
    );

    String tempSort = state.selectedSort;
    List<String> tempCuisines = List.from(state.selectedCuisines);
    final cuisineCategories = AppConstants.recipeCategories(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: AppColors.greyScale50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalHandle(),
                      // Filter content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSortSection(context, tempSort, (newSort) {
                              setModalState(() {
                                tempSort = newSort;
                              });
                            }),
                            const SizedBox(height: 20),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.greyScale200,
                            ),
                            const SizedBox(height: 20),
                            _buildCuisineSection(
                              context,
                              cuisineCategories,
                              tempCuisines,
                              setModalState,
                            ),
                            const SizedBox(height: 24),
                            _buildFilterActionButtons(
                              context,
                              viewModel,
                              tempSort,
                              tempCuisines,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper methods for modularized components

  Widget _buildModalHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        width: _ModalConstants.handleWidth,
        height: _ModalConstants.handleHeight,
        decoration: BoxDecoration(
          color: AppColors.greyScale200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSortSection(
    BuildContext context,
    String tempSort,
    Function(String) onSortChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings(context).sort, style: _ModalConstants.sectionTitleStyle),
        const SizedBox(height: 12),
        _buildChipContainer([
          _buildSortChip(
            context,
            strings(context).sortByRating,
            tempSort,
            onSortChanged,
          ),
          _buildSortChip(
            context,
            strings(context).sortByCookTime,
            tempSort,
            onSortChanged,
          ),
        ]),
      ],
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String sortOption,
    String tempSort,
    Function(String) onSortChanged,
  ) {
    return _FilterChip(
      label: sortOption,
      isSelected: tempSort == sortOption,
      onTap: () {
        final newSort = tempSort == sortOption ? '' : sortOption;
        onSortChanged(newSort);
      },
      isModalChip: true,
    );
  }

  Widget _buildCuisineSection(
    BuildContext context,
    List<String> cuisineCategories,
    List<String> tempCuisines,
    Function setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings(context).countryCategory,
          style: _ModalConstants.sectionTitleStyle,
        ),
        const SizedBox(height: 12),
        _buildChipContainer(
          cuisineCategories.map((cuisine) {
            final isSelected = tempCuisines.contains(cuisine);
            return _FilterChip(
              label: cuisine,
              isSelected: isSelected,
              onTap: () {
                setModalState(() {
                  if (isSelected) {
                    tempCuisines.remove(cuisine);
                  } else {
                    tempCuisines.add(cuisine);
                  }
                });
              },
              isModalChip: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChipContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: _ModalConstants.filterChipSpacing,
        runSpacing: _ModalConstants.filterChipSpacing,
        children: children,
      ),
    );
  }

  Widget _buildFilterActionButtons(
    BuildContext context,
    SavedRecipesViewModel viewModel,
    String tempSort,
    List<String> tempCuisines,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              viewModel.resetFilters();
              Navigator.pop(context);
            },
            child: Text(strings(context).reset),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              viewModel.updateSelectedSort(tempSort);
              viewModel.updateSelectedCuisines(List.from(tempCuisines));
              await viewModel.loadRecipes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(strings(context).apply),
          ),
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onOptionsTap;
  final String category;
  final SavedRecipesViewModel viewModel;

  const _RecipeCard({
    required this.recipe,
    required this.onOptionsTap,
    required this.category,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await NavigationUtil.pushFromBottom<bool>(
          context,
          DetailRecipePage(
            recipe: recipe,
            category:
                category == strings(context).recipeTabAll ? null : category,
          ),
        );
        // If a rating was posted, refresh the recipes
        if (result == true && context.mounted) {
          viewModel.loadRecipes();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyScale200),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                child:
                    recipe.imageUrl != null
                        ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : Image.asset(
                          'assets/no_image.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.recipeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyScale800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onOptionsTap,
                          child: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Show user's rating as five-star system
                        Builder(
                          builder: (context) {
                            final userRating = viewModel.getUserRatingForRecipe(
                              recipe.id,
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (userRating ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color:
                                      index < (userRating ?? 0)
                                          ? AppColors.secondary600
                                          : AppColors.greyScale400,
                                  size: 14,
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final bool isModalChip;

  const _FilterChip({
    required this.label,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.isModalChip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isModalChip
                  ? (isSelected ? AppColors.primary700 : AppColors.white)
                  : (isSelected ? AppColors.primary50 : AppColors.primary50),
          borderRadius: BorderRadius.circular(13),
          border:
              isModalChip
                  ? Border.all(
                    color: isSelected ? AppColors.primary800 : AppColors.white,
                    width: 1,
                  )
                  : Border.all(color: AppColors.primary700, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isModalChip
                        ? (isSelected
                            ? AppColors.white
                            : AppColors.greyScale800)
                        : (isSelected
                            ? AppColors.primary700
                            : AppColors.primary700),
                fontSize: 12,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isModalChip ? AppColors.white : AppColors.primary700,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ],
        ),
      ),
    );
  }
}

class FilterIconWithDot extends StatelessWidget {
  final bool showDot;

  const FilterIconWithDot({super.key, required this.showDot});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.filter_list, color: Colors.black, size: 24),
        if (showDot)
          Positioned(
            right: -2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
