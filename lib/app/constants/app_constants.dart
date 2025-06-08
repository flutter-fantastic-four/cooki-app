import 'package:flutter/material.dart';

import '../../core/utils/general_util.dart';

class AppConstants {
  static const appTitle = 'Cooki';

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

  // Placeholder constants
  /// Placeholder for user's text input in prompt templates.
  static const String textInputPlaceholder = '__COOKI_TEXT_INPUT_PLACEHOLDER__';
  static const String textContextSectionPlaceholder = '__COOKI_TEXT_CONTEXT_SECTION__';
  static const String preferencesSectionPlaceholder = '__COOKI_PREFERENCES_SECTION__';
  static const String preferencesListPlaceholder = '__COOKI_PREFERENCES_LIST_PLACEHOLDER__';

  // Fixed paths for language-independent prompts
  static const String validationPromptPath = 'assets/prompts/validation.md';
  static const String preferencesTemplatePath = 'assets/prompts/preferences_section.md';
  static const String textContextTemplatePath = 'assets/prompts/text_context_section.md';
}
