import 'dart:typed_data';

class GeneratedRecipe {
  final String recipeName;
  final List<String> ingredients;
  final List<String> steps;
  final int cookTime;
  final int calories;
  final String category;
  final List<String> tags;
  final Uint8List? imageBytes;

  const GeneratedRecipe({
    required this.recipeName,
    required this.ingredients,
    required this.steps,
    required this.cookTime,
    required this.calories,
    required this.category,
    required this.tags,
    this.imageBytes,
  });

  bool get isError {
    return recipeName == "__ERROR__" ||
        recipeName.isEmpty ||
        calories == -1 ||
        cookTime == -1 ||
        ingredients.isEmpty ||
        steps.isEmpty;
  }

  GeneratedRecipe copyWith({
    String? recipeName,
    List<String>? ingredients,
    List<String>? steps,
    int? cookTime,
    int? calories,
    String? category,
    List<String>? tags,
    Uint8List? imageBytes,
  }) {
    return GeneratedRecipe(
      recipeName: recipeName ?? this.recipeName,
      ingredients: ingredients ?? List.from(this.ingredients),
      steps: steps ?? List.from(this.steps),
      cookTime: cookTime ?? this.cookTime,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      tags: tags ?? List.from(this.tags),
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  @override
  String toString() {
    return '{\n'
        '  "recipeName": "$recipeName",\n'
        '  "ingredients": [${ingredients.map((e) => '"$e"').join(', ')}],\n'
        '  "steps": [${steps.map((e) => '"$e"').join(', ')}],\n'
        '  "cookTime": $cookTime,\n'
        '  "calories": $calories,\n'
        '  "category": "$category",\n'
        '  "tags": [${tags.map((e) => '"$e"').join(', ')}]\n'
        '}';
  }
}
