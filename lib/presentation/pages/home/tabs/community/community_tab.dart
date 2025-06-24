// ignore_for_file: unused_element_parameter

import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/detailed_recipe/detailed_recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../core/utils/sharing_util.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../presentation/widgets/app_cached_image.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../../core/utils/general_util.dart';
import '../../../../../core/utils/snackbar_util.dart';
import 'community_tab_view_model.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen(communityViewModelProvider, (previous, next) {
      if (next.error != null) {
        SnackbarUtil.showSnackBar(context, next.error!);
        viewModel.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          strings(context).communityTitle,
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
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Active filters
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            child: RefreshIndicator(
              onRefresh: () => viewModel.refreshRecipes(),
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.greyScale400,
            ),
            const SizedBox(height: 16),
            Text(
              strings(context).errorOccurred,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.greyScale600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings(context).checkNetworkConnection,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyScale500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadRecipes(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(strings(context).retryButton),
            ),
          ],
        ),
      );
    }

    final filteredRecipes = state.getFilteredRecipes(context);
    if (filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.greyScale400,
            ),
            const SizedBox(height: 16),
            Text(
              strings(context).noSharedRecipes,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.greyScale600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings(context).shareFirstRecipe,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyScale500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
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
        return _RecipeCard(
          recipe: recipe,
          onOptionsTap: () => _showOptionsModal(context, recipe),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final state = ref.read(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

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
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.greyScale200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Filter content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sort options
                            Text(
                              strings(context).sort,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _FilterChip(
                                    label: strings(context).sortByRating,
                                    isSelected:
                                        tempSort ==
                                        strings(context).sortByRating,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort =
                                            tempSort ==
                                                    strings(
                                                      context,
                                                    ).sortByRating
                                                ? ''
                                                : strings(context).sortByRating;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                  _FilterChip(
                                    label: strings(context).sortByCookTime,
                                    isSelected:
                                        tempSort ==
                                        strings(context).sortByCookTime,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort =
                                            tempSort ==
                                                    strings(
                                                      context,
                                                    ).sortByCookTime
                                                ? ''
                                                : strings(
                                                  context,
                                                ).sortByCookTime;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.greyScale200,
                            ),
                            const SizedBox(height: 20),
                            // Cuisine filters
                            Text(
                              strings(context).countryCategory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    cuisineCategories.map((cuisine) {
                                      final isSelected = tempCuisines.contains(
                                        cuisine,
                                      );
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
                                    onPressed: () async {
                                      viewModel.resetFilters();
                                      await viewModel.loadRecipes();
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
                                      viewModel.updateSelectedCuisines(
                                        List.from(tempCuisines),
                                      );
                                      await viewModel.loadRecipes();
                                      Navigator.pop(context);
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

  void _showOptionsModal(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 30,
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.greyScale400,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),
              _PhotoModalStyleCard(
                text: strings(context).share,
                icon: Icons.share_outlined,
                onTap: () async {
                  await SharingUtil.shareRecipe(
                    context,
                    recipe,
                    ref.read(imageDownloadRepositoryProvider),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 15),
              _PhotoModalStyleCard(
                text: strings(context).close,
                onTap: () => Navigator.pop(context),
                isCenter: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onOptionsTap;

  const _RecipeCard({required this.recipe, required this.onOptionsTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushFromBottom(
          context,
          DetailRecipePage(recipe: recipe),
        );
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
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    child:
                        recipe.imageUrl != null
                            ? AppCachedImage(
                              imageUrl: recipe.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/no_image.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onOptionsTap,
                      child: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.black,
                      ),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 42,
                          child: Text(
                            recipe.recipeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyScale800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  index < recipe.ratingSum
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppColors.black,
                                  size: 14,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 10,
                    //       backgroundImage:
                    //           recipe.userProfileImage != null
                    //               ? NetworkImage(recipe.userProfileImage!)
                    //               : null,
                    //       backgroundColor: AppColors.greyScale200,
                    //       child:
                    //           recipe.userProfileImage == null
                    //               ? const Icon(
                    //                 Icons.person,
                    //                 size: 12,
                    //                 color: AppColors.greyScale600,
                    //               )
                    //               : null,
                    //     ),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         recipe.userName,
                    //         style: const TextStyle(
                    //           fontSize: 12,
                    //           color: AppColors.greyScale600,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
                fontSize: 13,
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

class _PhotoModalStyleCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCenter;
  final Color? textColor;
  final Color? iconColor;

  const _PhotoModalStyleCard({
    required this.text,
    this.icon,
    required this.onTap,
    this.isCenter = false,
    this.textColor,
    this.iconColor,
  });

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
            !isCenter
                ? Padding(
                  padding: const EdgeInsets.only(left: 24, right: 4),
                  child: Icon(icon, color: iconColor ?? Colors.black87),
                )
                : null,
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: isCenter ? TextAlign.center : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
