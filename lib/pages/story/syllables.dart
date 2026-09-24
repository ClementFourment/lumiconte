/// Découpage d'un mot en syllabes écrites et repérage des lettres muettes, pour
/// le mode dyslexie. Règles scolaires simples, propres à chaque langue.
library;

/// Langues dont on sait découper les syllabes.
const Set<String> syllableLanguages = {'fr', 'en', 'es', 'it', 'de'};

enum SyllableKind {
  /// Syllabe prononcée, colorée en alternance.
  syllable,

  /// Lettres qui ne se prononcent pas.
  silent,

  /// Ponctuation, tirets et élisions, dans la couleur du texte.
  plain,
}

class SyllablePiece {
  const SyllablePiece(this.text, this.kind);

  final String text;
  final SyllableKind kind;

  @override
  bool operator ==(Object other) =>
      other is SyllablePiece && other.text == text && other.kind == kind;

  @override
  int get hashCode => Object.hash(text, kind);

  @override
  String toString() => switch (kind) {
        SyllableKind.syllable => text,
        SyllableKind.silent => '[$text]',
        SyllableKind.plain => '<$text>',
      };
}

final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _leadingNonLetters = RegExp(r'^[^\p{L}]+', unicode: true);
final RegExp _trailingNonLetters = RegExp(r'[^\p{L}]+$', unicode: true);

/// Morceaux d'un mot : élision avec son apostrophe (l', dell'), tiret, reste.
final RegExp _chunk = RegExp(r"[^'’\-]*['’]|[^'’\-]+|-");
final RegExp _elision = RegExp(r"['’]$");

/// Découpe [word] (ponctuation comprise) selon les règles de [language].
List<SyllablePiece> splitSyllables(String word, String language) {
  final rules = _rules[language];
  if (rules == null) return [SyllablePiece(word, SyllableKind.plain)];

  final prefix = _leadingNonLetters.firstMatch(word)?.group(0) ?? '';
  final rest = word.substring(prefix.length);
  final suffix = _trailingNonLetters.firstMatch(rest)?.group(0) ?? '';
  final core = rest.substring(0, rest.length - suffix.length);

  final pieces = <SyllablePiece>[
    if (prefix.isNotEmpty) SyllablePiece(prefix, SyllableKind.plain),
  ];

  // Un morceau sans voyelle (l', d', qu') se colle à la syllabe suivante
  var pending = '';
  for (final match in _chunk.allMatches(core)) {
    final chunk = match.group(0)!;
    if (chunk == '-') {
      if (pending.isNotEmpty) {
        pieces.add(SyllablePiece(pending, SyllableKind.plain));
        pending = '';
      }
      pieces.add(const SyllablePiece('-', SyllableKind.plain));
      continue;
    }

    final elided = _elision.hasMatch(chunk);
    final chunkPieces = _splitChunk(chunk, rules, wordEnd: !elided);
    final first = chunkPieces.indexWhere((p) => p.kind != SyllableKind.plain);
    if (first < 0 && elided) {
      pending += chunk;
      continue;
    }
    if (pending.isNotEmpty) {
      if (first >= 0 && chunkPieces[first].kind == SyllableKind.syllable) {
        chunkPieces[first] = SyllablePiece(
            pending + chunkPieces[first].text, SyllableKind.syllable);
      } else {
        // « l'homme » : le h muet reste estompé derrière l'élision
        chunkPieces.insert(0, SyllablePiece(pending, SyllableKind.plain));
      }
      pending = '';
    }
    pieces.addAll(chunkPieces);
  }
  if (pending.isNotEmpty) {
    pieces.add(SyllablePiece(pending, SyllableKind.plain));
  }
  if (suffix.isNotEmpty) pieces.add(SyllablePiece(suffix, SyllableKind.plain));
  return pieces;
}

List<SyllablePiece> _splitChunk(
  String chunk,
  _LanguageRules rules, {
  required bool wordEnd,
}) {
  if (chunk.isEmpty) return [];
  if (!_letter.hasMatch(chunk)) {
    return [SyllablePiece(chunk, SyllableKind.plain)];
  }

  final lower = chunk.toLowerCase();
  // Le h initial ne se prononce pas (homme, hola, ho)
  final start = rules.silentH &&
          lower.length >= 2 &&
          lower.startsWith('h') &&
          rules.vowels.contains(lower[1])
      ? 1
      : 0;
  var end = chunk.length;
  if (wordEnd && rules.silentEnd != null) {
    end -= rules.silentEnd!(lower);
  }

  var syllables = _syllabify(chunk.substring(start, end), rules);
  if (syllables.isEmpty && end < chunk.length) {
    // Il ne resterait aucune voyelle : la fin se prononce (que, the)
    end = chunk.length;
    syllables = _syllabify(chunk.substring(start), rules);
  }
  if (syllables.isEmpty) return [SyllablePiece(chunk, SyllableKind.plain)];

  return [
    if (start > 0)
      SyllablePiece(chunk.substring(0, start), SyllableKind.silent),
    for (final s in syllables) SyllablePiece(s, SyllableKind.syllable),
    if (end < chunk.length)
      SyllablePiece(chunk.substring(end), SyllableKind.silent),
  ];
}

