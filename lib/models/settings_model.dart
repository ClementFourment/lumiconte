class SettingsModel {
  final String id;
  final int fontSize;
  final String theme;
  final bool dyslexia;
  final String voice;
  final bool autoReader;

  SettingsModel({
    required this.id,
    this.fontSize = 16,
    this.theme = 'light',
    this.dyslexia = false,
    this.voice = 'default',
    this.autoReader = false,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data, String docId) {
    return SettingsModel(
      id: docId,
      fontSize: data['fontSize'] ?? 16,
      theme: data['theme'] ?? 'light',
      dyslexia: data['dyslexia'] ?? false,
      voice: data['voice'] ?? 'default',
      autoReader: data['autoReader'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'theme': theme,
      'dyslexia': dyslexia,
      'voice': voice,
      'autoReader': autoReader,
    };
  }
}
