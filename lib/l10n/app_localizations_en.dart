// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dataLoadingError => 'Couldn\'t load the data';

  @override
  String get userNotConnected => 'You are not signed in.';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navTreasures => 'My treasures';

  @override
  String get noProfileFound => 'No profile found';

  @override
  String get noProfileSelected => 'No profile selected.';

  @override
  String get greetingEvening => 'A bedtime story?';

  @override
  String get greetingDay => 'Which story shall we read today?';

  @override
  String get continueReading => 'Keep reading';

  @override
  String get forYourAge => 'Just right for you';

  @override
  String get newStories => 'New stories';

  @override
  String percentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterUnread => 'Not read';

  @override
  String get myFavorites => 'My favorites';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get noFavoritesHint =>
      'Save the stories you love and find them here in a tap!';

  @override
  String get myMorals => 'My lessons';

  @override
  String get wisdomCollected => 'Wisdom collected';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total lessons unlocked';
  }

  @override
  String get noMoralForStory => 'No lesson saved for this story.';

  @override
  String get noMoralShort => 'No lesson saved.';

  @override
  String get moralLocked => 'Finish this story to unlock its lesson.';

  @override
  String get close => 'Close';

  @override
  String get myBadges => 'My badges';

  @override
  String get badgesLoadError => 'Can\'t load your badges right now.';

  @override
  String get surpriseBadge => 'Surprise badge';

  @override
  String get badgesIntroNone =>
      'Surprise badges are waiting for you! Read the clues to find them.';

  @override
  String get badgesIntroAll => 'Amazing, you\'ve found every badge!';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Well done, you already have $count badges! Who is next?',
      one: 'Well done, you already have 1 badge! Who is next?',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get badgeFirstPageName => 'First page';

  @override
  String get badgeFirstPageHint => 'Open your very first story…';

  @override
  String get badgeFirstPageEarned => 'You opened your first story!';

  @override
  String get badgeSmallFlameName => 'Little flame';

  @override
  String get badgeSmallFlameHint => 'Read 3 days in a row…';

  @override
  String get badgeSmallFlameEarned => 'You read 3 days in a row!';

  @override
  String get badgeBigFlameName => 'Big flame';

  @override
  String get badgeBigFlameHint => 'Read 7 days in a row…';

  @override
  String get badgeBigFlameEarned => 'A whole week of reading!';

  @override
  String get badgeBonfireName => 'Bonfire';

  @override
  String get badgeBonfireHint => 'Read 14 days in a row…';

  @override
  String get badgeBonfireEarned => 'Two weeks of reading without stopping!';

  @override
  String get badgeFavoriteName => 'Favorite pick';

  @override
  String get badgeFavoriteHint => 'Keep a story in your favorites…';

  @override
  String get badgeFavoriteEarned => 'You found a story you love!';

  @override
  String get badgeStoryTreasureName => 'Story treasure';

  @override
  String get badgeStoryTreasureHint => 'Keep 5 stories in your favorites…';

  @override
  String get badgeStoryTreasureEarned =>
      'You have a real treasure of 5 favorite stories!';

  @override
  String get badgeCuriousEarName => 'Curious ear';

  @override
  String get badgeCuriousEarHint => 'Listen to a story being told…';

  @override
  String get badgeCuriousEarEarned => 'You listened to your first story!';

  @override
  String get badgeExplorerName => 'Explorer';

  @override
  String get badgeExplorerHint => 'Finish stories from 3 different themes…';

  @override
  String get badgeExplorerEarned => 'You explored 3 different themes!';

  @override
  String get badgeGreatExplorerName => 'Great explorer';

  @override
  String get badgeGreatExplorerHint =>
      'Finish stories from 6 different themes…';

  @override
  String get badgeGreatExplorerEarned =>
      'You travelled through 6 different themes!';

  @override
  String get badgeBedtimeTaleName => 'Bedtime tale';

  @override
  String get badgeBedtimeTaleHint =>
      'Read a story in the evening, before sleep…';

  @override
  String get badgeBedtimeTaleEarned => 'A story before bedtime!';

  @override
  String get badgeEarlyBirdName => 'Early bird';

  @override
  String get badgeEarlyBirdHint => 'Read a story in the morning…';

  @override
  String get badgeEarlyBirdEarned => 'A story to start the day right!';

  @override
  String get badgeMagicWeekendName => 'Magic weekend';

  @override
  String get badgeMagicWeekendHint => 'Read a story on Saturday or Sunday…';

  @override
  String get badgeMagicWeekendEarned =>
      'Even at the weekend, you read stories!';

  @override
  String get badgeOnceMoreName => 'Once more';

  @override
  String get badgeOnceMoreHint => 'Read again a story you already finished…';

  @override
  String get badgeOnceMoreEarned => 'You read again a story you love!';

  @override
  String get badgeBigBookName => 'Big book';

  @override
  String get badgeBigBookHint => 'Finish one of the longest stories…';

  @override
  String get badgeBigBookEarned => 'You finished a very long story!';

  @override
  String get badgeMagicHourglassName => 'Magic hourglass';

  @override
  String get badgeMagicHourglassHint => 'Spend an hour reading stories…';

  @override
  String get badgeMagicHourglassEarned => 'A whole hour with your stories!';

  @override
  String get badgeGrandClockName => 'Grand clock';

  @override
  String get badgeGrandClockHint => 'Spend 5 hours reading stories…';

  @override
  String get badgeGrandClockEarned => 'Five hours travelling through stories!';

  @override
  String badgeCongrats(String text) {
    return 'Well done! $text';
  }

  @override
  String get profileNotFound => 'Profile not found.';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Well done! You have been reading $days days in a row!',
      one: 'You are off! Come back tomorrow to grow your flame.',
      zero: 'Read a story to light your flame!',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'Parents area';

  @override
  String get streakTileLabel => 'reading\nin a row';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'stories\nfinished',
      one: 'story\nfinished',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total unlocked';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total earned';
  }

  @override
  String get changeReader => 'Switch reader';

  @override
  String get parentsOnly => 'Grown-ups only';

  @override
  String get parentalGateInstruction =>
      'To continue, tap these numbers in order:';

  @override
  String get parentalGateWrong => 'That is not it. New code above.';

  @override
  String get digitZero => 'zero';

  @override
  String get digitOne => 'one';

  @override
  String get digitTwo => 'two';

  @override
  String get digitThree => 'three';

  @override
  String get digitFour => 'four';

  @override
  String get digitFive => 'five';

  @override
  String get digitSix => 'six';

  @override
  String get digitSeven => 'seven';

  @override
  String get digitEight => 'eight';

  @override
  String get digitNine => 'nine';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get noSettingsFound => 'No settings found.';

  @override
  String get narrationVoice => 'Narration voice';

  @override
  String get voiceFemale => 'Female';

  @override
  String get voiceMale => 'Male';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get dyslexiaMode => 'Dyslexia mode';

  @override
  String get dyslexiaHint => 'Adjusts colours, spacing and size';

  @override
  String get textDisplay => 'Text display';

  @override
  String get textSize => 'Text size';

  @override
  String get readingTheme => 'Reading theme';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterValidAge => 'Enter a valid age';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String deleteProfileConfirm(String name) {
    return 'Do you really want to delete $name’s profile? This cannot be undone.';
  }

  @override
  String get profileAndDataDeleted => 'Profile and data deleted';

  @override
  String activeProfileNamed(String name) {
    return 'Active profile: $name';
  }

  @override
  String get pleaseSignIn => 'Please sign in.';

  @override
  String get manageProfiles => 'Manage profiles';

  @override
  String get whoIsReadingToday => 'Who is reading today?';

  @override
  String get manageProfilesTooltip => 'Manage profiles (grown-ups)';

  @override
  String get createProfile => 'Create a profile';

  @override
  String ageYears(int age) {
    return '$age years old';
  }

  @override
  String get mascotWhoReads => 'Hello! Who is coming to read with me?';

  @override
  String get whoIsOurAdventurer => 'Who is our adventurer?';

  @override
  String get theirName => 'Their name?';

  @override
  String get nameHintExample => 'e.g. Leo, Nina…';

  @override
  String get theirAge => 'Their age?';

  @override
  String get createProfileAndStart => 'Create the profile and start reading';

  @override
  String get reconnectNeeded => 'Sign in again';

  @override
  String get reconnectExplain =>
      'For security, deleting the account requires a recent sign-in. You will be signed out: sign in again, then come back here to delete the account.';

  @override
  String get deleteAccountQuestion => 'Delete the account?';

  @override
  String get deleteAccountExplain =>
      'All profiles, progress, rewards and settings will be permanently erased. This cannot be undone.\n\nIf you have a subscription, remember to cancel it from the App Store or Google Play: deleting the account does not stop it.';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get readingTracking => 'Reading activity';

  @override
  String readingTrackingOf(String name) {
    return '$name’s reading activity';
  }

  @override
  String get statStoriesRead => 'Stories\nread';

  @override
  String get statReadingTime => 'Reading\ntime';

  @override
  String get statStreak => 'Days in\na row';

  @override
  String queueFull(int max) {
    return 'The queue is full: $max stories maximum';
  }

  @override
  String get addToQueue => 'Add to the reading queue';

  @override
  String get removeFromQueue => 'Remove from the reading queue';

  @override
  String removeStoryFromQueue(String title) {
    return 'Remove $title from the queue';
  }

  @override
  String get clearQueue => 'Clear the queue';

  @override
  String get previousStory => 'Previous story';

  @override
  String get nextStory => 'Next story';

  @override
  String get stopQueue => 'Stop the queue';

  @override
  String get noPreviousStory => 'No previous story';

  @override
  String get noNextStory => 'No next story';

  @override
  String get searchHint => 'Search for a story…';

  @override
  String get searchNotFound => 'I could not find that story… Try another word!';

  @override
  String get youMightLike => 'You might like';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories found',
      one: '1 story found',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => 'Any ideas?';

  @override
  String get forYou => 'For you';

  @override
  String get stories => 'Stories';

  @override
  String get actionBlocked => 'Action blocked';

  @override
  String get feedbackRateLimit =>
      'To prevent abuse, you must wait 5 minutes between comments.';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get yourOpinionMatters => 'We would love your feedback!';

  @override
  String get feedbackIntro =>
      'An idea, a bug or a suggestion? Write to us below.';

  @override
  String get feedbackHint => 'Write your message here…';

  @override
  String get feedbackEmpty => 'The message cannot be empty';

  @override
  String get feedbackTooShort =>
      'The message is a little too short (10 characters min)';

  @override
  String get feedbackThanks => 'Thank you! Your feedback has been sent.';

  @override
  String get feedbackError => 'Could not send your message';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get appleSignInFailed => 'Apple sign-in failed';

  @override
  String get signUpFailed => 'Sign-up failed';

  @override
  String get noAccountWithEmail => 'No account with this email';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get emailRequired => 'Email required';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordRequired => 'Password required';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get signingUp => 'Signing up…';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get termsNotice =>
      'By continuing, you accept our terms of use\nand our privacy policy';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get deleteError => 'Could not delete';

  @override
  String get audioError => 'Audio error';

  @override
  String get favoriteUpdateError => 'Could not update favorites';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
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
  String get onboardingTagline => 'Magical stories\nfor little dreamers';

  @override
  String get sectionProfilesAndReading => 'Profiles and reading';

  @override
  String get sectionSupportAndInfo => 'Help and information';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get termsOfService => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get chooseYourAvatar => 'Choose your avatar';

  @override
  String get signInError => 'Sign-in error';

  @override
  String get notificationChannelName => 'Reading reminders';

  @override
  String get notificationChannelDescription => 'Reminders to finish your story';

  @override
  String get notificationReminderBody =>
      'You have not finished your story! Come and find out what happens next.';

  @override
  String get profileCreationFailed =>
      'The profile could not be created. Please try again.';

  @override
  String get listen => 'Listen';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'Story $position of $total';
  }

  @override
  String get readingPreviewSample =>
      'Once upon a time, in a city of Persia, there lived two brothers named Kassim and Ali Baba.';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameLabel => 'Name';

  @override
  String get ageLabel => 'Age';

  @override
  String get ageHintExample => 'e.g. 5';

  @override
  String get readThemeClassic => 'Classic';

  @override
  String get readThemeImmersive => 'Immersive';

  @override
  String get readThemeManuscript => 'Manuscript';

  @override
  String get back => 'Back';

  @override
  String get searchFieldHint => 'Title, animal, character…';

  @override
  String get clear => 'Clear';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get readingReminders => 'Reading reminders';

  @override
  String get nightMode => 'Night mode';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get gotIt => 'Got it';

  @override
  String get newBadge => 'New badge!';

  @override
  String get great => 'Great!';

  @override
  String greetingHello(String name) {
    return 'Hello $name!';
  }

  @override
  String get send => 'Send';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';
}
