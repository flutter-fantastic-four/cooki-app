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
  final String userProfileImage;
  final bool isPublic;
  final String? imageUrl;
  final DateTime createdAt;

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
    required this.userProfileImage,
    required this.isPublic,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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
    );
  }
}
