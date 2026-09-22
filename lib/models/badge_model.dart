import 'package:flutter/material.dart';
import 'package:lumiconte/l10n/app_localizations.dart';

/// Données du profil utilisées pour décider quels badges sont gagnés.
/// Toutes existent déjà dans Firestore : rien n'est stocké en plus.
class BadgeStats {
  final int storiesStarted;
  final int currentStreak;
  final int favoritesCount;
  final int finishedCategoriesCount;

  /// Nombre de thèmes différents dans le catalogue.
  final int availableCategoriesCount;
  final bool hasEveningReading;
  final bool hasMorningReading;
  final bool hasWeekendReading;

  /// Une histoire déjà terminée a été recommencée.
  final bool hasReread;

  /// Une des histoires les plus longues du catalogue a été terminée.
  final bool finishedLongStory;
  final int totalReadingSeconds;

  const BadgeStats({
    this.storiesStarted = 0,
    this.currentStreak = 0,
    this.favoritesCount = 0,
    this.finishedCategoriesCount = 0,
    this.availableCategoriesCount = 0,
    this.hasEveningReading = false,
    this.hasMorningReading = false,
    this.hasWeekendReading = false,
    this.hasReread = false,
    this.finishedLongStory = false,
    this.totalReadingSeconds = 0,
  });
}

/// Nom, indice et phrase de victoire d'un badge, dans la langue du profil.
typedef BadgeTexts = ({String name, String hint, String earned});

/// Un badge d'habitude de lecture. Les histoires terminées sont déjà
/// récompensées par les morales : les badges récompensent la façon de lire.
class BadgeModel {
  final String id;
  final IconData icon;
  final Color color;

  /// Null pour un badge attribué au moment de l'action (ex. première écoute).
  final bool Function(BadgeStats stats)? isEarned;

  const BadgeModel({
    required this.id,
    required this.icon,
    required this.color,
    this.isEarned,
  });

  /// Textes du badge dans la langue du profil. Ils sont rangés avec les autres
  /// traductions (lib/l10n) plutôt que dans le modèle : un badge est une
  /// icône, une couleur et une condition — sa formulation change de langue.
  BadgeTexts texts(AppLocalizations l10n) => switch (id) {
        'premiere_page' => (
            name: l10n.badgeFirstPageName,
            hint: l10n.badgeFirstPageHint,
            earned: l10n.badgeFirstPageEarned,
          ),
        'petite_flamme' => (
            name: l10n.badgeSmallFlameName,
            hint: l10n.badgeSmallFlameHint,
            earned: l10n.badgeSmallFlameEarned,
          ),
        'grande_flamme' => (
            name: l10n.badgeBigFlameName,
            hint: l10n.badgeBigFlameHint,
            earned: l10n.badgeBigFlameEarned,
          ),
        'feu_de_joie' => (
            name: l10n.badgeBonfireName,
            hint: l10n.badgeBonfireHint,
            earned: l10n.badgeBonfireEarned,
          ),
        'coup_de_coeur' => (
            name: l10n.badgeFavoriteName,
            hint: l10n.badgeFavoriteHint,
            earned: l10n.badgeFavoriteEarned,
          ),
        'tresor_de_contes' => (
            name: l10n.badgeStoryTreasureName,
            hint: l10n.badgeStoryTreasureHint,
            earned: l10n.badgeStoryTreasureEarned,
          ),
        'oreille_curieuse' => (
            name: l10n.badgeCuriousEarName,
            hint: l10n.badgeCuriousEarHint,
            earned: l10n.badgeCuriousEarEarned,
          ),
        'explorateur' => (
            name: l10n.badgeExplorerName,
            hint: l10n.badgeExplorerHint,
            earned: l10n.badgeExplorerEarned,
          ),
        'grand_explorateur' => (
            name: l10n.badgeGreatExplorerName,
            hint: l10n.badgeGreatExplorerHint,
            earned: l10n.badgeGreatExplorerEarned,
          ),
        'conte_du_soir' => (
            name: l10n.badgeBedtimeTaleName,
            hint: l10n.badgeBedtimeTaleHint,
            earned: l10n.badgeBedtimeTaleEarned,
          ),
        'leve_tot' => (
            name: l10n.badgeEarlyBirdName,
            hint: l10n.badgeEarlyBirdHint,
            earned: l10n.badgeEarlyBirdEarned,
          ),
        'week_end_enchante' => (
            name: l10n.badgeMagicWeekendName,
            hint: l10n.badgeMagicWeekendHint,
            earned: l10n.badgeMagicWeekendEarned,
          ),
        'encore_une_fois' => (
            name: l10n.badgeOnceMoreName,
            hint: l10n.badgeOnceMoreHint,
            earned: l10n.badgeOnceMoreEarned,
          ),
        'grand_livre' => (
            name: l10n.badgeBigBookName,
            hint: l10n.badgeBigBookHint,
            earned: l10n.badgeBigBookEarned,
          ),
        'sablier_magique' => (
            name: l10n.badgeMagicHourglassName,
            hint: l10n.badgeMagicHourglassHint,
            earned: l10n.badgeMagicHourglassEarned,
          ),
        'grande_horloge' => (
            name: l10n.badgeGrandClockName,
            hint: l10n.badgeGrandClockHint,
            earned: l10n.badgeGrandClockEarned,
          ),
        _ => (name: id, hint: '', earned: ''),
      };

