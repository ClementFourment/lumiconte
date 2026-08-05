import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:lumiconte/models/reading_progress_model.dart';

class ReadingProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _readingProgressCollection(
      String profileId) {
    return _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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

    final existing =
        await collection.where('storyId', isEqualTo: storyId).limit(1).get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;

      await doc.reference.update({
        'progress': progress,
        'lastRead': FieldValue.serverTimestamp(),
      });

      debugPrint('ReadingProgress mis à jour pour $storyId');
      return;
    }

    await collection.add({
      'storyId': storyId,
      'progress': progress,
      'lastRead': FieldValue.serverTimestamp(),
    });

    debugPrint('ReadingProgress créé pour $storyId');
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
    final collection = _readingProgressCollection(profileId);

    final result =
        await collection.where('storyId', isEqualTo: storyId).limit(1).get();

    if (result.docs.isEmpty) {
      return null;
    }

    final doc = result.docs.first;

    return ReadingProgressModel.fromMap(
      doc.data(),
      doc.id,
    );
  }
}
