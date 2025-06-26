import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/domain/entity/review.dart';
import 'package:cooki/presentation/pages/add_review/write_review_page.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_page.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:cooki/presentation/pages/reviews/reviews_page.dart';
import 'package:cooki/presentation/pages/reviews/reviews_view_model.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/recipe_options_modal.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Constants for modal text styles
class _ModalTextStyles {
  static const modalTitle = TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Pretendard', fontWeight: FontWeight.w700, height: 1.50);

  static const modalSubtitle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: -0.14,
  );
}

// Provider for user rating that can be refreshed
final userRatingProvider = FutureProvider.family.autoDispose<int?, String>((ref, recipeId) async {
  try {
    final currentUser = ref.read(userGlobalViewModelProvider);
    if (currentUser == null) return null;

    final reviewRepository = ref.read(reviewRepositoryProvider);
    final userReview = await reviewRepository.getUserReviewForRecipe(recipeId: recipeId, userId: currentUser.id);
    return userReview?.rating;
  } catch (e) {
    return null;
  }
});

// Provider for calculating actual average rating from reviews
final actualAverageRatingProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, recipeId) async {
  try {
    final reviewRepository = ref.read(reviewRepositoryProvider);
    final reviews = await reviewRepository.getReviewsByRecipeId(recipeId);

    if (reviews.isEmpty) {
      return {'average': 0.0, 'count': 0};
    }

    final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    final average = totalRating / reviews.length;

    return {'average': average, 'count': reviews.length};
  } catch (e) {
    return {'average': 0.0, 'count': 0};
  }
});

// Provider for checking if a recipe is saved by the current user
final isRecipeSavedProvider = FutureProvider.family.autoDispose<bool, String>((ref, recipeId) async {
  try {
    final currentUser = ref.read(userGlobalViewModelProvider);
    if (currentUser == null) return false;

    final recipeRepository = ref.read(recipeRepositoryProvider);
    final savedRecipeIds = await recipeRepository.getUserSavedRecipeIds(currentUser.id);
    return savedRecipeIds.contains(recipeId);
  } catch (e) {
    return false;
  }
});

class DetailRecipePage extends ConsumerWidget {
  final Recipe recipe;
  final String? category;
  static bool _hasRatingBeenPosted = false;

  const DetailRecipePage({super.key, required this.recipe, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userGlobalViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                recipe.imageUrl != null
                    ? _buildImageSelector(context)
                    : Image.asset('assets/no_image.png', fit: BoxFit.cover, width: double.infinity, height: 230),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoChip(context, ref, user),
                      const SizedBox(height: 12),
                      _title(context, ref),
                      const SizedBox(height: 20),
                      TagChips(recipe.tags),
                      const SizedBox(height: 24),
                      _review(context),
                      const SizedBox(height: 24),
                      _ingredientsLabel(context),
                      const SizedBox(height: 16),
                      _ingredientsColumn(),
                      const SizedBox(height: 16),
                      Text(strings(context).stepsLabel, style: RecipePageWidgets.sectionTitleStyle),
                      const SizedBox(height: 16),
                      _stepsColumn(),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 4, padding: EdgeInsets.zero, backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pop(context, DetailRecipePage._hasRatingBeenPosted);
                        DetailRecipePage._hasRatingBeenPosted = false; // Reset after use
                      },
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 24),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child:
                        category == strings(context).recipeTabCreated || category == strings(context).recipeTabShared
                            ? ElevatedButton(
                              style: ElevatedButton.styleFrom(elevation: 4, padding: EdgeInsets.zero, backgroundColor: Colors.white),
                              onPressed: () {
                                NavigationUtil.pushFromBottom(context, RecipeEditPage(recipe: recipe));
                              },
                              child: Icon(Icons.edit_outlined, color: Colors.black, size: 24),
                            )
                            : SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _ingredientsLabel(BuildContext context) {
    return Row(
      children: [
        Text(strings(context).ingredientsLabel, style: RecipePageWidgets.sectionTitleStyle),
        const SizedBox(width: 3),
        Text(strings(context).servingsLabel, style: RecipePageWidgets.servingsTitleStyle),
      ],
    );
  }

