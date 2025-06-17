import 'package:flutter/material.dart';

import 'general_util.dart';

enum SaveRecipeErrorKey {
  invalidUserInput,
  invalidImage,
  generationFailed,
  saveFailed,
  categoryEmpty,
}

enum RecipeValidationErrorKey {
  titleRequired,
  textTooShort,
  ingredientEmpty,
  stepEmpty,
  required,
}

enum ReviewsErrorKey {
  loadFailed,
  deleteFailed,
}

enum WriteReviewErrorKey { tooManyImages, saveFailed, imageUploadFailed }

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
      case SaveRecipeErrorKey.categoryEmpty:
        return s.categoryRequiredError;
    }
  }

  static String? mapRecipeValidationError(
    BuildContext context,
    RecipeValidationErrorKey? key,
  ) {
    final s = strings(context);
    switch (key) {
      case RecipeValidationErrorKey.titleRequired:
        return s.recipeTitleRequiredError;
      case RecipeValidationErrorKey.textTooShort:
        return s.textTooShortError;
      // case RecipeValidationErrorKey.categoryRequired:
      //   return s.categoryRequiredError;
      case RecipeValidationErrorKey.ingredientEmpty:
        return s.ingredientEmptyError;
      case RecipeValidationErrorKey.stepEmpty:
        return s.stepEmptyError;
      case RecipeValidationErrorKey.required:
        return s.requiredError;
      case null:
        return null;
    }
  }

  static String mapWriteReviewError(BuildContext context, WriteReviewErrorKey key) {
    final s = strings(context);
    switch (key) {
      // case AddReviewErrorKey.ratingRequired:
      //   return s.ratingRequiredError;
      case WriteReviewErrorKey.tooManyImages:
        return s.tooManyImagesError;
      case WriteReviewErrorKey.saveFailed:
        return s.saveFailedError;
      case WriteReviewErrorKey.imageUploadFailed:
        return s.imageUploadFailedError;
    }
  }

  static String mapReviewsPageError(BuildContext context, ReviewsErrorKey errorKey) {
    final s = strings(context);
    switch (errorKey) {
      case ReviewsErrorKey.loadFailed:
        return s.reviewsLoadFailedError;
      case ReviewsErrorKey.deleteFailed:
        return s.reviewDeleteFailedError;
    }
  }
}
