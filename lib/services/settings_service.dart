import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/settings_model.dart';
import 'firebase_service.dart';

class SettingsService extends FirebaseService {
  // Créer les settings (1 par profil)
  Future<String> createSettings(
    String userId,
    String profileId, {
    int fontSize = 16,
    String theme = 'light',
    bool dyslexia = false,
    String voice = 'default',
    bool autoReader = false,
  }) async {
    try {
      final docRef = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('settings')
          .add({
        'fontSize': fontSize,
        'theme': theme,
        'dyslexia': dyslexia,
        'voice': voice,
        'autoReader': autoReader,
      });
      return docRef.id;
    } catch (e) {
      print('Erreur création settings: $e');
      rethrow;
    }
  }

  // Récupérer les settings
  Future<SettingsModel?> getSettings(
    String userId,
    String profileId,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('settings')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return SettingsModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erreur récupération settings: $e');
      rethrow;
    }
  }

  // Mettre à jour les settings
  Future<void> updateSettings(
    String userId,
    String profileId,
    String settingsId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('settings')
          .doc(settingsId)
          .update(updates);
    } catch (e) {
      print('Erreur update settings: $e');
      rethrow;
    }
  }

  // Stream des settings
  Stream<SettingsModel?> getSettingsStream(
    String userId,
    String profileId,
  ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .doc(profileId)
        .collection('settings')
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return SettingsModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
}
