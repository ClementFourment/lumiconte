class InterestModel {
  final String id;
  final String name;
  final String image;

  InterestModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory InterestModel.fromMap(Map<String, dynamic> data, String docId) {
    return InterestModel(
      id: docId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
    };
  }
}