  Widget _review(BuildContext context) {
    return recipe.isPublic
        ? Column(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final actualRatingAsync = ref.watch(actualAverageRatingProvider(recipe.id));
                return actualRatingAsync.when(
                  data: (ratingData) {
                    final average = ratingData['average'] as double;
                    final count = ratingData['count'] as int;
                    return _buildReviewRow(context, count: count, averageText: count == 0 ? '0' : average.toStringAsFixed(1));
                  },
                  loading:
                      () => _buildReviewRow(
                        context,
                        count: recipe.ratingCount,
                        averageText: recipe.ratingSum == 0.0 ? '0' : recipe.ratingSum.toStringAsFixed(1),
                      ),
                  error: (error, stack) => _buildReviewRow(context, count: recipe.ratingCount, averageText: '0'),
                );
              },
            ),
            const SizedBox(height: 16),
            ReviewCardList(recipe),
          ],
        )
        : SizedBox();
  }

  Widget _buildReviewRow(BuildContext context, {required int count, required String averageText}) {
    return Row(
      children: [
        _buildReviewNavigationButton(context, count),
        Spacer(),
        Icon(Icons.star, color: AppColors.secondary600),
        Text('${strings(context).average} $averageText${strings(context).score}', style: RecipePageWidgets.sectionTitleStyle),
      ],
    );
  }

  Widget _buildReviewNavigationButton(BuildContext context, int count) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushFromBottom(context, ReviewsPage(recipeId: recipe.id, recipeName: recipe.recipeName));
      },
      child: Row(
        children: [
          Text('${strings(context).review} ${count > 999 ? '999+' : count}${strings(context).amount}', style: RecipePageWidgets.sectionTitleStyle),
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text(item)),
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.appBarGrey, borderRadius: RecipePageWidgets.inputBorderRadius),
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
    return Row(
      children: [
        Expanded(child: Text(recipe.recipeName, style: RecipePageWidgets.sectionTitleStyle, softWrap: true, overflow: TextOverflow.visible)),
        SizedBox(width: 3),
        Consumer(
          builder: (context, ref, child) {
            final user = ref.read(userGlobalViewModelProvider);
            if (user == null) {
              return IconButton(
                onPressed: () {
                  // Navigate to login
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GuestLoginPage()));
                },
                icon: Icon(Icons.bookmark_border),
              );
            }

            final isRecipeSavedAsync = ref.watch(isRecipeSavedProvider(recipe.id));
            return isRecipeSavedAsync.when(
              data: (isSaved) {
                return IconButton(
                  onPressed: () async {
                    try {
                      final recipeRepository = ref.read(recipeRepositoryProvider);
                      if (isSaved) {
                        await recipeRepository.removeFromSavedRecipes(user.id, recipe.id);
                        ref.invalidate(isRecipeSavedProvider(recipe.id));
                        if (context.mounted) {
                          SnackbarUtil.showSnackBar(context, strings(context).recipeRemovedSuccessfully, showIcon: true);
                        }
                      } else {
                        await recipeRepository.addToSavedRecipes(user.id, recipe.id);
                        ref.invalidate(isRecipeSavedProvider(recipe.id));
                        if (context.mounted) {
                          SnackbarUtil.showSnackBar(context, strings(context).recipeSavedSuccessfully, showIcon: true);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarUtil.showSnackBar(context, strings(context).errorOccurred);
                      }
                    }
                  },
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                );
              },
              loading: () => IconButton(onPressed: null, icon: Icon(Icons.bookmark_border)),
              error: (error, stack) => IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
            );
          },
        ),
        IconButton(
          onPressed:
              () => RecipeOptionsModal.show(
                context: context,
                ref: ref,
                recipe: recipe,
                onRecipeDeleted: () {
                  // Navigate back to home when recipe is deleted
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                onRecipeUpdated: () {
                  // Refresh page state when recipe is updated
                  ref.invalidate(isRecipeSavedProvider(recipe.id));
                  ref.invalidate(actualAverageRatingProvider(recipe.id));
                },
              ),
          icon: Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Row _infoChip(BuildContext context, WidgetRef ref, AppUser? user) {
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
                      side: BorderSide(width: 1, color: AppColors.greyScale300),
                      borderRadius: BorderRadius.circular(99999),
                    ),
                  ),
                  child: Text(category!, style: TextStyle(fontSize: 12)),
                ),
                SizedBox(width: 8),
              ],
            )
            : SizedBox(),
        GestureDetector(
          onTap: () async {
            final currentRef = ref; // Capture ref for use in modal
            bool? ratingPosted = false;

            if (recipe.isPublic) {
              // Fetch existing review if any
              Review? existingReview;
              try {
                final currentUser = ref.read(userGlobalViewModelProvider);
                if (currentUser != null) {
                  final reviewRepository = ref.read(reviewRepositoryProvider);
                  existingReview = await reviewRepository.getUserReviewForRecipe(recipeId: recipe.id, userId: currentUser.id);
                }
              } catch (e) {
                // If fetching fails, proceed without existing review
                existingReview = null;
              }

              ratingPosted = await NavigationUtil.pushFromBottomAndWait<bool>(
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
                builder: (context) {
                  return _RatingModal(recipe: recipe, currentRef: currentRef);
                },
              );
            }

            // Store the result in a static variable or pass it through navigation
            if (ratingPosted == true) {
              DetailRecipePage._hasRatingBeenPosted = true;
              // Invalidate the rating providers to force refresh
              ref.invalidate(userRatingProvider(recipe.id));
              ref.invalidate(actualAverageRatingProvider(recipe.id));
            }
          },
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: AppColors.greyScale300), borderRadius: BorderRadius.circular(99999)),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final userRatingAsync = ref.watch(userRatingProvider(recipe.id));
                return userRatingAsync.when(
                  data: (userRating) {
                    final rating = userRating ?? 0;
                    return Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: index < rating ? AppColors.secondary600 : AppColors.greyScale300,
                          size: 12,
                        );
                      }),
                    );
                  },
                  loading:
                      () => Row(
                        children: List.generate(5, (index) {
                          return Icon(Icons.star_border, color: AppColors.greyScale300, size: 12);
                        }),
                      ),
                  error:
                      (error, stack) => Row(
                        children: List.generate(5, (index) {
                          return Icon(Icons.star_border, color: AppColors.greyScale300, size: 12);
                        }),
                      ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final imageProvider = CachedNetworkImageProvider(recipe.imageUrl!);
        showImageViewer(context, imageProvider, swipeDismissible: true, doubleTapZoomable: true, useSafeArea: true);
      },
      child: AppCachedImage(imageUrl: recipe.imageUrl!, fit: BoxFit.cover, height: 230, width: double.infinity),
    );
  }
}

