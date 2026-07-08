class StoryModel {
  final String id;
  final String name;
  final String content;
  final String image;
  final List<Map<String, String>> audio;
  final String audioTimes;
  final List<String> categoryIds;
  final String type; // 'original' ou 'generated'
  final String createdByProfileId;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.name,
    required this.content,
    required this.image,
    required this.audio,
    required this.audioTimes,
    this.categoryIds = const [],
    this.type = 'original',
    this.createdByProfileId = '',
    required this.createdAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic> data, String docId) {
    return StoryModel(
      id: docId,
      name: data['name'] ?? '',
      content: data['content'] ?? '',
      image: data['image'] ?? '',
      audio: (data['audio'] as List<dynamic>? ?? [])
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
      audioTimes: data['audioTimes'] ?? '',
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      type: data['type'] ?? 'original',
      createdByProfileId: data['createdByProfileId'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'content': content,
      'image': image,
      'audio': audio,
      'audioTimes': audioTimes,
      'categoryIds': categoryIds,
      'type': type,
      'createdByProfileId': createdByProfileId,
      'createdAt': createdAt,
    };
  }
}
