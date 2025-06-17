class Review {
  final String id;
  final String reviewText;
  final int rating; // 1-5 stars
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final bool isDeleted;

  Review({
    required this.id,
    required this.reviewText,
    required this.rating,
    required this.imageUrls,
    DateTime? createdAt,
    this.updatedAt,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    this.isDeleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Review copyWith({
    String? id,
    String? reviewText,
    int? rating,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? userName,
    String? userImageUrl,
    bool? isDeleted,
  }) {
    return Review(
      id: id ?? this.id,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Review{id: $id, reviewText: $reviewText, rating: $rating, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, userName: $userName, userImageUrl: $userImageUrl}';
  }
}
