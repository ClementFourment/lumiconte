import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String id;
  final int fontSize;
  final String theme;     // Thème de l'application (ex: light, dark)
  final String readTheme; // Thème de lecture (ex: light, dark, naturel)
  final bool dyslexia;
  final String langage;
  final int totalReadingTime;
  final int streak;
  final DateTime? stopRead;

  // Valeurs par défaut centralisées
  static const int defaultFontSize = 16;
  static const String defaultTheme = 'light';
  static const String defaultReadTheme = 'light';
  static const bool defaultDyslexia = false;
  static const String defaultLangage = 'fr';
  static const int defaultTotalReadingTime = 0;
  static const int defaultStreak = 0;

  const SettingsModel({
    required this.id,
    this.fontSize = defaultFontSize,
    this.theme = defaultTheme,
    this.readTheme = defaultReadTheme,
    this.dyslexia = defaultDyslexia,
    this.langage = defaultLangage,
    this.totalReadingTime = defaultTotalReadingTime,
    this.streak = defaultStreak,
    this.stopRead,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data, String docId) {
    return SettingsModel(
      id: docId,
      fontSize: (data['fontSize'] as int?) ?? defaultFontSize,
      theme: (data['theme'] as String?) ?? defaultTheme,
      // On lit 'read_theme', ou 'readTheme', ou fallback sur 'theme' / valeur par défaut
      readTheme: (data['read_theme'] as String?) ??
          (data['readTheme'] as String?) ??
          (data['theme'] as String?) ??
          defaultReadTheme,
      dyslexia: (data['dyslexia'] as bool?) ?? defaultDyslexia,
      langage: (data['langage'] as String?) ??
          (data['language'] as String?) ??
          defaultLangage,
      totalReadingTime:
          (data['totalReadingTime'] as int?) ?? defaultTotalReadingTime,
      streak: (data['streak'] as int?) ?? defaultStreak,
      stopRead: data['stopread'] != null
          ? (data['stopread'] as Timestamp).toDate()
          : (data['stopRead'] != null
              ? (data['stopRead'] as Timestamp).toDate()
              : null),
    );
  }

  factory SettingsModel.fromSnapshot(DocumentSnapshot doc) {
    return SettingsModel.fromMap(
      doc.data() as Map<String, dynamic>? ?? {},
      doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'theme': theme,
      'read_theme': readTheme,
      'dyslexia': dyslexia,
      'langage': langage,
      'totalReadingTime': totalReadingTime,
      'streak': streak,
      'stopread': stopRead != null ? Timestamp.fromDate(stopRead!) : null,
    };
  }

  /// Getters utilitaires pour l'affichage propre
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
    String? langage,
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
      langage: langage ?? this.langage,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      streak: streak ?? this.streak,
      stopRead: stopRead ?? this.stopRead,
    );
  }

  @override
  String toString() =>
      'SettingsModel(id: $id, fontSize: $fontSize, theme: $theme, readTheme: $readTheme, dyslexia: $dyslexia, langage: $langage, totalReadingTime: $totalReadingTime, streak: $streak, stopRead: $stopRead)';
}