class _Grapheme {
  const _Grapheme(this.start, this.end, this.text, {required this.vowel});

  final int start;
  final int end;
  final String text;
  final bool vowel;
}

/// Découpe les lettres de [text] en syllabes ; vide s'il n'y a pas de voyelle.
List<String> _syllabify(String text, _LanguageRules rules) {
  if (text.isEmpty) return const [];
  final lower = text.toLowerCase();
  if (lower.length != text.length) return [text];

  final muted = rules.mutedVowels?.call(lower).toSet() ?? const <int>{};

  // 1. Graphèmes : groupes de consonnes inséparables, voyelles, consonnes
  final graphemes = <_Grapheme>[];
  var i = 0;
  while (i < lower.length) {
    final unit = rules.consonantUnits
        .where((u) => u.matchesAt(lower, i))
        .firstOrNull
        ?.letters;
    if (unit != null) {
      graphemes.add(_Grapheme(i, i + unit.length, unit, vowel: false));
      i += unit.length;
      continue;
    }
    final c = lower[i];
    var vowel = rules.vowels.contains(c) && !muted.contains(i);
    // y devant une voyelle se lit comme une consonne (crayon, mayo, yellow)
    if (c == 'y' &&
        i + 1 < lower.length &&
        rules.vowels.contains(lower[i + 1]) &&
        !muted.contains(i + 1) &&
        switch (rules.consonantY) {
          _ConsonantY.never => false,
          _ConsonantY.beforeVowel => true,
          _ConsonantY.syllableStart =>
            i == 0 || !rules.vowels.contains(lower[i - 1]),
        }) {
      vowel = false;
    }
    graphemes.add(_Grapheme(i, i + 1, c, vowel: vowel));
    i++;
  }

  // 2. Noyaux : voyelles consécutives, sauf hiatus
  final nuclei = <(int, int)>[]; // indices de graphèmes [début, fin)
  for (var g = 0; g < graphemes.length; g++) {
    if (!graphemes[g].vowel) continue;
    if (nuclei.isNotEmpty && nuclei.last.$2 == g) {
      final run =
          graphemes.sublist(nuclei.last.$1, g).map((x) => x.text).join();
      if (!rules.hiatus(run, graphemes[g].text)) {
        nuclei[nuclei.length - 1] = (nuclei.last.$1, g + 1);
        continue;
      }
    }
    nuclei.add((g, g + 1));
  }
  if (nuclei.isEmpty) return const [];

  // 3. Coupures entre deux noyaux
  final cuts = <int>[]; // indices de graphèmes où commence une syllabe
  var syllableStart = 0;
  for (var n = 1; n < nuclei.length; n++) {
    final clusterStart = nuclei[n - 1].$2;
    final clusterEnd = nuclei[n].$1;
    final cluster = [
      for (var g = clusterStart; g < clusterEnd; g++) graphemes[g].text,
    ];
    var cut = clusterEnd;
    if (cluster.isNotEmpty) {
      final context = _OnsetContext(
        before: lower.substring(
            graphemes[syllableStart].start, graphemes[clusterStart].start),
        after: lower.substring(graphemes[clusterEnd].start),
      );
      cut = clusterEnd - rules.onsetLength(cluster, context);
    }
    cuts.add(cut);
    syllableStart = cut;
  }

  final syllables = <String>[];
  var from = 0;
  for (final cut in cuts) {
    syllables.add(text.substring(graphemes[from].start, graphemes[cut].start));
    from = cut;
  }
  syllables.add(text.substring(graphemes[from].start));
  return syllables;
}

class _Unit {
  const _Unit(this.letters, {this.before, this.orAtEnd = false});

  final String letters;

  /// Lettres dont l'une doit suivre (gu devant e ou i, par exemple).
  final String? before;

  /// Accepté aussi en fin de mot (longu[e]).
  final bool orAtEnd;

  bool matchesAt(String text, int i) {
    if (!text.startsWith(letters, i)) return false;
    if (before == null) return true;
    final next = i + letters.length;
    if (next >= text.length) return orAtEnd;
    return before!.contains(text[next]);
  }
}

