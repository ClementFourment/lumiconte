import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'firebase_service.dart';

class ProfileService extends FirebaseService {
  /// Collection de référence pour les profils d'un utilisateur
  CollectionReference<Map<String, dynamic>> _getProfilesRef(String userId) {
    return firestore.collection('users').doc(userId).collection('profiles');
  }

  // ---------------------------------------------------------------------------
  // SELECTION DU PROFIL ACTIF
  // ---------------------------------------------------------------------------

  /// Définir le profil actuellement actif pour un utilisateur
  Future<void> setActiveProfile(String userId, String profileId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'activeProfileId': profileId,
        'lastProfileChangedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur lors de la sélection du profil actif: $e');
      rethrow;
    }
  }

  /// Récupérer l'ID du profil actif
  Future<String?> getActiveProfileId(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['activeProfileId'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur récupération du profil actif: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CREATION & LECTURE
  // ---------------------------------------------------------------------------

  /// Créer un nouveau profil enfant
  Future<String> createProfile(
    String userId, {
    required String name,
    required int age,
    String? avatarPath,
    List<String> interestIds = const [],
  }) async {
    try {
      final newProfile = ProfileModel(
        id: '',
        userId: userId,
        name: name,
        age: age,
        avatarPath: avatarPath,
        interestIds: interestIds,
        createdAt: DateTime.now(),
      );

      final docRef = await _getProfilesRef(userId).add(newProfile.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Erreur création profil: $e');
      rethrow;
    }
  }

  /// Créer un nouveau profil ET le définir directement comme profil actif
  Future<String> createAndSetActiveProfile(
    String userId, {
    required String name,
    required int age,
    String? avatarPath,
    List<String> interestIds = const [],
  }) async {
    try {
      final newProfileId = await createProfile(
        userId,
        name: name,
        age: age,
        avatarPath: avatarPath,
        interestIds: interestIds,
      );

      await setActiveProfile(userId, newProfileId);

      return newProfileId;
    } catch (e) {
      debugPrint('Erreur création et activation profil: $e');
      rethrow;
    }
  }

  /// Récupérer tous les profils d'un utilisateur
  Future<List<ProfileModel>> getUserProfiles(String userId) async {
    try {
      final querySnapshot = await _getProfilesRef(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProfileModel.fromMap(doc.data(), doc.id, userId))
          .toList();
    } catch (e) {
      debugPrint('Erreur récupération profils: $e');
      rethrow;
    }
  }

  /// Récupérer un profil spécifique
  Future<ProfileModel?> getProfile(String userId, String profileId) async {
    try {
      final doc = await _getProfilesRef(userId).doc(profileId).get();

      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data()!, profileId, userId);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur récupération profil: $e');
      rethrow;
    }
  }

  /// Écouter un profil spécifique en temps réel (Stream)
  Stream<ProfileModel?> getProfileStream(String userId, String profileId) {
    return _getProfilesRef(userId).doc(profileId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data()!, profileId, userId);
      }
      return null;
    });
  }

  /// Flux en temps réel (Stream) des profils d'un utilisateur
  Stream<List<ProfileModel>> getUserProfilesStream(String userId) {
    return _getProfilesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ProfileModel.fromMap(doc.data(), doc.id, userId))
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // MISE A JOUR DES INFORMATIONS DE BASE
  // ---------------------------------------------------------------------------

  Future<void> updateProfile(
    String userId,
    String profileId, {
    String? name,
    int? age,
    String? avatarPath,
    List<String>? interestIds,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (avatarPath != null) updates['avatarPath'] = avatarPath;
      if (interestIds != null) updates['interests'] = interestIds;

      if (updates.isNotEmpty) {
        await _getProfilesRef(userId).doc(profileId).update(updates);
      }
    } catch (e) {
      debugPrint('Erreur update profil: $e');
      rethrow;
    }
  }

  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _getProfilesRef(profile.userId)
          .doc(profile.id)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur sauvegarde profil: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GESTION DE LA PROGRESSION & LECTURE
  // ---------------------------------------------------------------------------

  Future<void> markStoryAsCompleted(
    String userId,
    String profileId,
    String storyId, {
    List<String> newBadgeIds = const [],
    int readingTimeMinutes = 0,
  }) async {
    try {
      final updates = <String, dynamic>{
        'completedStoryIds': FieldValue.arrayUnion([storyId]),
        'storyProgress.$storyId': FieldValue.delete(),
      };

      if (newBadgeIds.isNotEmpty) {
        updates['unlockedBadgeIds'] = FieldValue.arrayUnion(newBadgeIds);
      }

      if (readingTimeMinutes > 0) {
        updates['readingTimeMinutes'] =
            FieldValue.increment(readingTimeMinutes);
      }

      await _getProfilesRef(userId).doc(profileId).update(updates);
    } catch (e) {
      debugPrint('Erreur completion histoire: $e');
      rethrow;
    }
  }

  Future<void> updateStoryProgress(
    String userId,
    String profileId,
    String storyId,
    int stepIndex,
  ) async {
    try {
      await _getProfilesRef(userId).doc(profileId).update({
        'storyProgress.$storyId': stepIndex,
      });
    } catch (e) {
      debugPrint('Erreur mise à jour progression: $e');
      rethrow;
    }
  }

  Future<void> addReadingTime(
    String userId,
    String profileId,
    int minutes,
  ) async {
    try {
      await _getProfilesRef(userId).doc(profileId).update({
        'readingTimeMinutes': FieldValue.increment(minutes),
      });
    } catch (e) {
      debugPrint('Erreur ajout temps de lecture: $e');
      rethrow;
    }
  }

  Future<void> toggleInterest(
    String userId,
    String profileId,
    String interestId,
    bool isSelected,
  ) async {
    try {
      await _getProfilesRef(userId).doc(profileId).update({
        'interests': isSelected
            ? FieldValue.arrayUnion([interestId])
            : FieldValue.arrayRemove([interestId]),
      });
    } catch (e) {
      debugPrint('Erreur toggle intérêt: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SUPPRESSION DU PROFIL
  // ---------------------------------------------------------------------------

  /// Supprimer définitivement un profil ainsi que l'ensemble de ses sous-collections
  Future<void> deleteProfile(String userId, String profileId) async {
    try {
      final profileDocRef = _getProfilesRef(userId).doc(profileId);

      // Les 4 sous-collections réelles utilisées dans ton application
      final List<String> subcollections = [
        'settings',
        'readingProgress',
        'badges',
        'feedbacks', 
      ];

      // Nettoyage de chaque sous-collection
      for (final subcolName in subcollections) {
        await _deleteCollectionDocs(profileDocRef.collection(subcolName));
      }

      // 1. Suppression du document profil principal
      await profileDocRef.delete();

      // 2. Vérification si le profil supprimé était le profil ACTIF
      final userDocRef = firestore.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists && userDoc.data()?['activeProfileId'] == profileId) {
        // Récupération des profils restants
        final remainingProfiles = await _getProfilesRef(userId).get();

        if (remainingProfiles.docs.isNotEmpty) {
          // Bascule sur le premier profil disponible
          final newActiveProfileId = remainingProfiles.docs.first.id;
          await userDocRef.update({
            'activeProfileId': newActiveProfileId,
            'lastProfileChangedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // S'il n'y en a plus, suppression du champ activeProfileId
          await userDocRef.update({
            'activeProfileId': FieldValue.delete(),
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur suppression profil: $e');
      rethrow;
    }
  }

  /// Supprime tous les documents d'une sous-collection en un seul appel (Batch)
  Future<void> _deleteCollectionDocs(CollectionReference collectionRef) async {
    final snapshots = await collectionRef.get();
    if (snapshots.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}