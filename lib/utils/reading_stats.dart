import 'package:lumiconte/models/settings_model.dart';

/// Formate un temps de lecture en secondes : « 45 sec », « 12min », « 6h08 ».
String formatReadingTime(int totalSeconds) {
  if (totalSeconds < 60) return '$totalSeconds sec';
  if (totalSeconds < 60 * 60) return '${totalSeconds ~/ 60}min';

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  if (minutes == 0) return '${hours}h';
  return minutes < 10 ? '${hours}h0$minutes' : '${hours}h$minutes';
}

/// Série de jours de lecture réellement en cours : elle est cassée si la
/// dernière lecture date d'avant-hier ou plus.
int currentStreak(SettingsModel settings) {
  final lastRead = settings.stopRead;
  if (lastRead == null) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final lastReadDay = DateTime(lastRead.year, lastRead.month, lastRead.day);
  return today.difference(lastReadDay).inDays > 1 ? 0 : settings.streak;
}

String formatStreak(int streak) => '$streak ${streak > 1 ? 'jours' : 'jour'}';
