import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/utils/reading_stats.dart';

class BadgeProgress {
  /// Badges déjà enregistrés sur le profil : un badge gagné le reste,
  /// même si la série de lecture se casse ensuite.
  final Set<String> stored;

  /// Badges dont la condition est remplie avec les données actuelles.
  final Set<String> computed;

  const BadgeProgress({required this.stored, required this.computed});

  Set<String> get earned => {...stored, ...computed};
}

class BadgeService {
  static const String _field = 'earnedBadges';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileDoc(
          String userId, String profileId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId);

  /// Enregistre des badges gagnés sur le profil.
  Future<void> award(String userId, String profileId, Iterable<String> ids) {
    return _profileDoc(userId, profileId)
        .set({_field: FieldValue.arrayUnion(ids.toList())},
            SetOptions(merge: true))
        .catchError((e) => debugPrint('Erreur enregistrement badges : $e'));
  }

  /// Progression des badges, recalculée à chaque changement des lectures,
  /// favoris ou paramètres du profil.
  Stream<BadgeProgress> watch(
      String userId, String profileId, List<StoryModel> stories) {
    final profileDoc = _profileDoc(userId, profileId);
    final catalog = _Catalog(stories);

    DocumentSnapshot<Map<String, dynamic>>? profile;
    QuerySnapshot<Map<String, dynamic>>? progress;
    QuerySnapshot<Map<String, dynamic>>? favorites;
    QuerySnapshot<Map<String, dynamic>>? settings;

    late final StreamController<BadgeProgress> controller;
    final subscriptions = <StreamSubscription>[];

    void emit() {
      if (profile == null ||
          progress == null ||
          favorites == null ||
          settings == null) {
        return;
      }
      controller.add(BadgeProgress(
        stored: Set<String>.from(profile!.data()?[_field] ?? const []),
        computed: BadgeModel.computeEarned(
            _stats(progress!, favorites!, settings!, catalog)),
      ));
    }

    controller = StreamController<BadgeProgress>(
      onListen: () {
        subscriptions.addAll([
          profileDoc.snapshots().listen((s) {
            profile = s;
            emit();
          }, onError: controller.addError),
          profileDoc.collection('readingProgress').snapshots().listen((s) {
            progress = s;
            emit();
          }, onError: controller.addError),
          profileDoc.collection('favorites').snapshots().listen((s) {
            favorites = s;
            emit();
          }, onError: controller.addError),
          profileDoc.collection('settings').snapshots().listen((s) {
            settings = s;
            emit();
          }, onError: controller.addError),
        ]);
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  BadgeStats _stats(
    QuerySnapshot<Map<String, dynamic>> progress,
    QuerySnapshot<Map<String, dynamic>> favorites,
    QuerySnapshot<Map<String, dynamic>> settings,
    _Catalog catalog,
  ) {
    final finishedCategories = <String>{};
    var hasEveningReading = false;
    var hasMorningReading = false;
    var hasWeekendReading = false;
    var hasReread = false;
    var finishedLongStory = false;

    for (final doc in progress.docs) {
      final data = doc.data();
      final storyId = data['storyId'] as String? ?? doc.id;

      if (ReadingProgressModel.moraleUnlockedFrom(data)) {
        finishedCategories
            .addAll(catalog.storiesById[storyId]?.categoryIds ?? []);
        if (catalog.longStoryIds.contains(storyId)) finishedLongStory = true;
      }

      // Morale débloquée mais progression revenue au début : l'histoire
      // terminée a été recommencée (et pas seulement feuilletée en arrière)
      final progressValue = (data['progress'] as num?) ?? 0;
      if (data['moraleUnlocked'] == true && progressValue < 25) {
        hasReread = true;
      }

      final lastRead = data['lastRead'];
      if (lastRead is Timestamp) {
        final date = lastRead.toDate();
        if (date.hour >= 19 || date.hour < 5) hasEveningReading = true;
        if (date.hour >= 6 && date.hour < 10) hasMorningReading = true;
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          hasWeekendReading = true;
        }
      }
    }

    var streak = 0;
    var totalReadingSeconds = 0;
    if (settings.docs.isNotEmpty) {
      final doc = settings.docs.first;
      final model = SettingsModel.fromMap(doc.data(), doc.id);
      streak = currentStreak(model);
      totalReadingSeconds = model.totalReadingTime;
    }

    return BadgeStats(
      storiesStarted: progress.docs.length,
      currentStreak: streak,
      favoritesCount: favorites.docs.length,
      finishedCategoriesCount: finishedCategories.length,
      availableCategoriesCount: catalog.categoriesCount,
      hasEveningReading: hasEveningReading,
      hasMorningReading: hasMorningReading,
      hasWeekendReading: hasWeekendReading,
      hasReread: hasReread,
      finishedLongStory: finishedLongStory,
      totalReadingSeconds: totalReadingSeconds,
    );
  }
}

/// Informations sur le catalogue d'histoires, calculées une fois.
class _Catalog {
  final Map<String, StoryModel> storiesById;
  final int categoriesCount;

  /// Le quart des histoires les plus longues (en nombre de mots).
  final Set<String> longStoryIds;

  factory _Catalog(List<StoryModel> stories) {
    final wordCounts = {
      for (final s in stories)
        s.id: s.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    };
    final sortedCounts = wordCounts.values.toList()..sort();
    final longThreshold = sortedCounts.isEmpty
        ? 0
        : sortedCounts[(sortedCounts.length * 3) ~/ 4];

    return _Catalog._(
      storiesById: {for (final s in stories) s.id: s},
      categoriesCount: {for (final s in stories) ...s.categoryIds}.length,
      longStoryIds: {
        for (final entry in wordCounts.entries)
          if (entry.value > 0 && entry.value >= longThreshold) entry.key,
      },
    );
  }

  const _Catalog._({
    required this.storiesById,
    required this.categoriesCount,
    required this.longStoryIds,
  });
}
