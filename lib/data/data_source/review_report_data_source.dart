import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/report_dto.dart';

abstract class ReviewReportDataSource {
  Future<String> createReport({
    required String recipeId,
    required String reviewId,
    required ReportDto reportDto,
  });

  // Future<bool> hasUserReportedReview({
  //   required String recipeId,
  //   required String reviewId,
  //   required String userId,
  // });
}

class ReviewReportFirestoreDataSource implements ReviewReportDataSource {
  final FirebaseFirestore _firestore;

  ReviewReportFirestoreDataSource(this._firestore);

  @override
  Future<String> createReport({
    required String recipeId,
    required String reviewId,
    required ReportDto reportDto,
  }) async {
    // // Check if user already reported this review
    // final existingReport = await hasUserReportedReview(
    //   recipeId: recipeId,
    //   reviewId: reviewId,
    //   userId: reportDto.reporterId,
    // );
    // if (existingReport) {
    //   throw Exception('User has already reported this review');
    // }

    final reportData = reportDto.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(reviewId)
        .collection('reports')
        .add(reportData);

    return docRef.id;
  }

  // @override
  // Future<bool> hasUserReportedReview({
  //   required String recipeId,
  //   required String reviewId,
  //   required String userId,
  // }) async {
  //   final querySnapshot = await _firestore
  //       .collection('recipes')
  //       .doc(recipeId)
  //       .collection('reviews')
  //       .doc(reviewId)
  //       .collection('reports')
  //       .where('reporterId', isEqualTo: userId)
  //       .where('isDeleted', isEqualTo: false)
  //       .limit(1)
  //       .get();
  //
  //   return querySnapshot.docs.isNotEmpty;
  // }
}