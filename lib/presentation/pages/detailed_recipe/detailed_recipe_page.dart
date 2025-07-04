import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/category_mapper.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/core/utils/sharing_util.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/domain/entity/review/review.dart';
import 'package:cooki/presentation/pages/detailed_recipe/recipe_detail_view_model.dart';
import 'package:cooki/presentation/pages/detailed_recipe/widget/rating_modal.dart';
import 'package:cooki/presentation/pages/detailed_recipe/widget/review_card_list.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_page.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/saved_recipes_tab_view_model.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:cooki/presentation/pages/reviews/reviews_page.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/recipe_options_modal.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../reviews/reviews_view_model.dart';
import '../write_review/write_review_page.dart';

// Provider for checking if a recipe is saved by the current user
final isRecipeSavedProvider = FutureProvider.family.autoDispose<bool, String>((
  ref,
  recipeId,
) async {
  try {
    final currentUser = ref.read(userGlobalViewModelProvider);
    if (currentUser == null) return false;

    final recipeRepository = ref.read(recipeRepositoryProvider);
    final savedRecipeIds = await recipeRepository.getUserSavedRecipeIds(
      currentUser.id,
    );
    return savedRecipeIds.contains(recipeId);
  } catch (e) {
    return false;
  }
});

class DetailRecipePage extends ConsumerWidget {
  final Recipe recipe;
  final String? category;

  // ignore: unused_field
  static bool _hasRatingBeenPosted = false;

