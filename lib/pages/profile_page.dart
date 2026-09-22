import 'package:lumiconte/l10n/app_localizations.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lumiconte/constants/avatars.dart';
import 'package:lumiconte/main.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/pages/manage_profiles_page.dart';
import 'package:lumiconte/pages/morals_page.dart';
import 'package:lumiconte/pages/parent_space_page.dart';
import 'package:lumiconte/pages/rewards_page.dart';
import 'package:lumiconte/services/badge_service.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/utils/reading_stats.dart';
import 'package:lumiconte/widget/mascot.dart';
import 'package:lumiconte/widget/night_sky_background.dart';
import 'package:lumiconte/widget/parental_gate.dart';

/// Onglet « Mes trésors » de l'enfant : uniquement du contenu adapté aux enfants.
/// Les réglages, le compte et les actions sensibles sont dans
/// [ParentSpacePage], derrière le contrôle parental.
class ProfilePage extends StatefulWidget {
  final String profileId;
  final List<StoryModel> stories;

  const ProfilePage({
    super.key,
    required this.profileId,
    required this.stories,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  late DocumentReference _profileDoc;
  late CollectionReference _readingProgressCollection;
  late CollectionReference _settingsCollection;

  late Stream<DocumentSnapshot> _profileStream;
  late Stream<QuerySnapshot> _progressStream;
  late Stream<QuerySnapshot> _settingsStream;
  late Stream<BadgeProgress> _badgeStream;

  StreamSubscription? _progressSubscription;
  StreamSubscription? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _initStreams();
    _initSubscriptions();
  }

  void _initStreams() {
    if (_uid == null) return;

    _profileDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profileId);

    _readingProgressCollection = _profileDoc.collection('readingProgress');
    _settingsCollection = _profileDoc.collection('settings');

    _profileStream = _profileDoc.snapshots();
    _progressStream = _readingProgressCollection.snapshots();
    _settingsStream = _settingsCollection.snapshots();
    _badgeStream =
        BadgeService().watch(_uid!, widget.profileId, widget.stories);
  }

