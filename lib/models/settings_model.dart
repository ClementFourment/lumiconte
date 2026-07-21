class SettingsModel {
  final String id;
  final int fontSize;
  final String theme;
  final bool dyslexia;

  // Valeurs par défaut centralisées
  static const int defaultFontSize = 16;
  static const String defaultTheme = 'light';
  static const bool defaultDyslexia = false;

  const SettingsModel({
    required this.id,
    this.fontSize = defaultFontSize,
    this.theme = defaultTheme,
    this.dyslexia = defaultDyslexia,
  });

  /// Crée un SettingsModel à partir des données Firestore
  factory SettingsModel.fromMap(Map<String, dynamic> data, String docId) {
    return SettingsModel(
      id: docId,
      fontSize: (data['fontSize'] as int?) ?? defaultFontSize,
      theme: (data['theme'] as String?) ?? defaultTheme,
      dyslexia: (data['dyslexia'] as bool?) ?? defaultDyslexia,
    );
  }

  /// Convertit le modèle en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'theme': theme,
      'dyslexia': dyslexia,
    };
  }

  /// Crée une copie avec certains champs modifiés (copyWith pattern)
  SettingsModel copyWith({
    String? id,
    int? fontSize,
    String? theme,
    bool? dyslexia,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      dyslexia: dyslexia ?? this.dyslexia,
    );
  }

  @override
  String toString() =>
      'SettingsModel(id: $id, fontSize: $fontSize, theme: $theme, dyslexia: $dyslexia)';
}
