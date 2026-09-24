import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/syllables.dart';

const String _nbsp = '\u00A0';

final RegExp _imageMarker = RegExp(r'\[img:(\d+)\]');
final RegExp _closingPunctuation = RegExp(r'^[»”’)\].,;:!?…]+$');
final RegExp _openingPunctuation = RegExp(r'^[«“‘(\[—–-]+$');
final RegExp _straightQuotes = RegExp(r'^"+$');
final RegExp _sentenceEnd = RegExp(r'[.!?…][»”’")\]\u00A0]*$');
final RegExp _clauseEnd = RegExp(r'[,;:—–][»”’")\]\u00A0]*$');

/// Unité de lecture insécable : un mot avec la ponctuation qui l'entoure.
@immutable
class StoryWord {
  const StoryWord(
    this.text, {
    this.start,
    this.end,
    this.startsParagraph = false,
    this.imageNumber,
  });

  final String text;
  final double? start;
  final double? end;
  final bool startsParagraph;

  /// Numéro de l'illustration `[img:N]` placée juste avant ce mot.
  final int? imageNumber;

  StoryWord _withText(String newText) => StoryWord(
        newText,
        start: start,
        end: end,
        startsParagraph: startsParagraph,
        imageNumber: imageNumber,
      );
}

class _Token {
  const _Token(this.text, {this.start, this.end, this.startsParagraph = false})
      : imageNumber = null;

  const _Token.image(int this.imageNumber)
      : text = '',
        start = null,
        end = null,
        startsParagraph = false;

  final String text;
  final double? start;
  final double? end;
  final bool startsParagraph;
  final int? imageNumber;
}

List<StoryWord> storyWordsFromText(String content) {
  final tokens = <_Token>[];
  final paragraphs = content.replaceAll(r'\n', '\n').split(RegExp(r'\n+'));

  for (final paragraph in paragraphs) {
    var startsParagraph = true;
    final spaced = paragraph.replaceAllMapped(_imageMarker, (m) => ' ${m[0]} ');
    for (final raw in spaced.split(RegExp(r'[ \t\r]+'))) {
      if (raw.isEmpty) continue;
      final marker = _imageMarker.firstMatch(raw);
      if (marker != null && marker.group(0) == raw) {
        tokens.add(_Token.image(int.parse(marker.group(1)!)));
        continue;
      }
      tokens.add(_Token(raw, startsParagraph: startsParagraph));
      startsParagraph = false;
    }
  }

  return _glueTokens(tokens);
}

List<StoryWord> storyWordsFromSegments(List<SegmentTiming> segments) {
  final tokens = <_Token>[];

  for (final segment in segments) {
    for (final marker in _imageMarker.allMatches(segment.text)) {
      tokens.add(_Token.image(int.parse(marker.group(1)!)));
    }
    for (final word in segment.words) {
      final cleaned = word.word.replaceAll(_imageMarker, ' ');
      for (final part in cleaned.split(RegExp(r'[ \t\r\n]+'))) {
        if (part.isEmpty) continue;
        tokens.add(_Token(part, start: word.start, end: word.end));
      }
    }
  }

  return _glueTokens(tokens);
}