  void _initSubscriptions() {
    _progressSubscription?.cancel();
    _settingsSubscription?.cancel();

    if (_uid == null) return;

    _progressSubscription = _readingProgressCollection.snapshots().listen((_) {
      if (mounted && appSettings.isNotificationsEnabled) {
        appSettings.scheduleReadingReminder();
      }
    });

    _settingsSubscription = _settingsCollection.snapshots().listen((snapshot) {
      if (mounted && snapshot.docs.isNotEmpty) {
        final rawData =
            snapshot.docs.first.data() as Map<String, dynamic>? ?? {};
        final isDark = rawData['theme'] == 'dark';

        if (appSettings.isDarkMode != isDark) {
          appSettings.toggleDarkMode(widget.profileId, isDark);
        }
      }
    });
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId) {
      _initStreams();
      _initSubscriptions();
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openParentSpace() async {
    final allowed = await showParentalGate(context);
    if (!allowed || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParentSpacePage(profileId: widget.profileId),
      ),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_uid == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).userNotConnected,
              style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot>(
          stream: _profileStream,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary));
            }
            if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
              return Center(
                  child: Text(AppLocalizations.of(context).profileNotFound,
                      style: TextStyle(color: theme.colorScheme.onSurface)));
            }

            final profile = ProfileModel.fromMap(
              profileSnapshot.data!.data() as Map<String, dynamic>? ?? {},
              profileSnapshot.data!.id,
              _uid!,
            );

            return StreamBuilder<QuerySnapshot>(
              stream: _progressStream,
              builder: (context, progressSnapshot) {
                final int storiesReadCount = progressSnapshot.hasData
                    ? progressSnapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>?;
                        // Une histoire est lue quand sa morale a été débloquée
                        return data != null &&
                            ReadingProgressModel.moraleUnlockedFrom(data);
                      }).length
                    : 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: _settingsStream,
                  builder: (context, settingsSnapshot) {
                    int streak = 0;

                    if (settingsSnapshot.hasData &&
                        settingsSnapshot.data!.docs.isNotEmpty) {
                      final settingsDoc = settingsSnapshot.data!.docs.first;
                      final settings = SettingsModel.fromMap(
                        settingsDoc.data() as Map<String, dynamic>? ?? {},
                        settingsDoc.id,
                      );
                      streak = currentStreak(settings);

                      // Série cassée : on la remet à zéro en base
                      if (streak == 0 && settings.streak != 0) {
                        Future.microtask(() => _settingsCollection
                            .doc(settingsDoc.id)
                            .set(
                                {'streak': 0},
                                SetOptions(
                                    merge: true)).catchError((e) =>
                                debugPrint('Erreur remise à zéro série: $e')));
                      }
                    }

                    return _buildContent(
                        context, profile, storiesReadCount, streak);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// La mascotte encourage l'enfant selon sa série de lecture.
  String _mascotMessage(BuildContext context, int streak) =>
      AppLocalizations.of(context).streakEncouragement(streak);

  Widget _buildContent(BuildContext context, ProfileModel profile,
      int storiesReadCount, int streak) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ListView(
      // Place pour la barre de navigation flottante
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        // Accès discret à l'espace parents
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _openParentSpace,
            style: TextButton.styleFrom(
              foregroundColor: onSurface.withValues(alpha: 0.6),
            ),
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: Text(AppLocalizations.of(context).parentSpace),
          ),
        ),
        const SizedBox(height: 8),

        // Avatar et prénom
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor,
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: AppTheme.getCardColor(context),
              backgroundImage: AssetImage(
                profile.avatarPath ?? AppAvatars.defaultAvatar,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(color: onSurface),
        ),
        const SizedBox(height: 20),

        Mascot(message: _mascotMessage(context, streak)),
        const SizedBox(height: 16),

        // Mes exploits
        Row(
          children: [
            _buildAchievementTile(
              context,
              icon: Icons.local_fire_department_rounded,
              iconColor: streak == 0
                  ? onSurface.withValues(alpha: 0.3)
                  : Colors.deepOrange,
              value: formatStreak(AppLocalizations.of(context), streak),
              label: AppLocalizations.of(context).streakTileLabel,
            ),
            const SizedBox(width: 12),
            _buildAchievementTile(
              context,
              icon: Icons.auto_stories_rounded,
              iconColor: AppTheme.accentColor,
              value: '$storiesReadCount',
              label: AppLocalizations.of(context)
                  .storiesFinishedTileLabel(storiesReadCount),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Une morale est débloquée à chaque histoire terminée
        _buildActionCard(
          context,
          icon: Icons.auto_awesome_rounded,
          iconColor: AppTheme.accentColor,
          title: AppLocalizations.of(context).myMorals,
          subtitle: AppLocalizations.of(context).moralsUnlockedSubtitle(
              storiesReadCount, widget.stories.length),
          progress: widget.stories.isEmpty
              ? null
              : storiesReadCount / widget.stories.length,
          onTap: () => _push(
            NightSkyBackground(
              child: MoralsPage(
                profile: profile,
                stories: widget.stories,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<BadgeProgress>(
          stream: _badgeStream,
          builder: (context, badgeSnapshot) {
            final total = BadgeModel.all.length;
            final earned = badgeSnapshot.data?.earned;
            final earnedCount = earned == null
                ? null
                : BadgeModel.all.where((b) => earned.contains(b.id)).length;

            return _buildActionCard(
              context,
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFF1C40F),
              title: AppLocalizations.of(context).myBadges,
              subtitle: earnedCount == null
                  ? null
                  : AppLocalizations.of(context).badgesEarnedSubtitle(earnedCount, total),
              progress: earnedCount == null ? null : earnedCount / total,
              onTap: () => _push(
                NightSkyBackground(
                  child: RewardsPage(
                    profileId: widget.profileId,
                    stories: widget.stories,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          icon: Icons.swap_horiz_rounded,
          iconColor: theme.colorScheme.primary,
          title: AppLocalizations.of(context).changeReader,
          onTap: () => _push(const ManageProfilesPage()),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 26, color: onSurface),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    double? progress,
    required VoidCallback onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: AppTheme.getCardColor(context),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 19, color: onSurface),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 6,
                          color: iconColor,
                          backgroundColor: onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 28, color: onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
