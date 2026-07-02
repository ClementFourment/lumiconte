import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/category_model.dart';
import 'firebase_service.dart';

class CategoryService extends FirebaseService {
  // Récupérer toutes les catégories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final querySnapshot = await firestore.collection('categories').get();

      return querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur récupération catégories: $e');
      rethrow;
    }
  }

  // Stream catégories
  Stream<List<CategoryModel>> getCategoriesStream() {
    return firestore.collection('categories').snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
