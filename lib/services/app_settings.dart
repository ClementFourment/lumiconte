import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';

class AppSettings extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true; // Valeur par défaut
  SettingsModel? _currentSettings;

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  SettingsModel? get currentSettings => _currentSettings;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppSettings() {
    _initNotifications();
    _initAuthListener(); // 👈 Écoute dynamique du statut d'authentification
  }

  /// Écoute l'authentification : si l'utilisateur se connecte, on charge ses paramètres globaux
  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadGlobalSettings();
      }
    });
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    try {
      final dynamic timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    }

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

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  /// Charge les paramètres globaux (`users/{uid}`)
  Future<void> _loadGlobalSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          // 👈 Récupère la valeur ou retombe sur true par défaut
          _isNotificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
          notifyListeners(); // 👈 Notifie l'UI pour positionner le Switch à droite
        }
      }
    } catch (_) {}
  }

  /// Charge les paramètres Firestore spécifiques au profil
  Future<void> loadSettingsFromFirestore(String profileId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Recharge la valeur globale de la notification au passage
    await _loadGlobalSettings();

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
  }

  /// Alterne le mode sombre et met à jour le SettingsModel du profil
  Future<void> toggleDarkMode(String profileId, bool value) async {
    _isDarkMode = value;
    final newTheme = value ? 'dark' : 'light';

    if (_currentSettings != null) {
      _currentSettings = _currentSettings!.copyWith(theme: newTheme);
    }

    notifyListeners();
    await _updateSettingsInFirestore(
        profileId, {'theme': newTheme, 'darkMode': value});
  }

  /// Alterne les notifications de manière globale au niveau de l'utilisateur (`users/{uid}`)
  Future<void> toggleNotifications(bool value) async {
    _isNotificationsEnabled = value;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationsEnabled': value,
      }, SetOptions(merge: true));

      if (value) {
        await scheduleReadingReminder();
      } else {
        await cancelReadingReminder();
      }
    } catch (_) {}
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

  /// Annule toutes les notifications
  Future<void> cancelReadingReminder() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Planifie une notification journalière à 19h30
  Future<void> scheduleReadingReminder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final profilesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .get();

      bool hasUnfinishedStoryAnywhere = false;

      for (var profileDoc in profilesSnapshot.docs) {
        final progressSnapshot = await profileDoc.reference
            .collection('readingProgress')
            .get(const GetOptions(source: Source.serverAndCache));

        bool hasUnfinishedInThisProfile = progressSnapshot.docs.any((doc) {
          final progressModel =
              ReadingProgressModel.fromMap(doc.data(), doc.id);
          return progressModel.progress < 100;
        });

        if (hasUnfinishedInThisProfile) {
          hasUnfinishedStoryAnywhere = true;
          break;
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

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        19,
        30,
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
    } catch (_) {}
  }
}