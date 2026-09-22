import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:lumiconte/models/settings_model.dart';

/// Formate un temps de lecture en secondes, dans la langue du profil :
/// « 45 sec », « 12min », « 6h08 » en français, « 6 Std. 08 » en allemand.
String formatReadingTime(AppLocalizations l10n, int totalSeconds) {
  if (totalSeconds < 60) return l10n.durationSeconds(totalSeconds);
  if (totalSeconds < 60 * 60) return l10n.durationMinutes(totalSeconds ~/ 60);

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  if (minutes == 0) return l10n.durationHours(hours);
  return l10n.durationHoursMinutes(
      hours, minutes.toString().padLeft(2, '0'));
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

/// « 3 jours », « 1 jour » — le mot suit la langue et ses règles de pluriel
/// (le japonais n'en a qu'une forme, le français met zéro au singulier).
String formatStreak(AppLocalizations l10n, int streak) =>
    l10n.streakDays(streak);
