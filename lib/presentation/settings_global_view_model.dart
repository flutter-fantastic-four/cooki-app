import 'dart:ui';
import 'package:cooki/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SupportedLanguage {
  korean('ko', '한국어'),
  english('en', 'English');

  const SupportedLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  static SupportedLanguage fromCode(String code) {
    for (final language in SupportedLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }
    return SupportedLanguage.korean; // Default fallback
  }
}

class SettingsState {
  final SupportedLanguage selectedLanguage;

  Locale get locale => Locale(selectedLanguage.code);

  const SettingsState({required this.selectedLanguage});

  SettingsState copyWith({SupportedLanguage? selectedLanguage}) {
    return SettingsState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class SettingsGlobalViewModel extends Notifier<SettingsState> {
  static const String _languageKey = 'selected_language';

  @override
  SettingsState build() {
    _loadSettings();
    // Default to device locale or Korean if not supported
    final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
    final defaultLanguage = SupportedLanguage.fromCode(deviceLocale);

    return SettingsState(selectedLanguage: defaultLanguage);
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        final language = SupportedLanguage.fromCode(languageCode);
        state = state.copyWith(selectedLanguage: language);
      }
    } catch (e, stack) {
      logError(e, stack);
      // If loading fails, keep the default language
    }
  }

  Future<void> changeLanguage(SupportedLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);

      state = state.copyWith(selectedLanguage: language);
    } catch (e, stack) {
      logError(e, stack);
      rethrow;
    }
  }

  SupportedLanguage getCurrentLanguage() {
    return state.selectedLanguage;
  }
}

final settingsGlobalViewModelProvider =
    NotifierProvider<SettingsGlobalViewModel, SettingsState>(
      SettingsGlobalViewModel.new,
    );
