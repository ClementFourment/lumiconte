class StoryModel {
  final String id;
  final String name;
  final String content;
  final String? image;
  final String? illustrations;
  final List<Map<String, String>>? audio;
  final String? audioTimes;
  final List<String> categoryIds;
  final String? type; // 'original' ou 'generated'
  final String? createdByProfileId;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.name,
    required this.content,
    this.image,
    this.illustrations,
    this.audio,
    this.audioTimes,
    this.categoryIds = const [],
    this.type = 'original',
    this.createdByProfileId = '',
    this.createdAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic> data, String docId) {
    return StoryModel(
      id: docId,
      name: data['name'] ?? '',
      content: data['content'] ?? '',
      image: data['image'],
      illustrations: data['illustrations'],
      audio: data['audio'] != null
          ? (data['audio'] as List<dynamic>)
              .map((item) => Map<String, String>.from(item as Map))
              .toList()
          : null, // Accepte null si l'audio n'existe pas
      audioTimes: data['audioTimes'],
      categoryIds: data['categoryIds'] != null
          ? List<String>.from(data['categoryIds'])
          : [],
      type: data['type'] ?? 'original',
      createdByProfileId: data['createdByProfileId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'content': content,
      'image': image,
      'illustrations': illustrations,
      'audio': audio,
      'audioTimes': audioTimes,
      'categoryIds': categoryIds,
      'type': type,
      'createdByProfileId': createdByProfileId,
      'createdAt': createdAt,
    };
  }
}
