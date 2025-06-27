import 'package:cooki/gen/l10n/app_localizations.dart';

import '../../data/data_source/review_data_source.dart';
import '../../domain/entity/recipe_category.dart';
import '../../domain/entity/sort_option.dart';

class AppConstants {
  static const appTitle = 'Cooki';

  static List<SortOption> getSortOptions() {
    return [
      SortOption(
        labelGetter: (strings) => strings.newestFirst,
        type: ReviewSortType.dateDescending,
      ),
      SortOption(
        labelGetter: (strings) => strings.highestRating,
        type: ReviewSortType.ratingDescending,
      ),
      SortOption(
        labelGetter: (strings) => strings.lowestRating,
        type: ReviewSortType.ratingAscending,
      ),
    ];
  }

  static List<String> recipePreferences(AppLocalizations strings) {
    return [
      strings.recipePreferences_diet,
      strings.recipePreferences_vegetarian,
      strings.recipePreferences_vegan,
      strings.recipePreferences_noSpicy,
      strings.recipePreferences_noPeanuts,
      strings.recipePreferences_simple,
      strings.recipePreferences_under15Min,
      strings.recipePreferences_noMeat,
      strings.recipePreferences_noDairy,
      strings.recipePreferences_highProtein,
      strings.recipePreferences_lowCarb,
      strings.recipePreferences_kidFriendly,
    ];
  }

  static List<String> recipeCategories(AppLocalizations strings) {
    return RecipeCategory.values
        .map((category) => category.getLabel(strings))
        .toList();
  }

  static List<String> recipeTabCategories(AppLocalizations strings) {
    return [
      strings.recipeTabAll,
      strings.recipeTabCreated,
      strings.recipeTabSaved,
      strings.recipeTabShared,
    ];
  }

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
