class ReadingProgressModel {
  final String id;
  final String storyId;
  final int progress;
  final DateTime lastRead;

  ReadingProgressModel({
    required this.id,
    required this.storyId,
    required this.progress,
    required this.lastRead,
  });

  factory ReadingProgressModel.fromMap(
      Map<String, dynamic> data, String docId) {
    return ReadingProgressModel(
      id: docId,
      storyId: data['storyId'] ?? '',
      progress: data['progress'] ?? 0,
      lastRead: data['lastRead']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'progress': progress,
      'lastRead': lastRead,
    };
  }
}