/// Colle la ponctuation isolée au mot voisin, avec les espaces insécables
/// de la typographie française, pour qu'elle ne soit jamais seule sur une ligne.
List<StoryWord> _glueTokens(List<_Token> tokens) {
  final words = <StoryWord>[];
  var prefix = '';
  var prefixStartsParagraph = false;
  int? pendingImage;
  var straightQuoteCount = 0;

  for (final token in tokens) {
    if (token.imageNumber != null) {
      pendingImage = token.imageNumber;
      continue;
    }

    final text = token.text;
    final isStraightQuote = _straightQuotes.hasMatch(text);
    final closes = _closingPunctuation.hasMatch(text) ||
        (isStraightQuote && straightQuoteCount.isOdd);
    final opens = _openingPunctuation.hasMatch(text) ||
        (isStraightQuote && straightQuoteCount.isEven);
    straightQuoteCount += '"'.allMatches(text).length;

    if (closes && words.isNotEmpty && prefix.isEmpty) {
      final previous = words.last;
      final joiner = '»!?;:'.contains(text[0]) ? _nbsp : '';
      words[words.length - 1] =
          previous._withText(_normalizeQuotes(previous.text + joiner + text));
      continue;
    }

    if (opens) {
      if (prefix.isEmpty) prefixStartsParagraph = token.startsParagraph;
      final needsSpace = RegExp(r'[«—–-]').hasMatch(text);
      prefix += needsSpace ? '$text$_nbsp' : text;
      continue;
    }

    words.add(StoryWord(
      _normalizeQuotes(prefix + text),
      start: token.start,
      end: token.end,
      startsParagraph:
          prefix.isEmpty ? token.startsParagraph : prefixStartsParagraph,
      imageNumber: pendingImage,
    ));
    prefix = '';
    pendingImage = null;
  }

  if (prefix.isNotEmpty) {
    final orphan = prefix.replaceAll(RegExp('$_nbsp\$'), '');
    if (words.isEmpty) {
      words.add(StoryWord(orphan, imageNumber: pendingImage));
    } else {
      words[words.length - 1] =
          words.last._withText('${words.last.text}$_nbsp$orphan');
    }
  }

  return words;
}

String _normalizeQuotes(String text) => text
    .replaceAllMapped(RegExp(r'«(?=\S)'), (_) => '«$_nbsp')
    .replaceAllMapped(RegExp(r'(?<=\S)»'), (_) => '$_nbsp»');

/// Texte complet d'une histoire, découpé en mots de lecture.
class StoryDocument {
  StoryDocument(this.words) : _charPrefix = _buildCharPrefix(words);

  final List<StoryWord> words;
  final List<int> _charPrefix;

  late final bool hasTimings = words.any((word) => word.start != null);
  late final List<int> _imageWordIndexes = [
    for (var i = 0; i < words.length; i++)
      if (words[i].imageNumber != null) i,
  ];

  static List<int> _buildCharPrefix(List<StoryWord> words) {
    final prefix = List<int>.filled(words.length + 1, 0);
    for (var i = 0; i < words.length; i++) {
      prefix[i + 1] = prefix[i] + words[i].text.length;
    }
    return prefix;
  }

  bool get isEmpty => words.isEmpty;
  int get _totalChars => _charPrefix.last;

  /// Part du texte (0 à 1) située avant le mot `wordIndex`.
  double fractionBefore(int wordIndex) {
    if (_totalChars == 0) return 0;
    return _charPrefix[wordIndex.clamp(0, words.length)] / _totalChars;
  }

  /// Mot qui commence à la position `fraction` du texte.
  int wordStartingAt(double fraction) =>
      _wordEndingAfter(fraction.clamp(0.0, 1.0) * _totalChars);

  /// Dernier mot lu quand on a lu la part `fraction` du texte.
  int lastWordReadAt(double fraction) =>
      _wordEndingAfter(fraction.clamp(0.0, 1.0) * _totalChars - 0.5);

  int _wordEndingAfter(double charOffset) {
    if (words.isEmpty) return 0;
    var low = 0;
    var high = words.length - 1;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (_charPrefix[mid + 1] > charOffset) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low;
  }

