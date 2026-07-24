import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';

class AppSettings extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = false;
  SettingsModel? _currentSettings;

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  SettingsModel? get currentSettings => _currentSettings;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppSettings() {
    _initNotifications();
    _loadGlobalSettings();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Charge les paramètres globaux au niveau du document user
  Future<void> _loadGlobalSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          _isNotificationsEnabled = data['notificationsEnabled'] ?? false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des paramètres globaux : $e");
    }
  }

  /// Charge les paramètres Firestore spécifiques au profil (ex: langue, thème du profil)
  Future<void> loadSettingsFromFirestore(String profileId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .collection('settings')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      _currentSettings = SettingsModel.fromMap(doc.data(), doc.id);
      
      _isDarkMode = _currentSettings?.theme == 'dark';
      
      notifyListeners();
    }
    
    // On s'assure de recharger l'état global des notifications stocké sur le user
    await _loadGlobalSettings();
  }

  /// Alterne le mode sombre et met à jour le SettingsModel du profil
  Future<void> toggleDarkMode(String profileId, bool value) async {
    _isDarkMode = value;
    final newTheme = value ? 'dark' : 'light';

    if (_currentSettings != null) {
      _currentSettings = _currentSettings!.copyWith(theme: newTheme);
    }

    notifyListeners();
    await _updateSettingsInFirestore(profileId, {'theme': newTheme, 'darkMode': value});
  }

  /// Alterne les notifications de manière globale au niveau de l'utilisateur (`users/{uid}`)
  Future<void> toggleNotifications(bool value) async {
    _isNotificationsEnabled = value;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Sauvegarde globale au niveau du document user
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationsEnabled': value,
      }, SetOptions(merge: true));

      if (value) {
        await scheduleReadingReminder();
      } else {
        await cancelReadingReminder();
      }
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour globale des notifications : $e");
    }
  }

  /// Met à jour les champs de la collection settings du profil
  Future<void> _updateSettingsInFirestore(
      String profileId, Map<String, dynamic> updates) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .collection('settings');

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update(updates);
    }
  }

  /// Annule explicitement les rappels de lecture
  Future<void> cancelReadingReminder() async {
    await _notificationsPlugin.cancel(id: 0);
    debugPrint("🔕 Notification annulée (Toutes les histoires sont finies ou switch désactivé).");
  }

  /// Planifie une notification journalière à 18h en inspectant TOUS les profils et leurs lectures
  Future<void> scheduleReadingReminder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // 1. Récupérer tous les profils de l'utilisateur
      final profilesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .get();

      bool hasUnfinishedStoryAnywhere = false;

      // 2. Parcourir chaque profil pour vérifier ses lectures en cours
      for (var profileDoc in profilesSnapshot.docs) {
        final progressSnapshot = await profileDoc.reference
            .collection('readingProgress')
            .get(const GetOptions(source: Source.serverAndCache));

        bool hasUnfinishedInThisProfile = progressSnapshot.docs.any((doc) {
          final progressModel = ReadingProgressModel.fromMap(doc.data(), doc.id);
          return progressModel.progress < 100;
        });

        if (hasUnfinishedInThisProfile) {
          hasUnfinishedStoryAnywhere = true;
          break; // Sortie anticipée dès qu'une histoire non finie est trouvée n'importe où
        }
      }

      if (!hasUnfinishedStoryAnywhere) {
        await cancelReadingReminder();
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reading_reminder_channel',
        'Rappels de lecture',
        channelDescription: 'Notifications pour rappeler de finir son histoire',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      // Calcul de l'heure cible : 18h00 aujourd'hui heure locale
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        18, // 18 heures
        0,  // 00 minutes
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Lumiconte 📖',
        body:
            'Tu n\'as pas fini ta lecture ! Viens vite découvrir la suite de ton histoire.',
        scheduledDate: scheduledTime,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
          "🔔 Rappel quotidien programmé à 18h00 avec succès (prochaine occurrence : $scheduledTime).");
    } catch (e) {
      debugPrint("Erreur lors de la vérification globale des lectures : $e");
    }
  }
}