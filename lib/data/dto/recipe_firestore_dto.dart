import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/recipe.dart';

class RecipeFirestoreDto {
  final String id;
  final String recipeName;
  final List<String> ingredients;
  final List<String> steps;
  final int calories;
  final int cookTime;
  final String category;
  final List<String> tags;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final bool isPublic;
  final String? imageUrl;
  final Timestamp createdAt;

  const RecipeFirestoreDto({
    required this.id,
    required this.recipeName,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.cookTime,
    required this.category,
    required this.tags,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.isPublic,
    required this.createdAt,
    this.imageUrl,
  });

  factory RecipeFirestoreDto.fromMap(String id, Map<String, dynamic> map) {
    return RecipeFirestoreDto(
      id: id,
      recipeName: map['recipeName'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      calories: map['calories'] ?? 0,
      cookTime: map['cookTime'] ?? 0,
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'],
      isPublic: map['isPublic'] ?? false,
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeName': recipeName,
      'ingredients': ingredients,
      'steps': steps,
      'calories': calories,
      'cookTime': cookTime,
      'category': category,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  factory RecipeFirestoreDto.fromEntity(Recipe recipe) {
    return RecipeFirestoreDto(
      id: recipe.id,
      recipeName: recipe.recipeName,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      calories: recipe.calories,
      cookTime: recipe.cookTime,
      category: recipe.category,
      tags: recipe.tags,
      userId: recipe.userId,
      userName: recipe.userName,
      userProfileImage: recipe.userProfileImage,
      isPublic: recipe.isPublic,
      imageUrl: recipe.imageUrl,
      createdAt: Timestamp.fromDate(recipe.createdAt),
    );
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      recipeName: recipeName,
      ingredients: ingredients,
      steps: steps,
      cookTime: cookTime,
      calories: calories,
      category: category,
      tags: tags,
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      isPublic: isPublic,
      imageUrl: imageUrl,
      createdAt: createdAt.toDate(),
    );
  }
}
