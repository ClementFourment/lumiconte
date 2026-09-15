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

  // met a jour le streak de reading
  Future<void> registerReading(
    String userId,
    String profileId,
    SettingsModel settings, {
    String settingsId = 'default',
  }) async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    int newStreak;

    if (settings.stopRead == null) {
      // Première lecture
      newStreak = 1;
    } else {
      final lastRead = settings.stopRead!;

      final lastReadDay = DateTime(
        lastRead.year,
        lastRead.month,
        lastRead.day,
      );

      final daysDifference = today.difference(lastReadDay).inDays;

      if (daysDifference == 0) {
        // Déjà enregistré comme ayant lu aujourd'hui
        newStreak = settings.streak;
      } else if (daysDifference == 1) {
        // Lecture hier → on continue la série
        newStreak = settings.streak + 1;
      } else {
        // Plus d'un jour → nouvelle série
        newStreak = 1;
      }
    }

    await _getSettingsDocRef(
      userId,
      profileId,
      settingsId,
    ).set({
      'streak': newStreak,
      'stopRead': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  // lastReadingDate mis à jour dans Firestore
  Future<void> updateLastReadingDate(
    String userId,
    String profileId, {
    String settingsId = 'default',
  }) async {
    try {
      await _getSettingsDocRef(userId, profileId, settingsId).set({
        'lastReadingDate': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur mise à jour lastReadingDate: $e');
      rethrow;
    }
  }

  /// Garantit qu'un profil a son document `settings/default`, celui que visent
  /// toutes les écritures.
  /// - Déjà présent : rien à faire.
  /// - Anciens profils dont les paramètres ont un autre identifiant : leur
  ///   contenu est recopié dans `default` et les anciens documents supprimés,
  ///   pour que lectures et écritures portent sur le même document.
  /// - Aucun document : création avec les valeurs par défaut.
  Future<void> ensureDefaultSettings(String userId, String profileId) async {
    try {
      final defaultRef = _getSettingsDocRef(userId, profileId);
      if ((await defaultRef.get()).exists) return;

      final others = await defaultRef.parent.get();
      if (others.docs.isEmpty) {
        await createOrInitSettings(userId, profileId);
        return;
      }

      // Plusieurs anciens documents : on garde le plus lu
      final source = others.docs.reduce((a, b) {
        final timeA = (a.data()['totalReadingTime'] as num?) ?? 0;
        final timeB = (b.data()['totalReadingTime'] as num?) ?? 0;
        return timeB > timeA ? b : a;
      });

      // Recopie et suppression dans un même batch : tout ou rien
      final batch = firestore.batch();
      batch.set(defaultRef, source.data(), SetOptions(merge: true));
      for (final doc in others.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Erreur migration settings/default: $e');
      rethrow;
    }
  }

  /// Initialise ou crée les paramètres par défaut pour un profil
  Future<void> createOrInitSettings(
    String userId,
    String profileId, {
    int fontSize = SettingsModel.defaultFontSize,
    String theme = SettingsModel.defaultTheme,
    String readTheme =
        SettingsModel.defaultReadTheme, // 👈 Nouveau : Thème de lecture
    bool dyslexia = SettingsModel.defaultDyslexia,
    String language = SettingsModel.defaultLanguage,
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
        language: language,
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
      await _getSettingsDocRef(userId, profileId, settingsId).set(
        updates,
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Erreur update settings: $e');
      rethrow;
    }
  }

  /// Incrémenter le temps de lecture total (en secondes)
  Future<void> incrementTotalReadingTime(
    String userId,
    String profileId,
    int secondes, {
    String settingsId = 'default',
  }) async {
    try {
      await _getSettingsDocRef(userId, profileId, settingsId).set({
        'totalReadingTime': FieldValue.increment(secondes),
      }, SetOptions(merge: true));
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
      await _getSettingsDocRef(userId, profileId, settingsId).set({
        'streak': newStreak,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur mise à jour streak: $e');
      rethrow;
    }
  }
}
