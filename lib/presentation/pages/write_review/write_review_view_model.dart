import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/general_util.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/app_user.dart';
import '../../../domain/entity/local_or_remote_image.dart';
import '../../../domain/entity/review/review.dart';

class WriteReviewState {
  final int rating;
  final List<LocalOrRemoteImage> selectedImages;
  final bool isSaving;
  final bool isDeleting;
  final WriteReviewErrorKey? errorKey;

  const WriteReviewState({
    this.rating = 0,
    this.selectedImages = const [],
    this.isSaving = false,
    this.isDeleting = false,
    this.errorKey,
  });

  WriteReviewState copyWith({
    int? rating,
    List<LocalOrRemoteImage>? selectedImages,
    bool? isSaving,
    bool? isDeleting,
    WriteReviewErrorKey? errorKey,
    bool clearErrorKey = false,
  }) {
    return WriteReviewState(
      rating: rating ?? this.rating,
      selectedImages: selectedImages ?? this.selectedImages,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorKey: clearErrorKey ? null : errorKey ?? this.errorKey,
    );
  }

  bool get canSubmit => rating > 0 && !isSaving;
}

class WriteReviewViewModel
    extends AutoDisposeFamilyNotifier<WriteReviewState, Review?> {
  @override
  WriteReviewState build(Review? arg) {
    if (arg != null) {
      // Edit Mode: Initialize with existing review data
      final existingImages =
          arg.imageUrls.map((url) => LocalOrRemoteImage.url(url)).toList();

      return WriteReviewState(
        rating: arg.rating,
        selectedImages: existingImages,
      );
    }
    return const WriteReviewState();
  }

  Future<void> saveReview({
    required String recipeId,
    required String reviewText,
    required AppUser user,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      final imageUrls = await _compressAndUploadImages(user.id);
      if (imageUrls == null) return;

      var review = Review(
        id: arg?.id ?? '',
        reviewText: reviewText.trim(),
        rating: state.rating,
        imageUrls: imageUrls,
        userId: user.id,
        userName: user.name,
        userImageUrl: user.profileImage,
        createdAt: arg?.createdAt,
        updatedAt: arg != null ? DateTime.now() : null,
      );

      if (arg != null) {
        await ref
            .read(reviewRepositoryProvider)
            .editReview(recipeId: recipeId, review: review);
      } else {
        final reviewId = await ref
            .read(reviewRepositoryProvider)
            .saveReview(recipeId: recipeId, review: review);
        review = review.copyWith(id: reviewId);
      }
      _detectAndUpdateLanguage(
        reviewText: reviewText,
        recipeId: recipeId,
        review: review,
      );
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: WriteReviewErrorKey.saveFailed);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<List<String>?> _compressAndUploadImages(String userId) async {
    if (state.selectedImages.isEmpty) return [];

    try {
      final List<String> existingUrls = [];
      final List<File> filesToUpload = [];

      for (final reviewImage in state.selectedImages) {
        if (reviewImage.isUrl) {
          existingUrls.add(reviewImage.url!);
        } else if (reviewImage.isFile) {
          filesToUpload.add(reviewImage.file!);
        }
      }

      // Upload new files in parallel
      final List<String> uploadedUrls;
      if (filesToUpload.isNotEmpty) {
        final uploadTasks = filesToUpload.map((imageFile) async {
          final compressedFile = await GeneralUtil.compressImageFile(imageFile);
          return ref
              .read(reviewRepositoryProvider)
              .uploadReviewImage(compressedFile, userId);
        });

        uploadedUrls = await Future.wait(uploadTasks);
      } else {
        uploadedUrls = [];
      }

      // Combine URLs in the correct order
      final List<String> finalImageUrls = [];
      int uploadedIndex = 0;

      for (final reviewImage in state.selectedImages) {
        if (reviewImage.isUrl) {
          finalImageUrls.add(reviewImage.url!);
        } else if (reviewImage.isFile) {
          finalImageUrls.add(uploadedUrls[uploadedIndex]);
          uploadedIndex++;
        }
      }

      return finalImageUrls;
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: WriteReviewErrorKey.imageUploadFailed);
      return null;
    }
  }

  Future<void> _detectAndUpdateLanguage({
    required String reviewText,
    required String recipeId,
    required Review review,
  }) async {
    if (reviewText.trim().isEmpty) return;
    try {
      final detectionResult = await ref
          .read(reviewRepositoryProvider)
          .detectReviewLanguage(text: reviewText.trim());
      if (detectionResult.mostLikelyLanguage != null) {
        final updatedReview = review.copyWith(
          language: detectionResult.mostLikelyLanguage,
        );
        await ref
            .read(reviewRepositoryProvider)
            .editReview(recipeId: recipeId, review: updatedReview);
      }
    } catch (e, stack) {
      logError(e, stack);
    }
  }

  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  }) async {
    state = state.copyWith(isDeleting: true);

    try {
      await ref
          .read(reviewRepositoryProvider)
          .deleteReview(recipeId: recipeId, reviewId: reviewId);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: WriteReviewErrorKey.deleteFailed);
    } finally {
      state = state.copyWith(isDeleting: false);
    }
  }

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void addImages(List<File> images) {
    final currentImages = List<LocalOrRemoteImage>.from(state.selectedImages);
    final totalImages = currentImages.length + images.length;

    if (totalImages > 5) {
      state = state.copyWith(errorKey: WriteReviewErrorKey.tooManyImages);
      return;
    }

    final newImages =
        images.map((file) => LocalOrRemoteImage.file(file)).toList();
    currentImages.addAll(newImages);
    state = state.copyWith(selectedImages: currentImages);
  }

  void removeImage(int index) {
    final updatedImages = List<LocalOrRemoteImage>.from(state.selectedImages);
    if (index >= 0 && index < updatedImages.length) {
      updatedImages.removeAt(index);
      state = state.copyWith(selectedImages: updatedImages);
    }
  }

  void clearError() {
    state = state.copyWith(clearErrorKey: true);
  }
}

final writeReviewViewModelProvider = NotifierProvider.autoDispose
    .family<WriteReviewViewModel, WriteReviewState, Review?>(
      WriteReviewViewModel.new,
    );
