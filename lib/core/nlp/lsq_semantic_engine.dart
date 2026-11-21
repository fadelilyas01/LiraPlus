import 'package:flutter/material.dart';

/// Types de mouvements gestuels en Langue des Signes Québécoise (LSQ)
enum LsqMovementKind {
  wingsFlapping, // Battements répétés (oiseau, papillon, voler)
  whiskersCaress, // Caresse symétrique vers l'extérieur (chat, animaux)
  pattingThigh, // Rythme de pas / appel / déplacement (chien, marcher, courir)
  treeSwaying, // Tronc fixe et oscillation douce (arbre, forêt, plante)
  handPinch, // Pincement délicat vers la bouche (manger, nourriture, petit)
  turningPages, // Ouverture des mains (livre, école, écrire, objet)
  heartPulse, // Battement chaleureux sur la poitrine (émotions, famille, amis)
  sunRaysExpansion, // Déploiement ample vers l'extérieur (soleil, ciel, grand, futur)
  houseRoofTriangle, // Chevron / toit / abri (maison, école, montagne, lieu)
  waterWaveFlow, // Vague ondulante fluide (eau, pluie, vent, calme, musique)
  starTwinkle, // Scintillement des doigts (étoile, lumière, fête, neige, couleurs)
  directionalArc, // Axe directionnel (temps passé/futur, communication, regarder)
}

/// Résultat de l'analyse sémantique LSQ 100 % hors ligne d'un mot (y compris issu d'une photo OCR)
class LsqSemanticMatch {
  final String title;
  final LsqMovementKind kind;
  final String startPosition;
  final String trajectoryDescription;
  final String repetition;
  final IconData icon;
  final String categoryLabel;
  final bool isKnownSign;

  const LsqSemanticMatch({
    required this.title,
    required this.kind,
    required this.startPosition,
    required this.trajectoryDescription,
    required this.repetition,
    required this.icon,
    required this.categoryLabel,
    required this.isKnownSign,
  });
}

/// Moteur sémantique LSQ 100 % hors ligne basé sur 300+ racines scolaires françaises.
/// Permet à toute photo scannée (manuel, devoir, histoire) d'associer automatiquement
/// un mouvement LSQ cohérent et un pictogramme, ou de basculer en épellation dactylologique
/// pour les noms propres et mots rares (fidèle à la vraie pratique LSQ).
class LsqSemanticEngine {
  LsqSemanticEngine._();

