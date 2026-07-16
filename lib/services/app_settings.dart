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
    // Initialise les fuseaux horaires (obligatoire pour planifier dans le futur)
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

    // Demander explicitement la permission pour Android 13+
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
      await _scheduleReadingReminder(profileId);
    } else {
      await _notificationsPlugin.cancelAll();
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

// Planifie une notification dans le futur
// Planifie une notification uniquement s'il y a une lecture en cours non terminée
Future<void> _scheduleReadingReminder(String profileId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  try {
    // 1. On va chercher tous les documents de progression de ce profil
    final progressSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .collection('readingProgress')
        .get();

    // 2. Vérification intelligente : 
    // On cherche s'il existe AU MOINS UN document où 'progress' est inférieur à 100
    bool hasUnfinishedStory = progressSnapshot.docs.any((doc) {
      final data = doc.data();
      // On convertit en int pour être sûr, avec 0 par défaut si le champ est vide
      final int progress = (data['progress'] as num?)?.toInt() ?? 0;
      return progress < 100;
    });

    // 3. Si tout est à 100 (ou que la liste est vide), on ne dérange pas l'enfant !
    if (!hasUnfinishedStory) {
      print("Toutes les histoires sont terminées (progress >= 100). Notification annulée.");
      return;
    }

    // 4. Sinon, on planifie le rappel
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reading_reminder_channel',
      'Rappels de lecture',
      channelDescription: 'Notifications pour rappeler de finir son histoire',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Test avec 5 secondes, change en Duration(days: 1) pour la mise en ligne
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Lumiconte 📖',
      body: 'Tu n\'as pas fini ta lecture ! Viens vite découvrir la suite de ton histoire.',
      scheduledDate: scheduledTime,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print("Notification de rappel programmée avec succès (une histoire est à < 100%).");
    
  } catch (e) {
    print("Erreur lors de la vérification des lectures : $e");
  }
}
}