  /// Mot prononcé à l'instant `seconds`, ou le dernier mot déjà commencé.
  int? wordAtTime(double seconds) {
    if (!hasTimings) return null;
    var low = 0;
    var high = words.length - 1;
    var result = 0;
    while (low <= high) {
      final mid = (low + high) >> 1;
      if ((words[mid].start ?? 0) <= seconds) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return result;
  }

  /// Mot à surligner : le dernier prononcé. Il reste surligné pendant les
  /// courts silences entre deux mots, pour que la pastille ne clignote pas,
  /// mais s'efface lors d'une vraie pause.
  int? spokenWordAt(double seconds) {
    final index = wordAtTime(seconds);
    if (index == null) return null;
    final word = words[index];
    final start = word.start;
    if (start == null || seconds < start) return null;
    final end = word.end ?? start;
    return seconds <= end + _highlightLinger ? index : null;
  }

  static const double _highlightLinger = 1.2;

  /// Dernière illustration rencontrée avant le mot `wordEnd` (exclu).
  int? imageNumberBefore(int wordEnd) {
    int? number;
    for (final index in _imageWordIndexes) {
      if (index >= wordEnd) break;
      number = words[index].imageNumber;
    }
    return number;
  }
}

/// Réglages qui influencent la mise en page du texte (pas les couleurs).
@immutable
class StoryTextMetrics {
  const StoryTextMetrics({
    required this.fontSize,
    this.fontFamily,
    this.lineHeight = 1.7,
    this.letterSpacing = 0.2,
    this.textAlign = TextAlign.left,
    this.dyslexia = false,
    this.dropCapFontFamily,
  });

  final double fontSize;
  final String? fontFamily;
  final double lineHeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final bool dyslexia;

  /// Police de la lettrine ; `null` pour ne pas en afficher.
  final String? dropCapFontFamily;

  bool get usesDropCap => dropCapFontFamily != null && !dyslexia;

  /// Le texte justifié ou centré crée des espaces irréguliers, pénibles en
  /// mode dyslexie : on aligne toujours à gauche.
  TextAlign get effectiveTextAlign => dyslexia ? TextAlign.left : textAlign;

  TextStyle get baseStyle => dyslexia
      ? TextStyle(
          fontFamily: _dyslexiaFontFamily,
          fontSize: fontSize + 2,
          // Espacements recommandés (WCAG 1.4.12) : les mots restent bien séparés
          letterSpacing: (fontSize + 2) * 0.12,
          wordSpacing: (fontSize + 2) * 0.35,
          height: 1.8,
        )
      : TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
          letterSpacing: letterSpacing,
        );

  @override
  bool operator ==(Object other) =>
      other is StoryTextMetrics &&
      other.fontSize == fontSize &&
      other.fontFamily == fontFamily &&
      other.lineHeight == lineHeight &&
      other.letterSpacing == letterSpacing &&
      other.textAlign == textAlign &&
      other.dyslexia == dyslexia &&
      other.dropCapFontFamily == dropCapFontFamily;

  @override
  int get hashCode => Object.hash(fontSize, fontFamily, lineHeight,
      letterSpacing, textAlign, dyslexia, dropCapFontFamily);
}

@immutable
class StoryTextColors {
  const StoryTextColors({
    required this.text,
    required this.activeText,
    required this.highlight,
    this.shadows,
  });

  static const measure = StoryTextColors(
    text: Color(0xFF000000),
    activeText: Color(0xFF000000),
    highlight: Color(0x00000000),
  );

  final Color text;

  /// Couleur du mot prononcé (sauf avec les syllabes colorées, qui gardent leurs couleurs).
  final Color activeText;
  final Color highlight;
  final List<Shadow>? shadows;
}

@immutable
class StoryLayoutRequest {
  const StoryLayoutRequest({
    required this.area,
    required this.metrics,
    required this.textScaler,
    this.locale,
  });

  final Size area;
  final StoryTextMetrics metrics;
  final TextScaler textScaler;
  final Locale? locale;

  @override
  bool operator ==(Object other) =>
      other is StoryLayoutRequest &&
      other.area == area &&
      other.metrics == metrics &&
      other.textScaler == textScaler &&
      other.locale == locale;

  @override
  int get hashCode => Object.hash(area, metrics, textScaler, locale);
}

class StoryParagraph {
  const StoryParagraph(this.span, this.wordRanges);

  final TextSpan span;
  final List<TextRange> wordRanges;
}

