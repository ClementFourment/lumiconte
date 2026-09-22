import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:lumiconte/models/app_language.dart';
import 'package:lumiconte/utils/reading_stats.dart';

AppLocalizations _texts(String code) =>
    lookupAppLocalizations(AppLanguage.localeOf(code));

void main() {
  test('la série de lecture compte les jours dans la langue du profil', () {
    expect(formatStreak(_texts('fr'), 3), '3 jours');
    expect(formatStreak(_texts('fr'), 1), '1 jour');
    // Le français met zéro au singulier
    expect(formatStreak(_texts('fr'), 0), '0 jour');

    expect(formatStreak(_texts('en'), 3), '3 days');
    expect(formatStreak(_texts('en'), 1), '1 day');
    expect(formatStreak(_texts('de'), 2), '2 Tage');
    expect(formatStreak(_texts('es'), 2), '2 días');
    expect(formatStreak(_texts('it'), 2), '2 giorni');
    // Le japonais n'a pas de pluriel. Le compteur des jours est en kanji :
    // écrit en hiragana, il imposerait une lecture fausse (3日 = みっか).
    expect(formatStreak(_texts('ja'), 1), '1日');
    expect(formatStreak(_texts('ja'), 5), '5日');
  });

  test('le temps de lecture porte ses unités dans chaque langue', () {
    expect(formatReadingTime(_texts('fr'), 45), '45 sec');
    expect(formatReadingTime(_texts('fr'), 12 * 60), '12min');
    expect(formatReadingTime(_texts('fr'), 6 * 3600), '6h');
    // Les minutes restent sur deux chiffres : 6h08, pas 6h8
    expect(formatReadingTime(_texts('fr'), 6 * 3600 + 8 * 60), '6h08');
    expect(formatReadingTime(_texts('fr'), 6 * 3600 + 25 * 60), '6h25');

    expect(formatReadingTime(_texts('de'), 45), '45 Sek.');
    expect(formatReadingTime(_texts('de'), 6 * 3600 + 8 * 60), '6 Std. 08');
    expect(formatReadingTime(_texts('ja'), 6 * 3600 + 8 * 60), '6時間08分');
  });

  test('aucune unité de temps ne reste en français dans les autres langues',
      () {
    for (final code in AppLanguage.codes) {
      if (code == 'fr') continue;
      final texts = _texts(code);
      final samples = [
        formatStreak(texts, 3),
        formatReadingTime(texts, 45),
        formatReadingTime(texts, 12 * 60),
      ];
      for (final sample in samples) {
        expect(sample.contains('jour'), isFalse, reason: '$code : $sample');
      }
    }
  });
}
