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

  factory FeedbackModel.fromMap(Map<String, dynamic>? map, String id) {
    final data = map ?? {};
    final rawDate = data['createdAt'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FeedbackModel(
      id: id,
      message: data['message'] as String? ?? '',
      createdAt: parsedDate,
      platform: data['platform'] as String? ?? 'Android/iOS',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'platform': platform,
    };
  }
}