/// Mise en page d'une page : un paragraphe simple, ou une lettrine avec le texte
/// qui l'entoure (`beside`) puis le reste en pleine largeur (`rest`).
class StoryPageLayout {
  const StoryPageLayout._({
    required this.height,
    this.cap,
    this.capBox = Size.zero,
    this.beside,
    this.besideWordCount = 0,
    this.rest,
  });

  final double height;
  final TextSpan? cap;
  final Size capBox;
  final StoryParagraph? beside;
  final int besideWordCount;
  final StoryParagraph? rest;
}

TextPainter _layoutPainter(
    TextSpan span, StoryLayoutRequest request, double width) {
  return TextPainter(
    text: span,
    textAlign: request.metrics.effectiveTextAlign,
    textDirection: TextDirection.ltr,
    textScaler: request.textScaler,
    locale: request.locale,
  )..layout(maxWidth: width);
}

double _measureHeight(
    StoryParagraph paragraph, StoryLayoutRequest request, double width) {
  final painter = _layoutPainter(paragraph.span, request, width);
  final height = painter.height;
  painter.dispose();
  return height;
}

// La taille d'une lettrine ne dépend que de la lettre et du style : inutile de la remesurer
final Map<(String, String?, double, TextScaler), Size> _capBoxCache = {};

/// À appeler quand une police finit de charger : les mesures en cache sont périmées.
void clearStoryTextCaches() => _capBoxCache.clear();

int _firstCharLength(String text) =>
    text.isEmpty ? 0 : String.fromCharCode(text.runes.first).length;

StoryPageLayout layoutStoryPage(
  List<StoryWord> words,
  StoryLayoutRequest request, {
  StoryTextColors colors = StoryTextColors.measure,
  int? activeIndex,
}) {
  final metrics = request.metrics;
  if (metrics.usesDropCap &&
      words.isNotEmpty &&
      RegExp(r'^\p{L}', unicode: true).hasMatch(words.first.text)) {
    final withCap = _layoutWithDropCap(words, request, colors, activeIndex);
    if (withCap != null) return withCap;
  }

  final paragraph = _buildParagraph(words, metrics, colors, request.locale);
  return StoryPageLayout._(
    height: _measureHeight(paragraph, request, request.area.width),
    rest: paragraph,
  );
}

StoryPageLayout? _layoutWithDropCap(
  List<StoryWord> words,
  StoryLayoutRequest request,
  StoryTextColors colors,
  int? activeIndex,
) {
  final metrics = request.metrics;
  final width = request.area.width;
  final first = words.first.text;

  final cap = TextSpan(
    text: first.substring(0, _firstCharLength(first)),
    style: TextStyle(
      fontFamily: metrics.dropCapFontFamily,
      fontSize: metrics.fontSize * 4.6,
      fontWeight: FontWeight.w700,
      height: 0.65,
      color: activeIndex == 0 ? colors.activeText : colors.text,
      shadows: colors.shadows,
    ),
  );
  final capBox = _capBoxCache.putIfAbsent(
    (
      cap.text!,
      metrics.dropCapFontFamily,
      metrics.fontSize,
      request.textScaler
    ),
    () {
      final capPainter = TextPainter(
        text: cap,
        textDirection: TextDirection.ltr,
        textScaler: request.textScaler,
        locale: request.locale,
      )..layout();
      final size = Size(capPainter.width + 4, capPainter.height + 1);
      capPainter.dispose();
      return size;
    },
  );

  final narrowWidth = width - capBox.width;
  if (narrowWidth < width * 0.5) return null;

  final all = _buildParagraph(words, metrics, colors, request.locale,
      skipFirstChar: true);
  final painter = _layoutPainter(all.span, request, narrowWidth);
  final rows =
      math.max(1, (capBox.height / painter.preferredLineHeight).ceil());
  final lines = painter.computeLineMetrics();

  var besideCount = words.length;
  final allHeight = painter.height;
  if (lines.length > rows) {
    var besideHeight = 0.0;
    for (var i = 0; i < rows; i++) {
      besideHeight += lines[i].height;
    }
    final splitOffset =
        painter.getPositionForOffset(Offset(1, besideHeight + 1)).offset;
    final firstBelow =
        all.wordRanges.indexWhere((range) => range.end > splitOffset);
    besideCount = firstBelow < 0 ? words.length : math.max(1, firstBelow);
  }
  painter.dispose();

  final besideIsAll = besideCount == words.length;
  final beside = besideIsAll
      ? all
      : _buildParagraph(
          words.sublist(0, besideCount), metrics, colors, request.locale,
          skipFirstChar: true);
  final besideHeight =
      besideIsAll ? allHeight : _measureHeight(beside, request, narrowWidth);

  StoryParagraph? rest;
  var restHeight = 0.0;
  if (besideCount < words.length) {
    rest = _buildParagraph(
        words.sublist(besideCount), metrics, colors, request.locale);
    restHeight = _measureHeight(rest, request, width);
  }

  return StoryPageLayout._(
    height: math.max(capBox.height, besideHeight) + restHeight,
    cap: cap,
    capBox: capBox,
    beside: beside,
    besideWordCount: besideCount,
    rest: rest,
  );
}

