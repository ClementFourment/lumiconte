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
    required double progress,
  }) async {
    final collection = _readingProgressCollection(profileId);

    // 1. On utilise directement l'ID de l'histoire (storyId) comme ID de document au lieu d'un auto-ID.
    // Cela évite de faire un .where().get() payant en lectures Firestore.
    final docRef = collection.doc(storyId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Une morale débloquée le reste, même si on relit l'histoire depuis le début
      final wasUnlocked =
          ReadingProgressModel.moraleUnlockedFrom(docSnapshot.data()!);
      await docRef.update({
        'progress': progress,
        'lastRead': FieldValue.serverTimestamp(),
        'moraleUnlocked': wasUnlocked || progress >= 100,
      });
      debugPrint('ReadingProgress mis à jour à $progress pour $storyId');
    } else {
      // Si le document n'existe PAS ENCORE (premier clic), on FORCE la création à 0
      await docRef.set({
        'storyId': storyId,
        'progress': 0.0, // Initialisation forcée à 0
        'lastRead': FieldValue.serverTimestamp(),
        'moraleUnlocked': false,
      });
      debugPrint('ReadingProgress créé à 0 pour $storyId');
    }
  }

  /// Histoire écoutée jusqu'au bout.
  Future<void> markFinished({
    required String profileId,
    required String storyId,
  }) async {
    await ensureExists(profileId: profileId, storyId: storyId);
    await createOrUpdate(profileId: profileId, storyId: storyId, progress: 100);
  }

  /// createOrUpdate crée un document absent à 0 sans tenir compte de la
  /// progression demandée : à appeler avant d'écrire une progression.
  Future<void> ensureExists({
    required String profileId,
    required String storyId,
  }) async {
    final progress =
        await getStoryProgress(profileId: profileId, storyId: storyId);
    if (progress == null) {
      await createOrUpdate(profileId: profileId, storyId: storyId, progress: 0);
    }
  }

  /// Ajoute `moraleUnlocked` aux documents qui ne l'ont pas encore.
  Future<void> addMissingMoraleUnlocked(String profileId) async {
    final snapshot = await _readingProgressCollection(profileId).get();
    final batch = _firestore.batch();
    var missingCount = 0;

    for (final doc in snapshot.docs) {
      if (doc.data().containsKey('moraleUnlocked')) continue;
      batch.update(doc.reference, {
        'moraleUnlocked': ReadingProgressModel.moraleUnlockedFrom(doc.data()),
      });
      missingCount++;
    }

    if (missingCount > 0) {
      await batch.commit();
      debugPrint('moraleUnlocked ajouté à $missingCount progression(s)');
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
