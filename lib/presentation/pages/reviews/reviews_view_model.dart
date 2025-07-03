import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/review/review.dart';
import '../../../domain/entity/review/review_sort_type.dart';
import '../detailed_recipe/recipe_detail_view_model.dart';

class ReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final bool isRefreshing;
  final ReviewSortType currentSortType;
  final ReviewsErrorKey? errorKey;
  final Set<String> expandedReviews;

  /// Stores translated texts by reviewId
  final Map<String, String> translatedTexts;

  /// Tracks which reviews are being translated
  final Set<String> translatingReviews;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.currentSortType = ReviewSortType.dateDescending,
    this.errorKey,
    this.expandedReviews = const {},
    this.translatedTexts = const {},
    this.translatingReviews = const {},
  });

  ReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isRefreshing,
    ReviewSortType? currentSortType,
    ReviewsErrorKey? errorKey,
    bool clearErrorKey = false,
    Set<String>? expandedReviews,
    Map<String, String>? translatedTexts,
    Set<String>? translatingReviews,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentSortType: currentSortType ?? this.currentSortType,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
      expandedReviews: expandedReviews ?? this.expandedReviews,
      translatedTexts: translatedTexts ?? this.translatedTexts,
      translatingReviews: translatingReviews ?? this.translatingReviews,
    );
  }
}

class ReviewsViewModel extends AutoDisposeFamilyNotifier<ReviewsState, String> {
  @override
  ReviewsState build(String recipeId) {
    Future.microtask(() => loadReviews());
    return const ReviewsState(isLoading: true);
  }

  Future<void> loadReviews() async {
    try {
      final reviews = await ref
          .read(reviewRepositoryProvider)
          .getReviewsByRecipeId(arg, sortType: state.currentSortType);

      state = state.copyWith(reviews: reviews, translatedTexts: const {});
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: ReviewsErrorKey.loadFailed);
    } finally {
      state = state.copyWith(isLoading: false, isRefreshing: false);
    }
  }

  Future<void> refreshReviews() async {
    if (state.isRefreshing || state.isLoading) {
      return;
    }
    state = state.copyWith(isRefreshing: true);
    await loadReviews();
  }

  Future<void> changeSortType(ReviewSortType sortType) async {
    if (state.currentSortType == sortType ||
        state.isRefreshing ||
        state.isLoading) {
      return;
    }

    state = state.copyWith(currentSortType: sortType, isLoading: true);

    await loadReviews();
  }

  void toggleReviewExpansion(String reviewId) {
    final expandedReviews = Set<String>.from(state.expandedReviews);

    if (expandedReviews.contains(reviewId)) {
      expandedReviews.remove(reviewId);
    } else {
      expandedReviews.add(reviewId);
    }

    state = state.copyWith(expandedReviews: expandedReviews);
  }

  bool isReviewExpanded(String reviewId) {
    return state.expandedReviews.contains(reviewId);
  }

  Future<void> deleteReview(String reviewId) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(reviewRepositoryProvider)
          .deleteReview(recipeId: arg, reviewId: reviewId);

      // Remove the review from the local list
      final updatedReviews =
          state.reviews.where((review) => review.id != reviewId).toList();

      state = state.copyWith(reviews: updatedReviews);
      _refreshRecipeWithDelay(arg);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: ReviewsErrorKey.deleteFailed);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _refreshRecipeWithDelay(String recipeId) async {
    await Future.delayed(Duration(milliseconds: 2000));
    ref
        .read(recipeDetailViewModelProvider(recipeId).notifier)
        .refreshRecipeData();
  }


  Future<Review?> getUserReviewForRecipe(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      return await ref
          .read(reviewRepositoryProvider)
          .getUserReviewForRecipe(recipeId: arg, userId: userId);
    } catch (e, stack) {
      logError(e, stack);
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Checks if translate option should be shown
  bool shouldShowTranslate(Review review, String currentAppLanguage) {
    return review.reviewText?.isNotEmpty == true &&
        review.language != null &&
        review.language != currentAppLanguage;
  }

  Future<void> translateReview(String reviewId, String currentLanguage) async {
    final review = state.reviews.firstWhere((r) => r.id == reviewId);

    // Add to translating set
    final updatedTranslatingReviews = Set<String>.from(
      state.translatingReviews,
    );
    updatedTranslatingReviews.add(reviewId);
    state = state.copyWith(translatingReviews: updatedTranslatingReviews);

    try {
      final translationResult = await ref
          .read(reviewRepositoryProvider)
          .translateReviewText(
            text: review.reviewText!,
            targetLanguage: currentLanguage,
            sourceLanguage: review.language,
          );

      // Update translated texts
      final updatedTranslatedTexts = Map<String, String>.from(
        state.translatedTexts,
      );
      updatedTranslatedTexts[reviewId] = translationResult.translatedText;
      state = state.copyWith(translatedTexts: updatedTranslatedTexts);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: ReviewsErrorKey.translationFailed);
    } finally {
      // Remove from translating set
      final updatedTranslatingReviews = Set<String>.from(
        state.translatingReviews,
      );
      updatedTranslatingReviews.remove(reviewId);
      state = state.copyWith(translatingReviews: updatedTranslatingReviews);
    }
  }

  /// Gets translated text for a review
  String? getTranslatedText(String reviewId) {
    return state.translatedTexts[reviewId];
  }

  /// Checks if review is being translated
  bool isReviewTranslating(String reviewId) {
    return state.translatingReviews.contains(reviewId);
  }

  /// Checks if review has been translated
  bool hasTranslation(String reviewId) {
    return state.translatedTexts.containsKey(reviewId);
  }

  // Clear translation for a review (undo translation)
  void clearTranslation(String reviewId) {
    final updatedTranslatedTexts = Map<String, String>.from(
      state.translatedTexts,
    );
    updatedTranslatedTexts.remove(reviewId);
    state = state.copyWith(translatedTexts: updatedTranslatedTexts);
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }
}

final reviewsViewModelProvider = NotifierProvider.autoDispose
    .family<ReviewsViewModel, ReviewsState, String>(ReviewsViewModel.new);
