class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final int age;
  final List<String> interestIds;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
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
      interestIds: List<String>.from(data['interests'] ?? []),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'interests': interestIds,
      'createdAt': createdAt,
    };
  }
}