/// Police conçue pour la fluidité de lecture, chargée à la première utilisation.
final String? _dyslexiaFontFamily = GoogleFonts.lexend().fontFamily;

/// Syllabes colorées dans les langues dont on connaît les règles ; ailleurs
/// (japonais), seule la typographie est adaptée.
bool _colorsSyllables(StoryTextMetrics metrics, Locale? locale) =>
    metrics.dyslexia && syllableLanguages.contains(locale?.languageCode);

/// Texte mis en forme comme dans la lecture, pour les aperçus.
TextSpan storyTextSpan(
  String text,
  StoryTextMetrics metrics,
  StoryTextColors colors, {
  Locale? locale,
}) =>
    _buildParagraph(storyWordsFromText(text), metrics, colors, locale).span;

StoryParagraph _buildParagraph(
  List<StoryWord> words,
  StoryTextMetrics metrics,
  StoryTextColors colors,
  Locale? locale, {
  bool skipFirstChar = false,
}) {
  final syllables = _colorsSyllables(metrics, locale);
  final base =
      metrics.baseStyle.copyWith(color: colors.text, shadows: colors.shadows);
  final children = <InlineSpan>[];
  final ranges = <TextRange>[];
  var offset = 0;

  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    if (i > 0) {
      if (word.startsParagraph) {
        // Saut de ligne suivi d'une demi-ligne vide pour aérer les paragraphes
        children
          ..add(const TextSpan(text: '\n'))
          ..add(TextSpan(
            text: '\n',
            style: TextStyle(fontSize: base.fontSize! * 0.5, height: 1),
          ));
        offset += 2;
      } else {
        children.add(const TextSpan(text: ' '));
        offset += 1;
      }
    }

    var text = word.text;
    if (i == 0 && skipFirstChar) text = text.substring(_firstCharLength(text));

    if (syllables) {
      children.addAll(_dyslexiaSpans(text, colors.text, locale!.languageCode));
    } else {
      // Le mot prononcé est recoloré par-dessus, en suivant la pastille
      children.add(TextSpan(text: text));
    }
    ranges.add(TextRange(start: offset, end: offset + text.length));
    offset += text.length;
  }

  return StoryParagraph(TextSpan(style: base, children: children), ranges);
}

/// Syllabes colorées en alternance et lettres muettes estompées.
List<InlineSpan> _dyslexiaSpans(String word, Color textColor, String language) {
  // Sur fond sombre, des teintes claires gardent un bon contraste
  final onDark = textColor.computeLuminance() > 0.5;
  final even = onDark ? Colors.blue.shade200 : Colors.blue.shade700;
  final odd = onDark ? Colors.red.shade200 : Colors.red.shade700;

  var index = 0;
  return [
    for (final piece in splitSyllables(word, language))
      switch (piece.kind) {
        SyllableKind.syllable => TextSpan(
            text: piece.text,
            style: TextStyle(color: (index++).isEven ? even : odd),
          ),
        SyllableKind.silent => TextSpan(
            text: piece.text,
            style: TextStyle(color: textColor.withValues(alpha: 0.4)),
          ),
        SyllableKind.plain => TextSpan(text: piece.text),
      },
  ];
}

