import 'package:flutter/material.dart';
import 'general_util.dart';

/// Utility class for mapping recipe categories between languages
/// This ensures that categories are displayed in the app's current language
/// regardless of the language the recipe was originally created in
class CategoryMapper {
  // Normalized category keys (language-independent)
  static const String _korean = 'korean';
  static const String _chinese = 'chinese';
  static const String _japanese = 'japanese';
  static const String _thai = 'thai';
  static const String _indian = 'indian/desi';
  static const String _american = 'american';
  static const String _french = 'french';
  static const String _italian = 'italian';
  static const String _mediterranean = 'mediterranean';
  static const String _middleEastern = 'middle_eastern';
  static const String _mexican = 'mexican';
  static const String _southeastAsian = 'southeast_asian';
  static const String _african = 'african';
  static const String _other = 'other';

  /// Maps category strings to normalized keys
  static const Map<String, String> _categoryToKeyMap = {
    // English categories
    'Korean': _korean,
    'Chinese': _chinese,
    'Japanese': _japanese,
    'Thai': _thai,
    'Indian/Desi': _indian,
    'American': _american,
    'French': _french,
    'Italian': _italian,
    'Mediterranean': _mediterranean,
    'Middle Eastern': _middleEastern,
    'Mexican': _mexican,
    'Southeast Asian': _southeastAsian,
    'African': _african,
    'Other': _other,

    // Korean categories
    '한식': _korean,
    '중식': _chinese,
    '일식': _japanese,
    '태국식': _thai,
    '인도/남아시아식': _indian,
    '미국식': _american,
    '프랑스식': _french,
    '이탈리아식': _italian,
    '지중해식': _mediterranean,
    '중동식': _middleEastern,
    '멕시코식': _mexican,
    '동남아식': _southeastAsian,
    '아프리카식': _african,
    '기타': _other,
  };

  /// Gets the normalized key for a category string
  static String getCategoryKey(String category) {
    return _categoryToKeyMap[category] ?? _other;
  }

  /// Gets the localized category name for the current app language
  static String getLocalizedCategory(BuildContext context, String categoryKey) {
    final s = strings(context);
    switch (categoryKey) {
      case _korean:
        return s.recipeCategoryKorean;
      case _chinese:
        return s.recipeCategoryChinese;
      case _japanese:
        return s.recipeCategoryJapanese;
      case _thai:
        return s.recipeCategoryThai;
      case _indian:
        return s.recipeCategoryIndian;
      case _american:
        return s.recipeCategoryAmerican;
      case _french:
        return s.recipeCategoryFrench;
      case _italian:
        return s.recipeCategoryItalian;
      case _mediterranean:
        return s.recipeCategoryMediterranean;
      case _middleEastern:
        return s.recipeCategoryMiddleEastern;
      case _mexican:
        return s.recipeCategoryMexican;
      case _southeastAsian:
        return s.recipeCategorySoutheastAsian;
      case _african:
        return s.recipeCategoryAfrican;
      case _other:
      default:
        return s.recipeCategoryOther;
    }
  }

  /// Converts a recipe's stored category to the current app language
  static String translateCategoryToAppLanguage(
    BuildContext context,
    String recipeCategory,
  ) {
    final categoryKey = getCategoryKey(recipeCategory);
    return getLocalizedCategory(context, categoryKey);
  }

  /// Checks if a recipe's category matches a filter category in any language
  static bool doesCategoryMatch(String recipeCategory, String filterCategory) {
    final recipeCategoryKey = getCategoryKey(recipeCategory);
    final filterCategoryKey = getCategoryKey(filterCategory);
    return recipeCategoryKey == filterCategoryKey;
  }

  /// Gets all category keys for filtering purposes
  static List<String> getAllCategoryKeys() {
    return [
      _korean,
      _chinese,
      _japanese,
      _thai,
      _indian,
      _american,
      _french,
      _italian,
      _mediterranean,
      _middleEastern,
      _mexican,
      _southeastAsian,
      _african,
      _other,
    ];
  }
}
