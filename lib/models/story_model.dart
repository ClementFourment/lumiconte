import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String name;
  final int? age_min;
  final int? age_max;
  final String content;
  final String? image;
  final String? illustrations;
  final List<Map<String, String>>? audio;
  final String? audioTimes;
  final List<String> categoryIds;
  final String? type;
  final String? createdByProfileId;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.name,
    required this.age_min,
    required this.age_max,
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

  factory StoryModel.fromMap(Map<String, dynamic>? data, String docId) {
    final map = data ?? {};

    // Cast sécurisé du tableau Audio
    List<Map<String, String>>? parsedAudio;
    if (map['audio'] != null && map['audio'] is List) {
      parsedAudio = (map['audio'] as List).map((item) {
        if (item is Map) {
          return item
              .map((key, value) => MapEntry(key.toString(), value.toString()));
        }
        return <String, String>{};
      }).toList();
    }

    // Cast sécurisé de la date
    DateTime? parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    }

    return StoryModel(
      id: docId,
      name: map['name'] as String? ?? '',
      age_min: map['age_min'] as int? ?? null,
      age_max: map['age_max'] as int? ?? null,
      content: map['content'] as String? ?? '',
      image: map['image'] as String?,
      illustrations: map['illustrations'] as String?,
      audio: parsedAudio,
      audioTimes: map['audioTimes'] as String?,
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      type: map['type'] as String? ?? 'original',
      createdByProfileId: map['createdByProfileId'] as String? ?? '',
      createdAt: parsedDate,
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
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