@immutable
class StoryTextPage {
  const StoryTextPage(this.start, this.end);

  final int start;
  final int end;
}

class StoryPagination {
  const StoryPagination(this.pages);

  final List<StoryTextPage> pages;

  int pageOfWord(int wordIndex) {
    var low = 0;
    var high = pages.length - 1;
    var result = 0;
    while (low <= high) {
      final mid = (low + high) >> 1;
      if (pages[mid].start <= wordIndex) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return result;
  }

  bool hasSameBreaks(StoryPagination other) {
    if (other.pages.length != pages.length) return false;
    for (var i = 0; i < pages.length; i++) {
      if (other.pages[i].start != pages[i].start) return false;
    }
    return true;
  }
}

/// Découpe l'histoire en pages qui tiennent entièrement dans la zone de texte,
/// en coupant de préférence à la fin d'une phrase.
StoryPagination paginateStory(
    StoryDocument document, StoryLayoutRequest request) {
  final words = document.words;
  if (words.isEmpty) return const StoryPagination([StoryTextPage(0, 0)]);

  // Petite marge contre les écarts d'arrondi entre la mesure et l'affichage
  final maxHeight = request.area.height - 2;
  bool fits(int start, int end) =>
      layoutStoryPage(words.sublist(start, end), request).height <= maxHeight;

  final pages = <StoryTextPage>[];
  var start = 0;
  var expectedWords = 20;

  while (start < words.length) {
    final fitEnd = _largestFittingEnd(start, words.length, expectedWords, fits);
    final end = fitEnd >= words.length
        ? words.length
        : _bestBreak(words, start, fitEnd);
    pages.add(StoryTextPage(start, end));
    expectedWords = math.max(1, fitEnd - start);
    start = end;
  }

  return StoryPagination(pages);
}

int _largestFittingEnd(
  int start,
  int length,
  int expectedWords,
  bool Function(int start, int end) fits,
) {
  var low = start + 1;
  if (!fits(start, low)) return low;

  int? high;
  final guess = math.min(length, start + expectedWords);
  if (guess > low) {
    if (fits(start, guess)) {
      low = guess;
    } else {
      high = guess;
    }
  }

  if (high == null) {
    var step = math.max(1, expectedWords ~/ 4);
    while (low < length) {
      final next = math.min(length, low + step);
      if (!fits(start, next)) {
        high = next;
        break;
      }
      low = next;
      step *= 2;
    }
    if (high == null) return length;
  }

  while (high! - low > 1) {
    final mid = (low + high) >> 1;
    if (fits(start, mid)) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return low;
}

/// Fin de page la plus naturelle : fin de phrase, sinon fin de proposition,
/// à condition de garder au moins la moitié des mots qui tiennent.
int _bestBreak(List<StoryWord> words, int start, int fitEnd) {
  final minimumEnd = start + ((fitEnd - start) / 2).ceil();

  for (var end = fitEnd; end >= minimumEnd; end--) {
    if (_sentenceEnd.hasMatch(words[end - 1].text) ||
        words[end].startsParagraph) {
      return end;
    }
  }
  for (var end = fitEnd; end >= minimumEnd; end--) {
    if (_clauseEnd.hasMatch(words[end - 1].text)) return end;
  }
  return fitEnd;
}

/// Affiche une page déjà paginée, avec le mot prononcé surligné.
class StoryPageText extends StatelessWidget {
  const StoryPageText({
    super.key,
    required this.words,
    required this.request,
    required this.colors,
    this.activeIndex,
  });

  final List<StoryWord> words;
  final StoryLayoutRequest request;
  final StoryTextColors colors;
  final int? activeIndex;

  @override
  Widget build(BuildContext context) {
    final layout = layoutStoryPage(words, request,
        colors: colors, activeIndex: activeIndex);

    final Widget content;
    if (layout.cap == null) {
      content = _paragraph(layout.rest!, activeIndex);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.fromSize(
                size: layout.capBox,
                child: RichText(
                  text: layout.cap!,
                  textScaler: request.textScaler,
                  locale: request.locale,
                ),
              ),
              Expanded(child: _paragraph(layout.beside!, activeIndex)),
            ],
          ),
          if (layout.rest != null)
            _paragraph(
              layout.rest!,
              activeIndex == null
                  ? null
                  : activeIndex! - layout.besideWordCount,
            ),
        ],
      );
    }

    return SizedBox(width: request.area.width, child: content);
  }

  Widget _paragraph(StoryParagraph paragraph, int? active) {
    final range =
        active == null || active < 0 || active >= paragraph.wordRanges.length
            ? null
            : paragraph.wordRanges[active];

    // Toujours présent, même sans mot actif : la pastille peut s'effacer en fondu
    return _WordHighlight(
      span: paragraph.span,
      range: range == null || range.isCollapsed ? null : range,
      request: request,
      color: colors.highlight,
      // Avec les syllabes colorées, le mot garde leurs couleurs
      activeText: _colorsSyllables(request.metrics, request.locale)
          ? null
          : colors.activeText,
      child: RichText(
        text: paragraph.span,
        textAlign: request.metrics.effectiveTextAlign,
        textScaler: request.textScaler,
        locale: request.locale,
      ),
    );
  }
}