  static const List<({List<String> roots, LsqSemanticMatch match})> _families =
      [
    // 1. OISEAUX & VOL
    (
      roots: [
        'oiseau',
        'vole',
        'voler',
        'volai',
        'geai',
        'papillon',
        'aile',
        'plume',
        'avion',
        'hibou',
        'canard',
        'poule',
        'corbeau',
        'aigle',
        'abeille',
        'mouche',
      ],
      match: LsqSemanticMatch(
        title: 'Battement des ailes',
        kind: LsqMovementKind.wingsFlapping,
        startPosition: 'Mains devant la poitrine ou près du visage.',
        trajectoryDescription:
            'Les deux mains battent doucement de haut en bas comme des ailes dans le ciel.',
        repetition: '2 battements doux consécutifs.',
        icon: Icons.flutter_dash,
        categoryLabel: 'Animal & Vol',
        isKnownSign: true,
      ),
    ),

    // 2. ARBRES, PLANTES & FORÊT
    (
      roots: [
        'arbre',
        'sapin',
        'erabl',
        'foret',
        'bois',
        'feuill',
        'branch',
        'fleur',
        'jardin',
        'herb',
        'plant',
        'champ',
        'parc',
        'rose',
        'tulip',
        'racin',
        'buisson',
        'mousse',
        'nature',
        'verger',
      ],
      match: LsqSemanticMatch(
        title: 'Oscillation du tronc et des branches',
        kind: LsqMovementKind.treeSwaying,
        startPosition: 'Avant-bras dressé verticalement devant soi.',
        trajectoryDescription:
            'La main ouverte ondule doucement de gauche à droite comme des branches au vent.',
        repetition: 'Mouvement fluide continu.',
        icon: Icons.park_rounded,
        categoryLabel: 'Nature & Plante',
        isKnownSign: true,
      ),
    ),

    // 3. NOURRITURE, REPAS & BOIRE
    (
      roots: [
        'mang',
        'boir',
        'buvai',
        'pomm',
        'pain',
        'gateau',
        'repas',
        'diner',
        'souper',
        'dejeun',
        'faim',
        'soif',
        'grain',
        'fruit',
        'legum',
        'soupe',
        'lait',
        'jus',
        'fromag',
        'chocolat',
        'bonbon',
        'sucre',
        'cuisine',
        'recett',
        'cuiller',
        'fourchett',
        'assiett',
        'bec',
        'petit',
        'mince',
      ],
      match: LsqSemanticMatch(
        title: 'Geste délicat vers la bouche',
        kind: LsqMovementKind.handPinch,
        startPosition: 'Bout des doigts réunis devant la bouche.',
        trajectoryDescription:
            'Approcher et pincer délicatement les doigts vers la bouche (manger, goûter ou petit).',
        repetition: '2 petits mouvements doux.',
        icon: Icons.restaurant_rounded,
        categoryLabel: 'Nourriture & Quotidien',
        isKnownSign: true,
      ),
    ),

    // 4. ÉMOTIONS, FAMILLE & AMIS
    (
      roots: [
        'aim',
        'coeur',
        'souri',
        'ami',
        'famill',
        'maman',
        'mere',
        'papa',
        'pere',
        'frere',
        'soeur',
        'bebe',
        'grand-mere',
        'grand-pere',
        'content',
        'heureu',
        'joie',
        'rire',
        'riait',
        'trist',
        'pleur',
        'peur',
        'coler',
        'gentil',
        'bravo',
        'merci',
        'bonjour',
        'salut',
        'bisou',
        'calin',
        'souhait',
        'merveilleu',
        'courageu',
        'fier',
        'plaisir',
        'fete',
        'anniversair',
      ],
      match: LsqSemanticMatch(
        title: 'Élan chaleureux près du cœur',
        kind: LsqMovementKind.heartPulse,
        startPosition: 'Main ouverte posée près du cœur ou du visage.',
        trajectoryDescription:
            'Mouvement circulaire doux sur la poitrine accompagné d\'une expression du visage claire.',
        repetition: '2 pulsations douces.',
        icon: Icons.favorite_rounded,
        categoryLabel: 'Émotion & Famille',
        isKnownSign: true,
      ),
    ),

    // 5. ÉTOILES, LUMIÈRE, NEIGE & COULEURS
    (
      roots: [
        'etoil',
        'brill',
        'dore',
        'neig',
        'illumin',
        'etincel',
        'lumier',
        'lune',
        'nuit',
        'flocon',
        'hiver',
        'glace',
        'froid',
        'rouge',
        'jaune',
        'vert',
        'bleu',
        'blanc',
        'noir',
        'rose',
        'orange',
        'violet',
        'couleur',
        'arc-en-ciel',
        'magi',
        'feu',
        'flamm',
        'bougie',
        'lampe',
        'eclat',
      ],
      match: LsqSemanticMatch(
        title: 'Scintillement lumineux des doigts',
        kind: LsqMovementKind.starTwinkle,
        startPosition: 'Mains levées, doigts légèrement courbés.',
        trajectoryDescription:
            'Ouvrir et fermer les doigts en alternance comme des étoiles, la neige ou des couleurs vives.',
        repetition: 'Scintillement continu.',
        icon: Icons.auto_awesome_rounded,
        categoryLabel: 'Lumière & Couleur',
        isKnownSign: true,
      ),
    ),

    // 6. ANIMAUX TERRESTRES
    (
      roots: [
        'chat',
        'cerf',
        'lapin',
        'ours',
        'loup',
        'renard',
        'cheval',
        'chevau',
        'vache',
        'mouton',
        'cochon',
        'souris',
        'ecureuil',
        'castor',
        'orignal',
        'lion',
        'tigre',
        'eleph',
        'giraf',
        'singe',
        'tortue',
        'grenouill',
        'dinosaur',
        'animal',
        'animau',
        'bete',
        'patte',
        'queue',
        'poil',
      ],
      match: LsqSemanticMatch(
        title: 'Geste expressif de l\'animal',
        kind: LsqMovementKind.whiskersCaress,
        startPosition: 'Mains placées de chaque côté du visage ou devant soi.',
        trajectoryDescription:
            'Écarter les doigts vers l\'extérieur pour mimer les traits caractéristiques de l\'animal.',
        repetition: '2 fois de suite.',
        icon: Icons.pets_rounded,
        categoryLabel: 'Animal',
        isKnownSign: true,
      ),
    ),

    // 7. DÉPLACEMENTS, ACTIONS & CORPS
    (
      roots: [
        'chien',
        'march',
        'cour',
        'saut',
        'avanc',
        'part',
        'venir',
        'vien',
        'arriv',
        'aller',
        'vais',
        'vont',
        'promen',
        'voyag',
        'roul',
        'velo',
        'voitur',
        'autobus',
        'train',
        'bateau',
        'chemin',
        'route',
        'sentier',
        'rue',
        'enfant',
        'garcon',
        'fille',
        'eleve',
        'pied',
        'jambe',
        'sport',
        'jou',
        'ballon',
        'balle',
        'danse',
        'grimp',
        'monte',
        'descend',
        'vite',
      ],
      match: LsqSemanticMatch(
        title: 'Rythme de déplacement et d\'action',
        kind: LsqMovementKind.pattingThigh,
        startPosition: 'Main ouverte devant soi, paume vers le bas.',
        trajectoryDescription:
            'Mouvement rythmé vers l\'avant ou vers le bas pour montrer le pas, le jeu ou le trajet.',
        repetition: '2 mouvements rythmés.',
        icon: Icons.directions_walk_rounded,
        categoryLabel: 'Action & Déplacement',
        isKnownSign: true,
      ),
    ),

    // 8. ÉCOLE, LECTURE, ÉCRITURE & OBJETS
    (
      roots: [
        'livr',
        'lire',
        'lisai',
        'lu',
        'histoir',
        'conte',
        'page',
        'cahier',
        'crayon',
        'stylo',
        'ecri',
        'dessin',
        'peint',
        'decouvr',
        'appren',
        'etudi',
        'devoir',
        'lecon',
        'classe',
        'enseign',
        'professeur',
        'maitr',
        'sac',
        'cartabl',
        'table',
        'chaise',
        'bureau',
        'tableau',
        'mot',
        'lettre',
        'phrase',
        'nombre',
        'chiffr',
        'calcul',
        'compter',
        'science',
        'ordinateur',
        'tablett',
        'telephone',
        'photo',
        'image',
        'camera',
      ],
      match: LsqSemanticMatch(
        title: 'Ouverture du livre et apprentissage',
        kind: LsqMovementKind.turningPages,
        startPosition: 'Deux mains jointes paumes collées devant soi.',
        trajectoryDescription:
            'Ouvrir les deux paumes vers le haut comme un livre ou un cahier d\'école.',
        repetition: '1 ouverture franche.',
        icon: Icons.menu_book_rounded,
        categoryLabel: 'École & Savoir',
        isKnownSign: true,
      ),
    ),

    // 9. CIEL, SOLEIL, GRANDEUR & ESPACE
    (
      roots: [
        'soleil',
        'ciel',
        'jour',
        'matin',
        'midi',
        'printemps',
        'ete',
        'chaud',
        'grand',
        'gros',
        'haut',
        'geant',
        'immens',
        'large',
        'loin',
        'monde',
        'terre',
        'planet',
        'espac',
        'nuage',
        'air',
        'frais',
        'libre',
        'ouvrir',
        'ouvert',
        'fort',
        'puissant',
        'beaucoup',
        'tous',
        'tout',
      ],
      match: LsqSemanticMatch(
        title: 'Déploiement ample vers le haut',
        kind: LsqMovementKind.sunRaysExpansion,
        startPosition: 'Main devant le front ou le torse.',
        trajectoryDescription:
            'Déployer largement les doigts vers l\'extérieur et le haut pour montrer le ciel ou la grandeur.',
        repetition: '1 déploiement ample.',
        icon: Icons.wb_sunny_rounded,
        categoryLabel: 'Ciel & Grandeur',
        isKnownSign: true,
      ),
    ),

    // 10. MAISON, LIEUX & ABRIS
    (
      roots: [
        'maison',
        'ecole',
        'caban',
        'chambre',
        'cuisine',
        'salon',
        'porte',
        'fenetr',
        'toit',
        'mur',
        'lit',
        'dorm',
        'ville',
        'villag',
        'quebec',
        'canada',
        'pays',
        'montagn',
        'sommet',
        'collin',
        'volcan',
        'grotte',
        'chateau',
        'ferme',
        'magasin',
        'hopital',
        'bibliothequ',
        'pont',
        'dedans',
        'interieur',
        'abri',
        'refug',
      ],
      match: LsqSemanticMatch(
        title: 'Tracé du toit ou du lieu',
        kind: LsqMovementKind.houseRoofTriangle,
        startPosition: 'Bouts des doigts joints au sommet en angle.',
        trajectoryDescription:
            'Descendre les deux mains obliquement pour dessiner un toit, un abri ou une montagne.',
        repetition: '1 descente ferme.',
        icon: Icons.home_rounded,
        categoryLabel: 'Lieu & Maison',
        isKnownSign: true,
      ),
    ),

    // 11. EAU, MÉTÉO, VENT & DOUCEUR
    (
      roots: [
        'eau',
        'eaux',
        'mer',
        'ocean',
        'lac',
        'fleuv',
        'rivier',
        'ruisseau',
        'pluie',
        'pleut',
        'orage',
        'goutt',
        'vague',
        'balein',
        'beluga',
        'dauphin',
        'poisson',
        'requin',
        'nage',
        'plong',
        'bain',
        'piscin',
        'douc',
        'calme',
        'lent',
        'vent',
        'souffl',
        'tempet',
        'musiqu',
        'chant',
        'chanson',
        'melodi',
        'coul',
        'gliss',
        'tranquill',
        'paix',
        'repos',
      ],
      match: LsqSemanticMatch(
        title: 'Ondulation fluide et calme',
        kind: LsqMovementKind.waterWaveFlow,
        startPosition: 'Main horizontale paume vers le bas.',
        trajectoryDescription:
            'Faire onduler la main en vagues régulières vers l\'avant (eau, pluie, vent ou douceur).',
        repetition: 'Mouvement continu et calme.',
        icon: Icons.waves_rounded,
        categoryLabel: 'Eau & Douceur',
        isKnownSign: true,
      ),
    ),

    // 12. AXE DU TEMPS LSQ (Passé = vers l'arrière, Futur = vers l'avant) & PERCEPTION
    (
      roots: [
        'hier',
        'avant',
        'autrefois',
        'passe',
        'ancien',
        'dernier',
      ],
      match: LsqSemanticMatch(
        title: 'Axe du temps LSQ : Passé (vers l\'arrière)',
        kind: LsqMovementKind.directionalArc,
        startPosition: 'Main ouverte près de l\'épaule.',
        trajectoryDescription:
            'En LSQ, le passé se signe par un arc doux par-dessus l\'épaule vers l\'arrière.',
        repetition: '1 mouvement clair vers l\'arrière.',
        icon: Icons.history_rounded,
        categoryLabel: 'Temps (Passé)',
        isKnownSign: true,
      ),
    ),
    (
      roots: [
        'demain',
        'bientot',
        'apres',
        'futur',
        'prochain',
        'ensuite',
        'puis',
        'toujours',
        'maintenant',
        'aujourd',
        'heure',
        'minute',
        'semaine',
        'mois',
        'annee',
        'temps',
      ],
      match: LsqSemanticMatch(
        title: 'Axe du temps LSQ : Présent & Futur',
        kind: LsqMovementKind.directionalArc,
        startPosition: 'Main devant soi à hauteur de la joue ou du torse.',
        trajectoryDescription:
            'En LSQ, le futur se signe par un arc fluide vers l\'avant (et le présent devant soi).',
        repetition: '1 mouvement clair vers l\'avant.',
        icon: Icons.schedule_rounded,
        categoryLabel: 'Temps (Futur)',
        isKnownSign: true,
      ),
    ),
    (
      roots: [
        'regard',
        'voir',
        'voyai',
        'vu',
        'observ',
        'admir',
        'yeux',
        'oeil',
        'ecout',
        'entend',
        'parl',
        'dire',
        'dit',
        'racont',
        'demand',
        'repond',
        'pens',
        'idee',
        'savoir',
        'sait',
        'compren',
        'cherch',
        'trouv',
        'donn',
        'prend',
        'montr',
        'aid',
      ],
      match: LsqSemanticMatch(
        title: 'Communication & Perception visuelle',
        kind: LsqMovementKind.directionalArc,
        startPosition: 'Main près des yeux, du front ou de la bouche.',
        trajectoryDescription:
            'Diriger la main vers l\'avant depuis les yeux (regarder), le front (penser) ou la bouche (dire).',
        repetition: '1 à 2 mouvements nets.',
        icon: Icons.visibility_rounded,
        categoryLabel: 'Perception & Langage',
        isKnownSign: true,
      ),
    ),
  ];

