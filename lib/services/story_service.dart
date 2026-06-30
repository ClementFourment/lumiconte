import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import 'firebase_service.dart';

class StoryService extends FirebaseService {
  // Récupérer toutes les stories
  Future<List<StoryModel>> getAllStories() async {
    try {
      final querySnapshot = await firestore
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur récupération stories: $e');
      rethrow;
    }
  }

  // Récupérer une story
  Future<StoryModel?> getStory(String storyId) async {
    try {
      final doc = await firestore.collection('stories').doc(storyId).get();
      if (doc.exists) {
        return StoryModel.fromMap(doc.data() as Map<String, dynamic>, storyId);
      }
      return null;
    } catch (e) {
      print('Erreur récupération story: $e');
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

      return querySnapshot.docs
          .map((doc) =>
              StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur récupération stories par catégorie: $e');
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

      return querySnapshot.docs
          .map((doc) =>
              StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur récupération stories par âge: $e');
      rethrow;
    }
  }

  // Stream stories
  Stream<List<StoryModel>> getStoriesStream() {
    return firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) =>
              StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
