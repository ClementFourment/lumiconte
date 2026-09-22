import 'package:lumiconte/models/localized_text.dart';

export 'package:lumiconte/models/localized_text.dart';

class CategoryModel {
  final String id;
  final LocalizedText name;
  final String image;
  final LocalizedText description;
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
    final age = map['age'] ?? map['ageGroup'];
    return CategoryModel(
      id: docId,
      name: LocalizedText.fromAny(map['name']),
      image: map['image'] is String ? map['image'] as String : '',
      description: LocalizedText.fromAny(map['description']),
      ageGroup: age is String ? age : '',
    );
  }

  /// Nom dans la langue du profil.
  String get displayName => name.display;

  /// Description dans la langue du profil.
  String get displayDescription => description.display;

  Map<String, dynamic> toMap() {
    return {
      'name': name.toMap(),
      'image': image,
      'description': description.toMap(),
      'age': ageGroup,
    };
  }
}
