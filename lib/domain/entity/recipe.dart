class Recipe {
  final String id;
  final String recipeName;
  final List<String> ingredients;
  final List<String> steps;
  final int cookTime;
  final int calories;
  final String category;
  final List<String> tags;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final bool isPublic;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? promptInput;
  final int ratingCount;
  final double ratingSum;
  final double ratingAverage;
  final int userRating;

  Recipe({
    required this.id,
    required this.recipeName,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.calories,
    required this.category,
    required this.tags,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.isPublic,
    this.imageUrl,
    DateTime? createdAt,
    this.updatedAt,
    this.promptInput,
    int? ratingCount,
    double? ratingSum,
    double? ratingAverage,
    int? userRating,
  }) : createdAt = createdAt ?? DateTime.now(),
        ratingCount = ratingCount ?? 0,
        ratingSum = ratingSum ?? 0,
        ratingAverage = ratingAverage ?? 0,
        userRating = userRating ?? 0;

  Recipe copyWith({
    String? id,
    String? recipeName,
    List<String>? ingredients,
    List<String>? steps,
    int? cookTime,
    int? calories,
    String? category,
    List<String>? tags,
    String? userId,
    String? userName,
    String? userProfileImage,
    bool? isPublic,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? promptInput,
    int? ratingCount,
    double? ratingSum,
    double? ratingAverage,
    int? userRating,
  }) {
    return Recipe(
      id: id ?? this.id,
      recipeName: recipeName ?? this.recipeName,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookTime: cookTime ?? this.cookTime,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      isPublic: isPublic ?? this.isPublic,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      promptInput: promptInput ?? this.promptInput,
      ratingCount: ratingCount ?? this.ratingCount,
      ratingSum: ratingSum ?? this.ratingSum,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      userRating: userRating ?? this.userRating,
    );
  }
}