/// Pastille derrière le mot prononcé, et couleur du mot par-dessus. Elles
/// glissent d'un mot à l'autre sur une même ligne, et passent d'une ligne à
/// l'autre en fondu.
class _WordHighlight extends StatefulWidget {
  const _WordHighlight({
    required this.span,
    required this.range,
    required this.request,
    required this.color,
    required this.activeText,
    required this.child,
  });

  final TextSpan span;
  final TextRange? range;
  final StoryLayoutRequest request;
  final Color color;

  /// Couleur du mot prononcé ; null pour garder celle du texte.
  final Color? activeText;
  final Widget child;

  @override
  State<_WordHighlight> createState() => _WordHighlightState();
}

class _WordHighlightState extends State<_WordHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: 1,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  final _WordBoxes _boxes = _WordBoxes();

  TextRange? _from;
  TextRange? _to;

  @override
  void initState() {
    super.initState();
    _to = widget.range;
  }

  @override
  void didUpdateWidget(_WordHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Le texte est reconstruit à chaque position : on ne remesure que si sa
    // mise en page ou ses couleurs changent vraiment
    if (oldWidget.request != widget.request ||
        oldWidget.activeText != widget.activeText ||
        oldWidget.span.compareTo(widget.span) != RenderComparison.identical) {
      _boxes.invalidate();
    }
    if (widget.range == _to) return;
    _from = _to;
    _to = widget.range;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _boxes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeText = widget.activeText;
    return CustomPaint(
      painter: _WordHighlightPainter(
        boxes: _boxes,
        span: widget.span,
        request: widget.request,
        from: _from,
        to: _to,
        progress: _progress,
        color: widget.color,
      ),
      foregroundPainter: activeText == null
          ? null
          : _WordHighlightPainter(
              boxes: _boxes,
              span: widget.span,
              request: widget.request,
              from: _from,
              to: _to,
              progress: _progress,
              color: activeText,
              recolorsText: true,
            ),
      child: widget.child,
    );
  }
}

/// Mise en page du paragraphe, gardée d'une frame à l'autre pendant l'animation.
class _WordBoxes {
  TextPainter? _painter;
  TextPainter? _recolored;
  double? _width;

  void invalidate() {
    _painter?.dispose();
    _painter = null;
    _recolored?.dispose();
    _recolored = null;
  }

