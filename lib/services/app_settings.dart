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

  /// Charge les paramètres Firestore et les mappe dans un SettingsModel
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
      
      // Adaptation selon la propriété 'theme' du SettingsModel
      _isDarkMode = _currentSettings?.theme == 'dark';
      _isNotificationsEnabled = snapshot.docs.first.data()['notificationsEnabled'] ?? false;
      
      notifyListeners();
    }
  }

  /// Alterne le mode sombre et met à jour le SettingsModel
  Future<void> toggleDarkMode(String profileId, bool value) async {
    _isDarkMode = value;
    final newTheme = value ? 'dark' : 'light';

    if (_currentSettings != null) {
      _currentSettings = _currentSettings!.copyWith(theme: newTheme);
    }

    notifyListeners();
    await _updateSettingsInFirestore(profileId, {'theme': newTheme, 'darkMode': value});
  }

  /// Alterne les notifications et planifie/annule le rappel
  Future<void> toggleNotifications(String profileId, bool value) async {
    _isNotificationsEnabled = value;
    notifyListeners();
    await _updateSettingsInFirestore(profileId, {'notificationsEnabled': value});

    if (value) {
      await scheduleReadingReminder(profileId);
    } else {
      await cancelReadingReminder();
    }
  }

  /// Met à jour les champs de la collection settings
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
    print("🔕 Notification annulée (Toutes les histoires sont finies ou switch désactivé).");
  }

  /// Planifie une notification journalière à 18h en inspectant ReadingProgressModel
  Future<void> scheduleReadingReminder(String profileId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .doc(profileId)
          .collection('readingProgress')
          .get(const GetOptions(source: Source.serverAndCache));

      // Utilisation de ReadingProgressModel.fromMap pour évaluer la progression
      bool hasUnfinishedStory = progressSnapshot.docs.any((doc) {
        final progressModel = ReadingProgressModel.fromMap(doc.data(), doc.id);
        return progressModel.progress < 100;
      });

      if (!hasUnfinishedStory) {
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
      print(
          "🔔 Rappel quotidien programmé à 18h00 avec succès (prochaine occurrence : $scheduledTime).");
    } catch (e) {
      print("Erreur lors de la vérification des lectures : $e");
    }
  }
}