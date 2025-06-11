import 'package:flutter/material.dart';

import '../../presentation/pages/generate/generate_recipe_view_model.dart';
import 'general_util.dart';

class ErrorMapper {
  static String mapGenerateRecipeError(
    BuildContext context,
    GenerateRecipeErrorKey key,
  ) {
    final s = strings(context);
    switch (key) {
      case GenerateRecipeErrorKey.invalidUserInput:
        return s.invalidUserInputError;
      case GenerateRecipeErrorKey.invalidImage:
        return s.invalidImageError;
      case GenerateRecipeErrorKey.generationFailed:
        return s.generationFailedError;
      case GenerateRecipeErrorKey.saveFailed:
        return s.recipeSaveFailedError;
    }
  }
}
