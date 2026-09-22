import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/story_model.dart';

import 'firebase_service.dart';

class StoryService extends FirebaseService {
  /// Une histoire mal renseignée ne doit pas vider la bibliothèque : le
  /// document fautif est signalé puis laissé de côté, les autres s'affichent.
  static List<StoryModel> _parse(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final stories = <StoryModel>[];
    for (final doc in snapshot.docs) {
      try {
        stories.add(StoryModel.fromMap(doc.data(), doc.id));
      } catch (e) {
        debugPrint('Histoire ignorée (${doc.id}) : $e');
      }
    }
    return stories;
  }

  /// Tri sur le titre affiché : le champ `name` de Firestore est un texte par
  /// langue, on ne peut plus trier dessus côté serveur.
  static List<StoryModel> _sortedByName(List<StoryModel> stories) {
    stories.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return stories;
  }

  // Récupérer toutes les stories
  Future<List<StoryModel>> getAllStories() async {
    try {
      final querySnapshot = await firestore.collection('stories').get();

      return _sortedByName(_parse(querySnapshot));
    } catch (e) {
      debugPrint('Erreur récupération stories: $e');
      rethrow;
    }
  }

  // Récupérer une story
  Future<StoryModel?> getStory(String storyId) async {
    try {
      final doc = await firestore.collection('stories').doc(storyId).get();
      if (doc.exists) {
        return StoryModel.fromMap(doc.data(), storyId);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur récupération story: $e');
      rethrow;
    }
  }

  // Stories par catégorie
  Future<List<StoryModel>> getStoriesByCategory(String categoryId) async {
    try {
      final querySnapshot = await firestore
          .collection('stories')
          .where('categoryIds', arrayContains: categoryId)
          .get();

      return _parse(querySnapshot);
    } catch (e) {
      debugPrint('Erreur récupération stories par catégorie: $e');
      rethrow;
    }
  }

  // Stories pour l'âge
  Future<List<StoryModel>> getStoriesByAge(int age) async {
    try {
      final querySnapshot = await firestore
          .collection('stories')
          .where('ageGroup', isLessThanOrEqualTo: age)
          .orderBy('ageGroup', descending: true)
          .get();

      return _parse(querySnapshot);
    } catch (e) {
      debugPrint('Erreur récupération stories par âge: $e');
      rethrow;
    }
  }

  // Stream stories
  Stream<List<StoryModel>> getStoriesStream() {
    return firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_parse);
  }
}
