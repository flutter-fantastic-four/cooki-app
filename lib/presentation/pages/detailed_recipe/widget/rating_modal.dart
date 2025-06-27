import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/domain/entity/review.dart';
import 'package:cooki/presentation/pages/detailed_recipe/detailed_recipe_page.dart';
import 'package:cooki/presentation/pages/reviews/reviews_view_model.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatingModal extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RatingModal({super.key, required this.recipe});

  @override
  ConsumerState<RatingModal> createState() => RatingModalState();
}

class RatingModalState extends ConsumerState<RatingModal> {
  int currentRating = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with current rating if available
    if (!widget.recipe.isPublic && widget.recipe.userRating > 0) {
      currentRating = widget.recipe.userRating;
    }
  }

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
            decoration: BoxDecoration(
              color: AppColors.greyScale400,
              borderRadius: BorderRadius.circular(10),
            ),
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
                        style: _ModalTextStyles.modalTitle,
                      ),
                      Text(
                        strings(context).recipeRating,
                        style: _ModalTextStyles.modalSubtitle,
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
                Expanded(
                  child: _buildModalButton(
                    text: strings(context).close,
                    isPrimary: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
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

  Widget _buildModalButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: isPrimary ? const Color(0xFF1D8163) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0xFF1D8163)),
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
        final currentUser = ref.read(userGlobalViewModelProvider);
        if (currentUser != null) {
          if (widget.recipe.isPublic) {
            // For public recipes, create a review
            final review = Review(
              id: '',
              reviewText: null,
              rating: currentRating,
              imageUrls: [],
              userId: currentUser.id,
              userName: currentUser.name,
              userImageUrl: currentUser.profileImage,
            );
            await ref
                .read(reviewRepositoryProvider)
                .saveReview(recipeId: widget.recipe.id, review: review);
          } else {
            // For private recipes, update the recipe's userRating field
            final updatedRecipe = widget.recipe.copyWith(
              userRating: currentRating,
            );
            await ref.read(recipeRepositoryProvider).editRecipe(updatedRecipe);
          }

          // Invalidate providers to refresh data
          ref.invalidate(userRatingProvider(widget.recipe));
          ref.invalidate(actualAverageRatingProvider(widget.recipe.id));
          // Invalidate the reviews provider to refresh the review list
          ref.invalidate(reviewsViewModelProvider(widget.recipe.id));

          // For private recipes, invalidate the recipe data provider
          // so fresh rating data is fetched from Firestore
          if (!widget.recipe.isPublic) {
            ref.invalidate(recipeByIdProvider(widget.recipe.id));
          }

          if (!context.mounted) return;
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings(context).saveFailedError}: $e')),
        );
      }
    } else {
      Navigator.pop(context);
    }
  }
}

// Constants for modal text styles
class _ModalTextStyles {
  static const modalTitle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w700,
    height: 1.50,
  );

  static const modalSubtitle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: -0.14,
  );
}
