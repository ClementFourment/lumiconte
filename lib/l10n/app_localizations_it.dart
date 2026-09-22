// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get dataLoadingError => 'Impossibile caricare i dati';

  @override
  String get userNotConnected => 'Non hai effettuato l\'accesso.';

  @override
  String get preferences => 'Preferenze';

  @override
  String get language => 'Lingua';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navTreasures => 'I miei tesori';

  @override
  String get noProfileFound => 'Nessun profilo trovato';

  @override
  String get noProfileSelected => 'Nessun profilo selezionato.';

  @override
  String get greetingEvening => 'Una storia prima di dormire?';

  @override
  String get greetingDay => 'Quale storia leggiamo oggi?';

  @override
  String get continueReading => 'Continua a leggere';

  @override
  String get forYourAge => 'Adatte alla tua età';

  @override
  String get newStories => 'Novità';

  @override
  String percentDone(int percent) {
    return '$percent% completato';
  }

  @override
  String get filterAll => 'Tutto';

  @override
  String get filterInProgress => 'Iniziate';

  @override
  String get filterUnread => 'Da leggere';

  @override
  String get myFavorites => 'I miei preferiti';

  @override
  String get noFavoritesYet => 'Ancora nessun preferito';

  @override
  String get noFavoritesHint =>
      'Salva le tue storie preferite e ritrovale qui in un attimo!';

  @override
  String get myMorals => 'Le mie morali';

  @override
  String get wisdomCollected => 'Saggezza raccolta';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total morali sbloccate';
  }

  @override
  String get noMoralForStory => 'Nessuna morale salvata per questa storia.';

  @override
  String get noMoralShort => 'Nessuna morale salvata.';

  @override
  String get moralLocked =>
      'Finisci questa storia per sbloccare la sua morale.';

  @override
  String get close => 'Chiudi';

  @override
  String get myBadges => 'I miei distintivi';

  @override
  String get badgesLoadError =>
      'Non riesco a caricare i tuoi distintivi in questo momento.';

  @override
  String get surpriseBadge => 'Distintivo a sorpresa';

  @override
  String get badgesIntroNone =>
      'Ti aspettano distintivi a sorpresa! Leggi gli indizi per trovarli.';

  @override
  String get badgesIntroAll => 'Incredibile, hai trovato tutti i distintivi!';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bravo, hai già $count distintivi! Chi sarà il prossimo?',
      one: 'Bravo, hai già 1 distintivo! Chi sarà il prossimo?',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'Preferiti';

  @override
  String get badgeFirstPageName => 'Prima pagina';

  @override
  String get badgeFirstPageHint => 'Apri la tua primissima storia…';

  @override
  String get badgeFirstPageEarned => 'Hai aperto la tua prima storia!';

  @override
  String get badgeSmallFlameName => 'Piccola fiamma';

  @override
  String get badgeSmallFlameHint => 'Leggi 3 giorni di fila…';

  @override
  String get badgeSmallFlameEarned => 'Hai letto 3 giorni di fila!';

  @override
  String get badgeBigFlameName => 'Grande fiamma';

  @override
  String get badgeBigFlameHint => 'Leggi 7 giorni di fila…';

  @override
  String get badgeBigFlameEarned => 'Una settimana intera di lettura!';

  @override
  String get badgeBonfireName => 'Falò';

  @override
  String get badgeBonfireHint => 'Leggi 14 giorni di fila…';

  @override
  String get badgeBonfireEarned => 'Due settimane di lettura senza fermarti!';

  @override
  String get badgeFavoriteName => 'Colpo di fulmine';

  @override
  String get badgeFavoriteHint => 'Tieni una storia nei preferiti…';

  @override
  String get badgeFavoriteEarned => 'Hai trovato una storia che adori!';

  @override
  String get badgeStoryTreasureName => 'Tesoro di storie';

  @override
  String get badgeStoryTreasureHint => 'Tieni 5 storie nei preferiti…';

  @override
  String get badgeStoryTreasureEarned =>
      'Hai un vero tesoro di 5 storie preferite!';

  @override
  String get badgeCuriousEarName => 'Orecchio curioso';

  @override
  String get badgeCuriousEarHint => 'Ascolta una storia raccontata…';

  @override
  String get badgeCuriousEarEarned => 'Hai ascoltato la tua prima storia!';

  @override
  String get badgeExplorerName => 'Esploratore';

  @override
  String get badgeExplorerHint => 'Finisci storie di 3 temi diversi…';

  @override
  String get badgeExplorerEarned => 'Hai esplorato 3 temi diversi!';

  @override
  String get badgeGreatExplorerName => 'Grande esploratore';

  @override
  String get badgeGreatExplorerHint => 'Finisci storie di 6 temi diversi…';

  @override
  String get badgeGreatExplorerEarned => 'Hai viaggiato in 6 temi diversi!';

  @override
  String get badgeBedtimeTaleName => 'Storia della sera';

  @override
  String get badgeBedtimeTaleHint =>
      'Leggi una storia la sera, prima di dormire…';

  @override
  String get badgeBedtimeTaleEarned => 'Una storia prima di dormire!';

  @override
  String get badgeEarlyBirdName => 'Mattiniero';

  @override
  String get badgeEarlyBirdHint => 'Leggi una storia la mattina…';

  @override
  String get badgeEarlyBirdEarned =>
      'Una storia per iniziare bene la giornata!';

  @override
  String get badgeMagicWeekendName => 'Weekend incantato';

  @override
  String get badgeMagicWeekendHint =>
      'Leggi una storia il sabato o la domenica…';

  @override
  String get badgeMagicWeekendEarned => 'Anche nel weekend leggi storie!';

  @override
  String get badgeOnceMoreName => 'Ancora una volta';

  @override
  String get badgeOnceMoreHint => 'Rileggi una storia che hai già finito…';

  @override
  String get badgeOnceMoreEarned => 'Hai riletto una storia che ti piace!';

  @override
  String get badgeBigBookName => 'Grande libro';

  @override
  String get badgeBigBookHint => 'Finisci una delle storie più lunghe…';

  @override
  String get badgeBigBookEarned => 'Hai finito una storia lunghissima!';

  @override
  String get badgeMagicHourglassName => 'Clessidra magica';

  @override
  String get badgeMagicHourglassHint => 'Passa un\'ora a leggere storie…';

  @override
  String get badgeMagicHourglassEarned => 'Un\'ora intera con le tue storie!';

  @override
  String get badgeGrandClockName => 'Grande orologio';

  @override
  String get badgeGrandClockHint => 'Passa 5 ore a leggere storie…';

  @override
  String get badgeGrandClockEarned => 'Cinque ore di viaggio nelle storie!';

  @override
  String badgeCongrats(String text) {
    return 'Bravo! $text';
  }

  @override
  String get profileNotFound => 'Profilo non trovato.';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Bravo! Leggi da $days giorni di fila!',
      one: 'Si comincia! Torna domani per far crescere la tua fiamma.',
      zero: 'Leggi una storia per accendere la tua fiamma!',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'Area genitori';

  @override
  String get streakTileLabel => 'di lettura\ndi fila';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'storie\nfinite',
      one: 'storia\nfinita',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total sbloccate';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total ottenuti';
  }

  @override
  String get changeReader => 'Cambia lettore';

  @override
  String get parentsOnly => 'Solo per i grandi';

  @override
  String get parentalGateInstruction =>
      'Per continuare, tocca questi numeri in ordine:';

  @override
  String get parentalGateWrong => 'Non è giusto. Nuovo codice qui sopra.';

  @override
  String get digitZero => 'zero';

  @override
  String get digitOne => 'uno';

  @override
  String get digitTwo => 'due';

  @override
  String get digitThree => 'tre';

  @override
  String get digitFour => 'quattro';

  @override
  String get digitFive => 'cinque';

  @override
  String get digitSix => 'sei';

  @override
  String get digitSeven => 'sette';

  @override
  String get digitEight => 'otto';

  @override
  String get digitNine => 'nove';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get noSettingsFound => 'Nessuna impostazione trovata.';

  @override
  String get narrationVoice => 'Voce della narrazione';

  @override
  String get voiceFemale => 'Femminile';

  @override
  String get voiceMale => 'Maschile';

  @override
  String get accessibility => 'Accessibilità';

  @override
  String get dyslexiaMode => 'Modalità dislessia';

  @override
  String get dyslexiaHint => 'Adatta colori, spaziatura e dimensione';

  @override
  String get textDisplay => 'Visualizzazione del testo';

  @override
  String get textSize => 'Dimensione del testo';

  @override
  String get readingTheme => 'Tema di lettura';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get enterName => 'Inserisci un nome';

  @override
  String get enterValidAge => 'Inserisci un’età valida';

  @override
  String get profileUpdated => 'Profilo aggiornato!';

  @override
  String get deleteProfile => 'Elimina profilo';

  @override
  String deleteProfileConfirm(String name) {
    return 'Vuoi davvero eliminare il profilo di $name? L’azione è irreversibile.';
  }

  @override
  String get profileAndDataDeleted => 'Profilo e dati eliminati';

  @override
  String activeProfileNamed(String name) {
    return 'Profilo attivo: $name';
  }

  @override
  String get pleaseSignIn => 'Accedi, per favore.';

  @override
  String get manageProfiles => 'Gestisci profili';

  @override
  String get whoIsReadingToday => 'Chi legge oggi?';

  @override
  String get manageProfilesTooltip => 'Gestisci profili (genitori)';

  @override
  String get createProfile => 'Crea un profilo';

  @override
  String ageYears(int age) {
    return '$age anni';
  }

  @override
  String get mascotWhoReads => 'Ciao! Chi viene a leggere con me?';

  @override
  String get whoIsOurAdventurer => 'Chi è il nostro avventuriero?';

  @override
  String get theirName => 'Come si chiama?';

  @override
  String get nameHintExample => 'Es.: Leo, Nina…';

  @override
  String get theirAge => 'Quanti anni ha?';

  @override
  String get createProfileAndStart => 'Crea il profilo e inizia a leggere';

  @override
  String get reconnectNeeded => 'È necessario riconnettersi';

  @override
  String get reconnectExplain =>
      'Per sicurezza, l’eliminazione dell’account richiede un accesso recente. Verrai disconnesso: accedi di nuovo e torna qui per eliminare l’account.';

  @override
  String get deleteAccountQuestion => 'Eliminare l’account?';

  @override
  String get deleteAccountExplain =>
      'Tutti i profili, i progressi, le ricompense e le impostazioni saranno cancellati definitivamente. L’azione è irreversibile.\n\nSe hai un abbonamento, ricordati di disdirlo dall’App Store o da Google Play: eliminare l’account non lo interrompe.';

  @override
  String get deleteForever => 'Elimina definitivamente';

  @override
  String get readingTracking => 'Monitoraggio lettura';

  @override
  String readingTrackingOf(String name) {
    return 'Monitoraggio lettura di $name';
  }

  @override
  String get statStoriesRead => 'Storie\nlette';

  @override
  String get statReadingTime => 'Tempo di\nlettura';

  @override
  String get statStreak => 'Giorni\ndi fila';

  @override
  String queueFull(int max) {
    return 'La coda è piena: massimo $max storie';
  }

  @override
  String get addToQueue => 'Aggiungi alla coda di lettura';

  @override
  String get removeFromQueue => 'Togli dalla coda di lettura';

  @override
  String removeStoryFromQueue(String title) {
    return 'Togli $title dalla coda';
  }

  @override
  String get clearQueue => 'Svuota la coda';

  @override
  String get previousStory => 'Storia precedente';

  @override
  String get nextStory => 'Storia successiva';

  @override
  String get stopQueue => 'Ferma la coda';

  @override
  String get noPreviousStory => 'Nessuna storia precedente';

  @override
  String get noNextStory => 'Nessuna storia successiva';

  @override
  String get searchHint => 'Cerca una storia…';

  @override
  String get searchNotFound =>
      'Non ho trovato questa storia… Prova con un’altra parola!';

  @override
  String get youMightLike => 'Forse ti piacerà';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storie trovate',
      one: '1 storia trovata',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => 'Qualche idea?';

  @override
  String get forYou => 'Per te';

  @override
  String get stories => 'Storie';

  @override
  String get actionBlocked => 'Azione bloccata';

  @override
  String get feedbackRateLimit =>
      'Per evitare abusi, devi attendere 5 minuti tra un commento e l’altro.';

  @override
  String get sendFeedback => 'Invia un commento';

  @override
  String get yourOpinionMatters => 'La tua opinione ci interessa!';

  @override
  String get feedbackIntro =>
      'Un’idea, un bug o un suggerimento? Scrivici qui sotto.';

  @override
  String get feedbackHint => 'Scrivi il tuo messaggio qui…';

  @override
  String get feedbackEmpty => 'Il messaggio non può essere vuoto';

  @override
  String get feedbackTooShort =>
      'Il messaggio è un po’ troppo corto (minimo 10 caratteri)';

  @override
  String get feedbackThanks => 'Grazie! Il tuo commento è stato inviato.';

  @override
  String get feedbackError => 'Errore durante l’invio';

  @override
  String get googleSignInFailed => 'Accesso con Google non riuscito';

  @override
  String get appleSignInFailed => 'Accesso con Apple non riuscito';

  @override
  String get signUpFailed => 'Registrazione non riuscita';

  @override
  String get noAccountWithEmail => 'Nessun account con questa email';

  @override
  String get wrongPassword => 'Password errata';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String get emailRequired => 'Email obbligatoria';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordRequired => 'Password obbligatoria';

  @override
  String get passwordTooShort => 'Almeno 6 caratteri';

  @override
  String get signingIn => 'Accesso in corso…';

  @override
  String get signingUp => 'Registrazione in corso…';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get termsNotice =>
      'Continuando, accetti le nostre condizioni d’uso\ne la nostra informativa sulla privacy';

  @override
  String get cancel => 'Annulla';

  @override
  String get signOut => 'Esci';

  @override
  String get deleteMyAccount => 'Elimina il mio account';

  @override
  String get deleteError => 'Errore durante l’eliminazione';

  @override
  String get audioError => 'Errore audio';

  @override
  String get favoriteUpdateError => 'Impossibile aggiornare i preferiti';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '$count giorno',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int count) {
    return '$count sec';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String get onboardingTagline => 'Storie magiche\nper piccoli sognatori';

  @override
  String get sectionProfilesAndReading => 'Profili e lettura';

  @override
  String get sectionSupportAndInfo => 'Assistenza e informazioni';

  @override
  String get readingSettings => 'Impostazioni di lettura';

  @override
  String get termsOfService => 'Condizioni d’uso';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get chooseYourAvatar => 'Scegli il tuo avatar';

  @override
  String get signInError => 'Errore di accesso';

  @override
  String get notificationChannelName => 'Promemoria di lettura';

  @override
  String get notificationChannelDescription =>
      'Promemoria per finire la tua storia';

  @override
  String get notificationReminderBody =>
      'Non hai finito la tua storia! Vieni a scoprire come continua.';

  @override
  String get profileCreationFailed =>
      'Non è stato possibile creare il profilo. Riprova.';

  @override
  String get listen => 'Ascolta';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'Storia $position di $total';
  }

  @override
  String get readingPreviewSample =>
      'C’erano una volta, in una città della Persia, due fratelli di nome Kassim e Alì Babà.';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameLabel => 'Nome';

  @override
  String get ageLabel => 'Età';

  @override
  String get ageHintExample => 'Es.: 5';

  @override
  String get readThemeClassic => 'Classico';

  @override
  String get readThemeImmersive => 'Immersivo';

  @override
  String get readThemeManuscript => 'Manoscritto';

  @override
  String get back => 'Indietro';

  @override
  String get searchFieldHint => 'Titolo, animale, personaggio…';

  @override
  String get clear => 'Cancella';

  @override
  String get genericError => 'Si è verificato un errore. Riprova.';

  @override
  String get readingReminders => 'Promemoria di lettura';

  @override
  String get nightMode => 'Modalità notte';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get gotIt => 'Va bene';

  @override
  String get newBadge => 'Nuovo distintivo!';

  @override
  String get great => 'Fantastico!';

  @override
  String greetingHello(String name) {
    return 'Ciao $name!';
  }

  @override
  String get send => 'Invia';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get start => 'Inizia';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Riproduci';
}
