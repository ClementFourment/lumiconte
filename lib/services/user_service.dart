import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/user_model.dart';

import 'firebase_service.dart';

class UserService extends FirebaseService {
  // Créer ou mettre à jour un user
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await setData('users/${user.uid}', user.toMap());
    } catch (e) {
      print('Erreur création/update user: $e');
      rethrow;
    }
  }

  // Récupérer un user
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await getData('users/$userId');
      if (data != null) {
        return UserModel.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      print('Erreur récupération user: $e');
      rethrow;
    }
  }

  // Mettre à jour subscription
  Future<void> updateSubscription(String userId, bool subscribed) async {
    try {
      await updateData('users/$userId', {'subscribed': subscribed});
    } catch (e) {
      print('Erreur update subscription: $e');
      rethrow;
    }
  }

  // Stream temps réel
  Stream<UserModel?> getUserStream(String userId) {
    return firestore.doc('users/$userId').snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, userId);
      }
      return null;
    });
  }
}
