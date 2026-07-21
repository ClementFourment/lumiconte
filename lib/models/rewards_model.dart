class BadgeModel {
  final String id;
  final String name; // Issu du champ 'series_lectures' ou 'badges_lectures'

  BadgeModel({
    required this.id,
    required this.name,
  });

  /// Factory pour créer un BadgeModel depuis Firestore
  factory BadgeModel.fromMap(Map<String, dynamic> data, String docId) {
    return BadgeModel(
      id: docId.trim().toLowerCase(),
      // On vérifie les deux clés possibles selon qu'il s'agisse de la collection globale ou du profil utilisateur
      name: (data['series_lectures'] ?? data['badges_lectures'] ?? 'Badge').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'series_lectures': name,
    };
  }
}