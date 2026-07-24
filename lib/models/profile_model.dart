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

  /// Factory pour lire un document Firestore
  factory ProfileModel.fromMap(
    Map<String, dynamic>? data,
    String docId,
    String userId,
  ) {
    final map = data ?? {};

    return ProfileModel(
      id: docId,
      userId: userId,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      avatarPath: map['avatarPath'], // null si non encore renseigné
      interestIds: List<String>.from(map['interests'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Map pour l'écriture dans Firestore (Création / Mise à jour)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // On n'ajoute ces champs à Firestore QUE s'ils contiennent de l'information
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      map['avatarPath'] = avatarPath;
    }

    if (interestIds.isNotEmpty) {
      map['interests'] = interestIds;
    }

    return map;
  }

  /// Pratique pour modifier un champ du profil sans devoir tout réécrire
  ProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    String? avatarPath,
    List<String>? interestIds,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarPath: avatarPath ?? this.avatarPath,
      interestIds: interestIds ?? this.interestIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}