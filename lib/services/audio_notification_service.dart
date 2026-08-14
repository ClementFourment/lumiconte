import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';

/// Service pour gérer les notifications de lecture audio
class AudioNotificationService {
  static final AudioNotificationService _instance =
      AudioNotificationService._internal();

  factory AudioNotificationService() {
    return _instance;
  }

  AudioNotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  static const String _channelId = 'lumiconte_audio_playback';
  static const String _channelName = 'Lumiconte Audio Playback';
  static const int _notificationId = 1;

  /// Initialiser le service de notification
  Future<void> init() async {
    if (_isInitialized) return;

    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Configuration iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Configuration Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
    );

    // Créer le canal de notification (Android)
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Créer le canal de notification Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Canal pour la lecture audio en arrière-plan',
      importance: Importance.max,
      enableVibration: false,
      sound: null,
      playSound: false,
      showBadge: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Afficher la notification avec les contrôles de lecture
  Future<void> showPlaybackNotification({
    required String title,
    required String subtitle,
    required bool isPlaying,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onStop,
  }) async {
    if (!_isInitialized) await init();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Contrôles de lecture audio',
      channelShowBadge: false,
      importance: Importance.high,
      priority: Priority.high,
      color: const Color.fromARGB(255, 245, 158, 11), // Couleur accent
      enableVibration: false,
      playSound: false,
      showProgress: false,
      maxProgress: 100,
      progress: 0,
      indeterminate: false,
      autoCancel: false,
      ongoing: true,
      showWhen: false,
      silent: true,
      // Actions personnalisées
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_previous',
          'Précédent',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          isPlaying ? 'action_pause' : 'action_play',
          isPlaying ? 'Pause' : 'Jouer',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'action_next',
          'Suivant',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'action_close',
          'Fermer',
          showsUserInterface: false,
        ),
      ],
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      subtitle: subtitle,
    );

    await _notificationsPlugin.show(
      id: _notificationId,
      title: title,
      body: subtitle,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      ),
    );
  }

  /// Afficher la notification de lecture avec barre de progression
  Future<void> showPlaybackProgressNotification({
    required String title,
    required String subtitle,
    required bool isPlaying,
    required int progress, // 0-100
    required Duration position,
    required Duration duration,
  }) async {
    if (!_isInitialized) await init();

    // Format du temps
    final positionStr = _formatDuration(position);
    final durationStr = _formatDuration(duration);
    final progressText = '$positionStr / $durationStr';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Lecture audio en cours',
      channelShowBadge: false,
      importance: Importance.high,
      priority: Priority.high,
      color: const Color.fromARGB(255, 245, 158, 11),
      enableVibration: false,
      playSound: false,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      autoCancel: false,
      ongoing: true,
      showWhen: false,
      silent: true,
      subText: progressText,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          isPlaying ? 'action_pause' : 'action_play',
          isPlaying ? 'Pause' : 'Jouer',
          showsUserInterface: false,
        ),
      ],
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      subtitle: subtitle,
    );

    await _notificationsPlugin.show(
      id: _notificationId,
      title: title,
      body: subtitle,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      ),
    );
  }

  /// Masquer la notification
  Future<void> hideNotification() async {
    await _notificationsPlugin.cancel(id: _notificationId);
  }

  /// Formater une durée en mm:ss
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
