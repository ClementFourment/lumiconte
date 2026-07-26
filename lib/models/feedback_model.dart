import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String message;
  final DateTime createdAt;
  final String platform;

  FeedbackModel({
    required this.id,
    required this.message,
    required this.createdAt,
    this.platform = 'Android/iOS',
  });

  /// Factory pour instancier depuis un document Firestore
  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      message: map['message'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      platform: map['platform'] as String? ?? 'Android/iOS',
    );
  }

  /// Convertit l'objet pour l'enregistrement Firestore
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'platform': platform,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? message,
    DateTime? createdAt,
    String? platform,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      platform: platform ?? this.platform,
    );
  }
}