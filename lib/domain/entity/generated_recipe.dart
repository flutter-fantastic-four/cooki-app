class GeneratedRecipe {
  final String recipeName;
  final List<String> ingredients;
  final List<String> steps;
  final int cookTime;
  final int calories;
  final String category;
  final List<String> tags;

  const GeneratedRecipe({
    required this.recipeName,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.calories,
    required this.category,
    required this.tags,
  });

  GeneratedRecipe copyWith({
    String? recipeName,
    List<String>? ingredients,
    List<String>? steps,
    int? cookTime,
    int? calories,
    String? category,
    List<String>? tags,
  }) {
    return GeneratedRecipe(
      recipeName: recipeName ?? this.recipeName,
      ingredients: ingredients ?? List.from(this.ingredients),
      steps: steps ?? List.from(this.steps),
      cookTime: cookTime ?? this.cookTime,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      tags: tags ?? List.from(this.tags),
    );
  }
}