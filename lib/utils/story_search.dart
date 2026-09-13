import 'package:lumiconte/utils/string_utils.dart';

// Petits mots qui n'ont pas besoin d'être trouvés pour qu'une histoire corresponde
// ("La chaperon" doit trouver "Le petit chaperon rouge").
const _stopWords = {
  'le', 'la', 'les', 'l', 'un', 'une', 'des', 'de', 'du', 'd',
  'et', 'a', 'au', 'aux', 'en',
};

List<String> tokenize(String text) => normalizeText(text)
    .split(RegExp(r'[^a-z0-9]+'))
    .where((word) => word.isNotEmpty)
    .toList();

/// Score de pertinence d'une histoire pour la recherche, ou `null` si elle ne correspond pas.
/// Chaque mot significatif de la recherche doit se retrouver dans le titre ou une catégorie,
/// dans n'importe quel ordre.
int? storySearchScore(String query, String name, List<String> categories) {
  final queryWords = tokenize(query);
  if (queryWords.isEmpty) return null;

  final nameWords = tokenize(name);
  final categoryWords = categories.expand(tokenize).toList();
  final allStopWords = queryWords.every(_stopWords.contains);

  var score = 0;
  for (final word in queryWords) {
    final wordScore = _bestWordScore(word, nameWords, categoryWords);
    if (wordScore == 0) {
      if (allStopWords || !_stopWords.contains(word)) return null;
      continue;
    }
    score += wordScore;
  }

  final queryPhrase = queryWords.join(' ');
  final namePhrase = nameWords.join(' ');
  if (namePhrase.startsWith(queryPhrase)) {
    score += 80;
  } else if (namePhrase.contains(queryPhrase)) {
    score += 40;
  }

  return score;
}

int _bestWordScore(
  String word,
  List<String> nameWords,
  List<String> categoryWords,
) {
  var best = 0;
  for (final nameWord in nameWords) {
    best = _max(best, _wordScore(word, nameWord, exact: 100, prefix: 60, inside: 30));
  }
  for (final categoryWord in categoryWords) {
    best = _max(best, _wordScore(word, categoryWord, exact: 40, prefix: 25, inside: 10));
  }
  return best;
}

int _wordScore(
  String word,
  String candidate, {
  required int exact,
  required int prefix,
  required int inside,
}) {
  if (candidate == word) return exact;
  if (candidate.startsWith(word)) return prefix;
  // Sous 3 lettres, une correspondance au milieu d'un mot ne veut rien dire.
  if (word.length >= 3 && candidate.contains(word)) return inside;
  return 0;
}

int _max(int a, int b) => a > b ? a : b;
