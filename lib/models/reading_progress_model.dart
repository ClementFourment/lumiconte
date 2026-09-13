class ReadingProgressModel {
  final String id;
  final String storyId;
  final double progress;
  final DateTime lastRead;
  final bool moraleUnlocked;

  ReadingProgressModel({
    required this.id,
    required this.storyId,
    required this.progress,
    required this.lastRead,
    required this.moraleUnlocked,
  });

  factory ReadingProgressModel.fromMap(
      Map<String, dynamic> data, String docId) {
    return ReadingProgressModel(
      id: docId,
      storyId: data['storyId'] ?? '',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      lastRead: data['lastRead']?.toDate() ?? DateTime.now(),
      moraleUnlocked: moraleUnlockedFrom(data),
    );
  }

  /// Sans champ `moraleUnlocked` (documents créés avant son ajout), une histoire déjà
  /// terminée garde sa morale débloquée.
  static bool moraleUnlockedFrom(Map<String, dynamic> data) {
    final unlocked = data['moraleUnlocked'];
    if (unlocked is bool) return unlocked;
    return ((data['progress'] as num?) ?? 0) >= 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'progress': progress,
      'lastRead': lastRead,
      'moraleUnlocked': moraleUnlocked,
    };
  }
}
