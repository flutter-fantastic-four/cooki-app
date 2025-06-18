// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../core/utils/sharing_util.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../presentation/widgets/app_cached_image.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../../app/constants/app_strings.dart';

// Provider for shared recipes from all users
final communityRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getSharedRecipes();
});

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  List<String> selectedCuisines = [];
  String selectedSort = '';

  List<Recipe> get filteredRecipes {
    final recipesAsync = ref.watch(communityRecipesProvider);
    return recipesAsync.when(
      loading: () => [],
      error: (_, __) => [],
      data: (recipes) {
        List<Recipe> filtered = recipes;

        // Filter by cuisine categories if any selected
        if (selectedCuisines.isNotEmpty) {
          filtered = filtered.where((r) => selectedCuisines.contains(r.category)).toList();
        }

        // Apply sort option if selected
        if (selectedSort == AppConstants.sortByRating) {
          filtered.sort((a, b) => b.ratingSum.compareTo(a.ratingSum));
        } else if (selectedSort == AppConstants.sortByCookTimeAsc) {
          filtered.sort((a, b) => a.cookTime.compareTo(b.cookTime));
        }

        return filtered;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
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
          // Active filters
          if (selectedCuisines.isNotEmpty || selectedSort.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            child: RefreshIndicator(onRefresh: _refreshRecipes, color: AppColors.primary, backgroundColor: AppColors.white, child: _buildContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final recipesAsync = ref.watch(communityRecipesProvider);

    return recipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.greyScale400),
                const SizedBox(height: 16),
                Text('오류가 발생했습니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.greyScale600)),
                const SizedBox(height: 8),
                Text('네트워크 연결을 확인해주세요', style: TextStyle(fontSize: 14, color: AppColors.greyScale500)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(communityRecipesProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
      data: (recipes) {
        if (filteredRecipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 64, color: AppColors.greyScale400),
                const SizedBox(height: 16),
                Text('공유된 레시피가 없습니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.greyScale600)),
                const SizedBox(height: 8),
                Text('첫 번째로 레시피를 공유해보세요!', style: TextStyle(fontSize: 14, color: AppColors.greyScale500)),
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
            return _RecipeCard(recipe: recipe, onOptionsTap: () => _showOptionsModal(context, recipe));
          },
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    String tempSort = selectedSort;
    List<String> tempCuisines = List.from(selectedCuisines);
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
                                          return _FilterChip(
                                            label: cuisine,
                                            isSelected: tempCuisines.contains(cuisine),
                                            onTap: () {
                                              setModalState(() {
                                                if (tempCuisines.contains(cuisine)) {
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
                            const SizedBox(height: 32),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      setModalState(() {
                                        tempSort = '';
                                        tempCuisines.clear();
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: AppColors.greyScale300),
                                      ),
                                    ),
                                    child: const Text(AppStrings.reset, style: TextStyle(color: AppColors.greyScale600, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSort = tempSort;
                                        selectedCuisines = tempCuisines;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text(AppStrings.apply, style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                text: AppStrings.share,
                icon: Icons.share_outlined,
                onTap: () async {
                  await SharingUtil.shareRecipe(context, recipe, ref.read(imageDownloadRepositoryProvider));
                  if (!context.mounted) return;
                  Navigator.pop(context);
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

  Future<void> _refreshRecipes() async {
    ref.invalidate(communityRecipesProvider);
    await Future.delayed(const Duration(milliseconds: 300)); // Small delay for better UX
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onOptionsTap;

  const _RecipeCard({required this.recipe, required this.onOptionsTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onOptionsTap,
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
                            ? AppCachedImage(imageUrl: recipe.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
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
            top: 4,
            right: 4,
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
  final Color? iconColor;
  final Color? textColor;
  final bool isCenter;

  const _PhotoModalStyleCard({required this.text, this.icon, required this.onTap, this.iconColor, this.textColor, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child:
            isCenter
                ? Center(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? AppColors.greyScale800)))
                : Row(
                  children: [
                    if (icon != null) ...[Icon(icon, color: iconColor ?? AppColors.greyScale800, size: 24), const SizedBox(width: 12)],
                    Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? AppColors.greyScale800)),
                  ],
                ),
      ),
    );
  }
}
