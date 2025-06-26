import '../utils/error_mappers.dart';

class RecipeValidator {
  static RecipeValidationErrorKey? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return RecipeValidationErrorKey.titleRequired;
    }
    return null;
  }

  // static RecipeValidationErrorKey? validateCategory(String? category) {
  //   if (category == null || category.trim().isEmpty) {
  //     return RecipeValidationErrorKey.categoryRequired;
  //   }
  //   return null;
  // }

  static RecipeValidationErrorKey? validateIngredient(String? ingredient) {
    if (ingredient == null || ingredient.trim().isEmpty) {
      return RecipeValidationErrorKey.ingredientEmpty;
    }
    if (ingredient.trim().length < 2) {
      return RecipeValidationErrorKey.textTooShort;
    }
    return null;
  }

  static RecipeValidationErrorKey? validateStep(String? step) {
    if (step == null || step.trim().isEmpty) {
      return RecipeValidationErrorKey.stepEmpty;
    }
    if (step.trim().length < 2) {
      return RecipeValidationErrorKey.textTooShort;
    }
    return null;
  }

  static RecipeValidationErrorKey? validateGeneralNotEmpty(String? input) {
    if (input == null || input.trim().isEmpty) {
      return RecipeValidationErrorKey.required;
    }
    return null;
  }
}