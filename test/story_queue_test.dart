import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/story_queue.dart';

StoryModel _story(String id, {bool withAudio = true}) => StoryModel(
      id: id,
      name: LocalizedText({'fr': id}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: withAudio
          ? {'fr_femme': AudioVoiceData(url: 'audio/$id.mp3', audioTimes: '')}
          : null,
    );

void main() {
  test('refuse les doublons, les histoires sans audio et au-delà de 5', () {
    final queue = StoryQueue.forTesting();

    expect(queue.add(_story('a')), isTrue);
    expect(queue.add(_story('a')), isFalse);
    expect(queue.add(_story('muet', withAudio: false)), isFalse);

    for (final id in ['b', 'c', 'd', 'e']) {
      expect(queue.add(_story(id)), isTrue);
    }
    expect(queue.isFull, isTrue);
    expect(queue.add(_story('f')), isFalse);
    expect(queue.stories.map((s) => s.id), ['a', 'b', 'c', 'd', 'e']);
  });

  test("refuse une histoire dont l'audio n'est pas une voix lisible", () {
    final queue = StoryQueue.forTesting();
    final otherKey = StoryModel(
      id: 'autre',
      name: const LocalizedText({'fr': 'autre'}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: {'femme': AudioVoiceData(url: 'audio/x.mp3', audioTimes: '')},
    );
    final emptyUrl = StoryModel(
      id: 'vide',
      name: const LocalizedText({'fr': 'vide'}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: {'fr_femme': AudioVoiceData(url: ' ', audioTimes: '')},
    );

    expect(queue.add(otherKey), isFalse);
    expect(queue.add(emptyUrl), isFalse);
  });

  test("n'accepte que les histoires ayant une voix dans la langue du profil",
      () {
    final queue = StoryQueue.forTesting();
    final bilingual = StoryModel(
      id: 'bi',
      name: const LocalizedText({'fr': 'bi'}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: {
        'fr_femme': AudioVoiceData(url: 'audio/bi_fr.mp3', audioTimes: ''),
        'en_homme': AudioVoiceData(url: 'audio/bi_en.mp3', audioTimes: ''),
      },
    );
    // Même cas que dans la base : clé en_ présente, url vide
    final frenchOnly = StoryModel(
      id: 'fr',
      name: const LocalizedText({'fr': 'fr'}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: {
        'fr_femme': AudioVoiceData(url: 'audio/fr.mp3', audioTimes: ''),
        'en_femme': AudioVoiceData(url: '', audioTimes: ''),
      },
    );

    queue
      ..add(bilingual)
      ..add(frenchOnly);
    expect(queue.stories.map((s) => s.id), ['bi', 'fr']);

    // Passage à l'anglais : l'histoire sans voix anglaise quitte la file
    queue.language = 'en';
    expect(queue.canQueue(frenchOnly), isFalse);
    expect(queue.stories.map((s) => s.id), ['bi']);
    expect(queue.add(frenchOnly), isFalse);
  });

  test("changer de langue garde l'histoire en cours d'écoute", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'));

    queue.start();
    queue.next();
    queue.language = 'es';
    expect(queue.stories.map((s) => s.id), ['b']);
    expect(queue.current?.id, 'b');
  });

  test("enchaîne les histoires puis se vide après la dernière", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'));

    expect(queue.isPlaying, isFalse);
    expect(queue.start()?.id, 'a');
    expect(queue.hasNext, isTrue);
    expect(queue.next()?.id, 'b');
    expect(queue.hasNext, isFalse);

    expect(queue.next(), isNull);
    expect(queue.isEmpty, isTrue);
    expect(queue.isPlaying, isFalse);
  });

  test("revient à l'histoire précédente sans vider la file", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'));

    queue.start();
    expect(queue.hasPrevious, isFalse);
    expect(queue.previous(), isNull);

    queue.next();
    expect(queue.hasPrevious, isTrue);
    expect(queue.previous()?.id, 'a');
    expect(queue.hasNext, isTrue);
  });

  test("lancer une histoire la place devant la file préparée", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'));

    queue.playNow(_story('b'));
    expect(queue.stories.map((s) => s.id), ['b', 'a']);
    expect(queue.current?.id, 'b');
    expect(queue.hasNext, isTrue);
  });

  test("lancer une histoire pendant l'écoute remplace la file", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'));

    queue.start();
    queue.playNow(_story('c'));
    expect(queue.stories.map((s) => s.id), ['c']);
    expect(queue.hasNext, isFalse);
  });

  test("retirer une histoire déjà écoutée garde l'histoire en cours", () {
    final queue = StoryQueue.forTesting()
      ..add(_story('a'))
      ..add(_story('b'))
      ..add(_story('c'));

    queue.start();
    queue.next();
    queue.remove('b');
    expect(queue.current?.id, 'b');
    queue.remove('a');
    expect(queue.current?.id, 'b');

    expect(queue.hasNext, isTrue);
    expect(queue.next()?.id, 'c');
  });
}
