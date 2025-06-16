import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/review_dto.dart';

enum ReviewSortType { dateDescending, ratingAscending, ratingDescending }

abstract class ReviewDataSource {
  Future<String> saveReview(ReviewDto review);

  Future<void> editReview(ReviewDto reviewDto);

  Future<void> deleteReview(String reviewId);

  Future<List<ReviewDto>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  });
}

class ReviewFirestoreDataSource implements ReviewDataSource {
  final FirebaseFirestore _firestore;

  ReviewFirestoreDataSource(this._firestore);

  @override
  Future<String> saveReview(ReviewDto reviewDto) async {
    final docRef = await _firestore
        .collection('reviews')
        .add(reviewDto.toMap());
    return docRef.id;
  }

  @override
  Future<void> editReview(ReviewDto reviewDto) async {
    await _firestore
        .collection('reviews')
        .doc(reviewDto.id)
        .update(reviewDto.toMap());
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'deleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<ReviewDto>> getReviewsByRecipeId(
    String recipeId, {
    ReviewSortType sortType = ReviewSortType.dateDescending,
    int? limit,
  }) async {
    var query = _firestore
        .collection('reviews')
        .where('recipeId', isEqualTo: recipeId)
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
}
