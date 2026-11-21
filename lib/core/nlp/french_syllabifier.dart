/// Modèle d'un mot français analysé phonétiquement et orthographiquement
class AnalyzedWord {
  final String originalToken;
  final String leadingPunctuation;
  final String cleanWord;
  final String trailingPunctuation;
  final List<String> syllables;
  final String basePart;
  final String silentEnding;
  final bool hasLiaisonWithNext;

  const AnalyzedWord({
    required this.originalToken,
    required this.leadingPunctuation,
    required this.cleanWord,
    required this.trailingPunctuation,
    required this.syllables,
    required this.basePart,
    required this.silentEnding,
    required this.hasLiaisonWithNext,
  });

  /// Indique si le mot comporte une lettre muette identifiée
  bool get hasSilentEnding => silentEnding.isNotEmpty;
}

/// Moteur linguistique de traitement de la langue française 100 % hors ligne
class FrenchSyllabifier {
  FrenchSyllabifier._();

  static const String liaisonArc = '‿';

  // Voyelles et voyelles accentuées en français
  static const Set<String> _vowels = {
    'a',
    'e',
    'i',
    'o',
    'u',
    'y',
    'à',
    'â',
    'ä',
    'é',
    'è',
    'ê',
    'ë',
    'î',
    'ï',
    'ô',
    'ö',
    'ù',
    'û',
    'ü',
    'ÿ',
  };

  // Groupes consonantiques inséparables français
  static const Set<String> _inseparableConsonantGroups = {
    'bl',
    'br',
    'cl',
    'cr',
    'dr',
    'fl',
    'fr',
    'gl',
    'gr',
    'pl',
    'pr',
    'tr',
    'vr',
    'ch',
    'ph',
    'gn',
    'th',
  };

  // Digrammes et trigrammes vocaliques inséparables
  static const List<String> _vocalicDigraphs = [
    'eau',
    'oeu',
    'oin',
    'ain',
    'ein',
    'ian',
    'ien',
    'ion',
    'ai',
    'ei',
    'oi',
    'ui',
    'au',
    'eu',
    'ou',
    'an',
    'en',
    'in',
    'on',
    'un',
  ];

  // Liste de mots déclencheurs de liaison obligatoire ou fréquente
  static const Set<String> _liaisonTriggers = {
    // Déterminants
    'un', 'les', 'des', 'mon', 'ton', 'son', 'mes', 'tes', 'ses', 'nos', 'vos',
    'leurs', 'ces', 'aucun', 'tout', 'tous', 'deux', 'trois', 'six', 'dix',
    'aux',
    // Pronoms
    'on', 'nous', 'vous', 'ils', 'elles', 'en', 'y',
    // Prépositions & adverbes
    'dans', 'sans', 'sous', 'chez', 'très', 'trop', 'bien', 'plus',
    // Adjectifs antéposés
    'petit', 'petits', 'petite', 'petites', 'grand', 'grands', 'grande',
    'grandes',
    'gros', 'bon', 'bons', 'bonne', 'bonnes', 'beaux', 'vieux', 'premier',
    'derniers',
    // Formes verbales courantes
    'est', 'sont', 'ont', 'avaient', 'sont-ils', 'est-ce',
  };

  // Mots dont la consonne finale est toujours prononcée (sonore)
  static const Set<String> _pronouncedFinalConsonants = {
    'bus',
    'plus',
    'fils',
    'mars',
    'ours',
    'sens',
    'os',
    'vis',
    'maïs',
    'albatros',
    'ananas',
    'cactus',
    'oasis',
    'tennis',
    'est',
    'ouest',
    'sud',
    'sept',
    'huit',
    'net',
    'coq',
    'sac',
    'lac',
    'parc',
    'chef',
    'soif',
    'oeuf',
    'boeuf',
    'gaz',
  };

  /// Vérifie si un caractère est une voyelle
  static bool isVowel(String char) {
    if (char.isEmpty) return false;
    return _vowels.contains(char.toLowerCase());
  }