  /// Normalise un mot français en minuscules sans accents pour la recherche par racine
  static String _normalize(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('œ', 'oe')
        .replaceAll(RegExp(r'[^a-z\-]'), '')
        .trim();
  }

  /// Analyse n'importe quel mot (pré-chargé ou scanné d'une photo OCR) et retourne
  /// son mouvement LSQ sémantique, ou marque `isKnownSign: false` pour déclencher
  /// l'épellation automatique en dactylologie LSQ (fidèle à la vraie langue des signes).
  static LsqSemanticMatch analyze(String rawWord) {
    final normalized = _normalize(rawWord);
    if (normalized.length < 2) {
      return _dactylologyFallback;
    }

    for (final family in _families) {
      for (final root in family.roots) {
        if (normalized == root ||
            (root.length >= 4 && normalized.contains(root)) ||
            (root.length >= 3 && normalized.startsWith(root))) {
          return family.match;
        }
      }
    }

    return _dactylologyFallback;
  }

  static const LsqSemanticMatch _dactylologyFallback = LsqSemanticMatch(
    title: 'Épellation manuelle LSQ (Dactylologie)',
    kind: LsqMovementKind.directionalArc,
    startPosition:
        'Main levée à hauteur de l\'épaule, paume face à l\'interlocuteur.',
    trajectoryDescription:
        'Pour ce mot précis ou nom propre, on l\'épelle lettre par lettre avec l\'alphabet manuel LSQ.',
    repetition: '1 signe de main par lettre.',
    icon: Icons.sign_language_rounded,
    categoryLabel: 'Épellation A-Z',
    isKnownSign: false,
  );
}
