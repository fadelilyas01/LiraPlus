import 'package:flutter/material.dart';

/// Entrée de dictionnaire multimodale et FALC (Français Facile à Lire et à Comprendre)
class FalcWordEntry {
  final String word;
  final String falcDefinition;
  final String exampleSentence;
  final IconData icon;
  final String lsqSignTitle;
  final String lsqDescription;

  const FalcWordEntry({
    required this.word,
    required this.falcDefinition,
    required this.exampleSentence,
    required this.icon,
    required this.lsqSignTitle,
    required this.lsqDescription,
  });
}

/// Question éclair de compréhension bienveillante en fin d'histoire
class ComprehensionQuestion {
  final String question;
  final List<({String label, IconData icon})> choices;
  final int correctIndex;
  final String encouragement;

  const ComprehensionQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.encouragement,
  });
}

/// Dictionnaire pédagogique embarqué 100 % hors ligne
class FalcDictionary {
  FalcDictionary._();

  /// Vérifie si un mot possède une entrée illustrée directe dans le dictionnaire FALC
  static bool hasEntry(String rawWord) {
    final clean = rawWord
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '')
        .trim();
    return _entries.containsKey(clean);
  }

  /// Retourne une Question Éclair adaptée au texte en cours de lecture
  static ComprehensionQuestion getQuestionForText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('oiseaux') && lower.contains('sapins')) {
      return const ComprehensionQuestion(
        question: 'Que font les oiseaux au-dessus des sapins ?',
        choices: [
          (label: 'Ils volent doucement', icon: Icons.flutter_dash),
          (label: 'Ils nagent dans la mer', icon: Icons.waves_rounded),
          (label: 'Ils dorment dans un lit', icon: Icons.bedtime_rounded),
        ],
        correctIndex: 0,
        encouragement: 'Bravo ! Les oiseaux volent doucement dans le ciel.',
      );
    }
    if (lower.contains('étoile') && lower.contains('neige')) {
      return const ComprehensionQuestion(
        question: 'Qu\'est-ce qui brille très fort dans la nuit d\'hiver ?',
        choices: [
          (label: 'Un gros camion', icon: Icons.local_shipping_rounded),
          (label: 'Une belle étoile', icon: Icons.star_rounded),
          (label: 'Un parapluie rouge', icon: Icons.umbrella_rounded),
        ],
        correctIndex: 1,
        encouragement: 'Super ! Une belle étoile brille sur la neige blanche.',
      );
    }
    if (lower.contains('rentrée') && lower.contains('école')) {
      return const ComprehensionQuestion(
        question: 'Que découvrent les enfants dans leur sac d\'école ?',
        choices: [
          (label: 'Des livres colorés', icon: Icons.menu_book_rounded),
          (label: 'Des poissons rouges', icon: Icons.set_meal_rounded),
          (label: 'Des ballons de plage', icon: Icons.beach_access_rounded),
        ],
        correctIndex: 0,
        encouragement:
            'Exactement ! Ils découvrent leurs nouveaux livres colorés.',
      );
    }
    if (lower.contains('saint-hilaire') || lower.contains('clairière')) {
      return const ComprehensionQuestion(
        question: 'Quels animaux les explorateurs observent-ils ?',
        choices: [
          (label: 'Des éléphants', icon: Icons.pets_rounded),
          (label: 'Des cerfs de Virginie', icon: Icons.forest_rounded),
          (label: 'Des dauphins', icon: Icons.water_rounded),
        ],
        correctIndex: 1,
        encouragement:
            'Bravo explorateur ! Ils observent les cerfs de Virginie.',
      );
    }
    if (lower.contains('baleines') || lower.contains('bélugas')) {
      return const ComprehensionQuestion(
        question: 'Où nagent les bélugas blancs et les baleines bleues ?',
        choices: [
          (label: 'Dans le fleuve Saint-Laurent', icon: Icons.waves_rounded),
          (label: 'Dans une forêt de sapins', icon: Icons.park_rounded),
          (label: 'Dans une cour d\'école', icon: Icons.school_rounded),
        ],
        correctIndex: 0,
        encouragement: 'Magnifique ! Ils nagent dans le fleuve Saint-Laurent.',
      );
    }
    return const ComprehensionQuestion(
      question: 'Comment t\'es-tu senti en lisant ce texte ?',
      choices: [
        (
          label: 'Fier et content !',
          icon: Icons.sentiment_very_satisfied_rounded
        ),
        (label: 'J\'ai appris des mots', icon: Icons.lightbulb_rounded),
        (
          label: 'Prêt pour une autre histoire',
          icon: Icons.auto_stories_rounded
        ),
      ],
      correctIndex: 0,
      encouragement: 'Chaque mot lu te rend encore plus fort !',
    );
  }

  static final Map<String, FalcWordEntry> _entries = {
    // --- ANIMAUX & NATURE ---
    'oiseaux': const FalcWordEntry(
      word: 'oiseaux',
      falcDefinition:
          'Un oiseau est un animal avec deux ailes et des plumes. Il a un bec et il pond des œufs. La plupart des oiseaux volent dans le ciel.',
      exampleSentence: 'Les oiseaux chantent dans les arbres le matin.',
      icon: Icons.flutter_dash,
      lsqSignTitle: 'Signe LSQ : Oiseau',
      lsqDescription:
          'L\'index et le pouce forment un bec près de la bouche qui s\'ouvre et se ferme deux fois, puis les mains battent comme des ailes.',
    ),
    'oiseau': const FalcWordEntry(
      word: 'oiseau',
      falcDefinition:
          'Un oiseau est un animal qui a des plumes et deux ailes. Il pond des œufs et vole souvent dans le ciel.',
      exampleSentence: 'Le petit oiseau mange des graines.',
      icon: Icons.flutter_dash,
      lsqSignTitle: 'Signe LSQ : Oiseau',
      lsqDescription:
          'L\'index et le pouce forment un bec près de la bouche qui s\'ouvre et se ferme deux fois.',
    ),
    'chat': const FalcWordEntry(
      word: 'chat',
      falcDefinition:
          'Le chat est un petit animal de compagnie à poils doux. Il a des moustaches, quatre pattes et il fait « miaou » quand il est content.',
      exampleSentence: 'Le chat dort doucement sur le coussin.',
      icon: Icons.pets_rounded,
      lsqSignTitle: 'Signe LSQ : Chat',
      lsqDescription:
          'Le pouce et l\'index caressent les moustaches imaginaires de chaque côté de la joue en s\'écartant.',
    ),
    'chats': const FalcWordEntry(
      word: 'chats',
      falcDefinition:
          'Les chats sont des animaux agiles qui aiment chasser et faire la sieste au soleil.',
      exampleSentence: 'Les chats jouent dans le jardin.',
      icon: Icons.pets_rounded,
      lsqSignTitle: 'Signe LSQ : Chats',
      lsqDescription:
          'Mimer les moustaches avec les deux mains de chaque côté du visage deux fois de suite.',
    ),
    'chien': const FalcWordEntry(
      word: 'chien',
      falcDefinition:
          'Le chien est un animal fidèle et affectueux. Il a quatre pattes, une queue qui remue et il aboie pour communiquer.',
      exampleSentence: 'Le chien court après la balle dans l\'herbe.',
      icon: Icons.pets_rounded,
      lsqSignTitle: 'Signe LSQ : Chien',
      lsqDescription:
          'La main droite tape doucement deux fois sur la cuisse comme pour appeler un chien vers soi.',
    ),
    'arbre': const FalcWordEntry(
      word: 'arbre',
      falcDefinition:
          'Un arbre est une grande plante avec un tronc en bois solide et des branches pleines de feuilles vertes.',
      exampleSentence: 'L\'arbre donne de l\'ombre fraîche en été.',
      icon: Icons.park_rounded,
      lsqSignTitle: 'Signe LSQ : Arbre',
      lsqDescription:
          'L\'avant-bras dressé verticalement représente le tronc. La main ouverte s\'agite doucement pour imiter les branches et le vent.',
    ),
    'arbres': const FalcWordEntry(
      word: 'arbres',
      falcDefinition:
          'Les arbres sont de grandes plantes de la forêt avec du bois solide et des feuilles.',
      exampleSentence: 'Les arbres de la forêt sont très hauts et majestueux.',
      icon: Icons.forest_rounded,
      lsqSignTitle: 'Signe LSQ : Arbres / Forêt',
      lsqDescription:
          'L\'avant-bras dressé se déplace de gauche à droite pour montrer plusieurs arbres alignés.',
    ),
    'forêt': const FalcWordEntry(
      word: 'forêt',
      falcDefinition:
          'Une forêt est un très grand terrain couvert de centaines d\'arbres où vivent beaucoup d\'animaux sauvages.',
      exampleSentence: 'Nous nous promenons sur le sentier de la forêt.',
      icon: Icons.forest_rounded,
      lsqSignTitle: 'Signe LSQ : Forêt',
      lsqDescription:
          'Le bras droit dressé se déplace latéralement tandis que les doigts ondulent pour figurer la canopée.',
    ),
    'fleur': const FalcWordEntry(
      word: 'fleur',
      falcDefinition:
          'Une fleur est la partie colorée et parfumée d\'une plante qui s\'ouvre au printemps.',
      exampleSentence: 'La rose est une belle fleur rouge.',
      icon: Icons.local_florist_rounded,
      lsqSignTitle: 'Signe LSQ : Fleur',
      lsqDescription:
          'Le bout des doigts réunis touche doucement un côté du nez puis l\'autre comme pour respirer un parfum délicat.',
    ),
    'fleurs': const FalcWordEntry(
      word: 'fleurs',
      falcDefinition:
          'Les fleurs colorent les champs et les jardins avec du jaune, du rouge et du violet.',
      exampleSentence: 'Les abeilles butinent les jolies fleurs du pré.',
      icon: Icons.local_florist_rounded,
      lsqSignTitle: 'Signe LSQ : Fleurs',
      lsqDescription:
          'Le geste de sentir une fleur répété deux fois avec un sourire.',
    ),
    'étoile': const FalcWordEntry(
      word: 'étoile',
      falcDefinition:
          'Une étoile est un point lumineux et brillant qui éclaire la nuit dans le ciel lointain.',
      exampleSentence: 'La belle étoile brille très fort ce soir.',
      icon: Icons.star_rounded,
      lsqSignTitle: 'Signe LSQ : Étoile',
      lsqDescription:
          'Les deux index pointés vers le haut glissent alternativement l\'un contre l\'autre vers le ciel étoilé.',
    ),
    'étoiles': const FalcWordEntry(
      word: 'étoiles',
      falcDefinition:
          'Les étoiles sont des soleils très éloignés qui forment de jolis dessins dans le ciel nocturne.',
      exampleSentence: 'Nous contemplons les étoiles filantes dans la nuit.',
      icon: Icons.stars_rounded,
      lsqSignTitle: 'Signe LSQ : Étoiles',
      lsqDescription:
          'Les deux index frottent l\'un contre l\'autre en montant vers le ciel pour montrer le scintillement.',
    ),
    'soleil': const FalcWordEntry(
      word: 'soleil',
      falcDefinition:
          'Le soleil est la grande lumière chaude dans le ciel qui nous éclaire pendant la journée.',
      exampleSentence:
          'Le soleil réchauffe la terre et fait pousser les plantes.',
      icon: Icons.wb_sunny_rounded,
      lsqSignTitle: 'Signe LSQ : Soleil',
      lsqDescription:
          'L\'index trace un cercle au-dessus de la tête puis la main s\'ouvre largement vers l\'avant pour rayonner la lumière.',
    ),
    'mer': const FalcWordEntry(
      word: 'mer',
      falcDefinition:
          'La mer est une immense étendue d\'eau salée bleue où nagent les poissons et naviguent les bateaux.',
      exampleSentence: 'Les vagues de la mer roulent sur le sable doré.',
      icon: Icons.waves_rounded,
      lsqSignTitle: 'Signe LSQ : Mer / Océan',
      lsqDescription:
          'Les deux mains à plat ondulent doucement vers l\'avant pour imiter le mouvement des vagues.',
    ),
    'océan': const FalcWordEntry(
      word: 'océan',
      falcDefinition:
          'L\'océan est une mer encore plus vaste qui sépare les grands continents de la Terre.',
      exampleSentence: 'Les baleines traversent l\'océan Pacifique.',
      icon: Icons.water_rounded,
      lsqSignTitle: 'Signe LSQ : Océan',
      lsqDescription:
          'Les deux bras écartés ondulent largement pour évoquer l\'immensité de l\'eau profonde.',
    ),
    'montagne': const FalcWordEntry(
      word: 'montagne',
      falcDefinition:
          'Une montagne est un très haut relief de roche et de terre dont le sommet touche souvent les nuages.',
      exampleSentence:
          'Le sommet de la montagne est recouvert de neige blanche.',
      icon: Icons.landscape_rounded,
      lsqSignTitle: 'Signe LSQ : Montagne',
      lsqDescription:
          'Le dos des deux poings se touche, puis les mains montent en formant une pointe triangulaire élevée.',
    ),
    'érable': const FalcWordEntry(
      word: 'érable',
      falcDefinition:
          'L\'érable est l\'arbre emblématique du Québec et du Canada. Au printemps, sa sève donne le fameux sirop d\'érable à la cabane à sucre.',
      exampleSentence:
          'La feuille d\'érable rouge est le symbole du drapeau canadien.',
      icon: Icons.eco_rounded,
      lsqSignTitle: 'Signe LSQ : Érable / Sirop d\'érable',
      lsqDescription:
          'La main mime la récolte de l\'eau d\'érable qui coule d\'un chalumeau dans un seau en bois.',
    ),
    'neige': const FalcWordEntry(
      word: 'neige',
      falcDefinition:
          'La neige est de l\'eau gelée en petits flocons blancs très légers qui tombent du ciel en hiver.',
      exampleSentence: 'La belle neige blanche recouvre la cour d\'école.',
      icon: Icons.ac_unit_rounded,
      lsqSignTitle: 'Signe LSQ : Neige',
      lsqDescription:
          'Les deux mains ouvertes descendent lentement en oscillant doucement des doigts comme des flocons qui tombent.',
    ),
    'hiver': const FalcWordEntry(
      word: 'hiver',
      falcDefinition:
          'L\'hiver est la saison froide au Québec où l\'on met des mitaines et une tuque pour jouer dehors dans la neige.',
      exampleSentence: 'En hiver, nous construisons un grand fort de neige.',
      icon: Icons.severe_cold_rounded,
      lsqSignTitle: 'Signe LSQ : Hiver / Froid',
      lsqDescription:
          'Les deux poings fermés se serrent devant la poitrine et tremblent légèrement comme si on grelottait de froid.',
    ),
    'fleuve': const FalcWordEntry(
      word: 'fleuve',
      falcDefinition:
          'Le fleuve Saint-Laurent est une immense étendue d\'eau navigable qui traverse le Québec d\'un bout à l\'autre.',
      exampleSentence:
          'Les bateaux naviguent sur le grand fleuve Saint-Laurent.',
      icon: Icons.water_rounded,
      lsqSignTitle: 'Signe LSQ : Fleuve / Rivière',
      lsqDescription:
          'Les deux mains ouvertes serpentent parallèlement vers l\'avant pour tracer le lit sinueux d\'un cours d\'eau majestueux.',
    ),
    'baleine': const FalcWordEntry(
      word: 'baleine',
      falcDefinition:
          'La baleine est un immense mammifère marin qui nage dans le fleuve Saint-Laurent et souffle de l\'eau en surface.',
      exampleSentence:
          'À Tadoussac, nous apercevons le dos d\'une baleine bleue.',
      icon: Icons.sailing_rounded,
      lsqSignTitle: 'Signe LSQ : Baleine',
      lsqDescription:
          'Le bras ondule comme le dos d\'un cétacé qui plonge, puis la main s\'ouvre au sommet pour imiter le souffle d\'eau.',
    ),

    // --- ÉCOLE & APPRENTISSAGE ---
    'enfants': const FalcWordEntry(
      word: 'enfants',
      falcDefinition:
          'Les enfants sont des garçons et des filles qui grandissent et qui apprennent à l\'école.',
      exampleSentence: 'Les enfants lisent un livre ensemble.',
      icon: Icons.child_care_rounded,
      lsqSignTitle: 'Signe LSQ : Enfants',
      lsqDescription:
          'La main droite à plat tapote deux fois dans l\'air à hauteur d\'un enfant pour indiquer la taille.',
    ),
    'enfant': const FalcWordEntry(
      word: 'enfant',
      falcDefinition:
          'Un enfant est un jeune garçon ou une jeune fille qui va à l\'école pour apprendre et s\'épanouir.',
      exampleSentence: 'L\'enfant regarde les étoiles avec émerveillement.',
      icon: Icons.face_rounded,
      lsqSignTitle: 'Signe LSQ : Enfant',
      lsqDescription:
          'La main à plat tapote doucement une fois dans l\'air à hauteur d\'un enfant.',
    ),
    'école': const FalcWordEntry(
      word: 'école',
      falcDefinition:
          'L\'école est le lieu où les élèves vont pour apprendre à lire, écrire, compter et jouer avec leurs amis.',
      exampleSentence:
          'À l\'école, nous écoutons les histoires de notre enseignante.',
      icon: Icons.school_rounded,
      lsqSignTitle: 'Signe LSQ : École',
      lsqDescription:
          'Les deux mains ouvertes tapotent l\'une contre l\'autre deux fois horizontalement.',
    ),
    'classe': const FalcWordEntry(
      word: 'classe',
      falcDefinition:
          'La classe est la salle de travail de l\'école avec des bureaux, des chaises et un tableau.',
      exampleSentence:
          'Dans la classe, nous travaillons dans le calme et l\'entraide.',
      icon: Icons.meeting_room_rounded,
      lsqSignTitle: 'Signe LSQ : Classe',
      lsqDescription:
          'Les mains forment la lettre C des deux côtés puis se rejoignent pour délimiter l\'espace d\'une pièce.',
    ),
    'livre': const FalcWordEntry(
      word: 'livre',
      falcDefinition:
          'Un livre est un ensemble de feuilles de papier reliées avec des mots et des images pour raconter des histoires.',
      exampleSentence: 'J\'ouvre mon livre de lecture avec plaisir.',
      icon: Icons.menu_book_rounded,
      lsqSignTitle: 'Signe LSQ : Livre',
      lsqDescription:
          'Les deux paumes jointes s\'ouvrent vers le haut comme les deux pages d\'un livre qu\'on consulte.',
    ),
    'livres': const FalcWordEntry(
      word: 'livres',
      falcDefinition:
          'Les livres contiennent des connaissances, des contes et des poésies du monde entier.',
      exampleSentence:
          'Les étagères de la bibliothèque sont pleines de livres passionnants.',
      icon: Icons.library_books_rounded,
      lsqSignTitle: 'Signe LSQ : Livres',
      lsqDescription:
          'Ouvrir les deux paumes jointes deux fois pour désigner plusieurs ouvrages.',
    ),
    'histoire': const FalcWordEntry(
      word: 'histoire',
      falcDefinition:
          'Une histoire est un récit d\'aventures réelles ou imaginaires qu\'on lit ou qu\'on écoute avec passion.',
      exampleSentence:
          'Ce soir, grand-mère nous raconte une histoire formidable.',
      icon: Icons.auto_stories_rounded,
      lsqSignTitle: 'Signe LSQ : Histoire / Conte',
      lsqDescription:
          'Le pouce et l\'index réunis des deux mains s\'écartent de la bouche vers l\'avant avec un mouvement circulaire.',
    ),
    'musique': const FalcWordEntry(
      word: 'musique',
      falcDefinition:
          'La musique est un ensemble harmonieux de sons, de rythmes et de mélodies agréables à entendre.',
      exampleSentence: 'La musique douce nous aide à nous concentrer.',
      icon: Icons.music_note_rounded,
      lsqSignTitle: 'Signe LSQ : Musique',
      lsqDescription:
          'L\'avant-bras gauche est tendu, et la main droite effectue des allers-retours au-dessus comme le chef d\'orchestre.',
    ),
    'ami': const FalcWordEntry(
      word: 'ami',
      falcDefinition:
          'Un ami est une personne qu\'on aime beaucoup, en qui on a confiance et avec qui on partage ses jeux.',
      exampleSentence: 'Mon meilleur ami m\'aide quand j\'ai une question.',
      icon: Icons.favorite_rounded,
      lsqSignTitle: 'Signe LSQ : Ami',
      lsqDescription:
          'Les deux index courbés s\'accrochent l\'un dans l\'autre, d\'abord dans un sens puis dans l\'autre.',
    ),
    'amis': const FalcWordEntry(
      word: 'amis',
      falcDefinition:
          'Les amis forment un groupe bienveillant où chacun est respecté et soutenu.',
      exampleSentence: 'Tous les amis rient ensemble pendant la récréation.',
      icon: Icons.people_rounded,
      lsqSignTitle: 'Signe LSQ : Amis',
      lsqDescription:
          'Les index s\'accrochent fermement deux fois pour sceller le lien d\'amitié.',
    ),
    'famille': const FalcWordEntry(
      word: 'famille',
      falcDefinition:
          'La famille réunit les parents, les enfants, les grands-parents et les personnes qui prennent soin les unes des autres.',
      exampleSentence: 'Toute la famille se réunit le dimanche midi.',
      icon: Icons.family_restroom_rounded,
      lsqSignTitle: 'Signe LSQ : Famille',
      lsqDescription:
          'Les deux mains forment la lettre F et tracent un cercle horizontal pour se rejoindre, formant un cercle protecteur.',
    ),
    'maison': const FalcWordEntry(
      word: 'maison',
      falcDefinition:
          'La maison est un bâtiment où l\'on habite en sécurité et en paix avec sa famille.',
      exampleSentence: 'Notre maison a un joli jardin fleuri.',
      icon: Icons.home_rounded,
      lsqSignTitle: 'Signe LSQ : Maison',
      lsqDescription:
          'Le bout des doigts des deux mains se touche en angle pour former le toit triangulaire d\'une maison.',
    ),
    'château': const FalcWordEntry(
      word: 'château',
      falcDefinition:
          'Un château est un très grand palais en pierre avec des tours et des créneaux construit il y a longtemps.',
      exampleSentence: 'Les rois et les reines vivaient dans ce grand château.',
      icon: Icons.fort_rounded,
      lsqSignTitle: 'Signe LSQ : Château',
      lsqDescription:
          'Les mains dressées figurent les hautes tours de pierre de chaque côté du corps.',
    ),

    // --- MOTS CLÉS DU QUOTIDIEN ---
    'doucement': const FalcWordEntry(
      word: 'doucement',
      falcDefinition:
          'Faire quelque chose doucement, c\'est le faire avec calme, gentillesse et sans bruit ni violence.',
      exampleSentence: 'Le chat marche doucement sur le tapis.',
      icon: Icons.spa_rounded,
      lsqSignTitle: 'Signe LSQ : Doucement / Calme',
      lsqDescription:
          'Les deux mains à plat descendent lentement vers le sol avec un mouvement doux et apaisé.',
    ),
    'merveilleux': const FalcWordEntry(
      word: 'merveilleux',
      falcDefinition:
          'Quelque chose de merveilleux est tellement beau, étonnant et réussi qu\'il procure une grande joie.',
      exampleSentence: 'Ce conte de fées se termine par un moment merveilleux.',
      icon: Icons.auto_awesome_rounded,
      lsqSignTitle: 'Signe LSQ : Merveilleux / Magique',
      lsqDescription:
          'Les deux mains ouvertes près du visage s\'agitent doucement en montant avec une expression radieuse.',
    ),
    'courage': const FalcWordEntry(
      word: 'courage',
      falcDefinition:
          'Le courage est la force intérieure qui nous permet de surmonter la peur et d\'essayer même quand c\'est difficile.',
      exampleSentence:
          'Avec du courage et de la persévérance, tu vas réussir à lire ce texte.',
      icon: Icons.fitness_center_rounded,
      lsqSignTitle: 'Signe LSQ : Courage',
      lsqDescription:
          'Les deux poings fermés se serrent fermement devant la poitrine en descendant avec détermination.',
    ),
    'liraplus': const FalcWordEntry(
      word: 'liraplus',
      falcDefinition:
          'LiraPlus est ton ami sur la tablette ou le téléphone pour t\'aider à lire tous les mots sans stress.',
      exampleSentence:
          'Avec LiraPlus, je découvre le plaisir de lire en toute autonomie.',
      icon: Icons.auto_stories_rounded,
      lsqSignTitle: 'Signe LSQ : Lire ensemble',
      lsqDescription:
          'Les deux doigts en V balayent la paume de l\'autre main comme des yeux qui suivent une ligne de texte avec fluidité.',
    ),
  };

  /// Recherche une entrée FALC pour un mot (insensible à la casse)
  static FalcWordEntry getEntry(String rawWord) {
    final clean = rawWord
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '')
        .trim();

    if (_entries.containsKey(clean)) {
      return _entries[clean]!;
    }

    // Définition générique FALC automatique pour tout autre mot
    return FalcWordEntry(
      word: clean,
      falcDefinition:
          'Ce mot fait partie de ton texte. Lis chaque syllabe l\'une après l\'autre pour bien entendre le son complet.',
      exampleSentence:
          'Prends ton temps pour prononcer chaque partie avec calme.',
      icon: Icons.translate_rounded,
      lsqSignTitle: 'Épellation LSQ (Dactylologie)',
      lsqDescription:
          'Pour les mots non répertoriés, épelle chaque lettre avec l\'alphabet manuel en langue des signes.',
    );
  }

  /// Textes pédagogiques québécois pré-chargés et gradués par cycles du primaire (MEQ)
  static const List<Map<String, String>> sampleTexts = [
    {
      'title': '1. Les oiseaux de la forêt boréale (1er cycle - 1re année)',
      'text':
          'Les oiseaux volent doucement au-dessus des grands sapins et des érables. Un enfant regarde le ciel avec un grand sourire. Les petits geais bleus mangent des graines dorées près de la cabane au Québec.',
    },
    {
      'title': '2. L\'étoile dans la nuit d\'hiver (1er cycle - 2e année)',
      'text':
          'Dans la nuit d\'hiver calme, une belle étoile brille très fort sur la neige blanche. Deux amis marchent vers la maison en chantant. Le vent souffle doucement sur les fenêtres illuminées.',
    },
    {
      'title': '3. La rentrée à l\'école québécoise (2e cycle - 3e année)',
      'text':
          'C\'est le matin de la rentrée à l\'école primaire au Québec. Les enfants ouvrent leur sac d\'école et découvrent leurs nouveaux livres colorés. L\'enseignante sourit et souhaite une merveilleuse année scolaire à toute la classe.',
    },
    {
      'title': '4. Le secret du mont Saint-Hilaire (2e cycle - 4e année)',
      'text':
          'Au sommet de la montagne, un sentier de pierre mène à une clairière où coulent des ruisseaux d\'eau pure. Deux explorateurs courageux avancent pas à pas. Ils observent les cerfs de Virginie agiles et respirent le grand air frais.',
    },
    {
      'title':
          '5. Les baleines du fleuve Saint-Laurent (3e cycle - 5e/6e année)',
      'text':
          'Au large de Tadoussac, dans les eaux profondes du fleuve Saint-Laurent, des bélugas blancs et de grandes baleines bleues nagent gracieusement. Les jeunes observateurs admirent le souffle puissant des cétacés sous le soleil étincelant.',
    },
    {
      'title': '6. Bienvenue sur LiraPlus ! (Guide de l\'élève québécois)',
      'text':
          'Bienvenue dans LiraPlus ! Appuie sur un mot pour l\'écouter avec le rythme des syllabes et la voix québécoise. Découvre la dactylologie en Langue des Signes Québécoise (LSQ) et la caméra magique pour numériser ton manuel scolaire sans aucune connexion internet.',
    },
  ];
}