  /// Analyse un texte complet et le convertit en liste d'AnalyzedWord
  static List<AnalyzedWord> analyzeText(String text) {
    if (text.trim().isEmpty) return const [];

    final tokens = text.split(RegExp(r'\s+'));
    final List<AnalyzedWord> result = [];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.isEmpty) continue;

      final leadingPunctMatch =
          RegExp(r'^[^\p{L}\p{N}]+', unicode: true).firstMatch(token);
      final leadingPunct =
          leadingPunctMatch != null ? leadingPunctMatch.group(0)! : '';

      final trailingPunctMatch =
          RegExp(r'[^\p{L}\p{N}]+$', unicode: true).firstMatch(token);
      final trailingPunct =
          trailingPunctMatch != null ? trailingPunctMatch.group(0)! : '';

      var clean = token;
      if (leadingPunct.isNotEmpty) {
        clean = clean.substring(leadingPunct.length);
      }
      if (trailingPunct.isNotEmpty && clean.length >= trailingPunct.length) {
        clean = clean.substring(0, clean.length - trailingPunct.length);
      }

      final syllables = syllabify(clean);
      final (basePart, silentEnding) = detectSilentEnding(clean);

      // Détection de la liaison avec le mot suivant
      bool hasLiaison = false;
      if (i + 1 < tokens.length && trailingPunct.isEmpty) {
        final nextToken = tokens[i + 1];
        final nextCleanMatch =
            RegExp(r'[\p{L}\p{N}]+', unicode: true).firstMatch(nextToken);
        if (nextCleanMatch != null) {
          final nextClean = nextCleanMatch.group(0)!.toLowerCase();
          final currentCleanLower = clean.toLowerCase();
          if (_liaisonTriggers.contains(currentCleanLower)) {
            if (nextClean.isNotEmpty) {
              final firstChar = nextClean[0];
              if (isVowel(firstChar) ||
                  (firstChar == 'h' &&
                      nextClean.length > 1 &&
                      isVowel(nextClean[1]))) {
                hasLiaison = true;
              }
            }
          }
        }
      }

