import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => AppLanguage.current.value = AppLanguage.defaultCode);

  test('retient la langue choisie pour la prochaine ouverture', () async {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.select('de');

    // La valeur écrite doit survivre à un redémarrage
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'de');

    AppLanguage.current.value = AppLanguage.defaultCode;
    await AppLanguage.restore();
    expect(AppLanguage.current.value, 'de');
  });

  test(
      "l'écran de choix du profil suit la langue du téléphone à la première "
      'ouverture', () async {
    // Aucun choix mémorisé : cet écran arrive avant tout profil, donc avant
    // tout réglage de profil
    SharedPreferences.setMockInitialValues({});
    await AppLanguage.restore();

    final device = AppLanguage.sanitize(
        TestWidgetsFlutterBinding.instance.platformDispatcher.locale
            .languageCode);
    expect(AppLanguage.current.value, device);
  });

  test('une langue mémorisée qui n\'existe plus est ignorée', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'pt'});
    await AppLanguage.restore();

    // Repli : choix mémorisé -> langue du téléphone -> français
    expect(AppLanguage.codes.contains('pt'), isFalse);
    expect(AppLanguage.codes, contains(AppLanguage.current.value));
  });

  test('une langue du téléphone que l\'app ne propose pas donne le français',
      () {
    expect(AppLanguage.sanitize('pt'), AppLanguage.defaultCode);
    expect(AppLanguage.sanitize('zh'), AppLanguage.defaultCode);
  });
}