/// Ce qui entoure un groupe de consonnes entre deux voyelles.
class _OnsetContext {
  const _OnsetContext({
    required this.before,
    required this.after,
  });

  /// Début de la syllabe en cours, jusqu'au groupe de consonnes.
  final String before;

  /// Fin du mot, à partir de la voyelle suivante.
  final String after;
}

enum _ConsonantY { never, beforeVowel, syllableStart }

class _LanguageRules {
  const _LanguageRules({
    required this.vowels,
    required this.consonantUnits,
    required this.hiatus,
    required this.onsetLength,
    this.consonantY = _ConsonantY.never,
    this.silentH = false,
    this.silentEnd,
    this.mutedVowels,
  });

  final String vowels;

  /// Du plus long au plus court.
  final List<_Unit> consonantUnits;

  /// La voyelle [current] se prononce à part de celles qui la précèdent ([run]).
  final bool Function(String run, String current) hiatus;

  /// Nombre de graphèmes du groupe de consonnes qui passent à la syllabe suivante.
  final int Function(List<String> cluster, _OnsetContext context) onsetLength;
  final _ConsonantY consonantY;
  final bool silentH;

  /// Nombre de lettres muettes à la fin du mot.
  final int Function(String lower)? silentEnd;

  /// Positions de voyelles qui ne forment pas de syllabe (lived, snowflakes).
  final Iterable<int> Function(String lower)? mutedVowels;
}

const Set<String> _liquidOnsets = {
  'pl', 'pr', 'bl', 'br', 'tr', 'dr', 'cl', 'cr', 'kl', 'kr', 'gl', 'gr', //
  'fl', 'fr', 'vr', 'chr', 'chl', 'phr', 'phl', 'thr',
};

/// Une consonne suivie de l ou r commence la syllabe (ta-ble), sinon seule la
/// dernière consonne passe à la syllabe suivante (par-tir).
int _latinOnset(List<String> cluster, {Set<String> excluded = const {}}) {
  final n = cluster.length;
  if (n >= 2) {
    final pair = cluster[n - 2] + cluster[n - 1];
    if (_liquidOnsets.contains(pair) && !excluded.contains(pair)) return 2;
  }
  return 1;
}

bool _endsWithVowelOf(String run, String vowels) =>
    run.isNotEmpty && vowels.contains(run[run.length - 1]);

final Map<String, _LanguageRules> _rules = {
  'fr': _LanguageRules(
    vowels: 'aeiouyàâäéèêëîïôöùûüœæ',
    consonantUnits: const [
      _Unit('ch'),
      _Unit('ph'),
      _Unit('th'),
      _Unit('gn'),
      _Unit('qu'),
      _Unit('gu', before: 'eiéèêëy', orAtEnd: true),
    ],
    consonantY: _ConsonantY.beforeVowel,
    silentH: true,
    // Lé-on, a-é-ro-port, No-ël, na-ïf, po-è-me
    hiatus: (run, current) =>
        run.endsWith('é') ||
        'éëï'.contains(current) ||
        (current == 'è' && run.endsWith('o')),
    onsetLength: (cluster, _) => _latinOnset(cluster),
    silentEnd: _frenchSilentEnd,
  ),
  'en': _LanguageRules(
    vowels: 'aeiouy',
    consonantUnits: const [
      _Unit('ch'),
      _Unit('sh'),
      _Unit('th'),
      _Unit('ph'),
      _Unit('wh'),
      _Unit('ck'),
      _Unit('qu'),
    ],
    consonantY: _ConsonantY.beforeVowel,
    hiatus: (run, current) => false,
    onsetLength: (cluster, context) {
      // lit-tle, ta-ble : la consonne passe avec le -le final
      if (context.after == 'e' && cluster.last == 'l' && cluster.length >= 2) {
        return 2;
      }
      // Suffixes : sing-ing, strong-ly
      if (context.after == 'ing' && cluster.join().endsWith('ng')) return 0;
      if (context.after == 'y' && cluster.join().endsWith('ngl')) return 1;
      return _latinOnset(cluster, excluded: {'vr'});
    },
    silentEnd: _englishSilentEnd,
    mutedVowels: _englishMutedVowels,
  ),
  'es': _LanguageRules(
    vowels: 'aeiouyáéíóúü',
    consonantUnits: const [
      _Unit('ch'),
      _Unit('ll'),
      _Unit('rr'),
      _Unit('qu'),
      _Unit('gu', before: 'eiéí'),
    ],
    consonantY: _ConsonantY.beforeVowel,
    silentH: true,
    // Deux voyelles fortes, ou une faible accentuée : le-ón, dí-a
    hiatus: (run, current) =>
        _endsWithVowelOf(run, 'aeoáéóíú') && 'aeoáéóíú'.contains(current),
    onsetLength: (cluster, _) => _latinOnset(cluster, excluded: {'vr'}),
  ),
  'it': _LanguageRules(
    vowels: 'aeiouàèéìíòóù',
    consonantUnits: const [
      _Unit('ch'),
      _Unit('gh'),
      _Unit('gn'),
      _Unit('gl', before: 'i'),
      _Unit('qu'),
    ],
    silentH: true,
    hiatus: (run, current) =>
        _endsWithVowelOf(run, 'aeoàèéòó') && 'aeoàèéòó'.contains(current),
    onsetLength: (cluster, _) => _italianOnset(cluster),
  ),
  'de': _LanguageRules(
    vowels: 'aeiouyäöü',
    consonantUnits: const [
      _Unit('sch'),
      _Unit('ch'),
      _Unit('ck'),
      _Unit('ph'),
      _Unit('th'),
      _Unit('qu'),
    ],
    // Fe-u-er n'existe pas : au, ei, eu, ie… restent ensemble ; Le-on, Feu-er
    hiatus: (run, current) =>
        run.length >= 2 ||
        !const {
          'ie', 'ei', 'ai', 'au', 'eu', 'äu', 'aa', 'ee', 'oo', 'ey', 'ay', //
        }.contains(run + current),
    onsetLength: _germanOnset,
  ),
};

