import '../../app/constants/app_constants.dart';

class PromptUtil {
  static String buildValidatePrompt(String textInput) {
    return AppConstants.validationPrompt.replaceAll(
      AppConstants.textInputPlaceholder,
      textInput,
    );
  }

  static String buildRecipePrompt(
    String? textInput,
    List<String>? preferences,
    bool hasImage,
  ) {
    if (hasImage) {
      String imagePrompt = AppConstants.imageRecipePrompt;

      final textContextSection =
          textInput?.isNotEmpty == true
              ? AppConstants.textContextTemplate.replaceAll(
                AppConstants.textInputPlaceholder,
                textInput!,
              )
              : '';
      imagePrompt = imagePrompt.replaceAll(
        AppConstants.textContextSectionPlaceholder,
        textContextSection,
      );
      final preferencesSection = _buildPreferencesSection(preferences);
      imagePrompt = imagePrompt.replaceAll(
        AppConstants.preferencesSectionPlaceholder,
        preferencesSection,
      );

      return imagePrompt;
    } else {
      String textPrompt = AppConstants.textOnlyRecipePrompt;

      textPrompt = textPrompt.replaceAll(
        AppConstants.textInputPlaceholder,
        textInput!,
      );
      final preferencesSection = _buildPreferencesSection(preferences);
      textPrompt = textPrompt.replaceAll(
        AppConstants.preferencesSectionPlaceholder,
        preferencesSection,
      );

      return textPrompt;
    }
  }

  static String _buildPreferencesSection(List<String>? preferences) {
    if (preferences?.isNotEmpty == true) {
      return AppConstants.preferencesTemplate.replaceAll(
        AppConstants.preferencesListPlaceholder,
        preferences!.join(', '),
      );
    }
    return '';
  }
}
