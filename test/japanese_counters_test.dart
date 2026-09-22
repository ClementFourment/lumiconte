import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Compteurs japonais dont la lecture change avec le nombre.
///
/// 3日 se lit みっか et non « さんにち », 3分 se lit さんぷん et non « さんふん ».
/// Écrits en hiragana juste après un chiffre, ils imposent une lecture fausse ;
/// en kanji, le lecteur applique la bonne. Le reste de la traduction japonaise
/// reste en hiragana pour les jeunes enfants : seuls les compteurs sont en
/// kanji, comme dans les livres pour enfants.
const _irregularCounters = {
  'にち': '日 (3日 = みっか)',
  'ふん': '分 (3分 = さんぷん)',
  'ぷん': '分',
  'じかん': '時間',
  'しゅうかん': '週間 (1週間 = いっしゅうかん)',
  'さい': '歳 (1歳 = いっさい, 8歳 = はっさい)',
  'びょう': '秒',
  'こ': '個 (1個 = いっこ, 6個 = ろっこ)',
};

void main() {
  test('aucun compteur japonais en hiragana ne suit un chiffre', () {
    final json = jsonDecode(File('lib/l10n/app_ja.arb').readAsStringSync())
        as Map<String, dynamic>;

    final offenders = <String>[];
    json.forEach((key, value) {
      if (key.startsWith('@') || value is! String) return;
      for (final entry in _irregularCounters.entries) {
        // Un chiffre, ou une valeur interpolée, suivi du compteur en hiragana
        final pattern = RegExp('(?:[0-9]|\})\s*${entry.key}');
        if (pattern.hasMatch(value)) {
          offenders.add('$key : « $value » → écrire ${entry.value}');
        }
      }
    });

    expect(
      offenders,
      isEmpty,
      reason: 'Compteurs à passer en kanji :\n${offenders.join('\n')}',
    );
  });
}