  const DetailRecipePage({super.key, required this.recipe, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recipeDetailViewModelProvider(recipe.id));
    final user = ref.read(userGlobalViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            actions: [
              SizedBox(
                width: 56,
                height: 56,
                child:
                    user != null && user.id == recipe.userId
                        ? IconButton(
                          onPressed: () {
                            NavigationUtil.pushFromBottom(
                              context,
                              RecipeEditPage(recipe: recipe),
                            );
                          },
                          icon: SvgPicture.asset(
                            'assets/icons/name=edit, size=24, state=Default.svg',
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                        : SizedBox(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipe.imageUrl != null
                    ? _buildImageSelector(context)
                    : Image.asset(
                      'assets/no_image.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 230,
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoChip(context, ref, user, state),
                      const SizedBox(height: 12),
                      _title(context, ref),
                      const SizedBox(height: 8),
                      _details(context),
                      const SizedBox(height: 13),
                      TagChips(recipe.tags),
                      const SizedBox(height: 24),
                      _review(context, ref, state.recipe),
                      const SizedBox(height: 24),
                      _ingredientsLabel(context),
                      const SizedBox(height: 16),
                      _ingredientsColumn(),
                      const SizedBox(height: 16),
                      Text(
                        strings(context).stepsLabel,
                        style: RecipePageWidgets.sectionTitleStyle,
                      ),
                      const SizedBox(height: 16),
                      _stepsColumn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) => Row(
    children: [
      Text(
        strings(context).cookTime(recipe.cookTime),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 12),
      Text(
        "${recipe.calories}${strings(context).caloriesUnitAfter}",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      Spacer(),
      Text(
        CategoryMapper.translateCategoryToAppLanguage(context, recipe.category),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 12),
    ],
  );

  Row _ingredientsLabel(BuildContext context) {
    return Row(
      children: [
        Text(
          strings(context).ingredientsLabel,
          style: RecipePageWidgets.sectionTitleStyle,
        ),
        const SizedBox(width: 3),
        Text(
          strings(context).servingsLabel,
          style: RecipePageWidgets.servingsTitleStyle,
        ),
      ],
    );
  }

  Widget _review(BuildContext context, WidgetRef ref, Recipe? currentRecipe) {
    final ratingCount = currentRecipe?.ratingCount ?? 0;
    final ratingAverage = currentRecipe?.ratingAverage ?? 0.0;
    return recipe.isPublic
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewRow(
              context,
              ref,
              count: ratingCount,
              averageText:
                  ratingCount == 0 ? '0' : ratingAverage.toStringAsFixed(1),
              recipe: recipe,
            ),
            const SizedBox(height: 16),
            ReviewCardList(recipe),
          ],
        )
        : SizedBox();
  }

  Widget _buildReviewRow(
    BuildContext context,
    WidgetRef ref, {
    required int count,
    required String averageText,
    required Recipe recipe,
  }) {
    return Row(
      children: [
        _buildReviewNavigationButton(context, ref, count, recipe),
        Spacer(),
        Icon(Icons.star, color: AppColors.secondary600),
        Text(
          '${strings(context).average} $averageText${strings(context).score}',
          style: RecipePageWidgets.sectionTitleStyle,
        ),
      ],
    );
  }

  Widget _buildReviewNavigationButton(
    BuildContext context,
    WidgetRef ref,
    int count,
    Recipe recipe,
  ) {
    return GestureDetector(
      onTap: () async {
        await NavigationUtil.pushFromBottom(
          context,
          ReviewsPage(recipeId: recipe.id, recipeName: recipe.recipeName),
        );
        // Refresh recipe data when returning from reviews page
        ref
            .read(recipeDetailViewModelProvider(recipe.id).notifier)
            .refreshRecipeData();
      },
      child: Row(
        children: [
          Text(
            '${strings(context).review} ${count > 999 ? '999+' : count}${strings(context).amount}',
            style: RecipePageWidgets.sectionTitleStyle,
          ),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Column _ingredientsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in recipe.ingredients) ...[
          RecipePageWidgets.divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(item),
          ),
        ],
      ],
    );
  }

  Column _stepsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < recipe.steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepIndexLabel(i + 1),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.appBarGrey,
                    borderRadius: RecipePageWidgets.inputBorderRadius,
                  ),
                  child: Text(recipe.steps[i]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Row _title(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(
      savedRecipesViewModelProvider(strings(context)).notifier,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            recipe.recipeName,
            style: RecipePageWidgets.sectionTitleStyle,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: 3),
        Consumer(
          builder: (context, ref, child) {
            final user = ref.read(userGlobalViewModelProvider);

            // Only show bookmark button for recipes from other users
            if (user != null && user.id == recipe.userId) {
              return SizedBox.shrink(); // Hide bookmark button for own recipes
            }

            if (user == null) {
              return IconButton(
                onPressed: () {
                  // Navigate to login
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GuestLoginPage(),
                    ),
                  );
                },
                icon: Icon(Icons.bookmark_border),
              );
            }

            final isRecipeSavedAsync = ref.watch(
              isRecipeSavedProvider(recipe.id),
            );
            return isRecipeSavedAsync.when(
              data: (isSaved) {
                return IconButton(
                  onPressed: () async {
                    try {
                      final recipeRepository = ref.read(
                        recipeRepositoryProvider,
                      );
                      if (isSaved) {
                        await recipeRepository.removeFromSavedRecipes(
                          user.id,
                          recipe.id,
                        );
                        ref.invalidate(isRecipeSavedProvider(recipe.id));
                        if (context.mounted) {
                          SnackbarUtil.showSnackBar(
                            context,
                            strings(context).recipeRemovedSuccessfully,
                            showIcon: true,
                          );
                        }
                      } else {
                        await recipeRepository.addToSavedRecipes(
                          user.id,
                          recipe.id,
                        );
                        ref.invalidate(isRecipeSavedProvider(recipe.id));
                        if (context.mounted) {
                          SnackbarUtil.showSnackBar(
                            context,
                            strings(context).recipeSavedSuccessfully,
                            showIcon: true,
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarUtil.showSnackBar(
                          context,
                          strings(context).errorOccurred,
                        );
                      }
                    }
                  },
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                );
              },
              loading:
                  () => IconButton(
                    onPressed: null,
                    icon: Icon(Icons.bookmark_border),
                  ),
              error:
                  (error, stack) => IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.bookmark_border),
                  ),
            );
          },
        ),
        recipe.isPublic
            ? IconButton(
              onPressed: () => _shareRecipe(context, ref, recipe),
              icon: Icon(Icons.ios_share),
            )
            : GestureDetector(
              onTap:
                  () => RecipeOptionsModal.show(
                    context: context,
                    ref: ref,
                    recipe: recipe,
                    isDetail: true,
                    onRecipeDeleted: () {
                      viewModel.refreshRecipes();
                      Navigator.of(context).pop();
                    },
                    onRecipeUpdated: () {
                      viewModel.refreshRecipes();
                    },
                  ),
              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.black,
              ),
            ),
      ],
    );
  }

