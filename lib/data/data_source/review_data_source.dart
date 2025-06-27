import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/review/review_sort_type.dart';
import '../dto/review_dto.dart';

abstract class ReviewDataSource {
  Future<String> saveReview({
    required String recipeId,
    required ReviewDto reviewDto,
  });

  Future<void> editReview({
    required String recipeId,
    required ReviewDto reviewDto,
  });

  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  });

  Future<List<ReviewDto>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  });

  Future<ReviewDto?> getUserReviewForRecipe({
    required String recipeId,
    required String userId,
  });
}

class ReviewFirestoreDataSource implements ReviewDataSource {
  final FirebaseFirestore _firestore;

  ReviewFirestoreDataSource(this._firestore);

  @override
  Future<String> saveReview({
    required String recipeId,
    required ReviewDto reviewDto,
  }) async {
    final reviewData =
        reviewDto.toMap()..['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .add(reviewData);
    return docRef.id;
  }

  @override
  Future<void> editReview({
    required String recipeId,
    required ReviewDto reviewDto,
  }) async {
    final reviewData =
        reviewDto.toMap()..['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(reviewDto.id)
        .update(reviewData);
  }

  @override
  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  }) async {
    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(reviewId)
        .update({'isDeleted': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<List<ReviewDto>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  }) async {
    var query = _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('isDeleted', isEqualTo: false);

    switch (sortType) {
      case ReviewSortType.dateDescending:
        query = query.orderBy('createdAt', descending: true);
        break;
      case ReviewSortType.ratingAscending:
        query = query.orderBy('rating', descending: false);
        break;
      case ReviewSortType.ratingDescending:
        query = query.orderBy('rating', descending: true);
        break;
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => ReviewDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<ReviewDto?> getUserReviewForRecipe({
    required String recipeId,
    required String userId,
  }) async {
    final querySnapshot =
        await _firestore
            .collection('recipes')
            .doc(recipeId)
            .collection('reviews')
            .where('userId', isEqualTo: userId)
            .where('isDeleted', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) return null;

    return ReviewDto.fromMap(
      querySnapshot.docs.first.id,
      querySnapshot.docs.first.data(),
    );
  }
}
