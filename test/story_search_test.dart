import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/utils/story_search.dart';

void main() {
  const chaperon = 'Le petit chaperon rouge';

  bool matches(String query, String name, [List<String> categories = const []]) =>
      storySearchScore(query, name, categories) != null;

  test('trouve des mots non consécutifs', () {
    expect(matches('Le chaperon', chaperon), isTrue);
    expect(matches('chaperon rouge', chaperon), isTrue);
  });

  test("trouve des mots dans le désordre", () {
    expect(matches('rouge chaperon', chaperon), isTrue);
  });

  test('ignore les accents, la casse et la ponctuation', () {
    expect(matches('ÉLÉPHANT', "L'éléphant et la souris"), isTrue);
    expect(matches("l'elephant", "L'éléphant et la souris"), isTrue);
  });

  test('trouve un mot en cours de frappe', () {
    expect(matches('le petit chap', chaperon), isTrue);
  });

  test('un petit mot absent ne bloque pas la recherche', () {
    expect(matches('La chaperon', chaperon), isTrue);
  });

  test('un mot significatif absent exclut l\'histoire', () {
    expect(matches('chaperon bleu', chaperon), isFalse);
    expect(matches('les', chaperon), isFalse);
  });

  test('trouve via une catégorie', () {
    expect(matches('conte', 'Blanche-Neige', ['contes classiques']), isTrue);
  });

  test('classe la correspondance exacte du début de titre en premier', () {
    final exact = storySearchScore('le petit chaperon', chaperon, [])!;
    final scattered =
        storySearchScore('le petit chaperon', 'Le chaperon du petit loup', [])!;
    expect(exact, greaterThan(scattered));
  });
}
