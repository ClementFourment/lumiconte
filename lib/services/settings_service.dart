import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'firebase_service.dart';

class SettingsService extends FirebaseService {
  /// Référence vers le document unique de paramètres d'un profil
  DocumentReference<Map<String, dynamic>> _getSettingsDocRef(
    String userId,
    String profileId, [
    String settingsId = 'default',
  ]) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .doc(profileId)
        .collection('settings')
        .doc(settingsId);
  }

  // ---------------------------------------------------------------------------
  // CRÉATION & SAUVEGARDE DE BASE
  // ---------------------------------------------------------------------------

  /// Initialise ou crée les paramètres par défaut pour un profil
  Future<void> createOrInitSettings(
    String userId,
    String profileId, {
    int fontSize = SettingsModel.defaultFontSize,
    String theme = SettingsModel.defaultTheme,
    String readTheme = SettingsModel.defaultReadTheme, // 👈 Nouveau : Thème de lecture
    bool dyslexia = SettingsModel.defaultDyslexia,
    String langage = SettingsModel.defaultLangage,
    int totalReadingTime = SettingsModel.defaultTotalReadingTime,
    int streak = SettingsModel.defaultStreak,
    String settingsId = 'default',
  }) async {
    try {
      final initialSettings = SettingsModel(
        id: settingsId,
        fontSize: fontSize,
        theme: theme,
        readTheme: readTheme, // 👈 Transmission au modèle
        dyslexia: dyslexia,
        langage: langage,
        totalReadingTime: totalReadingTime,
        streak: streak,
      );

      await _getSettingsDocRef(userId, profileId, settingsId).set(
        initialSettings.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Erreur création settings: $e');
      rethrow;
    }
  }

  /// Sauvegarde un [SettingsModel] complet
  Future<void> saveSettings(
    String userId,
    String profileId,
    SettingsModel settings,
  ) async {
    try {
      await _getSettingsDocRef(userId, profileId, settings.id).set(
        settings.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Erreur sauvegarde settings: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // LECTURE & STREAM
  // ---------------------------------------------------------------------------

  /// Récupère les paramètres d'un profil (si absent, regarde le premier document disponible)
  Future<SettingsModel?> getSettings(
    String userId,
    String profileId, {
    String settingsId = 'default',
  }) async {
    try {
      final doc = await _getSettingsDocRef(userId, profileId, settingsId).get();

      if (doc.exists && doc.data() != null) {
        return SettingsModel.fromMap(doc.data()!, doc.id);
      }

      // Si le doc 'default' n'existe pas, recherche de secours sur le premier doc disponible
      final fallbackQuery = await firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('settings')
          .limit(1)
          .get();

      if (fallbackQuery.docs.isNotEmpty) {
        final fallbackDoc = fallbackQuery.docs.first;
        return SettingsModel.fromMap(fallbackDoc.data(), fallbackDoc.id);
      }

      return null;
    } catch (e) {
      debugPrint('Erreur récupération settings: $e');
      rethrow;
    }
  }

  /// Flux en temps réel des paramètres
  Stream<SettingsModel?> getSettingsStream(
    String userId,
    String profileId, {
    String settingsId = 'default',
  }) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .doc(profileId)
        .collection('settings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Recherche prioritaire du doc 'default' ou du premier trouvé
        final doc = snapshot.docs.firstWhere(
          (d) => d.id == settingsId,
          orElse: () => snapshot.docs.first,
        );
        return SettingsModel.fromMap(doc.data(), doc.id);
      }
      return null;
    });
  }

  // ---------------------------------------------------------------------------
  // MISE À JOUR CIBLÉE & STATISTIQUES
  // ---------------------------------------------------------------------------

  /// Mettre à jour des champs spécifiques des paramètres
  Future<void> updateSettings(
    String userId,
    String profileId,
    String settingsId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _getSettingsDocRef(userId, profileId, settingsId).update(updates);
    } catch (e) {
      debugPrint('Erreur update settings: $e');
      rethrow;
    }
  }

  /// Incrémenter le temps de lecture total (en minutes)
  Future<void> incrementTotalReadingTime(
    String userId,
    String profileId,
    int minutes, {
    String settingsId = 'default',
  }) async {
    try {
      await _getSettingsDocRef(userId, profileId, settingsId).update({
        'totalReadingTime': FieldValue.increment(minutes),
      });
    } catch (e) {
      debugPrint('Erreur incrément temps de lecture: $e');
      rethrow;
    }
  }

  /// Mettre à jour la série (streak) de jours de lecture
  Future<void> updateStreak(
    String userId,
    String profileId,
    int newStreak, {
    String settingsId = 'default',
  }) async {
    try {
      await _getSettingsDocRef(userId, profileId, settingsId).update({
        'streak': newStreak,
      });
    } catch (e) {
      debugPrint('Erreur mise à jour streak: $e');
      rethrow;
    }
  }
}