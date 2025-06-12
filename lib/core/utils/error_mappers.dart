import 'package:flutter/material.dart';

import 'general_util.dart';

enum RecipeValidationErrorKey {
  titleRequired,
  titleTooShort,
  categoryRequired,
  ingredientEmpty,
  stepEmpty,
  required,
}

class ErrorMapper {
  static String mapGenerateRecipeError(
    BuildContext context,
    SaveRecipeErrorKey key,
  ) {
    final s = strings(context);
    switch (key) {
      case SaveRecipeErrorKey.invalidUserInput:
        return s.invalidUserInputError;
      case SaveRecipeErrorKey.invalidImage:
        return s.invalidImageError;
      case SaveRecipeErrorKey.generationFailed:
        return s.generationFailedError;
      case SaveRecipeErrorKey.saveFailed:
        return s.recipeSaveFailedError;
    }
  }
}
