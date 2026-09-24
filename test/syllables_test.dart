import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/pages/story/syllables.dart';

/// Syllabes séparées par ·, lettres muettes entre crochets, le reste entre <>.
String split(String word, String language) =>
    splitSyllables(word, language).join('·');

void expectSplits(String language, Map<String, String> cases) {
  for (final MapEntry(key: word, value: expected) in cases.entries) {
    expect(split(word, language), expected, reason: word);
  }
}

void main() {
  test('français', () {
    expectSplits('fr', {
      'papa': 'pa·pa',
      'chocolat': 'cho·co·la·[t]',
      'bus': 'bus',
      "l'Ours": "l'Ours",
      'Léon': 'Lé·on',
      'aéroport': 'a·é·ro·por·[t]',
      'poème': 'po·èm·[e]',
      'que': 'que',
      'longues': 'longu·[es]',
      'hiver': '[h]·i·ver',
      "d'hiver": "<d'>·[h]·i·ver",
      "aujourd'hui": "au·jourd'·[h]·ui",
      'chanter': 'chan·te·[r]',
      'rochers': 'ro·che·[rs]',
      'étaient': 'é·tai·[ent]',
      'décidèrent': 'dé·ci·dèr·[ent]',
      'mangent': 'mang·[ent]',
      'finissent': 'fi·niss·[ent]',
      'moment': 'mo·men·[t]',
      'printemps': 'prin·tem·[ps]',
      'loup': 'lou·[p]',
      'blanc': 'blan·[c]',
      'mangez': 'man·ge·[z]',
      'gentil': 'gen·ti·[l]',
      'mer': 'mer',
      'grand-mère': 'gran·[d]·<->·mèr·[e]',
      'crayons': 'cra·yon·[s]',
      'maillot': 'mail·lo·[t]',
      '«Bonjour!»': '<«>·Bon·jour·<!»>',
    });
  });

  test('anglais', () {
    expectSplits('en', {
      'time': 'tim·[e]',
      'the': 'the',
      'little': 'lit·tle',
      'people': 'peo·ple',
      'lived': 'lived',
      'wanted': 'wan·ted',
      'covered': 'co·vered',
      'snowflakes': 'snow·flakes',
      'horses': 'hor·ses',
      'kitchen': 'kit·chen',
      'singing': 'sing·ing',
      'strongly': 'strong·ly',
      'butterfly': 'but·ter·fly',
      'maybe': 'may·be',
      'played': 'played',
      'beyond': 'be·yond',
      'yellow': 'yel·low',
    });
  });

  test('allemand', () {
    expectSplits('de', {
      'Mutter': 'Mut·ter',
      'Fenster': 'Fens·ter',
      'Apfel': 'Ap·fel',
      'Zucker': 'Zu·cker',
      'Geschichte': 'Ge·schich·te',
      'beschlossen': 'be·schlos·sen',
      'eingestürzt': 'ein·ge·stürzt',
      'unzertrennlich': 'un·zer·trenn·lich',
      'verstehen': 'ver·ste·hen',
      'Buntstifte': 'Bunt·stif·te',
      'Briefträger': 'Brief·trä·ger',
      'wirklich': 'wirk·lich',
      'Feuer': 'Feu·er',
      'Leon': 'Le·on',
      'Familie': 'Fa·mi·lie',
    });
  });

  test('espagnol', () {
    expectSplits('es', {
      'había': '[h]·a·bí·a',
      'León': 'Le·ón',
      'río': 'rí·o',
      'poeta': 'po·e·ta',
      'bueno': 'bue·no',
      'guerrero': 'gue·rre·ro',
      'calle': 'ca·lle',
      'construir': 'cons·truir',
      'cayó': 'ca·yó',
      'muy': 'muy',
      'pingüino': 'pin·güi·no',
    });
  });

  test('italien', () {
    expectSplits('it', {
      'rossa': 'ros·sa',
      'finestra': 'fi·ne·stra',
      'Leone': 'Le·o·ne',
      'ho': '[h]·o',
      "dell'aereo": "dell'·a·e·re·o",
      "c'era": "c'e·ra",
      'famiglia': 'fa·mi·glia',
      'gnocchi': 'gnoc·chi',
      'acqua': 'ac·qua',
      'atlante': 'at·lan·te',
    });
  });

  test('langue sans règles : mot entier', () {
    expect(split('むかし', 'ja'), '<むかし>');
  });
}
