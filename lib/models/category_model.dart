class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String ageGroup; // "5-8", "8-12", etc.

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ageGroup,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String docId) {
    return CategoryModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ageGroup: data['age'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'age': ageGroup,
    };
  }
}