  void _shareRecipe(BuildContext context, WidgetRef ref, Recipe recipe) async {
    await SharingUtil.shareRecipe(
      context,
      recipe,
      ref.read(imageDownloadRepositoryProvider),
    );
    if (!context.mounted) return;
  }

  Row _infoChip(
    BuildContext context,
    WidgetRef ref,
    AppUser? user,
    RecipeDetailState state,
  ) {
    return Row(
      children: [
        category != null
            ? Row(
              children: [
                Container(
                  height: 28,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: AppColors.greyScale800),
                      borderRadius: BorderRadius.circular(99999),
                    ),
                  ),
                  child: Text(
                    category!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
              ],
            )
            : SizedBox(),
        GestureDetector(
          onTap: () async {
            bool? ratingPosted = false;

            if (recipe.isPublic) {
              // Fetch existing review if any
              Review? existingReview;
              try {
                final currentUser = ref.read(userGlobalViewModelProvider);
                if (currentUser != null) {
                  final reviewRepository = ref.read(reviewRepositoryProvider);
                  existingReview = await reviewRepository
                      .getUserReviewForRecipe(
                        recipeId: recipe.id,
                        userId: currentUser.id,
                      );
                }
              } catch (e) {
                // If fetching fails, proceed without existing review
                existingReview = null;
              }

              if (!context.mounted) return;
              ratingPosted = await NavigationUtil.pushFromBottom<bool>(
                context,
                WriteReviewPage(
                  recipeId: recipe.id,
                  recipeName: recipe.recipeName,
                  review: existingReview, // Pass existing review if found
                ),
              );
            } else {
              ratingPosted = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.greyScale50,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                builder: (context) {
                  return RatingModal(recipe: recipe);
                },
              );
            }

            // Store the result in a static variable or pass it through navigation
            if (ratingPosted == true) {
              DetailRecipePage._hasRatingBeenPosted = true;
              // Refresh recipe data and user rating
              ref
                  .read(recipeDetailViewModelProvider(recipe.id).notifier)
                  .refreshRecipeData();
              ref
                  .read(reviewsViewModelProvider(recipe.id).notifier)
                  .refreshReviews();
            }
          },
          child: _buildRatingStars(state.userRating),
        ),
      ],
    );
  }

  Widget _buildRatingStars(int? userRating) {
    final rating = userRating ?? 0;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color:
                rating == 0 ? AppColors.greyScale300 : AppColors.greyScale800,
          ),
          borderRadius: BorderRadius.circular(99999),
        ),
      ),
      child: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color:
                index < rating
                    ? AppColors.secondary600
                    : AppColors.greyScale300,
            size: 14,
          );
        }),
      ),
    );
  }

  Widget _buildImageSelector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final imageProvider = CachedNetworkImageProvider(recipe.imageUrl!);
        showImageViewer(
          context,
          imageProvider,
          swipeDismissible: true,
          doubleTapZoomable: true,
          useSafeArea: true,
        );
      },
      child: AppCachedImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        height: 230,
        width: double.infinity,
      ),
    );
  }
}
