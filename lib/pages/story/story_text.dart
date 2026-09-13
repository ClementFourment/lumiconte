import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumiconte/models/audio_sync_model.dart';

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

  bool isSpokenAt(double seconds) =>
      start != null && end != null && seconds >= start! && seconds <= end!;

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

  TextStyle get baseStyle => dyslexia
      ? TextStyle(
          fontSize: fontSize + 4,
          letterSpacing: 1.8,
          height: 1.6,
          fontWeight: FontWeight.bold,
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

  /// Couleur du mot prononcé (hors mode dyslexie, qui garde ses couleurs de syllabes).
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
    textAlign: request.metrics.textAlign,
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

  final paragraph = _buildParagraph(words, metrics, colors, activeIndex);
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
    (cap.text!, metrics.dropCapFontFamily, metrics.fontSize, request.textScaler),
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

  final all = _buildParagraph(words, metrics, colors, activeIndex,
      skipFirstChar: true);
  final painter = _layoutPainter(all.span, request, narrowWidth);
  final rows = math.max(1, (capBox.height / painter.preferredLineHeight).ceil());
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
      : _buildParagraph(words.sublist(0, besideCount), metrics, colors,
          activeIndex,
          skipFirstChar: true);
  final besideHeight =
      besideIsAll ? allHeight : _measureHeight(beside, request, narrowWidth);

  StoryParagraph? rest;
  var restHeight = 0.0;
  if (besideCount < words.length) {
    rest = _buildParagraph(words.sublist(besideCount), metrics, colors,
        activeIndex == null ? null : activeIndex - besideCount);
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

StoryParagraph _buildParagraph(
  List<StoryWord> words,
  StoryTextMetrics metrics,
  StoryTextColors colors,
  int? activeIndex, {
  bool skipFirstChar = false,
}) {
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

    if (metrics.dyslexia) {
      children.addAll(_dyslexiaSpans(text, colors.text));
    } else {
      children.add(TextSpan(
        text: text,
        style: i == activeIndex ? TextStyle(color: colors.activeText) : null,
      ));
    }
    ranges.add(TextRange(start: offset, end: offset + text.length));
    offset += text.length;
  }

  return StoryParagraph(TextSpan(style: base, children: children), ranges);
}

final RegExp _leadingNonLetters = RegExp(r'^[^\p{L}]+', unicode: true);
final RegExp _trailingNonLetters = RegExp(r'[^\p{L}]+$', unicode: true);
final RegExp _silentEnding =
    RegExp(r'(ts|ds|es|[stdxega])$', caseSensitive: false);
final RegExp _syllable = RegExp(
  r'[^aeiouyéèàùûâîôœüéèêë]*[aeiouyéèàùûâîôœüéèêë]+(?:[^aeiouyéèàùûâîôœüéèêë](?![aeiouyéèàùûâîôœüéèêë]))*',
  caseSensitive: false,
);

/// Syllabes colorées en alternance et lettres muettes estompées.
List<InlineSpan> _dyslexiaSpans(String word, Color textColor) {
  final prefix = _leadingNonLetters.firstMatch(word)?.group(0) ?? '';
  final afterPrefix = word.substring(prefix.length);
  final suffix = _trailingNonLetters.firstMatch(afterPrefix)?.group(0) ?? '';
  var cleanWord =
      afterPrefix.substring(0, afterPrefix.length - suffix.length);

  if (cleanWord.isEmpty) return [TextSpan(text: word)];

  var silentLetters = '';
  final silentMatch = _silentEnding.firstMatch(cleanWord);
  if (silentMatch != null &&
      cleanWord.length > 2 &&
      !['les', 'des', 'mes', 'tes', 'ses', 'est']
          .contains(cleanWord.toLowerCase())) {
    final potentialSilent = silentMatch.group(0)!;
    if (cleanWord.length > potentialSilent.length) {
      silentLetters = potentialSilent;
      cleanWord =
          cleanWord.substring(0, cleanWord.length - silentLetters.length);
    }
  }

  final syllables = <String>[];
  if (cleanWord.length <= 3) {
    syllables.add(cleanWord);
  } else {
    syllables.addAll(_syllable.allMatches(cleanWord).map((m) => m.group(0)!));
    final covered = syllables.join().length;
    if (syllables.isEmpty) {
      syllables.add(cleanWord);
    } else if (covered < cleanWord.length) {
      syllables[syllables.length - 1] += cleanWord.substring(covered);
    }
  }

  return [
    if (prefix.isNotEmpty) TextSpan(text: prefix),
    for (var i = 0; i < syllables.length; i++)
      if (syllables[i].isNotEmpty)
        TextSpan(
          text: syllables[i],
          style: TextStyle(
            color: i.isEven ? Colors.blue.shade700 : Colors.red.shade700,
          ),
        ),
    if (silentLetters.isNotEmpty)
      TextSpan(
        text: silentLetters,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.35),
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
        ),
      ),
    if (suffix.isNotEmpty) TextSpan(text: suffix),
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
    final end =
        fitEnd >= words.length ? words.length : _bestBreak(words, start, fitEnd);
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
    final text = RichText(
      text: paragraph.span,
      textAlign: request.metrics.textAlign,
      textScaler: request.textScaler,
      locale: request.locale,
    );
    if (active == null || active < 0 || active >= paragraph.wordRanges.length) {
      return text;
    }
    final range = paragraph.wordRanges[active];
    if (range.isCollapsed) return text;

    return CustomPaint(
      painter: _WordHighlightPainter(
        span: paragraph.span,
        range: range,
        request: request,
        color: colors.highlight,
      ),
      child: text,
    );
  }
}

class _WordHighlightPainter extends CustomPainter {
  _WordHighlightPainter({
    required this.span,
    required this.range,
    required this.request,
    required this.color,
  });

  final TextSpan span;
  final TextRange range;
  final StoryLayoutRequest request;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: span,
      textAlign: request.metrics.textAlign,
      textDirection: TextDirection.ltr,
      textScaler: request.textScaler,
      locale: request.locale,
    )..layout(minWidth: size.width, maxWidth: size.width);

    final paint = Paint()..color = color;
    final boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: range.start, extentOffset: range.end),
    );
    for (final box in boxes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box.toRect().inflate(2.5),
          const Radius.circular(4),
        ),
        paint,
      );
    }
    painter.dispose();
  }

  @override
  bool shouldRepaint(_WordHighlightPainter oldDelegate) =>
      oldDelegate.range != range ||
      oldDelegate.color != color ||
      oldDelegate.request != request ||
      oldDelegate.span != span;
}
