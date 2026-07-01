class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final String ageGroup; // "5-8", "8-12", etc.

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.ageGroup,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String docId) {
    return CategoryModel(
      id: docId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      ageGroup: data['age'] ?? '',
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