  static const String firstListenId = 'oreille_curieuse';

  static final List<BadgeModel> all = [
    BadgeModel(
      id: 'premiere_page',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF4FA3F7),
      isEarned: (s) => s.storiesStarted >= 1,
    ),

    // Séries de jours de lecture
    BadgeModel(
      id: 'petite_flamme',
      icon: Icons.local_fire_department_rounded,
      color: const Color(0xFFFF8A3D),
      isEarned: (s) => s.currentStreak >= 3,
    ),
    BadgeModel(
      id: 'grande_flamme',
      icon: Icons.whatshot_rounded,
      color: const Color(0xFFE8453C),
      isEarned: (s) => s.currentStreak >= 7,
    ),
    BadgeModel(
      id: 'feu_de_joie',
      icon: Icons.fireplace_rounded,
      color: const Color(0xFFC62828),
      isEarned: (s) => s.currentStreak >= 14,
    ),

    // Favoris
    BadgeModel(
      id: 'coup_de_coeur',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF06292),
      isEarned: (s) => s.favoritesCount >= 1,
    ),
    BadgeModel(
      id: 'tresor_de_contes',
      icon: Icons.diamond_rounded,
      color: const Color(0xFF29B6F6),
      isEarned: (s) => s.favoritesCount >= 5,
    ),

    const BadgeModel(
      id: firstListenId,
      icon: Icons.headphones_rounded,
      color: Color(0xFF26A69A),
    ),

    // Thèmes
    BadgeModel(
      id: 'explorateur',
      icon: Icons.explore_rounded,
      color: const Color(0xFF66BB6A),
      isEarned: (s) => s.finishedCategoriesCount >= 3,
    ),
    BadgeModel(
      id: 'grand_explorateur',
      icon: Icons.public_rounded,
      color: const Color(0xFF2E7D32),
      // Sans assez de thèmes au catalogue, tous les explorer suffit
      isEarned: (s) =>
          s.availableCategoriesCount > 0 &&
          s.finishedCategoriesCount >=
              (s.availableCategoriesCount < 6 ? s.availableCategoriesCount : 6),
    ),

    // Moments de lecture
    BadgeModel(
      id: 'conte_du_soir',
      icon: Icons.bedtime_rounded,
      color: const Color(0xFF7E57C2),
      isEarned: (s) => s.hasEveningReading,
    ),
    BadgeModel(
      id: 'leve_tot',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFFF8A80),
      isEarned: (s) => s.hasMorningReading,
    ),
    BadgeModel(
      id: 'week_end_enchante',
      icon: Icons.weekend_rounded,
      color: const Color(0xFFAB47BC),
      isEarned: (s) => s.hasWeekendReading,
    ),

    // Façons de lire
    BadgeModel(
      id: 'encore_une_fois',
      icon: Icons.replay_rounded,
      color: const Color(0xFF9CCC65),
      isEarned: (s) => s.hasReread,
    ),
    BadgeModel(
      id: 'grand_livre',
      icon: Icons.import_contacts_rounded,
      color: const Color(0xFF8D6E63),
      isEarned: (s) => s.finishedLongStory,
    ),

    // Temps de lecture
    BadgeModel(
      id: 'sablier_magique',
      icon: Icons.hourglass_bottom_rounded,
      color: const Color(0xFFF1B90F),
      isEarned: (s) => s.totalReadingSeconds >= 3600,
    ),
    BadgeModel(
      id: 'grande_horloge',
      icon: Icons.watch_later_rounded,
      color: const Color(0xFF3949AB),
      isEarned: (s) => s.totalReadingSeconds >= 5 * 3600,
    ),
  ];

  /// Badges dont la condition est remplie avec les données actuelles.
  static Set<String> computeEarned(BadgeStats stats) => {
        for (final badge in all)
          if (badge.isEarned?.call(stats) ?? false) badge.id,
      };
}
