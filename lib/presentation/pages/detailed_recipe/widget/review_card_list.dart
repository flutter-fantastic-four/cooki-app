import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/domain/entity/review/review.dart';
import 'package:cooki/presentation/pages/reviews/reviews_view_model.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewCardList extends ConsumerWidget {
  const ReviewCardList(this.recipe, {super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsViewModelProvider(recipe.id));

    final reviews =
        state.reviews.length > 5 ? state.reviews.sublist(0, 5) : state.reviews;
    if (reviews.isEmpty) return SizedBox();

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              reviews
                  .map((review) => _buildReviewCard(context, ref, review))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, WidgetRef ref, Review review) {
    return Container(
      width: 240,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          review.imageUrls.isNotEmpty
              ? _buildReviewImages(context, review)
              : SizedBox(
                width: 52,
                height: 52,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/no_image.png', fit: BoxFit.cover),
                ),
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
                  Text(
                    review.reviewText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.2),
                  ),
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
        child: AppCachedImage(
          imageUrl: review.imageUrls.first,
          width: imageDimension,
          height: imageDimension,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
