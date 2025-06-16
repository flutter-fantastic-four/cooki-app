import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/app_user.dart';
import '../../../domain/entity/review.dart';

class WriteReviewState {
  final int rating;
  final String reviewText;
  final List<File> selectedImages;
  final bool isSaving;
  final AddReviewErrorKey? errorKey;

  const WriteReviewState({
    this.rating = 0,
    this.reviewText = '',
    this.selectedImages = const [],
    this.isSaving = false,
    this.errorKey,
  });

  WriteReviewState copyWith({
    int? rating,
    String? reviewText,
    List<File>? selectedImages,
    bool? isSaving,
    AddReviewErrorKey? errorKey,
    bool clearErrorKey = false,
  }) {
    return WriteReviewState(
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      selectedImages: selectedImages ?? this.selectedImages,
      isSaving: isSaving ?? this.isSaving,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
    );
  }

  bool get canSubmit => rating > 0 && !isSaving;

  bool get hasImages => selectedImages.isNotEmpty;
}

class WriteReviewViewModel extends AutoDisposeNotifier<WriteReviewState> {
  @override
  WriteReviewState build() {
    return const WriteReviewState();
  }

  Future<void> saveReview({
    required String recipeId,
    required AppUser user,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      List<String> imageUrls = [];

      if (state.selectedImages.isNotEmpty) {
        try {
          for (final imageFile in state.selectedImages) {
            final imageUrl = await ref
                .read(reviewRepositoryProvider)
                .uploadReviewImage(imageFile, user.id);
            imageUrls.add(imageUrl);
          }
        } catch (e, stack) {
          logError(e, stack);
          state = state.copyWith(errorKey: AddReviewErrorKey.imageUploadFailed);
          return;
        }
      }

      final review = Review(
        id: '',
        reviewText: state.reviewText.trim(),
        rating: state.rating,
        imageUrls: imageUrls,
        userId: user.id,
        userName: user.name,
        userImageUrl: user.profileImage,
      );

      await ref
          .read(reviewRepositoryProvider)
          .saveReview(recipeId: recipeId, review: review);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: AddReviewErrorKey.saveFailed);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void updateReviewText(String text) {
    state = state.copyWith(reviewText: text);
  }

  void addImages(List<File> images) {
    final currentImages = List<File>.from(state.selectedImages);
    final totalImages = currentImages.length + images.length;

    if (totalImages > 5) {
      state = state.copyWith(errorKey: AddReviewErrorKey.tooManyImages);
      return;
    }

    currentImages.addAll(images);
    state = state.copyWith(selectedImages: currentImages);
  }

  void removeImage(int index) {
    final updatedImages = List<File>.from(state.selectedImages);
    if (index >= 0 && index < updatedImages.length) {
      updatedImages.removeAt(index);
      state = state.copyWith(selectedImages: updatedImages);
    }
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }
}

final writeReviewViewModelProvider =
    NotifierProvider.autoDispose<WriteReviewViewModel, WriteReviewState>(
      WriteReviewViewModel.new,
    );
