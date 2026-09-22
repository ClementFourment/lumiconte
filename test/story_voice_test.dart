import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/story_model.dart';

AudioVoiceData _voice(String url) => AudioVoiceData(url: url, audioTimes: '');

StoryModel _story(Map<String, AudioVoiceData> audio) => StoryModel(
      id: 's',
      name: const LocalizedText({'fr': 's'}),
      age_min: null,
      age_max: null,
      content: const LocalizedText.empty(),
      audio: audio,
    );

void main() {
  test('choisit la voix de la langue et du genre demandés', () {
    final story = _story({
      'fr_femme': _voice('fr_f'),
      'fr_homme': _voice('fr_h'),
      'en_femme': _voice('en_f'),
      'en_homme': _voice('en_h'),
      'es_femme': _voice('es_f'),
      'es_homme': _voice('es_h'),
    });

    expect(story.voiceFor('fr', 'femme')?.url, 'fr_f');
    expect(story.voiceFor('fr', 'homme')?.url, 'fr_h');
    expect(story.voiceFor('en', 'homme')?.url, 'en_h');
    expect(story.voiceFor('es', 'femme')?.url, 'es_f');
  });

  test("se rabat sur l'autre voix de la même langue, jamais sur une autre langue",
      () {
    final story = _story({
      'fr_femme': _voice('fr_f'),
      'en_homme': _voice('en_h'),
      'es_femme': _voice(' '),
    });

    expect(story.voiceFor('en', 'femme')?.url, 'en_h');
    expect(story.voiceFor('fr', 'homme')?.url, 'fr_f');
    expect(story.voiceFor('es', 'femme'), isNull);
  });

  test('langue inconnue : voix françaises', () {
    final story = _story({'fr_homme': _voice('fr_h')});

    expect(story.voiceFor(null, null)?.url, 'fr_h');
    // 'pt' n'est pas proposé dans les réglages : on retombe sur le français
    expect(story.voiceFor('pt', 'homme')?.url, 'fr_h');
  });

  test("une langue proposée sans voix enregistrée n'a pas de voix", () {
    final story = _story({'fr_homme': _voice('fr_h')});

    // L'allemand est une vraie langue des réglages : tant qu'aucune voix
    // allemande n'est en base, l'histoire n'est pas écoutable dans cette
    // langue. Elle reste lisible en texte.
    expect(story.voiceFor('de', 'homme'), isNull);
    expect(story.voiceFor('ja', 'femme'), isNull);
  });
}
