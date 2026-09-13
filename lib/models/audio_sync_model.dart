class WordTiming {
  final String word;
  final double start;
  final double end;

  WordTiming({required this.word, required this.start, required this.end});

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'] as String? ?? '',
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      end: (json['end'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SegmentTiming {
  final double start;
  final double end;
  final String text;
  final List<WordTiming> words;

  SegmentTiming({
    required this.start,
    required this.end,
    required this.text,
    required this.words,
  });

  factory SegmentTiming.fromJson(Map<String, dynamic> json) {
    return SegmentTiming(
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      end: (json['end'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      words: (json['words'] as List<dynamic>?)
              ?.map((w) => WordTiming.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
