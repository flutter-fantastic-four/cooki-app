import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/logger.dart';
import '../../../data/data_source/review_data_source.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/review.dart';

class ReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final bool isRefreshing;
  final ReviewSortType currentSortType;
  final ReviewsErrorKey? errorKey;
  final Set<String> expandedReviews;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.currentSortType = ReviewSortType.dateDescending,
    this.errorKey,
    this.expandedReviews = const {},
  });

  ReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isRefreshing,
    ReviewSortType? currentSortType,
    ReviewsErrorKey? errorKey,
    bool clearErrorKey = false,
    Set<String>? expandedReviews,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentSortType: currentSortType ?? this.currentSortType,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
      expandedReviews: expandedReviews ?? this.expandedReviews,
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

      state = state.copyWith(reviews: reviews);
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
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: ReviewsErrorKey.deleteFailed);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }
}

final reviewsViewModelProvider = NotifierProvider.autoDispose
    .family<ReviewsViewModel, ReviewsState, String>(ReviewsViewModel.new);
