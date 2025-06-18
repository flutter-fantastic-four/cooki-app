import 'dart:developer';

import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/detail_recipe/detail_recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';

import '../../../../../presentation/widgets/app_cached_image.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../../app/constants/app_strings.dart';
import '../../../../pages/edit/recipe_edit_page.dart';
import '../../../../../presentation/widgets/app_dialog.dart';
import '../../../../../core/utils/snackbar_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for the recipe list
final savedRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getAllRecipes();
});

class MyRecipesPage extends ConsumerStatefulWidget {
  const MyRecipesPage({super.key});

  @override
  ConsumerState<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends ConsumerState<MyRecipesPage> {
  String selectedCategory = AppConstants.recipeTabAll;
  List<String> selectedCuisines = [];
  String selectedSort = '';
  late PageController _pageController;

  List<Recipe> get filteredRecipes {
    final recipesAsync = ref.watch(savedRecipesProvider);
    return recipesAsync.when(
      loading: () => [],
      error: (_, __) => [],
      data: (recipes) {
        List<Recipe> filtered = recipes;

        // Filter by selected tab category
        switch (selectedCategory) {
          case AppConstants.recipeTabAll:
            // Show all recipes - no additional filtering needed
            break;
          case AppConstants.recipeTabCreated:
            // Show only generated recipes (recipes with 'generated' tag)
            filtered = filtered.where((r) => r.tags.contains('generated')).toList();
            break;
          case AppConstants.recipeTabSaved:
            // Show only saved recipes (recipes without 'generated' tag and not public)
            filtered = filtered.where((r) => !r.tags.contains('generated') && !r.isPublic).toList();
            break;
          case AppConstants.recipeTabShared:
            // Show only shared recipes (public recipes)
            filtered = filtered.where((r) => r.isPublic).toList();
            break;
        }

        // Filter by cuisine categories if any selected
        if (selectedCuisines.isNotEmpty) {
          filtered = filtered.where((r) => selectedCuisines.contains(r.category)).toList();
        }

        // Apply sort option if selected
        if (selectedSort == AppConstants.sortByRating) {
          // Sort by rating
          filtered.sort((a, b) => b.ratingSum.compareTo(a.ratingSum));
        } else if (selectedSort == AppConstants.sortByCookTimeAsc) {
          filtered.sort((a, b) => a.cookTime.compareTo(b.cookTime));
        }

        return filtered;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: AppConstants.recipeTabCategories(context).indexOf(selectedCategory));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('나의 레시피', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: FilterIconWithDot(showDot: selectedCuisines.isNotEmpty || selectedSort.isNotEmpty),
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(icon: const Icon(Icons.search, color: Colors.black, size: 24), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:
                  AppConstants.recipeTabCategories(context).asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isSelected = selectedCategory == category;
                    final isLastTab = index == AppConstants.recipeTabCategories(context).length - 1;
                    return Padding(
                      padding: EdgeInsets.only(right: isLastTab ? 0 : 8),
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            AppConstants.recipeTabCategories(context).indexOf(category),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primary : AppColors.greyScale600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Active filters
          if (selectedCuisines.isNotEmpty || selectedSort.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...selectedCuisines.map(
                    (cuisine) => _FilterChip(
                      label: cuisine,
                      onDeleted: () {
                        setState(() {
                          selectedCuisines.remove(cuisine);
                        });
                      },
                      isModalChip: false,
                    ),
                  ),
                  if (selectedSort.isNotEmpty)
                    _FilterChip(
                      label: selectedSort,
                      onDeleted: () {
                        setState(() {
                          selectedSort = '';
                        });
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
              onPageChanged: (index) {
                setState(() {
                  selectedCategory = AppConstants.recipeTabCategories(context)[index];
                });
              },
              itemCount: AppConstants.recipeTabCategories(context).length,
              itemBuilder: (context, index) {
                return RefreshIndicator(
                  onRefresh: _refreshRecipes,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate((context, recipeIndex) {
                            final recipe = filteredRecipes[recipeIndex];
                            return _RecipeCard(recipe: recipe, onOptionsTap: () => _showOptionsModal(context, recipe), category: selectedCategory);
                          }, childCount: filteredRecipes.length),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    String tempSort = selectedSort;
    List<String> tempCuisines = List.from(selectedCuisines);
    String tempCategory = selectedCategory;
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
                            const Text('정렬 기준', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const chipWidth = 100.0;
                                const spacing = 8.0;
                                final chipsPerRow = ((constraints.maxWidth - 24) / (chipWidth + spacing)).floor();
                                final totalWidth = chipsPerRow * (chipWidth + spacing) - spacing;
                                final horizontalPadding = (constraints.maxWidth - totalWidth) / 2;

                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _FilterChip(
                                        label: AppConstants.sortByRating,
                                        isSelected: tempSort == AppConstants.sortByRating,
                                        onTap: () {
                                          setModalState(() {
                                            tempSort = tempSort == AppConstants.sortByRating ? '' : AppConstants.sortByRating;
                                          });
                                        },
                                        isModalChip: true,
                                      ),
                                      _FilterChip(
                                        label: AppConstants.sortByCookTimeAsc,
                                        isSelected: tempSort == AppConstants.sortByCookTimeAsc,
                                        onTap: () {
                                          setModalState(() {
                                            tempSort = tempSort == AppConstants.sortByCookTimeAsc ? '' : AppConstants.sortByCookTimeAsc;
                                          });
                                        },
                                        isModalChip: true,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, thickness: 1, color: AppColors.greyScale200),
                            const SizedBox(height: 20),
                            // Cuisine filters
                            const Text('국가별', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const chipWidth = 100.0;
                                const spacing = 8.0;
                                final chipsPerRow = ((constraints.maxWidth - 24) / (chipWidth + spacing)).floor();
                                final totalWidth = chipsPerRow * (chipWidth + spacing) - spacing;
                                final horizontalPadding = (constraints.maxWidth - totalWidth) / 2;

                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSort = '';
                                        selectedCuisines.clear();
                                        selectedCategory = tempCategory;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(AppStrings.reset),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSort = tempSort;
                                        selectedCuisines = List.from(tempCuisines);
                                        selectedCategory = tempCategory;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text(AppStrings.apply),
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
                text: recipe.isPublic ? AppStrings.communityUnpost : AppStrings.communityPost,
                icon: recipe.isPublic ? Icons.public_off : Icons.public,
                onTap: () {
                  Navigator.pop(context);
                  _toggleCommunityPost(recipe);
                },
              ),

              _PhotoModalStyleCard(
                text: AppStrings.share,
                icon: Icons.share_outlined,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share action
                },
              ),

              _PhotoModalStyleCard(
                text: AppStrings.edit,
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeEditPage(recipe: recipe)));
                },
              ),

              _PhotoModalStyleCard(
                text: AppStrings.delete,
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, recipe);
                },
              ),

              const SizedBox(height: 15),
              _PhotoModalStyleCard(text: AppStrings.close, onTap: () => Navigator.pop(context), isCenter: true),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Recipe recipe) {
    // Add null checks
    if (recipe.id.isEmpty) {
      if (context.mounted) {
        SnackbarUtil.showSnackBar(context, AppStrings.deleteError);
      }
      return;
    }

    AppDialog.show(
      context: context,
      title: AppStrings.delete,
      subText: '${recipe.recipeName}을(를) 삭제하시겠습니까?',
      primaryButtonText: AppStrings.delete,
      secondaryButtonText: AppStrings.cancel,
      onPrimaryButtonPressed: () {
        _deleteRecipe(recipe.id);
      },
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    // Add null check for recipeId
    if (recipeId.isEmpty) {
      if (context.mounted) {
        SnackbarUtil.showSnackBar(context, AppStrings.deleteError);
      }
      return;
    }

    try {
      // Direct Firestore call to delete the recipe
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('recipes').doc(recipeId).delete();

      // Refresh the recipe list only if widget is still mounted
      if (mounted) {
        ref.invalidate(savedRecipesProvider);
      }

      // Show success message
      if (mounted && context.mounted) {
        SnackbarUtil.showSnackBar(context, AppStrings.deleteSuccess, showIcon: true);
      }
    } catch (e) {
      // Show error message with more specific error handling
      if (mounted && context.mounted) {
        SnackbarUtil.showSnackBar(context, AppStrings.deleteError);
      }
      // Log the error for debugging
      log('Delete error: $e');
    }
  }

  Future<void> _toggleCommunityPost(Recipe recipe) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.toggleRecipeShare(recipe.id, !recipe.isPublic);

      // Refresh the recipe list
      ref.invalidate(savedRecipesProvider);

      // Show success message
      if (mounted && context.mounted) {
        SnackbarUtil.showSnackBar(context, recipe.isPublic ? AppStrings.unpostSuccess : AppStrings.postSuccess, showIcon: true);
      }
    } catch (e) {
      // Show error message
      if (mounted && context.mounted) {
        SnackbarUtil.showSnackBar(context, AppStrings.postError);
      }
    }
  }

  // ignore: unused_element
  Widget _buildRecipeGrid(List<Recipe> recipes, List<Recipe> filteredRecipes) {
    return RefreshIndicator(
      onRefresh: _refreshRecipes,
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = filteredRecipes[index];
          return _RecipeCard(recipe: recipe, onOptionsTap: () => _showOptionsModal(context, recipe), category: selectedCategory);
        },
      ),
    );
  }

  Future<void> _refreshRecipes() async {
    ref.invalidate(savedRecipesProvider);
    await Future.delayed(const Duration(milliseconds: 300)); // Small delay for better UX
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
        NavigationUtil.pushFromBottom(context, DetailRecipePage(recipe: recipe, category: category == AppConstants.recipeTabAll ? null : category));
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
                        ? (isSelected ? AppColors.white : AppColors.greyScale600)
                        : (isSelected ? AppColors.primary700 : AppColors.primary700),
                fontSize: 12,
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
