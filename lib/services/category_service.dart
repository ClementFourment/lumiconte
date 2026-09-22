import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/category_model.dart';
import 'firebase_service.dart';

class CategoryService extends FirebaseService {
  /// Une catégorie mal renseignée est signalée puis laissée de côté : elle ne
  /// doit pas empêcher les autres de s'afficher.
  static List<CategoryModel> _parse(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final categories = <CategoryModel>[];
    for (final doc in snapshot.docs) {
      try {
        categories.add(CategoryModel.fromMap(doc.data(), doc.id));
      } catch (e) {
        debugPrint('Catégorie ignorée (${doc.id}) : $e');
      }
    }
    return categories;
  }

  // Récupérer toutes les catégories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final querySnapshot = await firestore.collection('categories').get();

      return _parse(querySnapshot);
    } catch (e) {
      debugPrint('Erreur récupération catégories: $e');
      rethrow;
    }
  }

  // Stream catégories
  Stream<List<CategoryModel>> getCategoriesStream() {
    return firestore.collection('categories').snapshots().map(_parse);
  }
}
