import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/user_model.dart';
import 'firebase_service.dart';

class UserService extends FirebaseService {
  // ---------------------------------------------------------------------------
  // CRÉATION & LECTURE
  // ---------------------------------------------------------------------------

  /// Créer ou mettre à jour un utilisateur complet
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await setData('users/${user.uid}', user.toMap());
    } catch (e) {
      debugPrint('Erreur création/update user: $e');
      rethrow;
    }
  }

  /// Récupérer les données d'un utilisateur
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await getData('users/$userId');
      if (data != null) {
        return UserModel.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur récupération user: $e');
      rethrow;
    }
  }

  /// Vérifier si le document utilisateur existe déjà dans Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await firestore.doc('users/$userId').get();
      return doc.exists;
    } catch (e) {
      debugPrint('Erreur vérification existence user: $e');
      return false;
    }
  }

  /// Flux en temps réel (Stream) des données de l'utilisateur
  Stream<UserModel?> getUserStream(String userId) {
    return firestore.doc('users/$userId').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, userId);
      }
      return null;
    });
  }

  // ---------------------------------------------------------------------------
  // MISES À JOUR SPÉCIFIQUES
  // ---------------------------------------------------------------------------

  /// Mettre à jour le statut d'abonnement
  Future<void> updateSubscription(String userId, bool subscribed) async {
    try {
      await updateData('users/$userId', {'subscribed': subscribed});
    } catch (e) {
      debugPrint('Erreur update subscription: $e');
      rethrow;
    }
  }

  /// Mettre à jour le profil (nom d'affichage et/ou photo)
  Future<void> updateUserProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await updateData('users/$userId', updates);
      }
    } catch (e) {
      debugPrint('Erreur update profil user: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SUPPRESSION
  // ---------------------------------------------------------------------------

  /// Supprimer le document utilisateur (consigne RGPD)
  Future<void> deleteUser(String userId) async {
    try {
      await deleteData('users/$userId');
    } catch (e) {
      debugPrint('Erreur suppression user: $e');
      rethrow;
    }
  }
}