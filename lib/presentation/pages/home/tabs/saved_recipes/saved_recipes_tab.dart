import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/presentation/pages/detailed_recipe/detailed_recipe_page.dart';
import 'package:cooki/core/utils/sharing_util.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/widget/no_recipe_notice.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../core/utils/general_util.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../pages/edit/recipe_edit_page.dart';
import '../../../../../presentation/widgets/app_dialog.dart';
import '../../../../../core/utils/snackbar_util.dart';
import 'saved_recipes_tab_view_model.dart';

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

    _pageController = PageController(initialPage: AppConstants.recipeTabCategories(context).indexOf(defaultCategory));
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
          SnackbarUtil.showSnackBar(context, strings(context).deleteSuccess, showIcon: true);
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
        children: [
          // Category tabs
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: Row(
                  children:
                      AppConstants.recipeTabCategories(
                        context,
                      ).asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected = state.selectedCategory == category;
                        final isLastTab =
                            index ==
                            AppConstants.recipeTabCategories(context).length -
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 13.5,
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
                          ),
                        );
                      }).toList(),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.greyScale50,
              ),
            ],
          ),
          // Active filters
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                    ),
                ],
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
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.75,
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
                                              () => _showOptionsModal(
                                                context,
                                                recipe,
                                              ),
                                          category: state.selectedCategory,
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
              }).toList(),
        ),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Colors.black, size: 24),
        onPressed: () {
          _searchController.clear();
          viewModel.clearSearch();
        },
      ),
      title: Container(
        height: 28,
        width: 267,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (query) => viewModel.updateSearchQuery(query),
          decoration: InputDecoration(
            hintText: strings(context).search,
            hintStyle: TextStyle(color: AppColors.greyScale400, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            height: 1.2,
          ),
          cursorHeight: 16,
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _searchController.clear();
            viewModel.clearSearch();
          },
          child: Text(
            strings(context).cancel,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, size: 64, color: AppColors.greyScale400),
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
            "Try different keywords",
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
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
              decoration: const BoxDecoration(color: AppColors.greyScale50, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.greyScale200, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      // Filter content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sort options
                            Text(strings(context).sort, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _FilterChip(
                                    label: strings(context).sortByRating,
                                    isSelected: tempSort == strings(context).sortByRating,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort = tempSort == strings(context).sortByRating ? '' : strings(context).sortByRating;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                  _FilterChip(
                                    label: strings(context).sortByCookTime,
                                    isSelected: tempSort == strings(context).sortByCookTime,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort = tempSort == strings(context).sortByCookTime ? '' : strings(context).sortByCookTime;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, thickness: 1, color: AppColors.greyScale200),
                            const SizedBox(height: 20),
                            // Cuisine filters
                            Text(strings(context).countryCategory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children:
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
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            Row(
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
                                      viewModel.updateSelectedSort(tempSort);
                                      viewModel.updateSelectedCuisines(List.from(tempCuisines));
                                      await viewModel.loadRecipes();
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(strings(context).apply),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
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

  void _showOptionsModal(BuildContext context, Recipe recipe) {
    final viewModel = ref.read(
      savedRecipesViewModelProvider(strings(context)).notifier,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 30, left: 15, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.greyScale400, borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(bottom: 12),
              ),

              _PhotoModalStyleCard(
                text: recipe.isPublic ? strings(context).communityUnpost : strings(context).communityPost,
                icon: recipe.isPublic ? Icons.public_off : Icons.public,
                onTap: () {
                  Navigator.pop(context);
                  viewModel.toggleCommunityPost(recipe);
                },
              ),

              _PhotoModalStyleCard(
                text: strings(context).share,
                icon: Icons.share_outlined,
                onTap: () async {
                  await SharingUtil.shareRecipe(context, recipe, ref.read(imageDownloadRepositoryProvider));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              ),

              _PhotoModalStyleCard(
                text: strings(context).edit,
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeEditPage(recipe: recipe)));
                },
              ),

              _PhotoModalStyleCard(
                text: strings(context).delete,
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, recipe);
                },
              ),

              const SizedBox(height: 15),
              _PhotoModalStyleCard(text: strings(context).close, onTap: () => Navigator.pop(context), isCenter: true),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Recipe recipe) {
    final viewModel = ref.read(
      savedRecipesViewModelProvider(strings(context)).notifier,
    );

    if (recipe.id.isEmpty) {
      SnackbarUtil.showSnackBar(context, strings(context).deleteError);
      return;
    }

    AppDialog.show(
      context: context,
      title: strings(context).delete,
      subText: strings(context).deleteConfirmMessage(recipe.recipeName),
      primaryButtonText: strings(context).delete,
      secondaryButtonText: strings(context).cancel,
      onPrimaryButtonPressed: () {
        viewModel.deleteRecipe(recipe.id);
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onOptionsTap;
  final String category;

  const _RecipeCard({required this.recipe, required this.onOptionsTap, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushFromBottom(context, DetailRecipePage(recipe: recipe, category: category));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyScale200),
          color: AppColors.white,
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    child:
                        recipe.imageUrl != null
                            ? Image.network(recipe.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                            : Image.asset('assets/no_image.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(onTap: onOptionsTap, child: const Icon(Icons.more_vert, size: 20, color: AppColors.black)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 42, // Approximately 2 lines of text at fontSize 15 with 1.2 height
                      child: Text(
                        recipe.recipeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.greyScale800, height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(index < recipe.ratingSum ? Icons.star : Icons.star_border, color: AppColors.black, size: 14),
                          );
                        }),
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

  const _FilterChip({required this.label, this.onTap, this.onDeleted, this.isSelected = false, this.isModalChip = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isModalChip ? (isSelected ? AppColors.primary700 : AppColors.white) : (isSelected ? AppColors.primary50 : AppColors.primary50),
          borderRadius: BorderRadius.circular(13),
          border:
              isModalChip
                  ? Border.all(color: isSelected ? AppColors.primary800 : AppColors.white, width: 1)
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
                        ? (isSelected ? AppColors.white : AppColors.greyScale800)
                        : (isSelected ? AppColors.primary700 : AppColors.primary700),
                fontSize: 13,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 2),
              GestureDetector(onTap: onDeleted, child: Icon(Icons.close, size: 14, color: isModalChip ? AppColors.white : AppColors.primary700)),
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
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ),
      ],
    );
  }
}

class _PhotoModalStyleCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCenter;
  final Color? textColor;
  final Color? iconColor;

  const _PhotoModalStyleCard({required this.text, this.icon, required this.onTap, this.isCenter = false, this.textColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading:
            !isCenter ? Padding(padding: const EdgeInsets.only(left: 24, right: 4), child: Icon(icon, color: iconColor ?? Colors.black87)) : null,
        title: Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor ?? Colors.black, fontWeight: FontWeight.w500),
          textAlign: isCenter ? TextAlign.center : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