      result.add(
        AnalyzedWord(
          originalToken: token,
          leadingPunctuation: leadingPunct,
          cleanWord: clean,
          trailingPunctuation: trailingPunct,
          syllables: syllables,
          basePart: basePart,
          silentEnding: silentEnding,
          hasLiaisonWithNext: hasLiaison,
        ),
      );
    }

    return result;
  }

  /// Découpage syllabique phonétique et orthographique français
  static List<String> syllabify(String word) {
    if (word.isEmpty) return const [];
    if (word.length <= 3) return [word];

    // Traitement des élisions françaises (ex: l'oiseau, d'arbre, c'est)
    final elisionMatch =
        RegExp(r"^([ldjcstnm]|qu)['’]", caseSensitive: false).firstMatch(word);
    if (elisionMatch != null) {
      final prefix = word.substring(0, elisionMatch.end);
      final remainder = word.substring(elisionMatch.end);
      if (remainder.isNotEmpty) {
        final remainderSyllables = syllabify(remainder);
        if (remainderSyllables.isNotEmpty) {
          return [
            '$prefix${remainderSyllables.first}',
            ...remainderSyllables.sublist(1),
          ];
        }
      }
    }

    final lower = word.toLowerCase();

    // Dictionnaire de découpages explicites prioritaires (Vocabulaire scolaire fondamental)
    const explicitMap = {
      'oiseaux': ['oi', 'seaux'],
      'oiseau': ['oi', 'seau'],
      'doucement': ['dou', 'ce', 'ment'],
      'enfants': ['en', 'fants'],
      'enfant': ['en', 'fant'],
      'lecture': ['lec', 'ture'],
      'ecole': ['e', 'co', 'le'],
      'école': ['é', 'co', 'le'],
      'maison': ['mai', 'son'],
      'papillon': ['pa', 'pil', 'lon'],
      'etoile': ['e', 'toi', 'le'],
      'étoile': ['é', 'toi', 'le'],
      'foret': ['fo', 'rêt'],
      'forêt': ['fo', 'rêt'],
      'arbre': ['ar', 'bre'],
      'arbres': ['ar', 'bres'],
      'soleil': ['so', 'leil'],
      'chateau': ['châ', 'teau'],
      'château': ['châ', 'teau'],
      'liraplus': ['li', 'ra', 'plus'],
      'québec': ['qué', 'bec'],
      'quebec': ['que', 'bec'],
      'érable': ['é', 'ra', 'ble'],
      'neige': ['nei', 'ge'],
      'hiver': ['hi', 'ver'],
      'fleuve': ['fleu', 've'],
      'baleine': ['ba', 'lei', 'ne'],
      'tadoussac': ['ta', 'dous', 'sac'],
      'laurentides': ['lau', 'ren', 'ti', 'des'],
      'boréale': ['bo', 'ré', 'a', 'le'],
      'merveilleux': ['mer', 'veil', 'leux'],
      'histoire': ['his', 'toi', 're'],
      'famille': ['fa', 'mil', 'le'],
      'musique': ['mu', 'si', 'que'],
      'classe': ['clas', 'se'],
      'courage': ['cou', 'ra', 'ge'],
      'montagne': ['mon', 'ta', 'gne'],
      'océan': ['o', 'cé', 'an'],
      'cascade': ['cas', 'ca', 'de'],
      'rentrée': ['ren', 'trée'],
      'livre': ['li', 'vre'],
      'livres': ['li', 'vres'],
      'cartable': ['car', 'ta', 'ble'],
      'cahier': ['ca', 'hier'],
      'jardin': ['jar', 'din'],
      'tableau': ['ta', 'bleau'],
      'aventure': ['a', 'ven', 'tu', 're'],
      'explorateur': ['ex', 'plo', 'ra', 'teur'],
      'explorateurs': ['ex', 'plo', 'ra', 'teurs'],
      'animaux': ['a', 'ni', 'maux'],
      'animal': ['a', 'ni', 'mal'],
      'chocolat': ['cho', 'co', 'lat'],
      'printemps': ['prin', 'temps'],
    };

    if (explicitMap.containsKey(lower)) {
      final list = explicitMap[lower]!;
      // Reconstituer avec la casse d'origine
      return _matchCase(word, list);
    }

    // Algorithme de découpage syllabique générique français
    final List<int> cuts = [];
    final n = lower.length;

    // Repérage des voyelles / noyaux syllabiques
    final List<int> vowelIndices = [];
    int idx = 0;
    while (idx < n) {
      if (isVowel(lower[idx])) {
        vowelIndices.add(idx);
        // Vérifier si digramme vocalique
        bool matchedDigraph = false;
        for (final digraph in _vocalicDigraphs) {
          if (lower.startsWith(digraph, idx)) {
            idx += digraph.length;
            matchedDigraph = true;
            break;
          }
        }
        if (!matchedDigraph) {
          idx++;
        }
      } else {
        idx++;
      }
    }

    if (vowelIndices.length <= 1) {
      return [word];
    }

    // Pour chaque paire de voyelles consécutives, analyser l'intervalle de consonnes
    for (int v = 0; v < vowelIndices.length - 1; v++) {
      final v1 = vowelIndices[v];
      final v2 = vowelIndices[v + 1];

      // Trouver la fin du noyau vocalique v1
      int coreEnd = v1 + 1;
      for (final digraph in _vocalicDigraphs) {
        if (lower.startsWith(digraph, v1)) {
          coreEnd = v1 + digraph.length;
          break;
        }
      }

      if (coreEnd >= v2) {
        // Deux voyelles contiguës (ex: hi-er, gé-ant)
        cuts.add(coreEnd);
        continue;
      }

      final consonantLength = v2 - coreEnd;
      if (consonantLength == 1) {
        // Une consonne entre deux voyelles va avec la deuxième : V-CV (ex: dou-ce-ment)
        cuts.add(coreEnd);
      } else if (consonantLength == 2) {
        final pair = lower.substring(coreEnd, coreEnd + 2);
        if (_inseparableConsonantGroups.contains(pair)) {
          // Groupe inséparable va avec la 2e voyelle : V-CCV (ex: ta-ble, ar-bre)
          cuts.add(coreEnd);
        } else {
          // Deux consonnes se séparent : VC-CV (ex: pom-me, lec-ture)
          cuts.add(coreEnd + 1);
        }
      } else if (consonantLength >= 3) {
        final pair = lower.substring(
            coreEnd + consonantLength - 2, coreEnd + consonantLength);
        if (_inseparableConsonantGroups.contains(pair)) {
          // VC-CCV (ex: obs-tacle)
          cuts.add(coreEnd + consonantLength - 2);
        } else {
          cuts.add(coreEnd + 1);
        }
      }
    }

    if (cuts.isEmpty) {
      return [word];
    }

    final List<String> result = [];
    int start = 0;
    for (final cut in cuts) {
      if (cut > start && cut <= word.length) {
        result.add(word.substring(start, cut));
        start = cut;
      }
    }
    if (start < word.length) {
      result.add(word.substring(start));
    }

    return result.isEmpty ? [word] : result;
  }

  /// Détecte les terminaisons muettes en français (ex: s, x, ent, ts, ds, p, d, t, g)
  static (String base, String silent) detectSilentEnding(String word) {
    if (word.length <= 1) return (word, '');

    final lower = word.toLowerCase();

    // Consonnes finales sonores protégées
    if (_pronouncedFinalConsonants.contains(lower)) {
      return (word, '');
    }

    // Détection des terminaisons verbales muettes 'ent' (au moins 5 lettres, polysyllabique)
    if (lower.endsWith('ent') && lower.length >= 5) {
      // Vérifier si le mot avant 'ent' contient au moins une voyelle
      final stem = lower.substring(0, lower.length - 3);
      if (stem.split('').any(isVowel)) {
        final base = word.substring(0, word.length - 3);
        final silent = word.substring(word.length - 3);
        return (base, silent);
      }
    }

    // Terminaisons composées muettes 'ts', 'ds', 'ps', 'cs'
    const doubleSilentEndings = ['ts', 'ds', 'ps', 'cs'];
    for (final ending in doubleSilentEndings) {
      if (lower.endsWith(ending) && lower.length >= 3) {
        final base = word.substring(0, word.length - 2);
        final silent = word.substring(word.length - 2);
        return (base, silent);
      }
    }

    // Terminaisons simples courantes : s, x, d, t, p, g
    const singleSilentEndings = ['s', 'x', 'd', 't', 'p', 'g'];
    for (final char in singleSilentEndings) {
      if (lower.endsWith(char) && lower.length >= 2) {
        // Cas particulier : voyelle avant
        final prevChar = lower[lower.length - 2];
        if (isVowel(prevChar) ||
            prevChar == 'r' ||
            prevChar == 'l' ||
            prevChar == 'n') {
          final base = word.substring(0, word.length - 1);
          final silent = word.substring(word.length - 1);
          return (base, silent);
        }
      }
    }

    return (word, '');
  }

  /// Adapte le découpage à la casse originale du mot
  static List<String> _matchCase(String original, List<String> syllables) {
    final List<String> res = [];
    int cursor = 0;
    for (final syl in syllables) {
      final len = syl.length;
      if (cursor + len <= original.length) {
        res.add(original.substring(cursor, cursor + len));
        cursor += len;
      } else {
        res.add(syl);
      }
    }
    if (cursor < original.length) {
      final last = res.isNotEmpty ? res.removeLast() : '';
      res.add(last + original.substring(cursor));
    }
    return res;
  }
}