class ReviewCardList extends ConsumerWidget {
  const ReviewCardList(this.recipe, {super.key});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsViewModelProvider(recipe.id));

    final reviews = state.reviews.length > 5 ? state.reviews.sublist(0, 5) : state.reviews;
    if (reviews.isEmpty) return SizedBox();

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: reviews.map((review) => _buildReviewCard(context, ref, review)).toList()),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, WidgetRef ref, Review review) {
    return Container(
      width: 240,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          review.imageUrls.isNotEmpty
              ? _buildReviewImages(context, review)
              : SizedBox(
                width: 52,
                height: 52,
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/no_image.png', fit: BoxFit.cover)),
              ),
          SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StarRating(
                  currentRating: review.rating,
                  iconSize: 16,
                  horizontalPadding: 0,
                  filledStarColor: AppColors.secondary600,
                  emptyStarColor: AppColors.greyScale300,
                  setRating: null,
                  alignment: MainAxisAlignment.start,
                ),
                const SizedBox(height: 4),
                if (review.reviewText?.isNotEmpty == true)
                  Text(review.reviewText!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewImages(BuildContext context, Review review) {
    final double imageDimension = 52;
    return SizedBox(
      width: imageDimension,
      height: imageDimension,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppCachedImage(imageUrl: review.imageUrls.first, width: imageDimension, height: imageDimension, fit: BoxFit.cover),
      ),
    );
  }
}

class _RatingModal extends StatefulWidget {
  final Recipe recipe;
  final WidgetRef currentRef;

  const _RatingModal({required this.recipe, required this.currentRef});

  @override
  State<_RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<_RatingModal> {
  int currentRating = 0;

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 24,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Text(strings(context).recipeReview, textAlign: TextAlign.center, style: _ModalTextStyles.modalTitle),
                      Text(strings(context).recipeRating, style: _ModalTextStyles.modalSubtitle),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 5,
                  children: [],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: StarRating(
              currentRating: currentRating,
              filledStarColor: AppColors.secondary600,
              emptyStarColor: AppColors.greyScale300,
              setRating: (value) {
                setState(() {
                  currentRating = value;
                });
              },
            ),
          ),

          _buildModalActionButtons(context, currentRating),
        ],
      ),
    );
  }

  Widget _buildModalActionButtons(BuildContext context, int currentRating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.greyScale50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Expanded(child: _buildModalButton(text: strings(context).close, isPrimary: false, onTap: () => Navigator.pop(context))),
                Expanded(
                  child: _buildModalButton(
                    text: strings(context).confirm,
                    isPrimary: true,
                    onTap: () => _handleConfirmRating(context, currentRating),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalButton({required String text, required bool isPrimary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: isPrimary ? const Color(0xFF1D8163) : Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: const Color(0xFF1D8163)), borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isPrimary ? Colors.white : const Color(0xFF1D8163),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirmRating(BuildContext context, int currentRating) async {
    if (currentRating > 0) {
      try {
        final currentUser = widget.currentRef.read(userGlobalViewModelProvider);
        if (currentUser != null) {
          final review = Review(
            id: '',
            reviewText: null,
            rating: currentRating,
            imageUrls: [],
            userId: currentUser.id,
            userName: currentUser.name,
            userImageUrl: currentUser.profileImage,
          );
          await widget.currentRef.read(reviewRepositoryProvider).saveReview(recipeId: widget.recipe.id, review: review);
          // Invalidate providers to refresh data
          widget.currentRef.invalidate(userRatingProvider(widget.recipe.id));
          widget.currentRef.invalidate(actualAverageRatingProvider(widget.recipe.id));
          if (!context.mounted) return;
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${strings(context).saveFailedError}: $e')));
      }
    } else {
      Navigator.pop(context);
    }
  }
}
