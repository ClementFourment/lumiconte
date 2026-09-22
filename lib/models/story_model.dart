import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/app_language.dart';
import 'package:lumiconte/models/localized_text.dart';

export 'package:lumiconte/models/localized_text.dart';

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
  final LocalizedText name;
  final int? age_min;
  final int? age_max;
  final LocalizedText content;
  final LocalizedText morals;
  final String? image;
  final String? illustrations;
  final Map<String, AudioVoiceData>? audio; // Voix par langue ("fr_femme", "en_homme", "es_femme"...)
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
    this.morals = const LocalizedText.empty(),
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
      name: LocalizedText.fromAny(map['name']),
      age_min: (map['age_min'] as num?)?.toInt(),
      age_max: (map['age_max'] as num?)?.toInt(),
      content: LocalizedText.fromAny(map['content']),
      morals: LocalizedText.fromAny(map['morals']),
      image: map['image'] is String ? map['image'] as String : null,
      illustrations:
          map['illustrations'] is String ? map['illustrations'] as String : null,
      audio: parsedAudio,
      categoryIds: [
        if (map['categoryIds'] is List)
          for (final id in map['categoryIds'] as List)
            if (id is String) id,
      ],
      type: map['type'] is String ? map['type'] as String : 'original',
      createdByProfileId: map['createdByProfileId'] is String
          ? map['createdByProfileId'] as String
          : '',
      createdAt: parsedDate,
    );
  }

  /// Langues des voix : les clés audio sont préfixées ("fr_femme", "en_homme"...).
  /// Mêmes langues que celles proposées dans les réglages.
  static List<String> get voiceLanguages => AppLanguage.codes;

  /// Titre dans la langue du profil.
  String get displayName => name.display;

  /// Texte de l'histoire dans la langue du profil.
  String get displayContent => content.display;

  /// Morale dans la langue du profil.
  String get displayMorals => morals.display;

  /// Voix de la langue choisie : le genre demandé s'il existe, sinon l'autre
  /// voix de la même langue. Jamais de voix d'une autre langue.
  AudioVoiceData? voiceFor(String? language, String? voiceGender) {
    final lang = AppLanguage.sanitize(language);
    final requested =
        (voiceGender == 'homme' || voiceGender == 'male') ? 'homme' : 'femme';
    final alternate = requested == 'homme' ? 'femme' : 'homme';
    for (final gender in [requested, alternate]) {
      final voice = audio?['${lang}_$gender'];
      if (voice != null && voice.url.trim().isNotEmpty) return voice;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.toMap(),
      'age_min': age_min,
      'age_max': age_max,
      'content': content.toMap(),
      'morals': morals.toMap(),
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