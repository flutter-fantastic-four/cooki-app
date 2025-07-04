import 'dart:io';
import 'package:cooki/data/dto/review_dto.dart';

import '../../domain/entity/review/review.dart';
import '../../domain/entity/review/review_sort_type.dart';
import '../../domain/entity/translation_entities.dart';
import '../data_source/image_storage_data_source.dart';
import '../data_source/review_data_source.dart';
import '../data_source/translation_data_source.dart';

abstract class ReviewRepository {
  Future<String> saveReview({required String recipeId, required Review review});

  Future<void> editReview({required String recipeId, required Review review});

  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  });

  Future<List<Review>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  });

  Future<List<Review>> getRecentReviewsByRecipeId(
    String recipeId, {
    int limit = 5,
  });

  Future<Review?> getUserReviewForRecipe({
    required String recipeId,
    required String userId,
  });

  Future<String> uploadReviewImage(File imageFile, String uid);

  Future<TranslationResult> translateReviewText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  Future<LanguageDetectionResult> detectReviewLanguage({required String text});
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource _reviewDataSource;
  final ImageStorageDataSource _imageStorageDataSource;
  final TranslationDataSource _translationDataSource;

  ReviewRepositoryImpl(
    this._reviewDataSource,
    this._imageStorageDataSource,
    this._translationDataSource,
  );

  @override
  Future<String> saveReview({
    required String recipeId,
    required Review review,
  }) async {
    return await _reviewDataSource.saveReview(
      recipeId: recipeId,
      reviewDto: ReviewDto.fromEntity(review),
    );
  }

  @override
  Future<void> editReview({
    required String recipeId,
    required Review review,
  }) async {
    await _reviewDataSource.editReview(
      recipeId: recipeId,
      reviewDto: ReviewDto.fromEntity(review),
    );
  }

  @override
  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  }) async {
    await _reviewDataSource.deleteReview(
      recipeId: recipeId,
      reviewId: reviewId,
    );
  }

  @override
  Future<List<Review>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  }) async {
    final reviewDtoList = await _reviewDataSource.getReviewsByRecipeId(
      recipeId,
      sortType: sortType,
      limit: limit,
    );
    return reviewDtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<Review>> getRecentReviewsByRecipeId(
    String recipeId, {
    int limit = 5,
  }) async {
    final reviewDtoList = await _reviewDataSource.getReviewsByRecipeId(
      recipeId,
      limit: limit,
      sortType: ReviewSortType.dateDescending,
    );
    return reviewDtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Review?> getUserReviewForRecipe({
    required String recipeId,
    required String userId,
  }) async {
    final reviewDto = await _reviewDataSource.getUserReviewForRecipe(
      recipeId: recipeId,
      userId: userId,
    );
    return reviewDto?.toEntity();
  }

  @override
  Future<String> uploadReviewImage(File imageFile, String uid) async {
    return await _imageStorageDataSource.uploadImageFile(
      imageFile,
      uid,
      'review_images',
    );
  }

  @override
  Future<TranslationResult> translateReviewText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    return await _translationDataSource.translateText(
      text: text,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
    );
  }

  @override
  Future<LanguageDetectionResult> detectReviewLanguage({
    required String text,
  }) async {
    return await _translationDataSource.detectLanguage(text: text);
  }
}
