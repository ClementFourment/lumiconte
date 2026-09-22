import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Toute chaîne littérale du code, quelle que soit sa position.
///
/// Chercher uniquement les emplacements connus (`Text(`, `label:`…) laissait
/// passer les arguments positionnels des constructeurs maison, du genre
/// `_buildSwitchTile(context, 'Mode nuit', …)`. On inspecte donc toutes les
/// chaînes et on écarte ensuite celles qui ne sont pas du texte affiché.
final _singleQuoted = RegExp(r"'((?:[^'\\\n]|\\.)*)'");
final _doubleQuoted = RegExp(r'"((?:[^"\\\n]|\\.)*)"');

/// Lignes dont les chaînes ne sont jamais affichées telles quelles.
final _ignoredLine = RegExp(
  r'^\s*(//|import |export |part )'
  r'|debugPrint|print\(|throw |Exception\(|RegExp\(|assert\('
  // Noms de polices et de familles : des valeurs, pas du texte affiché
  r'|fontFamily:|fontFamilyFallback:',
);

/// Chaînes qui ne sont pas du texte d'interface, malgré les apparences.
/// Chaque exemption est justifiée : sans ça, la liste se remplit de silence.
const _allowedLiterals = {
  // Nom du canal Android, fixé au démarrage avant que les traductions existent
  'Lumiconte Audio Playback',
  // Plateforme enregistrée avec un commentaire, pas affichée
  'Android/iOS',
  // Fuseau horaire de repli quand le système n'en donne pas
  'Europe/Paris',
};

/// Chaînes techniques : identifiants, clés Firestore, chemins, formats.
bool _isTechnical(String text) {
  if (_allowedLiterals.contains(text.trim())) return true;
  // Format de debug d'un toString() : « Modele(champ: $valeur, … ) »
  if (text.contains(': \$')) return true;
  // Morceau d'interpolation coupé en plusieurs chaînes
  if (text.trimLeft().startsWith('}') || text.trimRight().endsWith('\${')) {
    return true;
  }
  final trimmed = text.trim();
  if (trimmed.length < 3) return true;

  // identifiant_en_minuscules, camelCase, CONSTANTE — mais surtout pas un mot
  // isolé qui commence par une majuscule : « Envoyer » est du texte affiché,
  // et cette nuance a laissé passer plusieurs boutons.
  if (RegExp(r'^[a-z][a-zA-Z0-9_]*$').hasMatch(trimmed) ||
      RegExp(r'^[A-Z][A-Z0-9_]+$').hasMatch(trimmed)) {
    return true;
  }
  if (RegExp(r'^(assets/|audio/|package:|https?:|drawable|@|#|/|\$)')
      .hasMatch(trimmed)) {
    return true;
  }
  // Interpolation d'un texte déjà traduit
  if (trimmed.contains(r'${AppLocalizations') ||
      trimmed.contains(r'${language.label') ||
      trimmed.contains('l10n.')) {
    return true;
  }
  // Le nom de l'app ne se traduit pas
  if (trimmed.replaceAll(RegExp(r'[^A-Za-z]'), '') == 'Lumiconte') return true;

  // Du texte affiché : soit plusieurs mots, soit un mot capitalisé
  final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final hasLetters = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(trimmed);
  if (!hasLetters) return true;
  if (words.length >= 2) return false;
  return !RegExp(r'^[A-ZÀ-Þ]').hasMatch(trimmed);
}

/// Fichiers dont les chaînes ne sont pas de l'interface traduisible.
const _exempt = {
  'lib/l10n',
  // Textes juridiques, en attente d'une traduction relue par un humain
  'lib/pages/terms_page.dart',
  'lib/pages/privacy_page.dart',
  // Données de démonstration, jamais affichées en production
  'lib/services/seed_database.dart',
  // Noms des langues, écrits dans leur propre langue par définition
  'lib/models/app_language.dart',
  // Identifiants Firebase
  'lib/config/firebase_options.dart',
};

void main() {
  test('aucun texte affiché n\'est écrit en dur hors des traductions', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (_exempt.any(path.startsWith)) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_ignoredLine.hasMatch(line)) continue;
        for (final pattern in [_singleQuoted, _doubleQuoted]) {
          for (final match in pattern.allMatches(line)) {
            final text = match.group(1) ?? '';
            if (_isTechnical(text)) continue;
            offenders.add('$path:${i + 1}  $text');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Ces textes doivent passer par AppLocalizations :\n'
          '${offenders.join('\n')}',
    );
  });
}
