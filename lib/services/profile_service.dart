import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';
import 'firebase_service.dart';

class ProfileService extends FirebaseService {
  // Créer un profil
  Future<String> createProfile(
    String userId, {
    required String name,
    required int age,
    List<String> interestIds = const [],
  }) async {
    try {
      final docRef = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .add({
        'name': name,
        'age': age,
        'interests': interestIds,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Erreur création profil: $e');
      rethrow;
    }
  }

  // Récupérer tous les profils
  Future<List<ProfileModel>> getUserProfiles(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProfileModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id, userId))
          .toList();
    } catch (e) {
      print('Erreur récupération profils: $e');
      rethrow;
    }
  }

  // Récupérer un profil
  Future<ProfileModel?> getProfile(String userId, String profileId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .get();

      if (doc.exists) {
        return ProfileModel.fromMap(
            doc.data() as Map<String, dynamic>, profileId, userId);
      }
      return null;
    } catch (e) {
      print('Erreur récupération profil: $e');
      rethrow;
    }
  }

  // Mettre à jour profil
  Future<void> updateProfile(
    String userId,
    String profileId, {
    String? name,
    int? age,
    List<String>? interestIds,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (interestIds != null) updates['interests'] = interestIds;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .update(updates);
    } catch (e) {
      print('Erreur update profil: $e');
      rethrow;
    }
  }

  // Ajouter un intérêt
  Future<void> addInterest(
    String userId,
    String profileId,
    String interestId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .update({
        'interests': FieldValue.arrayUnion([interestId]),
      });
    } catch (e) {
      print('Erreur ajout intérêt: $e');
      rethrow;
    }
  }

  // Stream profils
  Stream<List<ProfileModel>> getUserProfilesStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ProfileModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id, userId))
          .toList();
    });
  }
}
