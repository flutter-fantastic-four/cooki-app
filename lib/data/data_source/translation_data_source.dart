import 'package:cloud_functions/cloud_functions.dart';

import '../../core/exceptions/data_exceptions.dart';
import '../../domain/entity/translation_entities.dart';

abstract class TranslationDataSource {
  Future<TranslationResult> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  Future<LanguageDetectionResult> detectLanguage({required String text});
}

class TranslationFirebaseDataSource implements TranslationDataSource {
  final FirebaseFunctions _functions;

  TranslationFirebaseDataSource(this._functions);

  @override
  Future<TranslationResult> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final HttpsCallable callable = _functions.httpsCallable('translateText');

    final result = await callable.call({
      'text': text,
      'targetLanguage': targetLanguage,
      if (sourceLanguage != null) 'sourceLanguage': sourceLanguage,
    });

    if (result.data['success'] == true) {
      return TranslationResult(
        translatedText: result.data['translatedText'],
        detectedSourceLanguage: result.data['detectedSourceLanguage'],
      );
    } else {
      throw TranslationException(result.data['error'] ?? 'Translation failed');
    }
  }

  @override
  Future<LanguageDetectionResult> detectLanguage({required String text}) async {
    final HttpsCallable callable = _functions.httpsCallable('detectLanguage');

    final result = await callable.call({'text': text});

    if (result.data['success'] == true) {
      final detectedLanguages =
          (result.data['detectedLanguages'] as List)
              .map(
                (lang) => DetectedLanguage(
                  languageCode: lang['languageCode'],
                  confidence: lang['confidence'].toDouble(),
                ),
              )
              .toList();

      return LanguageDetectionResult(
        detectedLanguages: detectedLanguages,
        mostLikelyLanguage: result.data['mostLikelyLanguage'],
      );
    } else {
      throw TranslationException(
        result.data['error'] ?? 'Language detection failed',
      );
    }
  }
}
