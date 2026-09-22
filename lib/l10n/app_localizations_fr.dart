// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dataLoadingError => 'Erreur lors du chargement des données';

  @override
  String get userNotConnected => 'Utilisateur non connecté.';

  @override
  String get preferences => 'Préférences';

  @override
  String get language => 'Langue';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navTreasures => 'Mes trésors';

  @override
  String get noProfileFound => 'Aucun profil trouvé';

  @override
  String get noProfileSelected => 'Aucun profil sélectionné.';

  @override
  String get greetingEvening => 'Une histoire avant de dormir ?';

  @override
  String get greetingDay => 'Quelle histoire on lit aujourd\'hui ?';

  @override
  String get continueReading => 'Reprendre la lecture';

  @override
  String get forYourAge => 'Adapté à ton âge';

  @override
  String get newStories => 'Nouveautés';

  @override
  String percentDone(int percent) {
    return '$percent% terminé';
  }

  @override
  String get filterAll => 'Tout';

  @override
  String get filterInProgress => 'En cours';

  @override
  String get filterUnread => 'Non lu';

  @override
  String get myFavorites => 'Mes Favoris';

  @override
  String get noFavoritesYet => 'Pas encore de favoris';

  @override
  String get noFavoritesHint =>
      'Enregistrez vos histoires préférées pour les retrouver facilement ici !';

  @override
  String get myMorals => 'Mes morales';

  @override
  String get wisdomCollected => 'Sagesse accumulée';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total morales débloquées';
  }

  @override
  String get noMoralForStory => 'Pas de morale enregistrée pour ce conte.';

  @override
  String get noMoralShort => 'Pas de morale enregistrée.';

  @override
  String get moralLocked =>
      'Terminez cette histoire pour en débloquer la morale.';

  @override
  String get close => 'Fermer';

  @override
  String get myBadges => 'Mes badges';

  @override
  String get badgesLoadError =>
      'Impossible de charger tes badges pour le moment.';

  @override
  String get surpriseBadge => 'Badge surprise';

  @override
  String get badgesIntroNone =>
      'Des badges surprises t\'attendent ! Lis les indices pour les trouver.';

  @override
  String get badgesIntroAll => 'Incroyable, tu as trouvé tous les badges !';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bravo, tu as déjà $count badges ! Qui sera le prochain ?',
      one: 'Bravo, tu as déjà 1 badge ! Qui sera le prochain ?',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get badgeFirstPageName => 'Première page';

  @override
  String get badgeFirstPageHint => 'Ouvre ta toute première histoire…';

  @override
  String get badgeFirstPageEarned => 'Tu as ouvert ta première histoire !';

  @override
  String get badgeSmallFlameName => 'Petite flamme';

  @override
  String get badgeSmallFlameHint => 'Lis 3 jours de suite…';

  @override
  String get badgeSmallFlameEarned => 'Tu as lu 3 jours de suite !';

  @override
  String get badgeBigFlameName => 'Grande flamme';

  @override
  String get badgeBigFlameHint => 'Lis 7 jours de suite…';

  @override
  String get badgeBigFlameEarned => 'Une semaine entière de lecture !';

  @override
  String get badgeBonfireName => 'Feu de joie';

  @override
  String get badgeBonfireHint => 'Lis 14 jours de suite…';

  @override
  String get badgeBonfireEarned => 'Deux semaines de lecture sans t\'arrêter !';

  @override
  String get badgeFavoriteName => 'Coup de cœur';

  @override
  String get badgeFavoriteHint => 'Garde une histoire dans tes favoris…';

  @override
  String get badgeFavoriteEarned => 'Tu as trouvé une histoire que tu adores !';

  @override
  String get badgeStoryTreasureName => 'Trésor de contes';

  @override
  String get badgeStoryTreasureHint => 'Garde 5 histoires dans tes favoris…';

  @override
  String get badgeStoryTreasureEarned =>
      'Tu as un vrai trésor de 5 histoires préférées !';

  @override
  String get badgeCuriousEarName => 'Oreille curieuse';

  @override
  String get badgeCuriousEarHint => 'Écoute une histoire racontée…';

  @override
  String get badgeCuriousEarEarned => 'Tu as écouté ta première histoire !';

  @override
  String get badgeExplorerName => 'Explorateur';

  @override
  String get badgeExplorerHint =>
      'Termine des histoires de 3 thèmes différents…';

  @override
  String get badgeExplorerEarned => 'Tu as exploré 3 thèmes différents !';

  @override
  String get badgeGreatExplorerName => 'Grand explorateur';

  @override
  String get badgeGreatExplorerHint =>
      'Termine des histoires de 6 thèmes différents…';

  @override
  String get badgeGreatExplorerEarned =>
      'Tu as voyagé dans 6 thèmes différents !';

  @override
  String get badgeBedtimeTaleName => 'Conte du soir';

  @override
  String get badgeBedtimeTaleHint =>
      'Lis une histoire le soir, avant de dormir…';

  @override
  String get badgeBedtimeTaleEarned => 'Une histoire avant de dormir !';

  @override
  String get badgeEarlyBirdName => 'Lève-tôt';

  @override
  String get badgeEarlyBirdHint => 'Lis une histoire le matin…';

  @override
  String get badgeEarlyBirdEarned =>
      'Une histoire pour bien commencer la journée !';

  @override
  String get badgeMagicWeekendName => 'Week-end enchanté';

  @override
  String get badgeMagicWeekendHint =>
      'Lis une histoire le samedi ou le dimanche…';

  @override
  String get badgeMagicWeekendEarned =>
      'Même le week-end, tu lis des histoires !';

  @override
  String get badgeOnceMoreName => 'Encore une fois';

  @override
  String get badgeOnceMoreHint => 'Relis une histoire que tu as déjà terminée…';

  @override
  String get badgeOnceMoreEarned => 'Tu as relu une histoire que tu aimes !';

  @override
  String get badgeBigBookName => 'Grand livre';

  @override
  String get badgeBigBookHint => 'Termine une des plus longues histoires…';

  @override
  String get badgeBigBookEarned => 'Tu as terminé une très longue histoire !';

  @override
  String get badgeMagicHourglassName => 'Sablier magique';

  @override
  String get badgeMagicHourglassHint => 'Passe une heure à lire des histoires…';

  @override
  String get badgeMagicHourglassEarned =>
      'Une heure entière avec tes histoires !';

  @override
  String get badgeGrandClockName => 'Grande horloge';

  @override
  String get badgeGrandClockHint => 'Passe 5 heures à lire des histoires…';

  @override
  String get badgeGrandClockEarned =>
      'Cinq heures de voyage dans les histoires !';

  @override
  String badgeCongrats(String text) {
    return 'Bravo ! $text';
  }

  @override
  String get profileNotFound => 'Profil introuvable.';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Bravo ! Tu lis depuis $days jours d’affilée !',
      one: 'C’est parti ! Reviens lire demain pour faire grandir ta flamme.',
      zero: 'Lis une histoire pour allumer ta flamme !',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'Espace parents';

  @override
  String get streakTileLabel => 'de lecture\nd’affilée';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'histoires\nterminées',
      one: 'histoire\nterminée',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total débloquées';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total gagnés';
  }

  @override
  String get changeReader => 'Changer de lecteur';

  @override
  String get parentsOnly => 'Réservé aux parents';

  @override
  String get parentalGateInstruction =>
      'Pour continuer, touchez ces chiffres dans l’ordre :';

  @override
  String get parentalGateWrong => 'Ce n’est pas ça. Nouveau code ci-dessus.';

  @override
  String get digitZero => 'zéro';

  @override
  String get digitOne => 'un';

  @override
  String get digitTwo => 'deux';

  @override
  String get digitThree => 'trois';

  @override
  String get digitFour => 'quatre';

  @override
  String get digitFive => 'cinq';

  @override
  String get digitSix => 'six';

  @override
  String get digitSeven => 'sept';

  @override
  String get digitEight => 'huit';

  @override
  String get digitNine => 'neuf';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get noSettingsFound => 'Aucun paramètre trouvé.';

  @override
  String get narrationVoice => 'Voix de la narration';

  @override
  String get voiceFemale => 'Féminine';

  @override
  String get voiceMale => 'Masculine';

  @override
  String get accessibility => 'Accessibilité';

  @override
  String get dyslexiaMode => 'Mode Dyslexie';

  @override
  String get dyslexiaHint => 'Adapte les couleurs, l’espacement et la taille';

  @override
  String get textDisplay => 'Affichage du texte';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get readingTheme => 'Thème de lecture';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get enterName => 'Entrez un nom';

  @override
  String get enterValidAge => 'Entrez un âge valide';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String get deleteProfile => 'Supprimer le profil';

  @override
  String deleteProfileConfirm(String name) {
    return 'Voulez-vous vraiment supprimer le profil de $name ? Cette action est irréversible.';
  }

  @override
  String get profileAndDataDeleted => 'Profil et données supprimés';

  @override
  String activeProfileNamed(String name) {
    return 'Profil actif : $name';
  }

  @override
  String get pleaseSignIn => 'Veuillez vous connecter.';

  @override
  String get manageProfiles => 'Gérer les profils';

  @override
  String get whoIsReadingToday => 'Qui lit aujourd’hui ?';

  @override
  String get manageProfilesTooltip => 'Gérer les profils (parents)';

  @override
  String get createProfile => 'Créer un profil';

  @override
  String ageYears(int age) {
    return '$age ans';
  }

  @override
  String get mascotWhoReads => 'Coucou ! Qui vient lire avec moi ?';

  @override
  String get whoIsOurAdventurer => 'Qui est notre aventurier(e) ?';

  @override
  String get theirName => 'Son nom ?';

  @override
  String get nameHintExample => 'Ex : Léo, Nina…';

  @override
  String get theirAge => 'Son âge ?';

  @override
  String get createProfileAndStart => 'Créer le profil et commencer la lecture';

  @override
  String get reconnectNeeded => 'Reconnexion nécessaire';

  @override
  String get reconnectExplain =>
      'Par sécurité, la suppression du compte demande une connexion récente. Vous allez être déconnecté : reconnectez-vous, puis revenez ici pour supprimer le compte.';

  @override
  String get deleteAccountQuestion => 'Supprimer le compte ?';

  @override
  String get deleteAccountExplain =>
      'Tous les profils, la progression, les récompenses et les réglages seront définitivement effacés. Cette action est irréversible.\n\nSi vous avez un abonnement, pensez à le résilier depuis l’App Store ou Google Play : supprimer le compte ne l’arrête pas.';

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get readingTracking => 'Suivi de lecture';

  @override
  String readingTrackingOf(String name) {
    return 'Suivi de lecture de $name';
  }

  @override
  String get statStoriesRead => 'Histoires\nlues';

  @override
  String get statReadingTime => 'Temps de\nlecture';

  @override
  String get statStreak => 'Lecture\nd’affilée';

  @override
  String queueFull(int max) {
    return 'La file est pleine : $max histoires maximum';
  }

  @override
  String get addToQueue => 'Ajouter à la file de lecture';

  @override
  String get removeFromQueue => 'Retirer de la file de lecture';

  @override
  String removeStoryFromQueue(String title) {
    return 'Retirer $title de la file';
  }

  @override
  String get clearQueue => 'Vider la file';

  @override
  String get previousStory => 'Histoire précédente';

  @override
  String get nextStory => 'Histoire suivante';

  @override
  String get stopQueue => 'Arrêter la file';

  @override
  String get noPreviousStory => 'Pas d’histoire précédente';

  @override
  String get noNextStory => 'Pas d’histoire suivante';

  @override
  String get searchHint => 'Rechercher une histoire…';

  @override
  String get searchNotFound =>
      'Je n’ai pas trouvé cette histoire… Essaie un autre mot !';

  @override
  String get youMightLike => 'Tu aimeras peut-être';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count histoires trouvées',
      one: '1 histoire trouvée',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => 'Des idées ?';

  @override
  String get forYou => 'Pour toi';

  @override
  String get stories => 'Histoires';

  @override
  String get actionBlocked => 'Action bloquée';

  @override
  String get feedbackRateLimit =>
      'Pour éviter les abus, vous devez attendre 5 minutes entre chaque commentaire.';

  @override
  String get sendFeedback => 'Envoyer un commentaire';

  @override
  String get yourOpinionMatters => 'Votre avis nous intéresse !';

  @override
  String get feedbackIntro =>
      'Une idée, un bug ou une suggestion ? Écrivez-nous ci-dessous.';

  @override
  String get feedbackHint => 'Écrivez votre message ici…';

  @override
  String get feedbackEmpty => 'Le message ne peut pas être vide';

  @override
  String get feedbackTooShort =>
      'Le message est un peu trop court (10 caractères min)';

  @override
  String get feedbackThanks => 'Merci ! Votre commentaire a bien été envoyé.';

  @override
  String get feedbackError => 'Erreur lors de l’envoi';

  @override
  String get googleSignInFailed => 'Échec de la connexion avec Google';

  @override
  String get appleSignInFailed => 'Échec de la connexion avec Apple';

  @override
  String get signUpFailed => 'Échec de l’inscription';

  @override
  String get noAccountWithEmail => 'Aucun compte avec cet email';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get passwordTooShort => 'Au minimum 6 caractères';

  @override
  String get signingIn => 'Connexion en cours…';

  @override
  String get signingUp => 'Inscription en cours…';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get termsNotice =>
      'En continuant, tu acceptes nos conditions\nd’utilisation et notre politique de confidentialité';

  @override
  String get cancel => 'Annuler';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get deleteError => 'Erreur lors de la suppression';

  @override
  String get audioError => 'Erreur audio';

  @override
  String get favoriteUpdateError => 'Erreur lors de la mise à jour des favoris';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int count) {
    return '$count sec';
  }

  @override
  String durationMinutes(int count) {
    return '${count}min';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '${hours}h$minutes';
  }

  @override
  String get onboardingTagline =>
      'Des histoires magiques\npour les petits rêveurs';

  @override
  String get sectionProfilesAndReading => 'Profils et lecture';

  @override
  String get sectionSupportAndInfo => 'Assistance et informations';

  @override
  String get readingSettings => 'Paramètres de lecture';

  @override
  String get termsOfService => 'Conditions Générales d\'Utilisation';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get chooseYourAvatar => 'Choisis ton avatar';

  @override
  String get signInError => 'Erreur de connexion';

  @override
  String get notificationChannelName => 'Rappels de lecture';

  @override
  String get notificationChannelDescription =>
      'Notifications pour rappeler de finir son histoire';

  @override
  String get notificationReminderBody =>
      'Tu n’as pas fini ta lecture ! Viens vite découvrir la suite de ton histoire.';

  @override
  String get profileCreationFailed =>
      'Le profil n’a pas pu être créé. Réessayez.';

  @override
  String get listen => 'Écouter';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'Histoire $position sur $total';
  }

  @override
  String get readingPreviewSample =>
      'Il y était une fois, dans une ville de Perse, deux frères nommés Kassim et Ali-Baba.';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameLabel => 'Nom';

  @override
  String get ageLabel => 'Âge';

  @override
  String get ageHintExample => 'Ex : 5';

  @override
  String get readThemeClassic => 'Classique';

  @override
  String get readThemeImmersive => 'Immersif';

  @override
  String get readThemeManuscript => 'Manuscrit';

  @override
  String get back => 'Retour';

  @override
  String get searchFieldHint => 'Titre, animal, personnage…';

  @override
  String get clear => 'Effacer';

  @override
  String get genericError => 'Une erreur est survenue. Réessayez.';

  @override
  String get readingReminders => 'Rappels de lecture';

  @override
  String get nightMode => 'Mode nuit';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S’inscrire';

  @override
  String get gotIt => 'D’accord';

  @override
  String get newBadge => 'Nouveau badge !';

  @override
  String get great => 'Super !';

  @override
  String greetingHello(String name) {
    return 'Bonjour $name !';
  }

  @override
  String get send => 'Envoyer';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Sauvegarder';

  @override
  String get delete => 'Supprimer';

  @override
  String get start => 'Commencer';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Lecture';
}
