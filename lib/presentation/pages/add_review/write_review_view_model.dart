import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/general_util.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/app_user.dart';
import '../../../domain/entity/review.dart';

class WriteReviewState {
  final int rating;
  final List<File> selectedImages;
  final bool isSaving;
  final WriteReviewErrorKey? errorKey;

  const WriteReviewState({
    this.rating = 0,
    this.selectedImages = const [],
    this.isSaving = false,
    this.errorKey,
  });

  WriteReviewState copyWith({
    int? rating,
    List<File>? selectedImages,
    bool? isSaving,
    WriteReviewErrorKey? errorKey,
    bool clearErrorKey = false,
  }) {
    return WriteReviewState(
      rating: rating ?? this.rating,
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
    required String reviewText,
    required AppUser user,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      final imageUrls = await _compressAndUploadImages(user.id);
      if (imageUrls == null) return;

      final review = Review(
        id: '',
        reviewText: reviewText.trim(),
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
      state = state.copyWith(errorKey: WriteReviewErrorKey.saveFailed);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<List<String>?> _compressAndUploadImages(String userId) async {
    if (state.selectedImages.isEmpty) return [];

    try {
      final uploadTasks = state.selectedImages.map((imageFile) async {
        final compressedFile = await GeneralUtil.compressImageFile(imageFile);
        return ref
            .read(reviewRepositoryProvider)
            .uploadReviewImage(compressedFile, userId);
      });

      return await Future.wait(uploadTasks);
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(errorKey: WriteReviewErrorKey.imageUploadFailed);
      return null;
    }
  }

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void addImages(List<File> images) {
    final currentImages = List<File>.from(state.selectedImages);
    final totalImages = currentImages.length + images.length;

    if (totalImages > 5) {
      state = state.copyWith(errorKey: WriteReviewErrorKey.tooManyImages);
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
