// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get dataLoadingError => 'Die Daten konnten nicht geladen werden';

  @override
  String get userNotConnected => 'Du bist nicht angemeldet.';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get navHome => 'Start';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navTreasures => 'Meine Schätze';

  @override
  String get noProfileFound => 'Kein Profil gefunden';

  @override
  String get noProfileSelected => 'Kein Profil ausgewählt.';

  @override
  String get greetingEvening => 'Eine Gute-Nacht-Geschichte?';

  @override
  String get greetingDay => 'Welche Geschichte lesen wir heute?';

  @override
  String get continueReading => 'Weiterlesen';

  @override
  String get forYourAge => 'Passend für dein Alter';

  @override
  String get newStories => 'Neu';

  @override
  String percentDone(int percent) {
    return '$percent% gelesen';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get filterInProgress => 'Angefangen';

  @override
  String get filterUnread => 'Ungelesen';

  @override
  String get myFavorites => 'Meine Favoriten';

  @override
  String get noFavoritesYet => 'Noch keine Favoriten';

  @override
  String get noFavoritesHint =>
      'Speichere deine Lieblingsgeschichten und finde sie hier sofort wieder!';

  @override
  String get myMorals => 'Meine Lehren';

  @override
  String get wisdomCollected => 'Gesammelte Weisheit';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total Lehren freigeschaltet';
  }

  @override
  String get noMoralForStory =>
      'Für diese Geschichte ist keine Lehre hinterlegt.';

  @override
  String get noMoralShort => 'Keine Lehre hinterlegt.';

  @override
  String get moralLocked =>
      'Lies die Geschichte zu Ende, um ihre Lehre freizuschalten.';

  @override
  String get close => 'Schließen';

  @override
  String get myBadges => 'Meine Abzeichen';

  @override
  String get badgesLoadError =>
      'Deine Abzeichen können gerade nicht geladen werden.';

  @override
  String get surpriseBadge => 'Überraschungsabzeichen';

  @override
  String get badgesIntroNone =>
      'Überraschungsabzeichen warten auf dich! Lies die Hinweise, um sie zu finden.';

  @override
  String get badgesIntroAll => 'Unglaublich, du hast alle Abzeichen gefunden!';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Super, du hast schon $count Abzeichen! Wer kommt als Nächstes?',
      one: 'Super, du hast schon 1 Abzeichen! Wer kommt als Nächstes?',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'Favoriten';

  @override
  String get badgeFirstPageName => 'Erste Seite';

  @override
  String get badgeFirstPageHint => 'Öffne deine allererste Geschichte…';

  @override
  String get badgeFirstPageEarned => 'Du hast deine erste Geschichte geöffnet!';

  @override
  String get badgeSmallFlameName => 'Kleine Flamme';

  @override
  String get badgeSmallFlameHint => 'Lies 3 Tage hintereinander…';

  @override
  String get badgeSmallFlameEarned => 'Du hast 3 Tage hintereinander gelesen!';

  @override
  String get badgeBigFlameName => 'Große Flamme';

  @override
  String get badgeBigFlameHint => 'Lies 7 Tage hintereinander…';

  @override
  String get badgeBigFlameEarned => 'Eine ganze Woche Lesen!';

  @override
  String get badgeBonfireName => 'Freudenfeuer';

  @override
  String get badgeBonfireHint => 'Lies 14 Tage hintereinander…';

  @override
  String get badgeBonfireEarned => 'Zwei Wochen Lesen ohne Pause!';

  @override
  String get badgeFavoriteName => 'Herzensgeschichte';

  @override
  String get badgeFavoriteHint =>
      'Behalte eine Geschichte in deinen Favoriten…';

  @override
  String get badgeFavoriteEarned =>
      'Du hast eine Geschichte gefunden, die du liebst!';

  @override
  String get badgeStoryTreasureName => 'Geschichtenschatz';

  @override
  String get badgeStoryTreasureHint =>
      'Behalte 5 Geschichten in deinen Favoriten…';

  @override
  String get badgeStoryTreasureEarned =>
      'Du hast einen echten Schatz aus 5 Lieblingsgeschichten!';

  @override
  String get badgeCuriousEarName => 'Neugieriges Ohr';

  @override
  String get badgeCuriousEarHint => 'Hör dir eine erzählte Geschichte an…';

  @override
  String get badgeCuriousEarEarned => 'Du hast deine erste Geschichte gehört!';

  @override
  String get badgeExplorerName => 'Entdecker';

  @override
  String get badgeExplorerHint =>
      'Lies Geschichten aus 3 verschiedenen Themen zu Ende…';

  @override
  String get badgeExplorerEarned => 'Du hast 3 verschiedene Themen entdeckt!';

  @override
  String get badgeGreatExplorerName => 'Großer Entdecker';

  @override
  String get badgeGreatExplorerHint =>
      'Lies Geschichten aus 6 verschiedenen Themen zu Ende…';

  @override
  String get badgeGreatExplorerEarned =>
      'Du bist durch 6 verschiedene Themen gereist!';

  @override
  String get badgeBedtimeTaleName => 'Gute-Nacht-Geschichte';

  @override
  String get badgeBedtimeTaleHint =>
      'Lies abends vor dem Schlafen eine Geschichte…';

  @override
  String get badgeBedtimeTaleEarned => 'Eine Geschichte vor dem Schlafen!';

  @override
  String get badgeEarlyBirdName => 'Frühaufsteher';

  @override
  String get badgeEarlyBirdHint => 'Lies morgens eine Geschichte…';

  @override
  String get badgeEarlyBirdEarned =>
      'Eine Geschichte für einen guten Start in den Tag!';

  @override
  String get badgeMagicWeekendName => 'Zauberhaftes Wochenende';

  @override
  String get badgeMagicWeekendHint =>
      'Lies samstags oder sonntags eine Geschichte…';

  @override
  String get badgeMagicWeekendEarned =>
      'Sogar am Wochenende liest du Geschichten!';

  @override
  String get badgeOnceMoreName => 'Noch einmal';

  @override
  String get badgeOnceMoreHint =>
      'Lies eine schon beendete Geschichte noch einmal…';

  @override
  String get badgeOnceMoreEarned =>
      'Du hast eine Lieblingsgeschichte noch einmal gelesen!';

  @override
  String get badgeBigBookName => 'Großes Buch';

  @override
  String get badgeBigBookHint => 'Lies eine der längsten Geschichten zu Ende…';

  @override
  String get badgeBigBookEarned =>
      'Du hast eine sehr lange Geschichte geschafft!';

  @override
  String get badgeMagicHourglassName => 'Zaubersanduhr';

  @override
  String get badgeMagicHourglassHint =>
      'Verbringe eine Stunde mit Geschichten…';

  @override
  String get badgeMagicHourglassEarned =>
      'Eine ganze Stunde mit deinen Geschichten!';

  @override
  String get badgeGrandClockName => 'Große Uhr';

  @override
  String get badgeGrandClockHint => 'Verbringe 5 Stunden mit Geschichten…';

  @override
  String get badgeGrandClockEarned => 'Fünf Stunden Reise durch Geschichten!';

  @override
  String badgeCongrats(String text) {
    return 'Super! $text';
  }

  @override
  String get profileNotFound => 'Profil nicht gefunden.';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Super! Du liest schon $days Tage hintereinander!',
      one: 'Los geht’s! Komm morgen wieder, damit deine Flamme wächst.',
      zero: 'Lies eine Geschichte und entzünde deine Flamme!',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'Elternbereich';

  @override
  String get streakTileLabel => 'Lesen\nin Folge';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Geschichten\ngelesen',
      one: 'Geschichte\ngelesen',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total freigeschaltet';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total verdient';
  }

  @override
  String get changeReader => 'Leser wechseln';

  @override
  String get parentsOnly => 'Nur für Erwachsene';

  @override
  String get parentalGateInstruction =>
      'Tippe zum Fortfahren diese Zahlen der Reihe nach an:';

  @override
  String get parentalGateWrong => 'Das war nicht richtig. Neuer Code oben.';

  @override
  String get digitZero => 'null';

  @override
  String get digitOne => 'eins';

  @override
  String get digitTwo => 'zwei';

  @override
  String get digitThree => 'drei';

  @override
  String get digitFour => 'vier';

  @override
  String get digitFive => 'fünf';

  @override
  String get digitSix => 'sechs';

  @override
  String get digitSeven => 'sieben';

  @override
  String get digitEight => 'acht';

  @override
  String get digitNine => 'neun';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get noSettingsFound => 'Keine Einstellungen gefunden.';

  @override
  String get narrationVoice => 'Erzählstimme';

  @override
  String get voiceFemale => 'Weiblich';

  @override
  String get voiceMale => 'Männlich';

  @override
  String get accessibility => 'Barrierefreiheit';

  @override
  String get dyslexiaMode => 'Legasthenie-Modus';

  @override
  String get dyslexiaHint => 'Passt Farben, Abstände und Größe an';

  @override
  String get textDisplay => 'Textdarstellung';

  @override
  String get textSize => 'Textgröße';

  @override
  String get readingTheme => 'Lese-Design';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get enterName => 'Gib einen Namen ein';

  @override
  String get enterValidAge => 'Gib ein gültiges Alter ein';

  @override
  String get profileUpdated => 'Profil aktualisiert!';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String deleteProfileConfirm(String name) {
    return 'Möchtest du das Profil von $name wirklich löschen? Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get profileAndDataDeleted => 'Profil und Daten gelöscht';

  @override
  String activeProfileNamed(String name) {
    return 'Aktives Profil: $name';
  }

  @override
  String get pleaseSignIn => 'Bitte melde dich an.';

  @override
  String get manageProfiles => 'Profile verwalten';

  @override
  String get whoIsReadingToday => 'Wer liest heute?';

  @override
  String get manageProfilesTooltip => 'Profile verwalten (Eltern)';

  @override
  String get createProfile => 'Profil erstellen';

  @override
  String ageYears(int age) {
    return '$age Jahre';
  }

  @override
  String get mascotWhoReads => 'Hallo! Wer liest mit mir?';

  @override
  String get whoIsOurAdventurer => 'Wer ist unser Abenteurer?';

  @override
  String get theirName => 'Wie heißt er oder sie?';

  @override
  String get nameHintExample => 'z. B. Leo, Nina…';

  @override
  String get theirAge => 'Wie alt ist er oder sie?';

  @override
  String get createProfileAndStart => 'Profil erstellen und loslesen';

  @override
  String get reconnectNeeded => 'Erneute Anmeldung nötig';

  @override
  String get reconnectExplain =>
      'Aus Sicherheitsgründen erfordert das Löschen des Kontos eine kürzliche Anmeldung. Du wirst abgemeldet: melde dich erneut an und komm dann hierher zurück, um das Konto zu löschen.';

  @override
  String get deleteAccountQuestion => 'Konto löschen?';

  @override
  String get deleteAccountExplain =>
      'Alle Profile, Fortschritte, Belohnungen und Einstellungen werden endgültig gelöscht. Das lässt sich nicht rückgängig machen.\n\nWenn du ein Abo hast, kündige es im App Store oder bei Google Play: das Löschen des Kontos beendet es nicht.';

  @override
  String get deleteForever => 'Endgültig löschen';

  @override
  String get readingTracking => 'Leseübersicht';

  @override
  String readingTrackingOf(String name) {
    return 'Leseübersicht von $name';
  }

  @override
  String get statStoriesRead => 'Gelesene\nGeschichten';

  @override
  String get statReadingTime => 'Lese-\nzeit';

  @override
  String get statStreak => 'Tage in\nFolge';

  @override
  String queueFull(int max) {
    return 'Die Warteschlange ist voll: höchstens $max Geschichten';
  }

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get removeFromQueue => 'Aus der Warteschlange entfernen';

  @override
  String removeStoryFromQueue(String title) {
    return '$title aus der Warteschlange entfernen';
  }

  @override
  String get clearQueue => 'Warteschlange leeren';

  @override
  String get previousStory => 'Vorherige Geschichte';

  @override
  String get nextStory => 'Nächste Geschichte';

  @override
  String get stopQueue => 'Warteschlange stoppen';

  @override
  String get noPreviousStory => 'Keine vorherige Geschichte';

  @override
  String get noNextStory => 'Keine nächste Geschichte';

  @override
  String get searchHint => 'Nach einer Geschichte suchen…';

  @override
  String get searchNotFound =>
      'Ich habe diese Geschichte nicht gefunden… Versuch ein anderes Wort!';

  @override
  String get youMightLike => 'Das gefällt dir vielleicht';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geschichten gefunden',
      one: '1 Geschichte gefunden',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => 'Ideen gefällig?';

  @override
  String get forYou => 'Für dich';

  @override
  String get stories => 'Geschichten';

  @override
  String get actionBlocked => 'Aktion blockiert';

  @override
  String get feedbackRateLimit =>
      'Zum Schutz vor Missbrauch musst du zwischen zwei Kommentaren 5 Minuten warten.';

  @override
  String get sendFeedback => 'Feedback senden';

  @override
  String get yourOpinionMatters => 'Deine Meinung ist uns wichtig!';

  @override
  String get feedbackIntro =>
      'Eine Idee, ein Fehler oder ein Vorschlag? Schreib uns unten.';

  @override
  String get feedbackHint => 'Schreib deine Nachricht hier…';

  @override
  String get feedbackEmpty => 'Die Nachricht darf nicht leer sein';

  @override
  String get feedbackTooShort =>
      'Die Nachricht ist etwas zu kurz (mindestens 10 Zeichen)';

  @override
  String get feedbackThanks => 'Danke! Dein Kommentar wurde gesendet.';

  @override
  String get feedbackError => 'Senden fehlgeschlagen';

  @override
  String get googleSignInFailed => 'Anmeldung mit Google fehlgeschlagen';

  @override
  String get appleSignInFailed => 'Anmeldung mit Apple fehlgeschlagen';

  @override
  String get signUpFailed => 'Registrierung fehlgeschlagen';

  @override
  String get noAccountWithEmail => 'Kein Konto mit dieser E-Mail';

  @override
  String get wrongPassword => 'Falsches Passwort';

  @override
  String get invalidEmail => 'Ungültige E-Mail';

  @override
  String get emailRequired => 'E-Mail erforderlich';

  @override
  String get passwordHint => 'Passwort';

  @override
  String get passwordRequired => 'Passwort erforderlich';

  @override
  String get passwordTooShort => 'Mindestens 6 Zeichen';

  @override
  String get signingIn => 'Anmeldung läuft…';

  @override
  String get signingUp => 'Registrierung läuft…';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get termsNotice =>
      'Wenn du fortfährst, akzeptierst du unsere Nutzungs-\nbedingungen und unsere Datenschutzerklärung';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get deleteMyAccount => 'Mein Konto löschen';

  @override
  String get deleteError => 'Löschen fehlgeschlagen';

  @override
  String get audioError => 'Audiofehler';

  @override
  String get favoriteUpdateError =>
      'Favoriten konnten nicht aktualisiert werden';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '$count Tag',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int count) {
    return '$count Sek.';
  }

  @override
  String durationMinutes(int count) {
    return '$count Min.';
  }

  @override
  String durationHours(int hours) {
    return '$hours Std.';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours Std. $minutes';
  }

  @override
  String get onboardingTagline => 'Zauberhafte Geschichten\nfür kleine Träumer';

  @override
  String get sectionProfilesAndReading => 'Profile und Lesen';

  @override
  String get sectionSupportAndInfo => 'Hilfe und Informationen';

  @override
  String get readingSettings => 'Leseeinstellungen';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get chooseYourAvatar => 'Wähle deinen Avatar';

  @override
  String get signInError => 'Anmeldefehler';

  @override
  String get notificationChannelName => 'Lese-Erinnerungen';

  @override
  String get notificationChannelDescription =>
      'Erinnerungen, die Geschichte zu Ende zu lesen';

  @override
  String get notificationReminderBody =>
      'Du hast deine Geschichte noch nicht zu Ende gelesen! Komm und sieh, wie sie weitergeht.';

  @override
  String get profileCreationFailed =>
      'Das Profil konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get listen => 'Anhören';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'Geschichte $position von $total';
  }

  @override
  String get readingPreviewSample =>
      'Es waren einmal, in einer Stadt in Persien, zwei Brüder namens Kassim und Ali Baba.';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get nameLabel => 'Name';

  @override
  String get ageLabel => 'Alter';

  @override
  String get ageHintExample => 'z. B. 5';

  @override
  String get readThemeClassic => 'Klassisch';

  @override
  String get readThemeImmersive => 'Immersiv';

  @override
  String get readThemeManuscript => 'Handschrift';

  @override
  String get back => 'Zurück';

  @override
  String get searchFieldHint => 'Titel, Tier, Figur…';

  @override
  String get clear => 'Löschen';

  @override
  String get genericError =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get readingReminders => 'Lese-Erinnerungen';

  @override
  String get nightMode => 'Nachtmodus';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get newBadge => 'Neues Abzeichen!';

  @override
  String get great => 'Super!';

  @override
  String greetingHello(String name) {
    return 'Hallo $name!';
  }

  @override
  String get send => 'Senden';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get start => 'Loslegen';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Abspielen';
}
