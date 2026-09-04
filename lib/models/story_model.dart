import 'package:cloud_firestore/cloud_firestore.dart';

class AudioVoiceData {
  final String url;
  final String audioTimes;

  AudioVoiceData({
    required this.url,
    required this.audioTimes,
  });

  factory AudioVoiceData.fromMap(Map<String, dynamic> map) {
    return AudioVoiceData(
      url: map['url'] as String? ?? '',
      audioTimes: map['audioTimes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'audioTimes': audioTimes,
    };
  }
}

class StoryModel {
  final String id;
  final String name;
  final int? age_min;
  final int? age_max;
  final String content;
  final String morals;
  final String? image;
  final String? illustrations;
  final Map<String, AudioVoiceData>? audio; // Map de types de voix ("femme", "homme")
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
    this.morals = '',
    this.image,
    this.illustrations,
    this.audio,
    this.categoryIds = const [],
    this.type = 'original',
    this.createdByProfileId = '',
    this.createdAt,
  });

  factory StoryModel.fromMap(Map<String, dynamic>? data, String docId) {
    final map = data ?? {};

    Map<String, AudioVoiceData>? parsedAudio;

    if (map['audio'] != null) {
      parsedAudio = {};
      
      // Cas 1 : Map directe dans Firestore (ex: { femme: { url: ..., audioTimes: ... }, homme: ... })
      if (map['audio'] is Map) {
        (map['audio'] as Map).forEach((key, value) {
          if (value is Map) {
            parsedAudio![key.toString()] = AudioVoiceData.fromMap(
              Map<String, dynamic>.from(value),
            );
          }
        });
      } 
      // Cas 2 : Si au format liste d'éléments Map
      else if (map['audio'] is List) {
        for (var item in (map['audio'] as List)) {
          if (item is Map) {
            item.forEach((key, value) {
              if (value is Map) {
                parsedAudio![key.toString()] = AudioVoiceData.fromMap(
                  Map<String, dynamic>.from(value),
                );
              }
            });
          }
        }
      }
    }

    DateTime? parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    }

    return StoryModel(
      id: docId,
      name: map['name'] as String? ?? '',
      age_min: map['age_min'] as int?,
      age_max: map['age_max'] as int?,
      content: map['content'] as String? ?? '',
      morals: map['morals'] as String? ?? '',
      image: map['image'] as String?,
      illustrations: map['illustrations'] as String?,
      audio: parsedAudio,
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      type: map['type'] as String? ?? 'original',
      createdByProfileId: map['createdByProfileId'] as String? ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age_min': age_min,
      'age_max': age_max,
      'content': content,
      'morals': morals,
      'image': image,
      'illustrations': illustrations,
      'audio': audio?.map((key, value) => MapEntry(key, value.toMap())),
      'categoryIds': categoryIds,
      'type': type,
      'createdByProfileId': createdByProfileId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}