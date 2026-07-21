class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? avatarPath; // Nouveau : chemin ou URL de l'avatar
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
      Map<String, dynamic> data, String docId, String userId) {
    return ProfileModel(
      id: docId,
      userId: userId,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      avatarPath: data['avatarPath'],
      interestIds: List<String>.from(data['interests'] ?? []),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      if (avatarPath != null) 'avatarPath': avatarPath,
      'interests': interestIds,
      'createdAt': createdAt,
    };
  }

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