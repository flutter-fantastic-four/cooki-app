// Data models for translation results

class TranslationResult {
  final String translatedText;
  final String? detectedSourceLanguage;

  const TranslationResult({
    required this.translatedText,
    this.detectedSourceLanguage,
  });
}

class LanguageDetectionResult {
  final List<DetectedLanguage> detectedLanguages;
  final String? mostLikelyLanguage;

  const LanguageDetectionResult({
    required this.detectedLanguages,
    this.mostLikelyLanguage,
  });
}

class DetectedLanguage {
  final String languageCode;
  final double confidence;

  const DetectedLanguage({
    required this.languageCode,
    required this.confidence,
  });
}
