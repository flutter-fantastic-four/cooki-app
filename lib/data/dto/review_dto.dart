import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/review.dart';

class ReviewDto {
  final String id;
  final String recipeId;
  final String reviewText;
  final int rating;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String userId;
  final String userName;
  final String? userImageUrl;

  const ReviewDto({
    required this.id,
    required this.recipeId,
    required this.reviewText,
    required this.rating,
    required this.imageUrls,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.userName,
    this.userImageUrl,
  });

  factory ReviewDto.fromMap(String id, Map<String, dynamic> map) {
    return ReviewDto(
      id: id,
      recipeId: map['recipeId'] ?? '',
      reviewText: map['reviewText'] ?? '',
      rating: map['rating'] ?? 1,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImageUrl: map['userImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'reviewText': reviewText,
      'rating': rating,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
    };
  }

  factory ReviewDto.fromEntity(Review review) {
    return ReviewDto(
      id: review.id,
      recipeId: review.recipeId,
      reviewText: review.reviewText,
      rating: review.rating,
      imageUrls: review.imageUrls,
      createdAt: Timestamp.fromDate(review.createdAt),
      updatedAt: review.updatedAt != null
          ? Timestamp.fromDate(review.updatedAt!)
          : null,
      userId: review.userId,
      userName: review.userName,
      userImageUrl: review.userImageUrl,
    );
  }

  Review toEntity() {
    return Review(
      id: id,
      recipeId: recipeId,
      reviewText: reviewText,
      rating: rating,
      imageUrls: imageUrls,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
    );
  }
}