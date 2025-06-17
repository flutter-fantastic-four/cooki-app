import 'package:flutter/material.dart';

import '../../core/utils/general_util.dart';
import '../../data/data_source/review_data_source.dart';

class SortOption {
  final ReviewSortType type;
  final String Function(BuildContext) labelGetter;

  const SortOption({
    required this.type,
    required this.labelGetter,
  });

  String getLabel(BuildContext context) => labelGetter(context);
}

class AppConstants {
  static const appTitle = 'Cooki';

  static List<SortOption> getSortOptions() {
    return [
      SortOption(
        labelGetter: (context) => strings(context).newestFirst,
        type: ReviewSortType.dateDescending,
      ),
      SortOption(
        labelGetter: (context) => strings(context).highestRating,
        type: ReviewSortType.ratingDescending,
      ),
      SortOption(
        labelGetter: (context) => strings(context).lowestRating,
        type: ReviewSortType.ratingAscending,
      ),
    ];
  }

  static List<String> recipePreferences(BuildContext context) {
    final s = strings(context);
    return [
      s.recipePreferences_diet,
      s.recipePreferences_vegetarian,
      s.recipePreferences_vegan,
      s.recipePreferences_noSpicy,
      s.recipePreferences_noPeanuts,
      s.recipePreferences_simple,
      s.recipePreferences_under15Min,
      s.recipePreferences_noMeat,
      s.recipePreferences_noDairy,
      s.recipePreferences_highProtein,
      s.recipePreferences_lowCarb,
      s.recipePreferences_kidFriendly,
    ];
  }

  static List<String> recipeCategories(BuildContext context) {
    final s = strings(context);
    return [
      s.recipeCategoryKorean,
      s.recipeCategoryChinese,
      s.recipeCategoryJapanese,
      s.recipeCategoryThai,
      s.recipeCategoryIndian,
      s.recipeCategoryAmerican,
      s.recipeCategoryFrench,
      s.recipeCategoryItalian,
      s.recipeCategoryMediterranean,
      s.recipeCategoryMiddleEastern,
      s.recipeCategoryMexican,
      s.recipeCategorySoutheastAsian,
      s.recipeCategoryAfrican,
      s.recipeCategoryOther,
    ];
  }

  static List<String> recipeTabCategories(BuildContext context) {
    // For now using hardcoded strings, should be moved to localization
    return ['전체', '생성한 레시피', '저장한 레시피', '공유한 레시피'];
  }

  static List<String> recipeSortOptions(BuildContext context) {
    // For now using hardcoded strings, should be moved to localization
    return ['별점순', '조리시간 빠른 순'];
  }

  // Recipe tab category constants
  static const String recipeTabAll = '전체';
  static const String recipeTabCreated = '생성한 레시피';
  static const String recipeTabSaved = '저장한 레시피';
  static const String recipeTabShared = '공유한 레시피';

  // Sort option constants
  static const String sortByRating = '별점순';
  static const String sortByCookTimeAsc = '조리시간 빠른 순';

  // Placeholder constants
  /// Placeholder for user's text input in prompt templates.
  static const String textInputPlaceholder = '__COOKI_TEXT_INPUT_PLACEHOLDER__';
  static const String textContextSectionPlaceholder =
      '__COOKI_TEXT_CONTEXT_SECTION__';
  static const String preferencesSectionPlaceholder =
      '__COOKI_PREFERENCES_SECTION__';
  static const String preferencesListPlaceholder =
      '__COOKI_PREFERENCES_LIST_PLACEHOLDER__';

  // Fixed paths for language-independent prompts
  static const String validationPromptPath = 'assets/prompts/validation.md';
  static const String preferencesTemplatePath =
      'assets/prompts/preferences_section.md';
  static const String textContextTemplatePath =
      'assets/prompts/text_context_section.md';
}
