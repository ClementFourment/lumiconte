import 'package:flutter/material.dart';

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

/// Un badge d'habitude de lecture. Les histoires terminées sont déjà
/// récompensées par les morales : les badges récompensent la façon de lire.
class BadgeModel {
  final String id;
  final String name;

  /// Indice montré tant que le badge n'est pas gagné.
  final String hint;

  /// Phrase montrée une fois le badge gagné.
  final String earnedText;
  final IconData icon;
  final Color color;

  /// Null pour un badge attribué au moment de l'action (ex. première écoute).
  final bool Function(BadgeStats stats)? isEarned;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.hint,
    required this.earnedText,
    required this.icon,
    required this.color,
    this.isEarned,
  });

  static const String firstListenId = 'oreille_curieuse';

  static final List<BadgeModel> all = [
    BadgeModel(
      id: 'premiere_page',
      name: 'Première page',
      hint: 'Ouvre ta toute première histoire…',
      earnedText: 'Tu as ouvert ta première histoire !',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF4FA3F7),
      isEarned: (s) => s.storiesStarted >= 1,
    ),

    // Séries de jours de lecture
    BadgeModel(
      id: 'petite_flamme',
      name: 'Petite flamme',
      hint: 'Lis 3 jours de suite…',
      earnedText: 'Tu as lu 3 jours de suite !',
      icon: Icons.local_fire_department_rounded,
      color: const Color(0xFFFF8A3D),
      isEarned: (s) => s.currentStreak >= 3,
    ),
    BadgeModel(
      id: 'grande_flamme',
      name: 'Grande flamme',
      hint: 'Lis 7 jours de suite…',
      earnedText: 'Une semaine entière de lecture !',
      icon: Icons.whatshot_rounded,
      color: const Color(0xFFE8453C),
      isEarned: (s) => s.currentStreak >= 7,
    ),
    BadgeModel(
      id: 'feu_de_joie',
      name: 'Feu de joie',
      hint: 'Lis 14 jours de suite…',
      earnedText: 'Deux semaines de lecture sans t\'arrêter !',
      icon: Icons.fireplace_rounded,
      color: const Color(0xFFC62828),
      isEarned: (s) => s.currentStreak >= 14,
    ),

    // Favoris
    BadgeModel(
      id: 'coup_de_coeur',
      name: 'Coup de cœur',
      hint: 'Garde une histoire dans tes favoris…',
      earnedText: 'Tu as trouvé une histoire que tu adores !',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF06292),
      isEarned: (s) => s.favoritesCount >= 1,
    ),
    BadgeModel(
      id: 'tresor_de_contes',
      name: 'Trésor de contes',
      hint: 'Garde 5 histoires dans tes favoris…',
      earnedText: 'Tu as un vrai trésor de 5 histoires préférées !',
      icon: Icons.diamond_rounded,
      color: const Color(0xFF29B6F6),
      isEarned: (s) => s.favoritesCount >= 5,
    ),

    const BadgeModel(
      id: firstListenId,
      name: 'Oreille curieuse',
      hint: 'Écoute une histoire racontée…',
      earnedText: 'Tu as écouté ta première histoire !',
      icon: Icons.headphones_rounded,
      color: Color(0xFF26A69A),
    ),

    // Thèmes
    BadgeModel(
      id: 'explorateur',
      name: 'Explorateur',
      hint: 'Termine des histoires de 3 thèmes différents…',
      earnedText: 'Tu as exploré 3 thèmes différents !',
      icon: Icons.explore_rounded,
      color: const Color(0xFF66BB6A),
      isEarned: (s) => s.finishedCategoriesCount >= 3,
    ),
    BadgeModel(
      id: 'grand_explorateur',
      name: 'Grand explorateur',
      hint: 'Termine des histoires de 6 thèmes différents…',
      earnedText: 'Tu as voyagé dans 6 thèmes différents !',
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
      name: 'Conte du soir',
      hint: 'Lis une histoire le soir, avant de dormir…',
      earnedText: 'Une histoire avant de dormir !',
      icon: Icons.bedtime_rounded,
      color: const Color(0xFF7E57C2),
      isEarned: (s) => s.hasEveningReading,
    ),
    BadgeModel(
      id: 'leve_tot',
      name: 'Lève-tôt',
      hint: 'Lis une histoire le matin…',
      earnedText: 'Une histoire pour bien commencer la journée !',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFFF8A80),
      isEarned: (s) => s.hasMorningReading,
    ),
    BadgeModel(
      id: 'week_end_enchante',
      name: 'Week-end enchanté',
      hint: 'Lis une histoire le samedi ou le dimanche…',
      earnedText: 'Même le week-end, tu lis des histoires !',
      icon: Icons.weekend_rounded,
      color: const Color(0xFFAB47BC),
      isEarned: (s) => s.hasWeekendReading,
    ),

    // Façons de lire
    BadgeModel(
      id: 'encore_une_fois',
      name: 'Encore une fois',
      hint: 'Relis une histoire que tu as déjà terminée…',
      earnedText: 'Tu as relu une histoire que tu aimes !',
      icon: Icons.replay_rounded,
      color: const Color(0xFF9CCC65),
      isEarned: (s) => s.hasReread,
    ),
    BadgeModel(
      id: 'grand_livre',
      name: 'Grand livre',
      hint: 'Termine une des plus longues histoires…',
      earnedText: 'Tu as terminé une très longue histoire !',
      icon: Icons.import_contacts_rounded,
      color: const Color(0xFF8D6E63),
      isEarned: (s) => s.finishedLongStory,
    ),

    // Temps de lecture
    BadgeModel(
      id: 'sablier_magique',
      name: 'Sablier magique',
      hint: 'Passe une heure à lire des histoires…',
      earnedText: 'Une heure entière avec tes histoires !',
      icon: Icons.hourglass_bottom_rounded,
      color: const Color(0xFFF1B90F),
      isEarned: (s) => s.totalReadingSeconds >= 3600,
    ),
    BadgeModel(
      id: 'grande_horloge',
      name: 'Grande horloge',
      hint: 'Passe 5 heures à lire des histoires…',
      earnedText: 'Cinq heures de voyage dans les histoires !',
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
