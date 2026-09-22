import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumiconte/l10n/app_localizations.dart';

/// Une langue proposée dans les réglages du profil.
///
/// [code] est la clé utilisée partout : les textes par langue dans Firestore
/// (`name: { fr: ..., de: ... }`), les voix (`audio: { de_femme: ... }`), les
/// traductions de l'interface (`lib/l10n/app_de.arb`) et la langue Flutter.
class AppLanguage {
  final String code;

  /// Nom de la langue écrit dans cette langue : un parent italien cherche
  /// « Italiano », pas « Italien ».
  final String label;

  const AppLanguage({required this.code, required this.label});

  /// Langues proposées dans les réglages, dans l'ordre d'affichage.
  static const List<AppLanguage> supported = [
    AppLanguage(code: 'de', label: 'Deutsch'),
    AppLanguage(code: 'en', label: 'English'),
    AppLanguage(code: 'es', label: 'Español'),
    AppLanguage(code: 'fr', label: 'Français'),
    AppLanguage(code: 'it', label: 'Italiano'),
    AppLanguage(code: 'ja', label: '日本語'),
  ];

  /// Langue de repli, celle des contes d'origine.
  static const String defaultCode = 'fr';

  /// Langue Flutter correspondant à ce code.
  Locale get locale => Locale(code);

  static List<String> get codes => [for (final l in supported) l.code];

  static bool isSupported(String? code) => codes.contains(code);

  /// Langue du code donné, le français si le code est inconnu : un réglage
  /// resté d'une ancienne version ne doit pas casser l'affichage.
  static AppLanguage of(String? code) => supported.firstWhere(
        (l) => l.code == code,
        orElse: () => supported.firstWhere((l) => l.code == defaultCode),
      );

  /// Code utilisable tel quel, le français si celui donné est inconnu.
  static String sanitize(String? code) =>
      isSupported(code) ? code! : defaultCode;

  /// Langue Flutter correspondant à un code de la base.
  static Locale localeOf(String? code) => of(code).locale;

  /// Langues proposées à Flutter pour traduire l'app.
  static List<Locale> get supportedLocales =>
      [for (final l in supported) l.locale];

  /// Langue du profil en cours de lecture, alignée sur ses réglages par
  /// StoryQueuePlayer.followLanguage. Observable : l'app se retraduit et les
  /// titres des contes changent de langue sans rouvrir l'écran.
  static final ValueNotifier<String> current =
      ValueNotifier<String>(defaultCode);

  /// Clé du dernier choix, pour retrouver la bonne langue dès l'ouverture.
  static const String _storageKey = 'app_language';

  /// Change la langue de lecture, et s'en souvient pour la prochaine ouverture.
  /// Un code inconnu retombe sur le français.
  static void select(String? code) {
    final language = sanitize(code);
    if (language == current.value) return;
    current.value = language;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_storageKey, language))
        .catchError((e) {
      debugPrint('Langue non mémorisée : $e');
      return false;
    });
  }

  /// Langue à utiliser avant qu'un profil soit choisi.
  ///
  /// L'écran de sélection des profils s'affiche avant tout profil, donc avant
  /// que ses réglages n'existent : sans ça, il restait en français même pour
  /// une famille qui avait tout mis en allemand. On reprend le dernier choix,
  /// sinon la langue du téléphone si on la propose, sinon le français.
  static Future<void> restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_storageKey);
      if (isSupported(saved)) {
        current.value = saved!;
        return;
      }
    } catch (e) {
      debugPrint('Langue mémorisée illisible : $e');
    }
    final deviceCode = PlatformDispatcher.instance.locale.languageCode;
    current.value = sanitize(deviceCode);
  }

  /// Textes traduits hors de l'arbre des widgets : notification audio, badges
  /// attribués en tâche de fond... Les écrans, eux, utilisent
  /// `AppLocalizations.of(context)`, qui suit le rebuild de MaterialApp.
  static AppLocalizations get texts =>
      lookupAppLocalizations(localeOf(current.value));
}
