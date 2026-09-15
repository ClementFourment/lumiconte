import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/story_model.dart';

AudioVoiceData _voice(String url) => AudioVoiceData(url: url, audioTimes: '');

StoryModel _story(Map<String, AudioVoiceData> audio) => StoryModel(
      id: 's',
      name: 's',
      age_min: null,
      age_max: null,
      content: '',
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
    expect(story.voiceFor('de', 'homme')?.url, 'fr_h');
  });
}
