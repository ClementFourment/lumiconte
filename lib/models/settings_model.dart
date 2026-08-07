import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String id;
  final int fontSize;
  final String theme; // Thème de l'application (ex: light, dark)
  final String readTheme; // Thème de lecture (ex: classic, immersive, manuscript)
  final bool dyslexia;
  final String language;
  final int totalReadingTime;
  final int streak;
  final DateTime? stopRead;

  // Valeurs par défaut centralisées
  static const int defaultFontSize = 16;
  static const String defaultTheme = 'light';
  static const String defaultReadTheme = 'classic';
  static const bool defaultDyslexia = false;
  static const String defaultLanguage = 'fr';
  static const int defaultTotalReadingTime = 0;
  static const int defaultStreak = 0;

  const SettingsModel({
    required this.id,
    this.fontSize = defaultFontSize,
    this.theme = defaultTheme,
    this.readTheme = defaultReadTheme,
    this.dyslexia = defaultDyslexia,
    this.language = defaultLanguage,
    this.totalReadingTime = defaultTotalReadingTime,
    this.streak = defaultStreak,
    this.stopRead,
  });

  factory SettingsModel.fromMap(Map<String, dynamic>? data, String docId) {
    final map = data ?? {};

    // 1. Gestion propre et simplifiée de stopRead (supporte 'stopRead' et 'stopread' sans doublon de cast)
    final rawStopRead = map['stopRead'] ?? map['stopread'];
    DateTime? parsedStopRead;
    if (rawStopRead is Timestamp) {
      parsedStopRead = rawStopRead.toDate();
    } else if (rawStopRead is String) {
      parsedStopRead = DateTime.tryParse(rawStopRead);
    }

    return SettingsModel(
      id: docId,
      fontSize: (map['fontSize'] as num?)?.toInt() ?? defaultFontSize,
      theme: map['theme'] as String? ?? defaultTheme,
      readTheme: map['readTheme'] as String? ?? defaultReadTheme,
      dyslexia: map['dyslexia'] as bool? ?? defaultDyslexia,

      language: map['language'] as String? ?? defaultLanguage,
      totalReadingTime: (map['totalReadingTime'] as num?)?.toInt() ?? defaultTotalReadingTime,
      streak: (map['streak'] as num?)?.toInt() ?? defaultStreak,
      stopRead: parsedStopRead,
    );
  }

  factory SettingsModel.fromSnapshot(DocumentSnapshot doc) {
    return SettingsModel.fromMap(
      doc.data() as Map<String, dynamic>?,
      doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'theme': theme,
      'readTheme': readTheme,
      'dyslexia': dyslexia,
      'language': language,
      'totalReadingTime': totalReadingTime,
      'streak': streak,
      'stopRead': stopRead != null ? Timestamp.fromDate(stopRead!) : null,
    };
  }

  /// Getters utilitaires
  String get formattedReadingTime {
    if (totalReadingTime < 60) return '$totalReadingTime min';
    final hours = totalReadingTime ~/ 60;
    final minutes = totalReadingTime % 60;
    return minutes > 0 ? '${hours}h $minutes' : '${hours}h';
  }

  String get formattedStreak {
    return '$streak ${streak > 1 ? 'jours' : 'jour'}';
  }

  SettingsModel copyWith({
    String? id,
    int? fontSize,
    String? theme,
    String? readTheme,
    bool? dyslexia,
    String? language,
    int? totalReadingTime,
    int? streak,
    DateTime? stopRead,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      readTheme: readTheme ?? this.readTheme,
      dyslexia: dyslexia ?? this.dyslexia,
      language: language ?? this.language,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      streak: streak ?? this.streak,
      stopRead: stopRead ?? this.stopRead,
    );
  }

  @override
  String toString() =>
      'SettingsModel(id: $id, fontSize: $fontSize, theme: $theme, readTheme: $readTheme, dyslexia: $dyslexia, language: $language, totalReadingTime: $totalReadingTime, streak: $streak, stopRead: $stopRead)';
}