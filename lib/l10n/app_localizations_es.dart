// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dataLoadingError => 'No se han podido cargar los datos';

  @override
  String get userNotConnected => 'No has iniciado sesión.';

  @override
  String get preferences => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navTreasures => 'Mis tesoros';

  @override
  String get noProfileFound => 'No se ha encontrado ningún perfil';

  @override
  String get noProfileSelected => 'No hay ningún perfil seleccionado.';

  @override
  String get greetingEvening => '¿Un cuento antes de dormir?';

  @override
  String get greetingDay => '¿Qué cuento leemos hoy?';

  @override
  String get continueReading => 'Seguir leyendo';

  @override
  String get forYourAge => 'Para tu edad';

  @override
  String get newStories => 'Novedades';

  @override
  String percentDone(int percent) {
    return '$percent% completado';
  }

  @override
  String get filterAll => 'Todo';

  @override
  String get filterInProgress => 'Empezados';

  @override
  String get filterUnread => 'Sin leer';

  @override
  String get myFavorites => 'Mis favoritos';

  @override
  String get noFavoritesYet => 'Aún no hay favoritos';

  @override
  String get noFavoritesHint =>
      '¡Guarda tus cuentos favoritos y encuéntralos aquí al instante!';

  @override
  String get myMorals => 'Mis moralejas';

  @override
  String get wisdomCollected => 'Sabiduría acumulada';

  @override
  String moralsUnlockedCount(int unlocked, int total) {
    return '$unlocked / $total moralejas desbloqueadas';
  }

  @override
  String get noMoralForStory =>
      'No hay ninguna moraleja guardada para este cuento.';

  @override
  String get noMoralShort => 'No hay ninguna moraleja guardada.';

  @override
  String get moralLocked => 'Termina este cuento para desbloquear su moraleja.';

  @override
  String get close => 'Cerrar';

  @override
  String get myBadges => 'Mis insignias';

  @override
  String get badgesLoadError =>
      'Ahora mismo no se pueden cargar tus insignias.';

  @override
  String get surpriseBadge => 'Insignia sorpresa';

  @override
  String get badgesIntroNone =>
      '¡Te esperan insignias sorpresa! Lee las pistas para encontrarlas.';

  @override
  String get badgesIntroAll =>
      '¡Increíble, has encontrado todas las insignias!';

  @override
  String badgesIntroSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Bravo, ya tienes $count insignias! ¿Cuál será la siguiente?',
      one: '¡Bravo, ya tienes 1 insignia! ¿Cuál será la siguiente?',
    );
    return '$_temp0';
  }

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get badgeFirstPageName => 'Primera página';

  @override
  String get badgeFirstPageHint => 'Abre tu primer cuento…';

  @override
  String get badgeFirstPageEarned => '¡Has abierto tu primer cuento!';

  @override
  String get badgeSmallFlameName => 'Llama pequeña';

  @override
  String get badgeSmallFlameHint => 'Lee 3 días seguidos…';

  @override
  String get badgeSmallFlameEarned => '¡Has leído 3 días seguidos!';

  @override
  String get badgeBigFlameName => 'Llama grande';

  @override
  String get badgeBigFlameHint => 'Lee 7 días seguidos…';

  @override
  String get badgeBigFlameEarned => '¡Una semana entera de lectura!';

  @override
  String get badgeBonfireName => 'Hoguera';

  @override
  String get badgeBonfireHint => 'Lee 14 días seguidos…';

  @override
  String get badgeBonfireEarned => '¡Dos semanas leyendo sin parar!';

  @override
  String get badgeFavoriteName => 'Flechazo';

  @override
  String get badgeFavoriteHint => 'Guarda un cuento en tus favoritos…';

  @override
  String get badgeFavoriteEarned => '¡Has encontrado un cuento que te encanta!';

  @override
  String get badgeStoryTreasureName => 'Tesoro de cuentos';

  @override
  String get badgeStoryTreasureHint => 'Guarda 5 cuentos en tus favoritos…';

  @override
  String get badgeStoryTreasureEarned =>
      '¡Tienes un tesoro de 5 cuentos favoritos!';

  @override
  String get badgeCuriousEarName => 'Oreja curiosa';

  @override
  String get badgeCuriousEarHint => 'Escucha un cuento narrado…';

  @override
  String get badgeCuriousEarEarned => '¡Has escuchado tu primer cuento!';

  @override
  String get badgeExplorerName => 'Explorador';

  @override
  String get badgeExplorerHint => 'Termina cuentos de 3 temas diferentes…';

  @override
  String get badgeExplorerEarned => '¡Has explorado 3 temas diferentes!';

  @override
  String get badgeGreatExplorerName => 'Gran explorador';

  @override
  String get badgeGreatExplorerHint => 'Termina cuentos de 6 temas diferentes…';

  @override
  String get badgeGreatExplorerEarned => '¡Has viajado por 6 temas diferentes!';

  @override
  String get badgeBedtimeTaleName => 'Cuento de la noche';

  @override
  String get badgeBedtimeTaleHint =>
      'Lee un cuento por la noche, antes de dormir…';

  @override
  String get badgeBedtimeTaleEarned => '¡Un cuento antes de dormir!';

  @override
  String get badgeEarlyBirdName => 'Madrugador';

  @override
  String get badgeEarlyBirdHint => 'Lee un cuento por la mañana…';

  @override
  String get badgeEarlyBirdEarned => '¡Un cuento para empezar bien el día!';

  @override
  String get badgeMagicWeekendName => 'Fin de semana encantado';

  @override
  String get badgeMagicWeekendHint => 'Lee un cuento el sábado o el domingo…';

  @override
  String get badgeMagicWeekendEarned =>
      '¡Incluso el fin de semana lees cuentos!';

  @override
  String get badgeOnceMoreName => 'Otra vez';

  @override
  String get badgeOnceMoreHint => 'Vuelve a leer un cuento que ya terminaste…';

  @override
  String get badgeOnceMoreEarned => '¡Has releído un cuento que te gusta!';

  @override
  String get badgeBigBookName => 'Gran libro';

  @override
  String get badgeBigBookHint => 'Termina uno de los cuentos más largos…';

  @override
  String get badgeBigBookEarned => '¡Has terminado un cuento muy largo!';

  @override
  String get badgeMagicHourglassName => 'Reloj de arena mágico';

  @override
  String get badgeMagicHourglassHint => 'Pasa una hora leyendo cuentos…';

  @override
  String get badgeMagicHourglassEarned => '¡Una hora entera con tus cuentos!';

  @override
  String get badgeGrandClockName => 'Gran reloj';

  @override
  String get badgeGrandClockHint => 'Pasa 5 horas leyendo cuentos…';

  @override
  String get badgeGrandClockEarned => '¡Cinco horas de viaje por los cuentos!';

  @override
  String badgeCongrats(String text) {
    return '¡Bravo! $text';
  }

  @override
  String get profileNotFound => 'Perfil no encontrado.';

  @override
  String streakEncouragement(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '¡Bravo! ¡Llevas $days días seguidos leyendo!',
      one: '¡Ya empezaste! Vuelve mañana para que tu llama crezca.',
      zero: '¡Lee un cuento para encender tu llama!',
    );
    return '$_temp0';
  }

  @override
  String get parentSpace => 'Zona de padres';

  @override
  String get streakTileLabel => 'leyendo\nseguidos';

  @override
  String storiesFinishedTileLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cuentos\nterminados',
      one: 'cuento\nterminado',
    );
    return '$_temp0';
  }

  @override
  String moralsUnlockedSubtitle(int count, int total) {
    return '$count / $total desbloqueadas';
  }

  @override
  String badgesEarnedSubtitle(int count, int total) {
    return '$count / $total conseguidas';
  }

  @override
  String get changeReader => 'Cambiar de lector';

  @override
  String get parentsOnly => 'Solo para adultos';

  @override
  String get parentalGateInstruction =>
      'Para continuar, toca estos números en orden:';

  @override
  String get parentalGateWrong => 'No es correcto. Nuevo código arriba.';

  @override
  String get digitZero => 'cero';

  @override
  String get digitOne => 'uno';

  @override
  String get digitTwo => 'dos';

  @override
  String get digitThree => 'tres';

  @override
  String get digitFour => 'cuatro';

  @override
  String get digitFive => 'cinco';

  @override
  String get digitSix => 'seis';

  @override
  String get digitSeven => 'siete';

  @override
  String get digitEight => 'ocho';

  @override
  String get digitNine => 'nueve';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get noSettingsFound => 'No se han encontrado ajustes.';

  @override
  String get narrationVoice => 'Voz de la narración';

  @override
  String get voiceFemale => 'Femenina';

  @override
  String get voiceMale => 'Masculina';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get dyslexiaMode => 'Modo dislexia';

  @override
  String get dyslexiaHint => 'Ajusta los colores, el espaciado y el tamaño';

  @override
  String get textDisplay => 'Visualización del texto';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get readingTheme => 'Tema de lectura';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get enterName => 'Introduce un nombre';

  @override
  String get enterValidAge => 'Introduce una edad válida';

  @override
  String get profileUpdated => '¡Perfil actualizado!';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String deleteProfileConfirm(String name) {
    return '¿Seguro que quieres eliminar el perfil de $name? Esta acción no se puede deshacer.';
  }

  @override
  String get profileAndDataDeleted => 'Perfil y datos eliminados';

  @override
  String activeProfileNamed(String name) {
    return 'Perfil activo: $name';
  }

  @override
  String get pleaseSignIn => 'Inicia sesión, por favor.';

  @override
  String get manageProfiles => 'Gestionar perfiles';

  @override
  String get whoIsReadingToday => '¿Quién lee hoy?';

  @override
  String get manageProfilesTooltip => 'Gestionar perfiles (adultos)';

  @override
  String get createProfile => 'Crear un perfil';

  @override
  String ageYears(int age) {
    return '$age años';
  }

  @override
  String get mascotWhoReads => '¡Hola! ¿Quién viene a leer conmigo?';

  @override
  String get whoIsOurAdventurer => '¿Quién es nuestro aventurero?';

  @override
  String get theirName => '¿Su nombre?';

  @override
  String get nameHintExample => 'Ej.: Leo, Nina…';

  @override
  String get theirAge => '¿Su edad?';

  @override
  String get createProfileAndStart => 'Crear el perfil y empezar a leer';

  @override
  String get reconnectNeeded => 'Hay que volver a iniciar sesión';

  @override
  String get reconnectExplain =>
      'Por seguridad, eliminar la cuenta requiere un inicio de sesión reciente. Se cerrará tu sesión: vuelve a iniciar sesión y regresa aquí para eliminar la cuenta.';

  @override
  String get deleteAccountQuestion => '¿Eliminar la cuenta?';

  @override
  String get deleteAccountExplain =>
      'Se borrarán definitivamente todos los perfiles, el progreso, las recompensas y los ajustes. Esta acción no se puede deshacer.\n\nSi tienes una suscripción, recuerda cancelarla desde la App Store o Google Play: eliminar la cuenta no la cancela.';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get readingTracking => 'Seguimiento de lectura';

  @override
  String readingTrackingOf(String name) {
    return 'Seguimiento de lectura de $name';
  }

  @override
  String get statStoriesRead => 'Cuentos\nleídos';

  @override
  String get statReadingTime => 'Tiempo de\nlectura';

  @override
  String get statStreak => 'Días\nseguidos';

  @override
  String queueFull(int max) {
    return 'La cola está llena: máximo $max cuentos';
  }

  @override
  String get addToQueue => 'Añadir a la cola de lectura';

  @override
  String get removeFromQueue => 'Quitar de la cola de lectura';

  @override
  String removeStoryFromQueue(String title) {
    return 'Quitar $title de la cola';
  }

  @override
  String get clearQueue => 'Vaciar la cola';

  @override
  String get previousStory => 'Cuento anterior';

  @override
  String get nextStory => 'Cuento siguiente';

  @override
  String get stopQueue => 'Detener la cola';

  @override
  String get noPreviousStory => 'No hay cuento anterior';

  @override
  String get noNextStory => 'No hay cuento siguiente';

  @override
  String get searchHint => 'Buscar un cuento…';

  @override
  String get searchNotFound =>
      'No he encontrado ese cuento… ¡Prueba con otra palabra!';

  @override
  String get youMightLike => 'Quizá te guste';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentos encontrados',
      one: '1 cuento encontrado',
    );
    return '$_temp0';
  }

  @override
  String get anyIdeas => '¿Alguna idea?';

  @override
  String get forYou => 'Para ti';

  @override
  String get stories => 'Cuentos';

  @override
  String get actionBlocked => 'Acción bloqueada';

  @override
  String get feedbackRateLimit =>
      'Para evitar abusos, debes esperar 5 minutos entre comentarios.';

  @override
  String get sendFeedback => 'Enviar un comentario';

  @override
  String get yourOpinionMatters => '¡Tu opinión nos importa!';

  @override
  String get feedbackIntro =>
      '¿Una idea, un error o una sugerencia? Escríbenos abajo.';

  @override
  String get feedbackHint => 'Escribe tu mensaje aquí…';

  @override
  String get feedbackEmpty => 'El mensaje no puede estar vacío';

  @override
  String get feedbackTooShort =>
      'El mensaje es demasiado corto (mínimo 10 caracteres)';

  @override
  String get feedbackThanks => '¡Gracias! Tu comentario se ha enviado.';

  @override
  String get feedbackError => 'Error al enviar';

  @override
  String get googleSignInFailed => 'Error al iniciar sesión con Google';

  @override
  String get appleSignInFailed => 'Error al iniciar sesión con Apple';

  @override
  String get signUpFailed => 'Error al registrarse';

  @override
  String get noAccountWithEmail => 'No hay ninguna cuenta con este correo';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get invalidEmail => 'Correo no válido';

  @override
  String get emailRequired => 'Correo obligatorio';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get passwordRequired => 'Contraseña obligatoria';

  @override
  String get passwordTooShort => 'Mínimo 6 caracteres';

  @override
  String get signingIn => 'Iniciando sesión…';

  @override
  String get signingUp => 'Registrando…';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get termsNotice =>
      'Al continuar, aceptas nuestras condiciones de uso\ny nuestra política de privacidad';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get deleteError => 'Error al eliminar';

  @override
  String get audioError => 'Error de audio';

  @override
  String get favoriteUpdateError => 'No se han podido actualizar los favoritos';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int count) {
    return '$count s';
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
  String get onboardingTagline => 'Cuentos mágicos\npara pequeños soñadores';

  @override
  String get sectionProfilesAndReading => 'Perfiles y lectura';

  @override
  String get sectionSupportAndInfo => 'Ayuda e información';

  @override
  String get readingSettings => 'Ajustes de lectura';

  @override
  String get termsOfService => 'Condiciones de uso';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get chooseYourAvatar => 'Elige tu avatar';

  @override
  String get signInError => 'Error al iniciar sesión';

  @override
  String get notificationChannelName => 'Recordatorios de lectura';

  @override
  String get notificationChannelDescription =>
      'Recordatorios para terminar tu cuento';

  @override
  String get notificationReminderBody =>
      '¡No has terminado tu cuento! Ven a descubrir cómo sigue.';

  @override
  String get profileCreationFailed =>
      'No se ha podido crear el perfil. Inténtalo de nuevo.';

  @override
  String get listen => 'Escuchar';

  @override
  String storyPositionInQueue(int position, int total) {
    return 'Cuento $position de $total';
  }

  @override
  String get readingPreviewSample =>
      'Érase una vez, en una ciudad de Persia, dos hermanos llamados Kassim y Alí Babá.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get ageLabel => 'Edad';

  @override
  String get ageHintExample => 'Ej.: 5';

  @override
  String get readThemeClassic => 'Clásico';

  @override
  String get readThemeImmersive => 'Inmersivo';

  @override
  String get readThemeManuscript => 'Manuscrito';

  @override
  String get back => 'Atrás';

  @override
  String get searchFieldHint => 'Título, animal, personaje…';

  @override
  String get clear => 'Borrar';

  @override
  String get genericError => 'Ha ocurrido un error. Inténtalo de nuevo.';

  @override
  String get readingReminders => 'Recordatorios de lectura';

  @override
  String get nightMode => 'Modo noche';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get gotIt => 'De acuerdo';

  @override
  String get newBadge => '¡Nueva insignia!';

  @override
  String get great => '¡Genial!';

  @override
  String greetingHello(String name) {
    return '¡Hola $name!';
  }

  @override
  String get send => 'Enviar';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get start => 'Empezar';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Reproducir';
}
