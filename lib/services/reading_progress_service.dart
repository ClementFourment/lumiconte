import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Remplacement de rendering.dart par foundation.dart pour debugPrint
import 'package:lumiconte/models/reading_progress_model.dart';

class ReadingProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _readingProgressCollection(
      String profileId) {
    // Sécurité si l'utilisateur n'est pas encore authentifié
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('profiles')
        .doc(profileId)
        .collection('readingProgress');
  }

  Future<void> createOrUpdate({
    required String profileId,
    required String storyId,
    required int progress,
  }) async {
    final collection = _readingProgressCollection(profileId);

    // 1. On utilise directement l'ID de l'histoire (storyId) comme ID de document au lieu d'un auto-ID.
    // Cela évite de faire un .where().get() payant en lectures Firestore.
    final docRef = collection.doc(storyId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Si le document existe déjà, on met à jour avec la progression transmise
      await docRef.update({
        'progress': progress,
        'lastRead': FieldValue.serverTimestamp(),
      });
      debugPrint('ReadingProgress mis à jour à $progress pour $storyId');
    } else {
      // Si le document n'existe PAS ENCORE (premier clic), on FORCE la création à 0
      await docRef.set({
        'storyId': storyId,
        'progress': 0, // Initialisation forcée à 0
        'lastRead': FieldValue.serverTimestamp(),
      });
      debugPrint('ReadingProgress créé à 0 pour $storyId');
    }
  }

  Stream<List<ReadingProgressModel>> getUserReadingProgress(String profileId) {
    return _readingProgressCollection(profileId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReadingProgressModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  Future<ReadingProgressModel?> getStoryProgress({
    required String profileId,
    required String storyId,
  }) async {
    // Grâce à l'ID de document fixé sur storyId, la lecture est directe et plus rapide
    final docSnapshot =
        await _readingProgressCollection(profileId).doc(storyId).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }

    return ReadingProgressModel.fromMap(
      docSnapshot.data()!,
      docSnapshot.id,
    );
  }
}