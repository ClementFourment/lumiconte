import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? avatarPath;
  final List<String> interestIds;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.avatarPath,
    this.interestIds = const [],
    required this.createdAt,
  });

  factory ProfileModel.fromMap(
    Map<String, dynamic>? data,
    String docId,
    String userId,
  ) {
    final map = data ?? {};
    final rawDate = map['createdAt'];

    return ProfileModel(
      id: docId,
      userId: userId,
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      avatarPath: map['avatarPath'] as String?,
      interestIds: List<String>.from(map['interests'] ?? []),
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'age': age,
      'createdAt': Timestamp.fromDate(createdAt), // Corrige la perte de date d'origine
    };

    if (avatarPath != null && avatarPath!.isNotEmpty) {
      map['avatarPath'] = avatarPath;
    }

    if (interestIds.isNotEmpty) {
      map['interests'] = interestIds;
    }

    return map;
  }
}