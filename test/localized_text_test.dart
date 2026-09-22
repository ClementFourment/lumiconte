import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/app_language.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/story_model.dart';

StoryModel _story(Map<String, dynamic> data) => StoryModel.fromMap(data, 's');

void main() {
  test('lit les textes traduits par langue', () {
    final story = _story({
      'name': {'fr': 'Peter Pan et Wendy', 'en': 'Peter Pan and Wendy'},
      'content': {'fr': 'Il était une fois', 'en': 'Once upon a time'},
      'morals': {'fr': 'Le conseil du conteur', 'en': "The teller's advice"},
    });

    expect(story.name.of('fr'), 'Peter Pan et Wendy');
    expect(story.name.of('en'), 'Peter Pan and Wendy');
    expect(story.content.of('en'), 'Once upon a time');
    expect(story.morals.of('en'), "The teller's advice");
  });

  test('retombe sur le français quand la traduction manque', () {
    final story = _story({
      'name': {'fr': 'Peter Pan et Wendy', 'en': ''},
      'content': {'fr': 'Il était une fois'},
    });

    // Traduction vide comme dans la base : on ne laisse pas un titre blanc
    expect(story.name.of('en'), 'Peter Pan et Wendy');
    expect(story.content.of('es'), 'Il était une fois');
    expect(story.morals.of('fr'), '');
    expect(story.morals.isEmpty, isTrue);
  });

  test('utilise une autre langue en dernier recours', () {
    final story = _story({
      'name': {'en': 'Moon Mission'},
      'content': <String, dynamic>{},
    });

    expect(story.name.of('fr'), 'Moon Mission');
    expect(story.content.of('fr'), '');
  });

  test("accepte l'ancien format où le texte était une simple chaîne", () {
    final story = _story({
      'name': 'Mission Lune',
      'content': 'bla bla',
    });

    expect(story.name.of('fr'), 'Mission Lune');
    expect(story.name.of('en'), 'Mission Lune');
    expect(story.content.of('fr'), 'bla bla');
  });

  test('affiche les textes dans la langue de lecture du profil', () {
    final story = _story({
      'name': {'fr': 'Peter Pan et Wendy', 'en': 'Peter Pan and Wendy'},
      'content': {'fr': 'Il était une fois', 'en': 'Once upon a time'},
      'morals': {'fr': 'Le conseil', 'en': 'The advice'},
    });

    addTearDown(() => AppLanguage.select('fr'));

    AppLanguage.select('en');
    expect(story.displayName, 'Peter Pan and Wendy');
    expect(story.displayContent, 'Once upon a time');
    expect(story.displayMorals, 'The advice');

    AppLanguage.select('fr');
    expect(story.displayName, 'Peter Pan et Wendy');
  });

  test('réécrit les textes par langue dans Firestore', () {
    final story = _story({
      'name': {'fr': 'Peter Pan et Wendy', 'en': 'Peter Pan and Wendy'},
      'content': {'fr': 'Il était une fois'},
    });

    final map = story.toMap();
    expect(map['name'], {'fr': 'Peter Pan et Wendy', 'en': 'Peter Pan and Wendy'});
    expect(map['content'], {'fr': 'Il était une fois'});
    expect(map['morals'], <String, String>{});
  });

  test('une histoire au champ incohérent ne fait pas tomber la lecture', () {
    // Champs au mauvais type, comme pendant une migration de la base
    final story = _story({
      'name': {'fr': 'Peter Pan et Wendy'},
      'age_min': 2.0,
      'age_max': 5,
      'image': {'fr': 'cover.webp'},
      'categoryIds': ['Les Incontournables', 42],
      'type': 12,
    });

    expect(story.displayName, 'Peter Pan et Wendy');
    expect(story.age_min, 2);
    expect(story.age_max, 5);
    expect(story.image, isNull);
    expect(story.categoryIds, ['Les Incontournables']);
    expect(story.type, 'original');
  });

  test('les catégories lisent aussi leurs textes par langue', () {
    final category = CategoryModel.fromMap({
      'name': {'fr': 'Les Incontournables', 'en': 'The Classics'},
      'description': {'fr': 'À ne pas manquer'},
      'image': 'cover.webp',
      'age': '6-8',
    }, 'c');

    expect(category.name.of('en'), 'The Classics');
    expect(category.displayDescription, 'À ne pas manquer');

    // Ancien format encore en base
    final legacy = CategoryModel.fromMap({'name': 'Aventure'}, 'c2');
    expect(legacy.displayName, 'Aventure');
    expect(legacy.ageGroup, '');
  });

  test('les réglages proposent les six langues, la voix suit', () {
    expect(AppLanguage.codes, ['de', 'en', 'es', 'fr', 'it', 'ja']);
    expect(StoryModel.voiceLanguages, AppLanguage.codes);

    expect(AppLanguage.localeOf('ja').languageCode, 'ja');
    expect(AppLanguage.of('de').label, 'Deutsch');
  });

  test('une langue inconnue retombe sur le français', () {
    expect(AppLanguage.sanitize('pt'), 'fr');
    expect(AppLanguage.sanitize(null), 'fr');
    expect(AppLanguage.of('pt').code, 'fr');
    expect(SettingsModel.fromMap({'language': 'pt'}, 's').language, 'fr');
  });

  test('choisit la voix des nouvelles langues', () {
    final story = StoryModel.fromMap({
      'audio': {
        'de_femme': {'url': 'de_f.flac', 'audioTimes': ''},
        'ja_homme': {'url': 'ja_h.flac', 'audioTimes': ''},
      },
    }, 's');

    expect(story.voiceFor('de', 'femme')?.url, 'de_f.flac');
    expect(story.voiceFor('ja', 'femme')?.url, 'ja_h.flac');
    // Jamais la voix d'une autre langue
    expect(story.voiceFor('it', 'femme'), isNull);
  });
}
