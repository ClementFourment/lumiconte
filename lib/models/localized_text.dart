import 'package:lumiconte/models/app_language.dart';

/// Texte traduit par langue : { "fr": "...", "en": "..." }.
/// Firestore peut encore contenir l'ancien format (une simple chaîne) :
/// il est alors rangé en français.
class LocalizedText {
  final Map<String, String> values;

  const LocalizedText(this.values);

  const LocalizedText.empty() : values = const {};

  factory LocalizedText.fromAny(dynamic raw) {
    if (raw is String) return LocalizedText({defaultLanguage: raw});
    if (raw is Map) {
      return LocalizedText({
        for (final entry in raw.entries)
          if (entry.value is String) entry.key.toString(): entry.value as String,
      });
    }
    return const LocalizedText.empty();
  }

  /// Langue pivot : elle sert de repli quand la traduction demandée manque.
  static const String defaultLanguage = AppLanguage.defaultCode;

  /// Traduction demandée, sinon le français, sinon la première traduction
  /// renseignée : mieux vaut un titre dans une autre langue qu'un blanc.
  String of(String? language) {
    for (final lang in [language, defaultLanguage]) {
      final text = lang == null ? null : values[lang];
      if (text != null && text.trim().isNotEmpty) return text;
    }
    for (final text in values.values) {
      if (text.trim().isNotEmpty) return text;
    }
    return '';
  }

  /// Traduction dans la langue de lecture du profil. Les écrans qui affichent
  /// un titre n'ont pas les réglages sous la main : ils passent par les
  /// getters `display...` des modèles.
  String get display => of(AppLanguage.current.value);

  /// Vrai quand aucune langue n'est renseignée.
  bool get isEmpty => of(null).isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toMap() => Map<String, String>.from(values);
}
