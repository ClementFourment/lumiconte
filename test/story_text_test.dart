import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/story_text.dart';

const nbsp = '\u00A0';

List<String> texts(String content) =>
    storyWordsFromText(content).map((w) => w.text).toList();

String longStory() {
  const sentences = [
    '« Bonjour ! » dit le petit chaperon rouge au loup qui passait par là.',
    'Le loup, très poli, lui demanda : « Où vas-tu ainsi ? »',
    'Elle répondit qu\'elle allait chez sa grand-mère… qui était malade.',
    '— Prends ce chemin, il est plus court ! dit le loup en souriant.',
    r"\nPendant ce temps, le loup courut jusqu'à la maison.",
    '[img:2] Il frappa à la porte : toc, toc, toc.',
  ];
  return List.generate(8, (_) => sentences.join(' ')).join(' ');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ponctuation insécable', () {
    test('les guillemets et la ponctuation haute restent collés au mot', () {
      expect(texts('« Bonjour ! » dit le loup .'), [
        '«${nbsp}Bonjour$nbsp!$nbsp»',
        'dit',
        'le',
        'loup.',
      ]);
    });

    test('les guillemets collés dans le texte reçoivent une espace insécable',
        () {
      expect(texts('«Bonjour» dit-il'), ['«${nbsp}Bonjour$nbsp»', 'dit-il']);
    });

    test('le tiret de dialogue reste avec le premier mot', () {
      expect(texts('— Viens ici , dit-elle .'),
          ['—${nbsp}Viens', 'ici,', 'dit-elle.']);
    });

    test('les guillemets droits s\'ouvrent puis se ferment', () {
      expect(texts('Il dit " oui " puis part'),
          ['Il', 'dit', '"oui"', 'puis', 'part']);
    });

    test('les points de suspension et deux-points restent attachés', () {
      expect(texts('Hmm ... Voici : rien'), ['Hmm...', 'Voici$nbsp:', 'rien']);
    });

    test('paragraphes et illustrations sont rattachés au mot suivant', () {
      final words = storyWordsFromText(r'Il était une fois.\n[img:2] Le loup.');
      final le = words.firstWhere((w) => w.text == 'Le');
      expect(le.startsParagraph, isTrue);
      expect(le.imageNumber, 2);
      expect(words.map((w) => w.text), isNot(contains('[img:2]')));
    });

    test('avec l\'audio, la ponctuation garde le minutage du mot', () {
      final words = storyWordsFromSegments([
        SegmentTiming(start: 0, end: 2, text: 'Bonjour !', words: [
          WordTiming(word: ' Bonjour', start: 0.2, end: 0.8),
          WordTiming(word: ' !', start: 0.8, end: 0.9),
        ]),
      ]);
      expect(words, hasLength(1));
      expect(words.single.text, 'Bonjour$nbsp!');
      expect(words.single.start, 0.2);
      expect(words.single.end, 0.8);
    });
  });

  group('document', () {
    final document = StoryDocument(storyWordsFromText('un deux trois quatre'));

    test('retrouve le dernier mot lu depuis une progression', () {
      final end = document.fractionBefore(2);
      expect(document.lastWordReadAt(end), 1);
      expect(document.wordStartingAt(end), 2);
    });
  });

  group('pagination', () {
    final document = StoryDocument(storyWordsFromText(longStory()));

    final configs = <String, StoryTextMetrics>{
      'classique':
          const StoryTextMetrics(fontSize: 18, textAlign: TextAlign.center),
      'grande police': const StoryTextMetrics(fontSize: 30),
      'dyslexie': const StoryTextMetrics(fontSize: 18, dyslexia: true),
      'lettrine': const StoryTextMetrics(
        fontSize: 16,
        lineHeight: 1.6,
        textAlign: TextAlign.justify,
        dropCapFontFamily: 'Serif',
      ),
    };

    for (final entry in configs.entries) {
      for (final area in const [Size(320, 220), Size(260, 420)]) {
        test('${entry.key} ${area.width}x${area.height} : chaque page tient',
            () {
          final request = StoryLayoutRequest(
            area: area,
            metrics: entry.value,
            textScaler: TextScaler.noScaling,
          );
          final pagination = paginateStory(document, request);

          expect(pagination.pages.first.start, 0);
          expect(pagination.pages.last.end, document.words.length);
          for (var i = 0; i < pagination.pages.length; i++) {
            final page = pagination.pages[i];
            expect(page.end, greaterThan(page.start));
            if (i > 0) expect(page.start, pagination.pages[i - 1].end);

            final words = document.words.sublist(page.start, page.end);
            expect(layoutStoryPage(words, request).height,
                lessThanOrEqualTo(area.height));
          }
        });
      }
    }

    test('coupe les pages en fin de phrase quand c\'est possible', () {
      final shortSentences = StoryDocument(storyWordsFromText(
          List.generate(40, (i) => 'Le chat numéro $i dort.').join(' ')));
      final request = StoryLayoutRequest(
        area: const Size(300, 200),
        metrics: const StoryTextMetrics(fontSize: 18),
        textScaler: TextScaler.noScaling,
      );
      final pagination = paginateStory(shortSentences, request);

      expect(pagination.pages.length, greaterThan(2));
      for (final page in pagination.pages) {
        expect(shortSentences.words[page.end - 1].text, endsWith('.'));
      }
    });
  });

  group('affichage', () {
    final words = storyWordsFromText(longStory()).take(40).toList();

    for (final metrics in const [
      StoryTextMetrics(fontSize: 18, textAlign: TextAlign.center),
      StoryTextMetrics(fontSize: 18, dyslexia: true),
      StoryTextMetrics(
        fontSize: 16,
        textAlign: TextAlign.justify,
        dropCapFontFamily: 'Serif',
      ),
    ]) {
      testWidgets(
          'la hauteur affichée correspond à la mesure (lettrine : ${metrics.usesDropCap})',
          (tester) async {
        tester.view.physicalSize = const Size(400, 3000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final request = StoryLayoutRequest(
          area: const Size(300, 2000),
          metrics: metrics,
          textScaler: TextScaler.noScaling,
        );

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: StoryPageText(
              words: words,
              request: request,
              colors: StoryTextColors.measure,
              activeIndex: 3,
            ),
          ),
        ));

        final rendered = tester.getSize(find.byType(StoryPageText)).height;
        expect(
            rendered,
            moreOrLessEquals(layoutStoryPage(words, request).height,
                epsilon: 1));
      });
    }
  });

  group('mode dyslexie', () {
    const metrics = StoryTextMetrics(fontSize: 18, dyslexia: true);
    const colors = StoryTextColors(
      text: Color(0xFF000000),
      activeText: Color(0xFF000000),
      highlight: Color(0x00000000),
    );

    List<String> pieces(String text, String language) {
      final span =
          storyTextSpan(text, metrics, colors, locale: Locale(language));
      final result = <String>[];
      span.visitChildren((child) {
        final t = (child as TextSpan).text;
        if (t != null && t != ' ') result.add(t);
        return true;
      });
      return result;
    }

    test('le a final se prononce', () {
      expect(pieces('papa', 'fr'), ['pa', 'pa']);
    });

    test('les consonnes finales muettes sont séparées', () {
      expect(pieces('chocolat', 'fr'), ['cho', 'co', 'la', 't']);
    });

    test('le s final de « bus » se prononce', () {
      expect(pieces('bus', 'fr'), ['bus']);
    });

    test("l'élision ne change pas la prononciation de la fin", () {
      expect(pieces("l'Ours", 'fr'), ["l'Ours"]);
      expect(pieces('l’os', 'fr'), ['l’os']);
    });

    test('syllabes dans les autres langues', () {
      expect(pieces('little', 'en'), ['lit', 'tle']);
      expect(pieces('Mutter', 'de'), ['Mut', 'ter']);
    });

    test('pas de syllabes en japonais', () {
      expect(pieces('むかしむかし', 'ja'), ['むかしむかし']);
    });

    test('le texte est toujours aligné à gauche', () {
      const justified = StoryTextMetrics(
          fontSize: 18, dyslexia: true, textAlign: TextAlign.justify);
      expect(justified.effectiveTextAlign, TextAlign.left);
    });
  });
}
