class Review {
  final String id;
  final String recipeId;
  final String reviewText;
  final int rating; // 1-5 stars
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String userName;
  final String? userImageUrl;

  Review({
    required this.id,
    required this.recipeId,
    required this.reviewText,
    required this.rating,
    required this.imageUrls,
    DateTime? createdAt,
    this.updatedAt,
    required this.userId,
    required this.userName,
    this.userImageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  Review copyWith({
    String? id,
    String? recipeId,
    String? reviewText,
    int? rating,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? userName,
    String? userImageUrl,
  }) {
    return Review(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
    );
  }

  @override
  String toString() {
    return 'Review{id: $id, recipeId: $recipeId, reviewText: $reviewText, rating: $rating, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, userName: $userName, userImageUrl: $userImageUrl}';
  }
}
