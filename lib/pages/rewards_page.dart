import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/badge_service.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/widget/badge_celebration.dart';
import 'package:lumiconte/widget/badge_medal.dart';
import 'package:lumiconte/widget/mascot.dart';

/// Badges d'habitudes de lecture. Les badges pas encore gagnés restent des
/// surprises, avec un indice pour les obtenir.
class RewardsPage extends StatefulWidget {
  final String profileId;
  final List<StoryModel> stories;

  const RewardsPage({
    super.key,
    required this.profileId,
    required this.stories,
  });

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late final Stream<BadgeProgress>? _progressStream = _uid == null
      ? null
      : BadgeService().watch(_uid!, widget.profileId, widget.stories);

  String _mascotMessage(BuildContext context, int earnedCount) {
    final l10n = AppLocalizations.of(context);
    if (earnedCount == 0) return l10n.badgesIntroNone;
    if (earnedCount == BadgeModel.all.length) return l10n.badgesIntroAll;
    return l10n.badgesIntroSome(earnedCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).myBadges,
          style: theme.textTheme.headlineSmall?.copyWith(color: onSurface),
        ),
      ),
      body: StreamBuilder<BadgeProgress>(
        stream: _progressStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Erreur chargement badges : ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  AppLocalizations.of(context).badgesLoadError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          final earned = snapshot.data!.earned;
          final earnedCount =
              BadgeModel.all.where((b) => earned.contains(b.id)).length;
          // Les badges gagnés d'abord
          final badges = [
            ...BadgeModel.all.where((b) => earned.contains(b.id)),
            ...BadgeModel.all.where((b) => !earned.contains(b.id)),
          ];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: Mascot(message: _mascotMessage(context, earnedCount)),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, MediaQuery.paddingOf(context).bottom + 24),
                sliver: SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    // Hauteur fixe : le texte garde sa place sur les petits écrans
                    mainAxisExtent: 220,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _BadgeTile(
                      badge: badge,
                      earned: earned.contains(badge.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;

  const _BadgeTile({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      color: AppTheme.getCardColor(context)
          .withValues(alpha: earned ? 1 : 0.6),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: earned
            ? () => showBadgeCelebration(context, badge, celebrate: false)
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: Column(
            children: [
              BadgeMedal(badge: badge, earned: earned),
              const SizedBox(height: 12),
              Text(
                earned
                    ? badge.texts(AppLocalizations.of(context)).name
                    : AppLocalizations.of(context).surpriseBadge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  color: earned ? onSurface : onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  earned
                      ? badge.texts(AppLocalizations.of(context)).earned
                      : badge.texts(AppLocalizations.of(context)).hint,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontStyle: earned ? FontStyle.normal : FontStyle.italic,
                    color: onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
