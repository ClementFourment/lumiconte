import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja')
  ];

  /// Message affiché quand les contes et les thèmes n'ont pas pu être chargés
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des données'**
  String get dataLoadingError;

  /// Message affiché quand aucun compte n'est connecté
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur non connecté.'**
  String get userNotConnected;

  /// Titre de la section des réglages, dans l'espace parents
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// Libellé du choix de la langue, dans l'espace parents
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get navLibrary;

  /// Onglet regroupant favoris, morales et badges
  ///
  /// In fr, this message translates to:
  /// **'Mes trésors'**
  String get navTreasures;

  /// No description provided for @noProfileFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil trouvé'**
  String get noProfileFound;

  /// No description provided for @noProfileSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil sélectionné.'**
  String get noProfileSelected;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Une histoire avant de dormir ?'**
  String get greetingEvening;

  /// No description provided for @greetingDay.
  ///
  /// In fr, this message translates to:
  /// **'Quelle histoire on lit aujourd\'hui ?'**
  String get greetingDay;

  /// No description provided for @continueReading.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la lecture'**
  String get continueReading;

  /// No description provided for @forYourAge.
  ///
  /// In fr, this message translates to:
  /// **'Adapté à ton âge'**
  String get forYourAge;

  /// No description provided for @newStories.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get newStories;

  /// Part de l'histoire deja lue, sur une vignette
  ///
  /// In fr, this message translates to:
  /// **'{percent}% terminé'**
  String percentDone(int percent);

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @filterInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get filterInProgress;

  /// No description provided for @filterUnread.
  ///
  /// In fr, this message translates to:
  /// **'Non lu'**
  String get filterUnread;

  /// No description provided for @myFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes Favoris'**
  String get myFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de favoris'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez vos histoires préférées pour les retrouver facilement ici !'**
  String get noFavoritesHint;

  /// No description provided for @myMorals.
  ///
  /// In fr, this message translates to:
  /// **'Mes morales'**
  String get myMorals;

  /// No description provided for @wisdomCollected.
  ///
  /// In fr, this message translates to:
  /// **'Sagesse accumulée'**
  String get wisdomCollected;

  /// Compteur de morales debloquees
  ///
  /// In fr, this message translates to:
  /// **'{unlocked} / {total} morales débloquées'**
  String moralsUnlockedCount(int unlocked, int total);

  /// No description provided for @noMoralForStory.
  ///
  /// In fr, this message translates to:
  /// **'Pas de morale enregistrée pour ce conte.'**
  String get noMoralForStory;

  /// No description provided for @noMoralShort.
  ///
  /// In fr, this message translates to:
  /// **'Pas de morale enregistrée.'**
  String get noMoralShort;

  /// No description provided for @moralLocked.
  ///
  /// In fr, this message translates to:
  /// **'Terminez cette histoire pour en débloquer la morale.'**
  String get moralLocked;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @myBadges.
  ///
  /// In fr, this message translates to:
  /// **'Mes badges'**
  String get myBadges;

  /// No description provided for @badgesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger tes badges pour le moment.'**
  String get badgesLoadError;

  /// No description provided for @surpriseBadge.
  ///
  /// In fr, this message translates to:
  /// **'Badge surprise'**
  String get surpriseBadge;

  /// No description provided for @badgesIntroNone.
  ///
  /// In fr, this message translates to:
  /// **'Des badges surprises t\'attendent ! Lis les indices pour les trouver.'**
  String get badgesIntroNone;

  /// No description provided for @badgesIntroAll.
  ///
  /// In fr, this message translates to:
  /// **'Incroyable, tu as trouvé tous les badges !'**
  String get badgesIntroAll;

  /// Phrase d'accueil de l'ecran des badges
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Bravo, tu as déjà 1 badge ! Qui sera le prochain ?} other{Bravo, tu as déjà {count} badges ! Qui sera le prochain ?}}'**
  String badgesIntroSome(int count);

  /// No description provided for @filterFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get filterFavorites;

  /// No description provided for @badgeFirstPageName.
  ///
  /// In fr, this message translates to:
  /// **'Première page'**
  String get badgeFirstPageName;

  /// No description provided for @badgeFirstPageHint.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre ta toute première histoire…'**
  String get badgeFirstPageHint;

  /// No description provided for @badgeFirstPageEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as ouvert ta première histoire !'**
  String get badgeFirstPageEarned;

  /// No description provided for @badgeSmallFlameName.
  ///
  /// In fr, this message translates to:
  /// **'Petite flamme'**
  String get badgeSmallFlameName;

  /// No description provided for @badgeSmallFlameHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis 3 jours de suite…'**
  String get badgeSmallFlameHint;

  /// No description provided for @badgeSmallFlameEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as lu 3 jours de suite !'**
  String get badgeSmallFlameEarned;

  /// No description provided for @badgeBigFlameName.
  ///
  /// In fr, this message translates to:
  /// **'Grande flamme'**
  String get badgeBigFlameName;

  /// No description provided for @badgeBigFlameHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis 7 jours de suite…'**
  String get badgeBigFlameHint;

  /// No description provided for @badgeBigFlameEarned.
  ///
  /// In fr, this message translates to:
  /// **'Une semaine entière de lecture !'**
  String get badgeBigFlameEarned;

  /// No description provided for @badgeBonfireName.
  ///
  /// In fr, this message translates to:
  /// **'Feu de joie'**
  String get badgeBonfireName;

  /// No description provided for @badgeBonfireHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis 14 jours de suite…'**
  String get badgeBonfireHint;

  /// No description provided for @badgeBonfireEarned.
  ///
  /// In fr, this message translates to:
  /// **'Deux semaines de lecture sans t\'arrêter !'**
  String get badgeBonfireEarned;

  /// No description provided for @badgeFavoriteName.
  ///
  /// In fr, this message translates to:
  /// **'Coup de cœur'**
  String get badgeFavoriteName;

  /// No description provided for @badgeFavoriteHint.
  ///
  /// In fr, this message translates to:
  /// **'Garde une histoire dans tes favoris…'**
  String get badgeFavoriteHint;

  /// No description provided for @badgeFavoriteEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as trouvé une histoire que tu adores !'**
  String get badgeFavoriteEarned;

  /// No description provided for @badgeStoryTreasureName.
  ///
  /// In fr, this message translates to:
  /// **'Trésor de contes'**
  String get badgeStoryTreasureName;

  /// No description provided for @badgeStoryTreasureHint.
  ///
  /// In fr, this message translates to:
  /// **'Garde 5 histoires dans tes favoris…'**
  String get badgeStoryTreasureHint;

  /// No description provided for @badgeStoryTreasureEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as un vrai trésor de 5 histoires préférées !'**
  String get badgeStoryTreasureEarned;

  /// No description provided for @badgeCuriousEarName.
  ///
  /// In fr, this message translates to:
  /// **'Oreille curieuse'**
  String get badgeCuriousEarName;

  /// No description provided for @badgeCuriousEarHint.
  ///
  /// In fr, this message translates to:
  /// **'Écoute une histoire racontée…'**
  String get badgeCuriousEarHint;

  /// No description provided for @badgeCuriousEarEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as écouté ta première histoire !'**
  String get badgeCuriousEarEarned;

  /// No description provided for @badgeExplorerName.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur'**
  String get badgeExplorerName;

  /// No description provided for @badgeExplorerHint.
  ///
  /// In fr, this message translates to:
  /// **'Termine des histoires de 3 thèmes différents…'**
  String get badgeExplorerHint;

  /// No description provided for @badgeExplorerEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as exploré 3 thèmes différents !'**
  String get badgeExplorerEarned;

  /// No description provided for @badgeGreatExplorerName.
  ///
  /// In fr, this message translates to:
  /// **'Grand explorateur'**
  String get badgeGreatExplorerName;

  /// No description provided for @badgeGreatExplorerHint.
  ///
  /// In fr, this message translates to:
  /// **'Termine des histoires de 6 thèmes différents…'**
  String get badgeGreatExplorerHint;

  /// No description provided for @badgeGreatExplorerEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as voyagé dans 6 thèmes différents !'**
  String get badgeGreatExplorerEarned;

  /// No description provided for @badgeBedtimeTaleName.
  ///
  /// In fr, this message translates to:
  /// **'Conte du soir'**
  String get badgeBedtimeTaleName;

  /// No description provided for @badgeBedtimeTaleHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis une histoire le soir, avant de dormir…'**
  String get badgeBedtimeTaleHint;

  /// No description provided for @badgeBedtimeTaleEarned.
  ///
  /// In fr, this message translates to:
  /// **'Une histoire avant de dormir !'**
  String get badgeBedtimeTaleEarned;

  /// No description provided for @badgeEarlyBirdName.
  ///
  /// In fr, this message translates to:
  /// **'Lève-tôt'**
  String get badgeEarlyBirdName;

  /// No description provided for @badgeEarlyBirdHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis une histoire le matin…'**
  String get badgeEarlyBirdHint;

  /// No description provided for @badgeEarlyBirdEarned.
  ///
  /// In fr, this message translates to:
  /// **'Une histoire pour bien commencer la journée !'**
  String get badgeEarlyBirdEarned;

  /// No description provided for @badgeMagicWeekendName.
  ///
  /// In fr, this message translates to:
  /// **'Week-end enchanté'**
  String get badgeMagicWeekendName;

  /// No description provided for @badgeMagicWeekendHint.
  ///
  /// In fr, this message translates to:
  /// **'Lis une histoire le samedi ou le dimanche…'**
  String get badgeMagicWeekendHint;

  /// No description provided for @badgeMagicWeekendEarned.
  ///
  /// In fr, this message translates to:
  /// **'Même le week-end, tu lis des histoires !'**
  String get badgeMagicWeekendEarned;

  /// No description provided for @badgeOnceMoreName.
  ///
  /// In fr, this message translates to:
  /// **'Encore une fois'**
  String get badgeOnceMoreName;

  /// No description provided for @badgeOnceMoreHint.
  ///
  /// In fr, this message translates to:
  /// **'Relis une histoire que tu as déjà terminée…'**
  String get badgeOnceMoreHint;

  /// No description provided for @badgeOnceMoreEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as relu une histoire que tu aimes !'**
  String get badgeOnceMoreEarned;

  /// No description provided for @badgeBigBookName.
  ///
  /// In fr, this message translates to:
  /// **'Grand livre'**
  String get badgeBigBookName;

  /// No description provided for @badgeBigBookHint.
  ///
  /// In fr, this message translates to:
  /// **'Termine une des plus longues histoires…'**
  String get badgeBigBookHint;

  /// No description provided for @badgeBigBookEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tu as terminé une très longue histoire !'**
  String get badgeBigBookEarned;

  /// No description provided for @badgeMagicHourglassName.
  ///
  /// In fr, this message translates to:
  /// **'Sablier magique'**
  String get badgeMagicHourglassName;

  /// No description provided for @badgeMagicHourglassHint.
  ///
  /// In fr, this message translates to:
  /// **'Passe une heure à lire des histoires…'**
  String get badgeMagicHourglassHint;

  /// No description provided for @badgeMagicHourglassEarned.
  ///
  /// In fr, this message translates to:
  /// **'Une heure entière avec tes histoires !'**
  String get badgeMagicHourglassEarned;

  /// No description provided for @badgeGrandClockName.
  ///
  /// In fr, this message translates to:
  /// **'Grande horloge'**
  String get badgeGrandClockName;

  /// No description provided for @badgeGrandClockHint.
  ///
  /// In fr, this message translates to:
  /// **'Passe 5 heures à lire des histoires…'**
  String get badgeGrandClockHint;

  /// No description provided for @badgeGrandClockEarned.
  ///
  /// In fr, this message translates to:
  /// **'Cinq heures de voyage dans les histoires !'**
  String get badgeGrandClockEarned;

  /// Felicitations affichees quand un badge vient d'etre gagne
  ///
  /// In fr, this message translates to:
  /// **'Bravo ! {text}'**
  String badgeCongrats(String text);

  /// No description provided for @profileNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Profil introuvable.'**
  String get profileNotFound;

  /// Phrase de la mascotte selon la serie de jours de lecture
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =0{Lis une histoire pour allumer ta flamme !} one{C’est parti ! Reviens lire demain pour faire grandir ta flamme.} other{Bravo ! Tu lis depuis {days} jours d’affilée !}}'**
  String streakEncouragement(int days);

  /// No description provided for @parentSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace parents'**
  String get parentSpace;

  /// No description provided for @streakTileLabel.
  ///
  /// In fr, this message translates to:
  /// **'de lecture\nd’affilée'**
  String get streakTileLabel;

  /// Libelle de la tuile des histoires terminees
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{histoire\nterminée} other{histoires\nterminées}}'**
  String storiesFinishedTileLabel(int count);

  /// No description provided for @moralsUnlockedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} / {total} débloquées'**
  String moralsUnlockedSubtitle(int count, int total);

  /// No description provided for @badgesEarnedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} / {total} gagnés'**
  String badgesEarnedSubtitle(int count, int total);

  /// No description provided for @changeReader.
  ///
  /// In fr, this message translates to:
  /// **'Changer de lecteur'**
  String get changeReader;

  /// No description provided for @parentsOnly.
  ///
  /// In fr, this message translates to:
  /// **'Réservé aux parents'**
  String get parentsOnly;

  /// No description provided for @parentalGateInstruction.
  ///
  /// In fr, this message translates to:
  /// **'Pour continuer, touchez ces chiffres dans l’ordre :'**
  String get parentalGateInstruction;

  /// No description provided for @parentalGateWrong.
  ///
  /// In fr, this message translates to:
  /// **'Ce n’est pas ça. Nouveau code ci-dessus.'**
  String get parentalGateWrong;

  /// No description provided for @digitZero.
  ///
  /// In fr, this message translates to:
  /// **'zéro'**
  String get digitZero;

  /// No description provided for @digitOne.
  ///
  /// In fr, this message translates to:
  /// **'un'**
  String get digitOne;

  /// No description provided for @digitTwo.
  ///
  /// In fr, this message translates to:
  /// **'deux'**
  String get digitTwo;

  /// No description provided for @digitThree.
  ///
  /// In fr, this message translates to:
  /// **'trois'**
  String get digitThree;

  /// No description provided for @digitFour.
  ///
  /// In fr, this message translates to:
  /// **'quatre'**
  String get digitFour;

  /// No description provided for @digitFive.
  ///
  /// In fr, this message translates to:
  /// **'cinq'**
  String get digitFive;

  /// No description provided for @digitSix.
  ///
  /// In fr, this message translates to:
  /// **'six'**
  String get digitSix;

  /// No description provided for @digitSeven.
  ///
  /// In fr, this message translates to:
  /// **'sept'**
  String get digitSeven;

  /// No description provided for @digitEight.
  ///
  /// In fr, this message translates to:
  /// **'huit'**
  String get digitEight;

  /// No description provided for @digitNine.
  ///
  /// In fr, this message translates to:
  /// **'neuf'**
  String get digitNine;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @noSettingsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paramètre trouvé.'**
  String get noSettingsFound;

  /// No description provided for @narrationVoice.
  ///
  /// In fr, this message translates to:
  /// **'Voix de la narration'**
  String get narrationVoice;

  /// No description provided for @voiceFemale.
  ///
  /// In fr, this message translates to:
  /// **'Féminine'**
  String get voiceFemale;

  /// No description provided for @voiceMale.
  ///
  /// In fr, this message translates to:
  /// **'Masculine'**
  String get voiceMale;

  /// No description provided for @accessibility.
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get accessibility;

  /// No description provided for @dyslexiaMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode Dyslexie'**
  String get dyslexiaMode;

  /// No description provided for @dyslexiaHint.
  ///
  /// In fr, this message translates to:
  /// **'Adapte les couleurs, l’espacement et la taille'**
  String get dyslexiaHint;

  /// No description provided for @textDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Affichage du texte'**
  String get textDisplay;

  /// No description provided for @textSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get textSize;

  /// No description provided for @readingTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème de lecture'**
  String get readingTheme;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @enterName.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nom'**
  String get enterName;

  /// No description provided for @enterValidAge.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un âge valide'**
  String get enterValidAge;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour !'**
  String get profileUpdated;

  /// No description provided for @deleteProfile.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le profil'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer le profil de {name} ? Cette action est irréversible.'**
  String deleteProfileConfirm(String name);

  /// No description provided for @profileAndDataDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Profil et données supprimés'**
  String get profileAndDataDeleted;

  /// No description provided for @activeProfileNamed.
  ///
  /// In fr, this message translates to:
  /// **'Profil actif : {name}'**
  String activeProfileNamed(String name);

  /// No description provided for @pleaseSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vous connecter.'**
  String get pleaseSignIn;

  /// No description provided for @manageProfiles.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les profils'**
  String get manageProfiles;

  /// No description provided for @whoIsReadingToday.
  ///
  /// In fr, this message translates to:
  /// **'Qui lit aujourd’hui ?'**
  String get whoIsReadingToday;

  /// No description provided for @manageProfilesTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les profils (parents)'**
  String get manageProfilesTooltip;

  /// No description provided for @createProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer un profil'**
  String get createProfile;

  /// No description provided for @ageYears.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans'**
  String ageYears(int age);

  /// No description provided for @mascotWhoReads.
  ///
  /// In fr, this message translates to:
  /// **'Coucou ! Qui vient lire avec moi ?'**
  String get mascotWhoReads;

  /// No description provided for @whoIsOurAdventurer.
  ///
  /// In fr, this message translates to:
  /// **'Qui est notre aventurier(e) ?'**
  String get whoIsOurAdventurer;

  /// No description provided for @theirName.
  ///
  /// In fr, this message translates to:
  /// **'Son nom ?'**
  String get theirName;

  /// No description provided for @nameHintExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Léo, Nina…'**
  String get nameHintExample;

  /// No description provided for @theirAge.
  ///
  /// In fr, this message translates to:
  /// **'Son âge ?'**
  String get theirAge;

  /// No description provided for @createProfileAndStart.
  ///
  /// In fr, this message translates to:
  /// **'Créer le profil et commencer la lecture'**
  String get createProfileAndStart;

  /// No description provided for @reconnectNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion nécessaire'**
  String get reconnectNeeded;

  /// No description provided for @reconnectExplain.
  ///
  /// In fr, this message translates to:
  /// **'Par sécurité, la suppression du compte demande une connexion récente. Vous allez être déconnecté : reconnectez-vous, puis revenez ici pour supprimer le compte.'**
  String get reconnectExplain;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountExplain.
  ///
  /// In fr, this message translates to:
  /// **'Tous les profils, la progression, les récompenses et les réglages seront définitivement effacés. Cette action est irréversible.\n\nSi vous avez un abonnement, pensez à le résilier depuis l’App Store ou Google Play : supprimer le compte ne l’arrête pas.'**
  String get deleteAccountExplain;

  /// No description provided for @deleteForever.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteForever;

  /// No description provided for @readingTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de lecture'**
  String get readingTracking;

  /// No description provided for @readingTrackingOf.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de lecture de {name}'**
  String readingTrackingOf(String name);

  /// No description provided for @statStoriesRead.
  ///
  /// In fr, this message translates to:
  /// **'Histoires\nlues'**
  String get statStoriesRead;

  /// No description provided for @statReadingTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps de\nlecture'**
  String get statReadingTime;

  /// No description provided for @statStreak.
  ///
  /// In fr, this message translates to:
  /// **'Lecture\nd’affilée'**
  String get statStreak;

  /// No description provided for @queueFull.
  ///
  /// In fr, this message translates to:
  /// **'La file est pleine : {max} histoires maximum'**
  String queueFull(int max);

  /// No description provided for @addToQueue.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la file de lecture'**
  String get addToQueue;

  /// No description provided for @removeFromQueue.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de la file de lecture'**
  String get removeFromQueue;

  /// No description provided for @removeStoryFromQueue.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {title} de la file'**
  String removeStoryFromQueue(String title);

  /// No description provided for @clearQueue.
  ///
  /// In fr, this message translates to:
  /// **'Vider la file'**
  String get clearQueue;

  /// No description provided for @previousStory.
  ///
  /// In fr, this message translates to:
  /// **'Histoire précédente'**
  String get previousStory;

  /// No description provided for @nextStory.
  ///
  /// In fr, this message translates to:
  /// **'Histoire suivante'**
  String get nextStory;

  /// No description provided for @stopQueue.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la file'**
  String get stopQueue;

  /// No description provided for @noPreviousStory.
  ///
  /// In fr, this message translates to:
  /// **'Pas d’histoire précédente'**
  String get noPreviousStory;

  /// No description provided for @noNextStory.
  ///
  /// In fr, this message translates to:
  /// **'Pas d’histoire suivante'**
  String get noNextStory;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une histoire…'**
  String get searchHint;

  /// No description provided for @searchNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Je n’ai pas trouvé cette histoire… Essaie un autre mot !'**
  String get searchNotFound;

  /// No description provided for @youMightLike.
  ///
  /// In fr, this message translates to:
  /// **'Tu aimeras peut-être'**
  String get youMightLike;

  /// No description provided for @searchResultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 histoire trouvée} other{{count} histoires trouvées}}'**
  String searchResultsCount(int count);

  /// No description provided for @anyIdeas.
  ///
  /// In fr, this message translates to:
  /// **'Des idées ?'**
  String get anyIdeas;

  /// No description provided for @forYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour toi'**
  String get forYou;

  /// No description provided for @stories.
  ///
  /// In fr, this message translates to:
  /// **'Histoires'**
  String get stories;

  /// No description provided for @actionBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Action bloquée'**
  String get actionBlocked;

  /// No description provided for @feedbackRateLimit.
  ///
  /// In fr, this message translates to:
  /// **'Pour éviter les abus, vous devez attendre 5 minutes entre chaque commentaire.'**
  String get feedbackRateLimit;

  /// No description provided for @sendFeedback.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un commentaire'**
  String get sendFeedback;

  /// No description provided for @yourOpinionMatters.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis nous intéresse !'**
  String get yourOpinionMatters;

  /// No description provided for @feedbackIntro.
  ///
  /// In fr, this message translates to:
  /// **'Une idée, un bug ou une suggestion ? Écrivez-nous ci-dessous.'**
  String get feedbackIntro;

  /// No description provided for @feedbackHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre message ici…'**
  String get feedbackHint;

  /// No description provided for @feedbackEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le message ne peut pas être vide'**
  String get feedbackEmpty;

  /// No description provided for @feedbackTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le message est un peu trop court (10 caractères min)'**
  String get feedbackTooShort;

  /// No description provided for @feedbackThanks.
  ///
  /// In fr, this message translates to:
  /// **'Merci ! Votre commentaire a bien été envoyé.'**
  String get feedbackThanks;

  /// No description provided for @feedbackError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l’envoi'**
  String get feedbackError;

  /// No description provided for @googleSignInFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion avec Google'**
  String get googleSignInFailed;

  /// No description provided for @appleSignInFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion avec Apple'**
  String get appleSignInFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l’inscription'**
  String get signUpFailed;

  /// No description provided for @noAccountWithEmail.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte avec cet email'**
  String get noAccountWithEmail;

  /// No description provided for @wrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get wrongPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Email requis'**
  String get emailRequired;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Au minimum 6 caractères'**
  String get passwordTooShort;

  /// No description provided for @signingIn.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours…'**
  String get signingIn;

  /// No description provided for @signingUp.
  ///
  /// In fr, this message translates to:
  /// **'Inscription en cours…'**
  String get signingUp;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continueWithApple;

  /// No description provided for @termsNotice.
  ///
  /// In fr, this message translates to:
  /// **'En continuant, tu acceptes nos conditions\nd’utilisation et notre politique de confidentialité'**
  String get termsNotice;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @deleteMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteMyAccount;

  /// No description provided for @deleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get deleteError;

  /// No description provided for @audioError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur audio'**
  String get audioError;

  /// No description provided for @favoriteUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour des favoris'**
  String get favoriteUpdateError;

  /// Nombre de jours de lecture daffilee
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} jour} other{{count} jours}}'**
  String streakDays(int count);

  /// No description provided for @durationSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{count} sec'**
  String durationSeconds(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{count}min'**
  String durationMinutes(int count);

  /// No description provided for @durationHours.
  ///
  /// In fr, this message translates to:
  /// **'{hours}h'**
  String durationHours(int hours);

  /// Minutes deja completees a deux chiffres
  ///
  /// In fr, this message translates to:
  /// **'{hours}h{minutes}'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @onboardingTagline.
  ///
  /// In fr, this message translates to:
  /// **'Des histoires magiques\npour les petits rêveurs'**
  String get onboardingTagline;

  /// No description provided for @sectionProfilesAndReading.
  ///
  /// In fr, this message translates to:
  /// **'Profils et lecture'**
  String get sectionProfilesAndReading;

  /// No description provided for @sectionSupportAndInfo.
  ///
  /// In fr, this message translates to:
  /// **'Assistance et informations'**
  String get sectionSupportAndInfo;

  /// No description provided for @readingSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de lecture'**
  String get readingSettings;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions Générales d\'Utilisation'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de Confidentialité'**
  String get privacyPolicy;

  /// No description provided for @chooseYourAvatar.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton avatar'**
  String get chooseYourAvatar;

  /// No description provided for @signInError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get signInError;

  /// No description provided for @notificationChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de lecture'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Notifications pour rappeler de finir son histoire'**
  String get notificationChannelDescription;

  /// No description provided for @notificationReminderBody.
  ///
  /// In fr, this message translates to:
  /// **'Tu n’as pas fini ta lecture ! Viens vite découvrir la suite de ton histoire.'**
  String get notificationReminderBody;

  /// No description provided for @profileCreationFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le profil n’a pas pu être créé. Réessayez.'**
  String get profileCreationFailed;

  /// No description provided for @listen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get listen;

  /// No description provided for @storyPositionInQueue.
  ///
  /// In fr, this message translates to:
  /// **'Histoire {position} sur {total}'**
  String storyPositionInQueue(int position, int total);

  /// Phrase d'exemple pour regler la taille et le theme de lecture
  ///
  /// In fr, this message translates to:
  /// **'Il y était une fois, dans une ville de Perse, deux frères nommés Kassim et Ali-Baba.'**
  String get readingPreviewSample;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @nameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get nameLabel;

  /// No description provided for @ageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get ageLabel;

  /// No description provided for @ageHintExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex : 5'**
  String get ageHintExample;

  /// No description provided for @readThemeClassic.
  ///
  /// In fr, this message translates to:
  /// **'Classique'**
  String get readThemeClassic;

  /// No description provided for @readThemeImmersive.
  ///
  /// In fr, this message translates to:
  /// **'Immersif'**
  String get readThemeImmersive;

  /// No description provided for @readThemeManuscript.
  ///
  /// In fr, this message translates to:
  /// **'Manuscrit'**
  String get readThemeManuscript;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @searchFieldHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre, animal, personnage…'**
  String get searchFieldHint;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get genericError;

  /// No description provided for @readingReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de lecture'**
  String get readingReminders;

  /// No description provided for @nightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode nuit'**
  String get nightMode;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S’inscrire'**
  String get signUp;

  /// No description provided for @gotIt.
  ///
  /// In fr, this message translates to:
  /// **'D’accord'**
  String get gotIt;

  /// No description provided for @newBadge.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau badge !'**
  String get newBadge;

  /// No description provided for @great.
  ///
  /// In fr, this message translates to:
  /// **'Super !'**
  String get great;

  /// No description provided for @greetingHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name} !'**
  String greetingHello(String name);

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @avatar.
  ///
  /// In fr, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get play;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