/// En italien, s + consonne commence la syllabe (pa-sta), sauf ss (ros-sa).
int _italianOnset(List<String> cluster) {
  var length = _latinOnset(cluster);
  final n = cluster.length;
  if (n > length &&
      cluster[n - length - 1] == 's' &&
      cluster[n - length] != 's') {
    length++;
  }
  return length;
}

/// Groupes qui peuvent commencer une syllabe allemande.
const Set<String> _germanOnsets = {
  'sch', 'schl', 'schm', 'schn', 'schr', 'schw', 'sp', 'spr', 'st', 'str', //
  'pf', 'pfl', 'pfr', 'bl', 'br', 'dr', 'fl', 'fr', 'gl', 'gr', 'kl', 'kr',
  'kn', 'pl', 'pr', 'tr', 'zw', 'qu', 'ph', 'th', 'ch',
};

/// Règle du Duden : seule la dernière consonne passe à la syllabe suivante
/// (Fens-ter, Ap-fel), sauf après un préfixe (be-schlos-sen, ver-ste-hen).
/// Les mots composés (Schnee-flo-cken) ne sont pas reconnus.
int _germanOnset(List<String> cluster, _OnsetContext context) {
  // Aussi en milieu de mot : ein-ge-stürzt, un-zer-trenn-lich
  for (final prefix in const ['ver', 'zer', 'ent', 'emp', 'be', 'ge', 'er']) {
    if (!prefix.startsWith(context.before)) continue;
    // Consonnes du préfixe qui font partie du groupe (le r de ver-)
    final remainder = prefix.substring(context.before.length);
    var taken = 0;
    var letters = '';
    while (letters.length < remainder.length && taken < cluster.length) {
      letters += cluster[taken++];
    }
    if (letters != remainder || taken >= cluster.length) continue;
    final onset = cluster.sublist(taken).join();
    if (cluster.length - taken == 1 || _germanOnsets.contains(onset)) {
      return cluster.length - taken;
    }
  }

  // Trois consonnes ou plus : souvent la jonction d'un mot composé
  // (Bunt-stif-te, Brief-trä-ger), sauf devant un suffixe (wirk-lich) ou
  // dans -ster (Fens-ter, Mons-ter)
  final n = cluster.length;
  if (n >= 3 &&
      !RegExp(r'^l(ich|ein|ing)').hasMatch(cluster.last + context.after) &&
      !(cluster.join().endsWith('st') &&
          RegExp(r'^er[ns]?$').hasMatch(context.after))) {
    for (final length in [3, 2]) {
      if (length < n &&
          _germanOnsets.contains(cluster.sublist(n - length).join())) {
        return length;
      }
    }
  }
  return 1;
}