  /// Le paragraphe entier dans la couleur [color], sans ombres : il est
  /// découpé à la forme de la pastille.
  TextPainter recolored(
    TextSpan span,
    StoryLayoutRequest request,
    double width,
    Color color,
  ) {
    if (_width != width) invalidate();
    _width = width;
    return _recolored ??= TextPainter(
      text: TextSpan(
        text: span.text,
        style: (span.style ?? const TextStyle())
            .copyWith(color: color, shadows: const []),
        children: span.children,
      ),
      textAlign: request.metrics.effectiveTextAlign,
      textDirection: TextDirection.ltr,
      textScaler: request.textScaler,
      locale: request.locale,
    )..layout(minWidth: width, maxWidth: width);
  }

  /// Cadres du mot, un par ligne s'il est coupé.
  List<Rect> rectsFor(
    TextRange range,
    TextSpan span,
    StoryLayoutRequest request,
    double width,
  ) {
    if (_width != width) invalidate();
    var painter = _painter;
    if (painter == null) {
      painter = TextPainter(
        text: span,
        textAlign: request.metrics.effectiveTextAlign,
        textDirection: TextDirection.ltr,
        textScaler: request.textScaler,
        locale: request.locale,
      )..layout(minWidth: width, maxWidth: width);
      _painter = painter;
      _width = width;
    }
    return [
      for (final box in painter.getBoxesForSelection(
        TextSelection(baseOffset: range.start, extentOffset: range.end),
      ))
        box.toRect().inflate(2.5),
    ];
  }

  void dispose() => invalidate();
}

class _WordHighlightPainter extends CustomPainter {
  _WordHighlightPainter({
    required this.boxes,
    required this.span,
    required this.request,
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
    this.recolorsText = false,
  }) : super(repaint: progress);

  final _WordBoxes boxes;
  final TextSpan span;
  final StoryLayoutRequest request;
  final TextRange? from;
  final TextRange? to;
  final Animation<double> progress;
  final Color color;

  /// Au premier plan : repeint le texte en [color] à l'intérieur de la
  /// pastille, au lieu de dessiner la pastille elle-même.
  final bool recolorsText;

  static const Radius _radius = Radius.circular(4);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final fromRects = from == null || t >= 1
        ? const <Rect>[]
        : boxes.rectsFor(from!, span, request, size.width);
    final toRects = to == null
        ? const <Rect>[]
        : boxes.rectsFor(to!, span, request, size.width);

    // Mot suivant sur la même ligne : la pastille glisse jusqu'à lui
    if (fromRects.length == 1 &&
        toRects.length == 1 &&
        (fromRects.single.center.dy - toRects.single.center.dy).abs() < 1) {
      _draw(
        canvas,
        size,
        [Rect.lerp(fromRects.single, toRects.single, t)!],
        1,
      );
      return;
    }

    // Changement de ligne, début ou fin : fondu
    _draw(canvas, size, fromRects, 1 - t);
    _draw(canvas, size, toRects, t);
  }

  void _draw(Canvas canvas, Size size, List<Rect> rects, double opacity) {
    if (rects.isEmpty || opacity <= 0) return;
    if (!recolorsText) {
      final paint = Paint()..color = color.withValues(alpha: color.a * opacity);
      for (final rect in rects) {
        canvas.drawRRect(RRect.fromRectAndRadius(rect, _radius), paint);
      }
      return;
    }

    final text = boxes.recolored(span, request, size.width, color);
    final clip = Path();
    for (final rect in rects) {
      clip.addRRect(RRect.fromRectAndRadius(rect, _radius));
    }
    canvas
      ..save()
      ..clipPath(clip);
    if (opacity < 1) {
      canvas.saveLayer(
        clip.getBounds(),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      );
      text.paint(canvas, Offset.zero);
      canvas.restore();
    } else {
      text.paint(canvas, Offset.zero);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WordHighlightPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.color != color ||
      oldDelegate.request != request ||
      oldDelegate.span != span;
}
