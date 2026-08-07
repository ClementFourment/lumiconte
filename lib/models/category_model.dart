class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final String ageGroup;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.ageGroup,
  });

  factory CategoryModel.fromMap(Map<String, dynamic>? data, String docId) {
    final map = data ?? {};
    return CategoryModel(
      id: docId,
      name: map['name'] as String? ?? '',
      image: map['image'] as String? ?? '',
      description: map['description'] as String? ?? '',
      ageGroup: (map['age'] ?? map['ageGroup']) as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'age': ageGroup,
    };
  }
}