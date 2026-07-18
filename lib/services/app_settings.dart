import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppSettings extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = false;
  
  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

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
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

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
      final data = snapshot.docs.first.data();
      _isDarkMode = data['darkMode'] ?? false;
      _isNotificationsEnabled = data['notificationsEnabled'] ?? false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(String profileId, bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _updateFirestore(profileId, 'darkMode', value);
  }

  Future<void> toggleNotifications(String profileId, bool value) async {
    _isNotificationsEnabled = value;
    notifyListeners();
    await _updateFirestore(profileId, 'notificationsEnabled', value);
    
    if (value) {
      await scheduleReadingReminder(profileId);
    } else {
      await cancelReadingReminder();
    }
  }

  Future<void> _updateFirestore(String profileId, String key, dynamic value) async {
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
      await snapshot.docs.first.reference.update({key: value});
    }
  }

/// Annule explicitement les rappels de lecture
  Future<void> cancelReadingReminder() async {
    await _notificationsPlugin.cancel(id: 0); // Ajout du paramètre nommé 'id'
    print("🔕 Notification annulée (Toutes les histoires sont finies ou switch désactivé).");
  }

  /// Planifie une notification uniquement s'il y a une lecture en cours non terminée
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
    .get(const GetOptions(source: Source.serverAndCache)); // Utilise le cache si pas d'internet !

      bool hasUnfinishedStory = progressSnapshot.docs.any((doc) {
        final data = doc.data();
        final int progress = (data['progress'] as num?)?.toInt() ?? 0;
        return progress < 100;
      });

      if (!hasUnfinishedStory) {
        await cancelReadingReminder();
        return;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reading_reminder_channel',
        'Rappels de lecture',
        channelDescription: 'Notifications pour rappeler de finir son histoire',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      // Configuré sur 5 secondes pour vos tests. Passez à Duration(days: 1) en production.
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Lumiconte 📖',
        body: 'Tu n\'as pas fini ta lecture ! Viens vite découvrir la suite de ton histoire.',
        scheduledDate: scheduledTime,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        //androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print("🔔 Notification de rappel programmée avec succès (une histoire est à < 100%).");
      
    } catch (e) {
      print("Erreur lors de la vérification des lectures : $e");
    }
  }
}