/// Mots dont la fin s'entend malgré les règles ci-dessous.
const Set<String> _frenchPronouncedEndings = {
  'les', 'des', 'mes', 'tes', 'ses', 'ces', 'est', //
  'bus', 'autobus', 'ours', 'fils', 'os', 'sens', 'hélas', 'oasis', 'cactus',
  'lys', 'mars', 'tennis', 'maïs', 'ouest', 'sept', 'huit', 'net', 'but',
  'chut', 'zut', 'six', 'dix', 'ananas', 'iris', 'vis', 'express', 'zig',
  'sud', 'atlas', 'virus', 'bonus', 'jadis', 'hiver', 'enfer', 'super',
  'cancer', 'hamster', 'laser', 'poster', 'gangster', 'reporter', 'scooter',
  'donc', 'gaz', 'fez', 'stop', 'top', 'hop', 'cap', 'rap', 'mat', 'brut',
  'dot', 'kit', 'fax', 'lynx', 'thorax', 'index', 'relax', 'amer', 'hier',
  'fier', 'cher', 'mer', 'fer', 'ver', 'tiers',
};

/// Mots dont la fin muette échappe aux règles (le l de gentil, le r de monsieur).
const Map<String, int> _frenchIrregularEndings = {
  'gentil': 1, 'outil': 1, 'fusil': 1, 'sourcil': 1, 'persil': 1, //
  'nombril': 1, 'monsieur': 1, 'messieurs': 2, 'clef': 1, 'porc': 1,
  'tabac': 1, 'estomac': 1, 'croc': 1, 'caoutchouc': 1, 'aspect': 2,
  'respect': 2, 'instinct': 2, 'doigt': 2, 'vingt': 2, 'nerf': 1, 'cerf': 1,
  'œufs': 2, 'bœufs': 2,
};

final List<(RegExp, int)> _frenchSilentEndings = [
  // étaient, voient, jouent, décidèrent
  (RegExp(r'(ai|oi|ou|èr)ent$'), 3),
  // Verbes au pluriel : finissent, prennent, mangent, marchent, tremblent ;
  // les noms en -ent (moment, dent, argent) n'ont pas ces terminaisons
  (RegExp(r'(ss|nn|tt|ch|ng|gu|ill|[pbcgf]l|[tbdgcpv]r)ent$'), 3),
  // rochers, premiers ; mais vers, univers
  (RegExp(r'^.{3,}[^v]ers$'), 2),
  // temps, corps
  (RegExp(r'[mr]ps$'), 2),
  // manger, premier
  (RegExp(r'^.{2,}er$'), 1),
  // chez, nez, mangez
  (RegExp(r'ez$'), 1),
  // blanc, banc
  (RegExp(r'nc$'), 1),
  // loup, beaucoup, trop, drap
  (RegExp(r'(oup|trop|sirop|galop|drap)$'), 1),
  (RegExp(r'(ts|ds|es)$'), 2),
  (RegExp(r'[stdxge]$'), 1),
];

int _frenchSilentEnd(String lower) {
  if (lower.length <= 2 || _frenchPronouncedEndings.contains(lower)) return 0;
  final irregular = _frenchIrregularEndings[lower];
  if (irregular != null) return irregular;
  // Pluriel : gentils, outils
  if (lower.endsWith('s')) {
    final singular =
        _frenchIrregularEndings[lower.substring(0, lower.length - 1)];
    if (singular != null) return singular + 1;
  }
  for (final (pattern, length) in _frenchSilentEndings) {
    if (pattern.hasMatch(lower)) return length;
  }
  return 0;
}

/// Mots où le e final se prononce.
const Set<String> _englishPronouncedE = {
  'maybe', 'recipe', 'karate', 'sesame', 'coyote', 'adobe', 'cafe', 'acne', //
  'apostrophe', 'catastrophe', 'simile', 'anemone', 'ukulele', 'tamale',
};

/// e final muet (time, house), sauf après consonne + l (little, table).
int _englishSilentEnd(String lower) {
  if (lower.length <= 2 ||
      !lower.endsWith('e') ||
      _englishPronouncedE.contains(lower)) {
    return 0;
  }
  if (RegExp(r'[^aeiouy]le$').hasMatch(lower)) return 0;
  if (RegExp(r'[aeiou]e$').hasMatch(lower)) return 0; // tree, blue
  return 1;
}

/// e de -ed et -es qui ne forme pas de syllabe : lived, snowflakes (mais
/// wanted, horses).
Iterable<int> _englishMutedVowels(String lower) sync* {
  final n = lower.length;
  if (n < 4) return;
  final before = lower[n - 3];
  if (lower.endsWith('ed') && !'tdaeiou'.contains(before)) yield n - 2;
  if (lower.endsWith('es') &&
      !'aeiou'.contains(before) &&
      !RegExp(r'(ch|sh|[sxzgc])es$').hasMatch(lower)) {
    yield n - 2;
  }
}
