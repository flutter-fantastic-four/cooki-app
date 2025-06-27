import 'package:cooki/gen/l10n/app_localizations.dart';

enum RecipeCategory {
  korean,
  chinese,
  japanese,
  thai,
  indian,
  american,
  french,
  italian,
  mediterranean,
  middleEastern,
  mexican,
  southeastAsian,
  african,
  other;

  String getLabel(AppLocalizations strings) {
    switch (this) {
      case RecipeCategory.korean:
        return strings.recipeCategoryKorean;
      case RecipeCategory.chinese:
        return strings.recipeCategoryChinese;
      case RecipeCategory.japanese:
        return strings.recipeCategoryJapanese;
      case RecipeCategory.thai:
        return strings.recipeCategoryThai;
      case RecipeCategory.indian:
        return strings.recipeCategoryIndian;
      case RecipeCategory.american:
        return strings.recipeCategoryAmerican;
      case RecipeCategory.french:
        return strings.recipeCategoryFrench;
      case RecipeCategory.italian:
        return strings.recipeCategoryItalian;
      case RecipeCategory.mediterranean:
        return strings.recipeCategoryMediterranean;
      case RecipeCategory.middleEastern:
        return strings.recipeCategoryMiddleEastern;
      case RecipeCategory.mexican:
        return strings.recipeCategoryMexican;
      case RecipeCategory.southeastAsian:
        return strings.recipeCategorySoutheastAsian;
      case RecipeCategory.african:
        return strings.recipeCategoryAfrican;
      case RecipeCategory.other:
        return strings.recipeCategoryOther;
    }
  }

  static RecipeCategory? fromLabel(
    String label,
    AppLocalizations strings,
  ) {
    for (final category in RecipeCategory.values) {
      if (category.getLabel(strings) == label) {
        return category;
      }
    }
    return null;
  }

  static RecipeCategory? fromName(String name) {
    for (final category in RecipeCategory.values) {
      if (category.name == name) {
        return category;
      }
    }
    return null;
  }
}
