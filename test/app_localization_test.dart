import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:lumiconte/models/app_language.dart';

/// Clés traduites d'un fichier .arb (les entrées `@...` sont des commentaires
/// pour les traducteurs, pas des textes).
Set<String> _keysOf(String languageCode) {
  final file = File('lib/l10n/app_$languageCode.arb');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('chaque langue proposée a son fichier de traduction', () {
    for (final code in AppLanguage.codes) {
      expect(File('lib/l10n/app_$code.arb').existsSync(), isTrue,
          reason: 'lib/l10n/app_$code.arb manquant');
    }
  });

  test('Flutter connaît exactement les langues des réglages', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      AppLanguage.codes.toSet(),
    );
  });

  test('aucune traduction ne manque dans une langue', () {
    final reference = _keysOf(AppLanguage.defaultCode);
    expect(reference, isNotEmpty);

    for (final code in AppLanguage.codes) {
      // Une clé oubliée afficherait du français au milieu d'un écran traduit
      expect(_keysOf(code), reference,
          reason: 'lib/l10n/app_$code.arb ne traduit pas les mêmes clés');
    }
  });

  testWidgets("l'app se traduit dans la langue choisie, pas celle du mobile",
      (tester) async {
    addTearDown(() => AppLanguage.select(AppLanguage.defaultCode));

    await tester.pumpWidget(
      ValueListenableBuilder<String>(
        valueListenable: AppLanguage.current,
        builder: (context, languageCode, child) => MaterialApp(
          locale: AppLanguage.localeOf(languageCode),
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Text(AppLocalizations.of(context).language),
          ),
        ),
      ),
    );

    expect(find.text('Langue'), findsOneWidget);

    for (final expected in {
      'de': 'Sprache',
      'en': 'Language',
      'es': 'Idioma',
      'it': 'Lingua',
      'ja': '言語',
    }.entries) {
      AppLanguage.select(expected.key);
      await tester.pumpAndSettle();
      expect(find.text(expected.value), findsOneWidget,
          reason: 'la langue ${expected.key} ne s\'applique pas');
    }
  });
}
