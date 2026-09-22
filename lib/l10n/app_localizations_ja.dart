// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get dataLoadingError => 'データを読み込めませんでした';

  @override
  String get userNotConnected => 'ログインしていません。';

  @override
  String get preferences => '設定';

  @override
  String get language => '言語';

  @override
  String get navHome => 'ホーム';

  @override
  String get navLibrary => 'としょかん';

  @override
  String get navTreasures => 'たからもの';

  @override
  String get noProfileFound => 'プロフィールが見つかりません';

  @override
  String get noProfileSelected => 'プロフィールが選ばれていません。';

  @override
  String get greetingEvening => 'ねるまえに おはなしを よむ？';

  @override
  String get greetingDay => 'きょうは どの おはなしを よむ？';

  @override
  String get continueReading => 'つづきを よむ';

  @override
  String get forYourAge => 'きみに ぴったり';

  @override
  String get newStories => 'あたらしい おはなし';

  @override
  String percentDone(int percent) {
    return '$percent% よんだ';
  }

  @override
  String get filterAll => 'ぜんぶ';

  @override
  String get filterInProgress => 'とちゅう';

  @override
  String get filterUnread => 'みよみ';

  @override
  String get myFavorites => 'おきにいり';

  @override
  String get noFavoritesYet => 'まだ おきにいりが ありません';

  @override
  String get noFavoritesHint => 'すきな おはなしを ほぞんすると ここで すぐに みつかります！';

  @override
  String get myMorals => 'おしえ';

  @override
  String get wisdomCollected => 'あつめた ちえ';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total ひらいた';
  }

  @override
  String get noMoralForStory => 'この おはなしには おしえが ありません。';

  @override
  String get noMoralShort => 'おしえが ありません。';

  @override
  String get moralLocked => 'この おはなしを さいごまで よむと おしえが ひらきます。';

  @override
  String get close => 'とじる';

  @override
  String get myBadges => 'バッジ';

  @override
  String get badgesLoadError => 'いま バッジを よみこめません。';

  @override
  String get surpriseBadge => 'ひみつの バッジ';

  @override
  String get badgesIntroNone => 'ひみつの バッジが まってるよ！ ヒントを よんで さがそう。';

  @override
  String get badgesIntroAll => 'すごい！ ぜんぶの バッジを みつけたよ！';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'バッジを $count個 あつめたよ！ つぎは どれかな？',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'おきにいり';

  @override
  String get badgeFirstPageName => 'はじめの ページ';

  @override
  String get badgeFirstPageHint => 'はじめての おはなしを ひらこう…';

  @override
  String get badgeFirstPageEarned => 'はじめての おはなしを ひらいたよ！';

  @override
  String get badgeSmallFlameName => 'ちいさな ほのお';

  @override
  String get badgeSmallFlameHint => '3日 つづけて よもう…';

  @override
  String get badgeSmallFlameEarned => '3日 つづけて よんだよ！';

  @override
  String get badgeBigFlameName => 'おおきな ほのお';

  @override
  String get badgeBigFlameHint => '7日 つづけて よもう…';

  @override
  String get badgeBigFlameEarned => '1週間 ずっと よんだよ！';

  @override
  String get badgeBonfireName => 'たきび';

  @override
  String get badgeBonfireHint => '14日 つづけて よもう…';

  @override
  String get badgeBonfireEarned => '2週間 やすまずに よんだよ！';

  @override
  String get badgeFavoriteName => 'だいすき';

  @override
  String get badgeFavoriteHint => 'おはなしを おきにいりに いれよう…';

  @override
  String get badgeFavoriteEarned => 'だいすきな おはなしを みつけたよ！';

  @override
  String get badgeStoryTreasureName => 'おはなしの たからばこ';

  @override
  String get badgeStoryTreasureHint => 'おはなしを 5つ おきにいりに いれよう…';

  @override
  String get badgeStoryTreasureEarned => 'だいすきな おはなしが 5つ あつまったよ！';

  @override
  String get badgeCuriousEarName => 'ふしぎな みみ';

  @override
  String get badgeCuriousEarHint => 'よみきかせを きいてみよう…';

  @override
  String get badgeCuriousEarEarned => 'はじめての よみきかせを きいたよ！';

  @override
  String get badgeExplorerName => 'たんけんか';

  @override
  String get badgeExplorerHint => 'ちがう テーマの おはなしを 3つ よみおえよう…';

  @override
  String get badgeExplorerEarned => '3つの テーマを たんけんしたよ！';

  @override
  String get badgeGreatExplorerName => 'だいたんけんか';

  @override
  String get badgeGreatExplorerHint => 'ちがう テーマの おはなしを 6つ よみおえよう…';

  @override
  String get badgeGreatExplorerEarned => '6つの テーマを たびしたよ！';

  @override
  String get badgeBedtimeTaleName => 'よるの おはなし';

  @override
  String get badgeBedtimeTaleHint => 'ねるまえに おはなしを よもう…';

  @override
  String get badgeBedtimeTaleEarned => 'ねるまえに おはなしを よんだよ！';

  @override
  String get badgeEarlyBirdName => 'はやおき';

  @override
  String get badgeEarlyBirdHint => 'あさに おはなしを よもう…';

  @override
  String get badgeEarlyBirdEarned => 'あさから おはなしを よんだよ！';

  @override
  String get badgeMagicWeekendName => 'たのしい しゅうまつ';

  @override
  String get badgeMagicWeekendHint => 'どようびか にちようびに よもう…';

  @override
  String get badgeMagicWeekendEarned => 'しゅうまつも おはなしを よんだよ！';

  @override
  String get badgeOnceMoreName => 'もう いちど';

  @override
  String get badgeOnceMoreHint => 'よみおえた おはなしを もういちど よもう…';

  @override
  String get badgeOnceMoreEarned => 'すきな おはなしを もういちど よんだよ！';

  @override
  String get badgeBigBookName => 'ぶあつい ほん';

  @override
  String get badgeBigBookHint => 'いちばん ながい おはなしを よみおえよう…';

  @override
  String get badgeBigBookEarned => 'とても ながい おはなしを よみおえたよ！';

  @override
  String get badgeMagicHourglassName => 'まほうの すなどけい';

  @override
  String get badgeMagicHourglassHint => '1時間 おはなしを よもう…';

  @override
  String get badgeMagicHourglassEarned => '1時間 ずっと おはなしを よんだよ！';

  @override
  String get badgeGrandClockName => 'おおきな とけい';

  @override
  String get badgeGrandClockHint => '5時間 おはなしを よもう…';

  @override
  String get badgeGrandClockEarned => '5時間 おはなしの たびを したよ！';

  @override
  String badgeCongrats(String text) {
    return 'すごい！ $text';
  }

  @override
  String get profileNotFound => 'プロフィールが見つかりません。';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日 つづけて よんでいるよ！',
      zero: 'おはなしを よんで ほのおを ともそう！',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'ほごしゃの ページ';

  @override
  String get streakTileLabel => 'れんぞく\nどくしょ';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'よみおえた\nおはなし',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total ひらいた';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total あつめた';
  }

  @override
  String get changeReader => 'よむひとを かえる';

  @override
  String get parentsOnly => 'おとなの かた へ';

  @override
  String get parentalGateInstruction => 'つづけるには、この すうじを じゅんばんに タップしてください：';

  @override
  String get parentalGateWrong => 'ちがいます。あたらしい コードが うえに あります。';

  @override
  String get digitZero => 'ゼロ';

  @override
  String get digitOne => 'いち';

  @override
  String get digitTwo => 'に';

  @override
  String get digitThree => 'さん';

  @override
  String get digitFour => 'よん';

  @override
  String get digitFive => 'ご';

  @override
  String get digitSix => 'ろく';

  @override
  String get digitSeven => 'なな';

  @override
  String get digitEight => 'はち';

  @override
  String get digitNine => 'きゅう';

  @override
  String get settingsTitle => 'せってい';

  @override
  String get noSettingsFound => 'せっていが みつかりません。';

  @override
  String get narrationVoice => 'よみきかせの こえ';

  @override
  String get voiceFemale => 'じょせい';

  @override
  String get voiceMale => 'だんせい';

  @override
  String get accessibility => 'アクセシビリティ';

  @override
  String get dyslexiaMode => 'ディスレクシア モード';

  @override
  String get dyslexiaHint => 'いろ・かんかく・おおきさを ちょうせいします';

  @override
  String get textDisplay => 'もじの ひょうじ';

  @override
  String get textSize => 'もじの おおきさ';

  @override
  String get readingTheme => 'よむ ときの デザイン';

  @override
  String get editProfile => 'プロフィールを へんしゅう';

  @override
  String get enterName => 'なまえを いれてください';

  @override
  String get enterValidAge => 'ただしい ねんれいを いれてください';

  @override
  String get profileUpdated => 'プロフィールを こうしんしました！';

  @override
  String get deleteProfile => 'プロフィールを さくじょ';

  @override
  String deleteProfileConfirm(String name) {
    return '$name の プロフィールを さくじょしますか？ もとに もどせません。';
  }

  @override
  String get profileAndDataDeleted => 'プロフィールと データを さくじょしました';

  @override
  String activeProfileNamed(String name) {
    return 'いまの プロフィール：$name';
  }

  @override
  String get pleaseSignIn => 'ログインしてください。';

  @override
  String get manageProfiles => 'プロフィールの かんり';

  @override
  String get whoIsReadingToday => 'きょうは だれが よむ？';

  @override
  String get manageProfilesTooltip => 'プロフィールの かんり（おとな）';

  @override
  String get createProfile => 'プロフィールを つくる';

  @override
  String ageYears(int age) {
    return '$age歳';
  }

  @override
  String get mascotWhoReads => 'こんにちは！ だれが いっしょに よむ？';

  @override
  String get whoIsOurAdventurer => 'ぼうけんするのは だれ？';

  @override
  String get theirName => 'なまえは？';

  @override
  String get nameHintExample => 'れい：レオ、ニナ…';

  @override
  String get theirAge => 'なんさい？';

  @override
  String get createProfileAndStart => 'プロフィールを つくって よみはじめる';

  @override
  String get reconnectNeeded => 'ログインし なおしてください';

  @override
  String get reconnectExplain =>
      'セキュリティのため、アカウントの さくじょには さいきんの ログインが ひつようです。いちど ログアウトします。ログインし なおしてから、ここに もどって さくじょしてください。';

  @override
  String get deleteAccountQuestion => 'アカウントを さくじょしますか？';

  @override
  String get deleteAccountExplain =>
      'すべての プロフィール、しんちょく、ごほうび、せっていが かんぜんに けされます。もとに もどせません。\n\nていきこうどくが ある ばあいは、App Store または Google Play で かいやくしてください。アカウントを けしても ていきこうどくは とまりません。';

  @override
  String get deleteForever => 'かんぜんに さくじょ';

  @override
  String get readingTracking => 'どくしょの きろく';

  @override
  String readingTrackingOf(String name) {
    return '$name の どくしょの きろく';
  }

  @override
  String get statStoriesRead => 'よんだ\nおはなし';

  @override
  String get statReadingTime => 'よんだ\n時間';

  @override
  String get statStreak => 'れんぞく\nにっすう';

  @override
  String queueFull(int max) {
    return 'まちリストが いっぱいです（さいだい $max件）';
  }

  @override
  String get addToQueue => 'まちリストに いれる';

  @override
  String get removeFromQueue => 'まちリストから はずす';

  @override
  String removeStoryFromQueue(String title) {
    return '$title を まちリストから はずす';
  }

  @override
  String get clearQueue => 'まちリストを からにする';

  @override
  String get previousStory => 'まえの おはなし';

  @override
  String get nextStory => 'つぎの おはなし';

  @override
  String get stopQueue => 'まちリストを とめる';

  @override
  String get noPreviousStory => 'まえの おはなしは ありません';

  @override
  String get noNextStory => 'つぎの おはなしは ありません';

  @override
  String get searchHint => 'おはなしを さがす…';

  @override
  String get searchNotFound => 'その おはなしは みつかりませんでした… ちがう ことばで さがしてみて！';

  @override
  String get youMightLike => 'すきかも しれない おはなし';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'おはなしが $count件 みつかりました',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => 'なにか さがす？';

  @override
  String get forYou => 'きみに おすすめ';

  @override
  String get stories => 'おはなし';

  @override
  String get actionBlocked => 'そうさが ブロックされました';

  @override
  String get feedbackRateLimit => 'あくようを ふせぐため、コメントの あいだに 5分 おまちください。';

  @override
  String get sendFeedback => 'コメントを おくる';

  @override
  String get yourOpinionMatters => 'ごいけんを おきかせください！';

  @override
  String get feedbackIntro => 'アイデア、ふぐあい、ごていあんなど、したに おかきください。';

  @override
  String get feedbackHint => 'メッセージを ここに かいてください…';

  @override
  String get feedbackEmpty => 'メッセージを にゅうりょくしてください';

  @override
  String get feedbackTooShort => 'メッセージが みじかすぎます（10もじ いじょう）';

  @override
  String get feedbackThanks => 'ありがとうございます！ コメントを そうしんしました。';

  @override
  String get feedbackError => 'そうしんに しっぱいしました';

  @override
  String get googleSignInFailed => 'Google での ログインに しっぱいしました';

  @override
  String get appleSignInFailed => 'Apple での ログインに しっぱいしました';

  @override
  String get signUpFailed => 'とうろくに しっぱいしました';

  @override
  String get noAccountWithEmail => 'この メールアドレスの アカウントは ありません';

  @override
  String get wrongPassword => 'パスワードが ちがいます';

  @override
  String get invalidEmail => 'メールアドレスが ただしく ありません';

  @override
  String get emailRequired => 'メールアドレスを にゅうりょくしてください';

  @override
  String get passwordHint => 'パスワード';

  @override
  String get passwordRequired => 'パスワードを にゅうりょくしてください';

  @override
  String get passwordTooShort => '6もじ いじょう';

  @override
  String get signingIn => 'ログインしています…';

  @override
  String get signingUp => 'とうろくしています…';

  @override
  String get continueWithGoogle => 'Google で つづける';

  @override
  String get continueWithApple => 'Apple で つづける';

  @override
  String get termsNotice => 'つづけると、りようきやくと プライバシーポリシーに\nどういしたことに なります';

  @override
  String get cancel => 'キャンセル';

  @override
  String get signOut => 'ログアウト';

  @override
  String get deleteMyAccount => 'アカウントを さくじょ';

  @override
  String get deleteError => 'さくじょに しっぱいしました';

  @override
  String get audioError => 'おとの エラー';

  @override
  String get favoriteUpdateError => 'おきにいりを こうしんできませんでした';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int count) {
    return '$count秒';
  }

  @override
  String durationMinutes(int count) {
    return '$count分';
  }

  @override
  String durationHours(int hours) {
    return '$hours時間';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get onboardingTagline => 'ちいさな ゆめみるこへ\nまほうの おはなし';

  @override
  String get sectionProfilesAndReading => 'プロフィールと どくしょ';

  @override
  String get sectionSupportAndInfo => 'サポートと おしらせ';

  @override
  String get readingSettings => 'どくしょの せってい';

  @override
  String get termsOfService => 'りようきやく';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get chooseYourAvatar => 'アバターを えらぼう';

  @override
  String get signInError => 'ログインに しっぱいしました';

  @override
  String get notificationChannelName => 'どくしょの おしらせ';

  @override
  String get notificationChannelDescription => 'おはなしを さいごまで よむ おしらせ';

  @override
  String get notificationReminderBody => 'おはなしが とちゅうだよ！ つづきを よみに きてね。';

  @override
  String get profileCreationFailed => 'プロフィールを つくれませんでした。もういちど おためしください。';

  @override
  String get listen => 'きく';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'おはなし $position / $total';
  }

  @override
  String get readingPreviewSample =>
      'むかし むかし、ペルシャの まちに カシムと アリババという ふたりの きょうだいが いました。';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get nameLabel => 'なまえ';

  @override
  String get ageLabel => 'ねんれい';

  @override
  String get ageHintExample => 'れい：5';

  @override
  String get readThemeClassic => 'クラシック';

  @override
  String get readThemeImmersive => 'ぼっとう';

  @override
  String get readThemeManuscript => 'てがき';

  @override
  String get back => 'もどる';

  @override
  String get searchFieldHint => 'タイトル、どうぶつ、とうじょうじんぶつ…';

  @override
  String get clear => 'けす';

  @override
  String get genericError => 'エラーが はっせいしました。もういちど おためしください。';

  @override
  String get readingReminders => 'どくしょの おしらせ';

  @override
  String get nightMode => 'ナイトモード';

  @override
  String get signIn => 'ログイン';

  @override
  String get signUp => 'とうろく';

  @override
  String get gotIt => 'わかりました';

  @override
  String get newBadge => 'あたらしい バッジ！';

  @override
  String get great => 'やったね！';

  @override
  String greetingHello(String name) {
    return 'こんにちは、$name！';
  }

  @override
  String get send => 'おくる';

  @override
  String get avatar => 'アバター';

  @override
  String get save => 'ほぞん';

  @override
  String get delete => 'さくじょ';

  @override
  String get start => 'はじめる';

  @override
  String get pause => 'いちじ ていし';

  @override
  String get play => 'さいせい';
}
