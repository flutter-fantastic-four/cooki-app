import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
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
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailRecipePage extends ConsumerWidget {
  final Recipe recipe;
  final String? category;

  // int currentRating = 0;

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
                      _infoChip(context, user),
                      const SizedBox(height: 12),
                      _title(),
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
                        Navigator.pop(context);
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
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    NavigationUtil.pushFromBottom(context, ReviewsPage(recipeId: recipe.id, recipeName: recipe.recipeName));
                  },
                  child: Row(
                    children: [
                      Text(
                        '${strings(context).review} ${recipe.ratingCount > 999 ? '999+' : recipe.ratingCount}${strings(context).amount}',
                        style: RecipePageWidgets.sectionTitleStyle,
                      ),

                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
                Spacer(),
                Icon(Icons.star, color: AppColors.secondary600),
                Text(
                  '${strings(context).average} ${recipe.ratingSum == 0.0 ? '0' : recipe.ratingSum}${strings(context).score}',
                  style: RecipePageWidgets.sectionTitleStyle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReviewCardList(recipe),
          ],
        )
        : SizedBox();
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

  Row _title() {
    return Row(
      children: [
        Expanded(child: Text(recipe.recipeName, style: RecipePageWidgets.sectionTitleStyle, softWrap: true, overflow: TextOverflow.visible)),
        SizedBox(width: 3),
        IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
      ],
    );
  }

  Row _infoChip(BuildContext context, AppUser? user) {
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
          onTap: () {
            int currentRating = 0;

            if (user == null) {
              NavigationUtil.pushFromBottom(context, GuestLoginPage());
            } else {
              recipe.isPublic
                  ? NavigationUtil.pushFromBottom(context, WriteReviewPage(recipeId: recipe.id, recipeName: recipe.recipeName))
                  : showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.greyScale50,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 30, left: 15, right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top handle
                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
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
                                        Text(
                                          strings(context).recipeReview,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w700,
                                            height: 1.50,
                                          ),
                                        ),
                                        Text(
                                          strings(context).recipeRating,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.14,
                                          ),
                                        ),
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
                                setRating: (value) {
                                  currentRating = value;
                                },
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5) /* Grayscale-50 */),
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
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: 54,
                                              padding: const EdgeInsets.all(8),
                                              decoration: ShapeDecoration(
                                                color: Colors.white /* Grayscale-White */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(width: 1, color: const Color(0xFF1D8163) /* Primary-700 */),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                  Text(
                                                    strings(context).close,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(0xFF1D8163) /* Primary-700 */,
                                                      fontSize: 16,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.50,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 54,
                                            padding: const EdgeInsets.all(8),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF1D8163) /* Primary-700 */,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  strings(context).confirm,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white /* Grayscale-White */,
                                                    fontSize: 16,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
            }
          },
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: AppColors.greyScale300), borderRadius: BorderRadius.circular(99999)),
            ),
            child: Row(children: List.generate(5, (_) => Icon(Icons.star_border, size: 12, color: AppColors.greyScale800))),
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
                StarRating(currentRating: review.rating, iconSize: 16, horizontalPadding: 0, setRating: null, alignment: MainAxisAlignment.start),
                const SizedBox(height: 4),
                if (review.reviewText?.isNotEmpty == true)
                  Text(review.reviewText!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
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
