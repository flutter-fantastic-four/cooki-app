import '../../domain/entity/generated_recipe.dart';

class GeneratedRecipeDto {
  final String recipeName;
  final List<String> ingredients;
  final List<String> steps;
  final int cookTime;
  final int calories;
  final String category;
  final List<String> tags;

  const GeneratedRecipeDto({
    required this.recipeName,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.calories,
    required this.category,
    required this.tags,
  });

  factory GeneratedRecipeDto.fromJson(Map<String, dynamic> json) {
    return GeneratedRecipeDto(
      recipeName: json['recipeName'] as String,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      cookTime: json['cookTime'] as int,
      calories: json['calories'] as int,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  GeneratedRecipe toEntity() {
    return GeneratedRecipe(
      recipeName: recipeName,
      ingredients: ingredients,
      steps: steps,
      cookTime: cookTime,
      calories: calories,
      category: category,
      tags: tags,
    );
  }
}
