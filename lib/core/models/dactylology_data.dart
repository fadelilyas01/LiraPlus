import 'package:flutter/material.dart';
import '../../features/reader/presentation/widgets/lsq_handshape_widget.dart';

/// Modèle d'une lettre en dactylologie de la Langue des Signes Québécoise (LSQ)
class DactylologyLetter {
  final String letter;
  final String name;
  final String handDescription;
  final IconData visualIcon;
  final String tipForParents;
  final LsqHandshapeType handshape;
  final bool hasMovement;
  final String exampleWord;
  final String phoneticSound;

  const DactylologyLetter({
    required this.letter,
    required this.name,
    required this.handDescription,
    required this.visualIcon,
    required this.tipForParents,
    required this.handshape,
    this.hasMovement = false,
    this.exampleWord = '',
    this.phoneticSound = '',
  });
}

/// Mot-clé du quotidien scolaire en Langue des Signes Québécoise (LSQ)
class SchoolSignWord {
  final String word;
  final String title;
  final String meaning;
  final String exampleSentence;
  final IconData icon;

  const SchoolSignWord({
    required this.word,
    required this.title,
    required this.meaning,
    required this.exampleSentence,
    required this.icon,
  });
}

/// Référentiel québécois de l'alphabet manuel en Langue des Signes Québécoise (LSQ)
class DactylologyData {
  DactylologyData._();

  static const Map<String, DactylologyLetter> letters = {
    'a': DactylologyLetter(
      letter: 'A',
      name: 'Lettre A',
      handDescription:
          'Poing fermé, les quatre doigts repliés vers la paume et le pouce dressé droit contre le côté de l\'index.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents:
          'Montrez à l\'enfant le pouce bien collé sur le côté du poing.',
      handshape: LsqHandshapeType.fistWithSideThumb,
    ),
    'b': DactylologyLetter(
      letter: 'B',
      name: 'Lettre B',
      handDescription:
          'Les quatre doigts bien tendus et serrés vers le haut, le pouce replié horizontalement sur la paume.',
      visualIcon: Icons.back_hand_rounded,
      tipForParents: 'Les doigts forment un mur plat et bien vertical.',
      handshape: LsqHandshapeType.flatVerticalPalm,
    ),
    'c': DactylologyLetter(
      letter: 'C',
      name: 'Lettre C',
      handDescription:
          'La main forme un arc de cercle ouvert vers la gauche, comme la forme de la lettre C.',
      visualIcon: Icons.radio_button_unchecked_rounded,
      tipForParents:
          'Les doigts et le pouce s\'arrondissent pour imiter un croissant de lune.',
      handshape: LsqHandshapeType.curvedArcC,
    ),
    'd': DactylologyLetter(
      letter: 'D',
      name: 'Lettre D',
      handDescription:
          'L\'index est dressé bien droit vers le haut. Le pouce et les trois autres doigts forment une boucle fermée.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents:
          'L\'index vertical représente la grande barre droite du D.',
      handshape: LsqHandshapeType.indexUpWithLoopD,
    ),
    'e': DactylologyLetter(
      letter: 'E',
      name: 'Lettre E',
      handDescription:
          'Tous les doigts sont recourbés vers le bas, le bout des doigts reposant sur le bord du pouce replié.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Imaginez une petite griffe fermée qui forme les trois barres du E.',
      handshape: LsqHandshapeType.curvedClawE,
    ),
    'f': DactylologyLetter(
      letter: 'F',
      name: 'Lettre F',
      handDescription:
          'Le pouce et l\'index se touchent pour former un cercle. Les trois autres doigts (majeur, annulaire, auriculaire) sont dressés et écartés.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'C\'est le signe universel du « OK », les 3 doigts dressés imitent les plumes.',
      handshape: LsqHandshapeType.okCircleF,
    ),
    'g': DactylologyLetter(
      letter: 'G',
      name: 'Lettre G',
      handDescription:
          'L\'index et le pouce sont tendus parallèlement à l\'horizontale vers l\'avant, les autres doigts repliés.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents: 'La main forme une petite pince orientée vers le côté.',
      handshape: LsqHandshapeType.horizontalPincerG,
    ),
    'h': DactylologyLetter(
      letter: 'H',
      name: 'Lettre H',
      handDescription:
          'L\'index et le majeur sont tendus ensemble à l\'horizontale vers le côté. Le pouce maintient les deux autres doigts repliés.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents:
          'Deux doigts allongés représentent les deux montants reliés du H.',
      handshape: LsqHandshapeType.twoFingersH,
    ),
    'i': DactylologyLetter(
      letter: 'I',
      name: 'Lettre I',
      handDescription:
          'Seul le petit doigt (auriculaire) est dressé verticalement vers le ciel. Tous les autres doigts sont fermés en poing.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents: 'Le petit doigt mince et vertical symbolise la tige du i.',
      handshape: LsqHandshapeType.littleFingerUpI,
    ),
    'j': DactylologyLetter(
      letter: 'J',
      name: 'Lettre J',
      handDescription:
          'Même position que le I (petit doigt levé), puis le petit doigt dessine une petite virgule / crochet dans l\'air.',
      visualIcon: Icons.gesture_rounded,
      tipForParents:
          'L\'enfant trace la boucle du J dans l\'air avec son auriculaire.',
      handshape: LsqHandshapeType.littleFingerHookJ,
      hasMovement: true,
    ),
    'k': DactylologyLetter(
      letter: 'K',
      name: 'Lettre K',
      handDescription:
          'L\'index est levé, le majeur s\'écarte vers l\'avant et le pouce s\'insère entre les deux à la base.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Les doigts dessinent la silhouette des branches obliques du K.',
      handshape: LsqHandshapeType.kShapeWithMiddleThumb,
    ),
    'l': DactylologyLetter(
      letter: 'L',
      name: 'Lettre L',
      handDescription:
          'L\'index est dressé vers le haut et le pouce est écarté à l\'horizontale, formant un angle droit parfait à 90 degrés.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents:
          'La forme du L majuscule est parfaitement visible entre l\'index et le pouce.',
      handshape: LsqHandshapeType.lShapeRightAngle,
    ),
    'm': DactylologyLetter(
      letter: 'M',
      name: 'Lettre M',
      handDescription:
          'Les trois doigts (index, majeur, annulaire) sont repliés vers le bas par-dessus le pouce caché dessous.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Les 3 doigts qui tombent imitent les trois ponts de la lettre M.',
      handshape: LsqHandshapeType.threeFingersDownM,
    ),
    'n': DactylologyLetter(
      letter: 'N',
      name: 'Lettre N',
      handDescription:
          'Deux doigts seulement (index et majeur) retombent par-dessus le pouce replié.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents: 'Les deux doigts imitent les deux ponts de la lettre N.',
      handshape: LsqHandshapeType.twoFingersDownN,
    ),
    'o': DactylologyLetter(
      letter: 'O',
      name: 'Lettre O',
      handDescription:
          'Tous les bouts des doigts se rejoignent pour toucher le pouce, formant un cercle parfait en O.',
      visualIcon: Icons.radio_button_unchecked_rounded,
      tipForParents:
          'La main forme un œil ou un hublot circulaire transparent.',
      handshape: LsqHandshapeType.circleFingersO,
    ),
    'p': DactylologyLetter(
      letter: 'P',
      name: 'Lettre P',
      handDescription:
          'Même configuration que le K, mais la main est inclinée vers le bas.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents: 'La tige du P pointe vers le sol.',
      handshape: LsqHandshapeType.kShapePointingDownP,
    ),
    'q': DactylologyLetter(
      letter: 'Q',
      name: 'Lettre Q',
      handDescription:
          'Même configuration que le G, mais la pince index-pouce pointe vers le sol.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents:
          'La pince orientée vers le bas imite la petite queue descendante du Q.',
      handshape: LsqHandshapeType.pincerPointingDownQ,
    ),
    'r': DactylologyLetter(
      letter: 'R',
      name: 'Lettre R',
      handDescription:
          'L\'index et le majeur sont levés et s\'entrecroisent fermement (doigts croisés porte-bonheur).',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Dites à l\'enfant de « croiser les doigts » comme pour souhaiter bonne chance.',
      handshape: LsqHandshapeType.crossedFingersR,
    ),
    's': DactylologyLetter(
      letter: 'S',
      name: 'Lettre S',
      handDescription:
          'Poing bien fermé, le pouce venant se croiser fermement par-dessus les doigts repliés.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Le pouce barre le devant des doigts comme une ceinture solide.',
      handshape: LsqHandshapeType.fistFrontThumbS,
    ),
    't': DactylologyLetter(
      letter: 'T',
      name: 'Lettre T',
      handDescription:
          'Le pouce se glisse entre l\'index replié et le majeur du poing fermé.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Le pouce dépasse légèrement entre les deux premiers doigts.',
      handshape: LsqHandshapeType.thumbBetweenT,
    ),
    'u': DactylologyLetter(
      letter: 'U',
      name: 'Lettre U',
      handDescription:
          'L\'index et le majeur sont dressés bien droits et complètement serrés l\'un contre l\'autre vers le ciel.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents: 'Deux doigts jumeaux très serrés qui montent ensemble.',
      handshape: LsqHandshapeType.twoFingersTogetherU,
    ),
    'v': DactylologyLetter(
      letter: 'V',
      name: 'Lettre V',
      handDescription:
          'L\'index et le majeur sont levés et largement écartés en forme de V (signe de la victoire).',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'C\'est le célèbre V de la victoire, facile et très motivant pour l\'enfant.',
      handshape: LsqHandshapeType.vVictorySpread,
    ),
    'w': DactylologyLetter(
      letter: 'W',
      name: 'Lettre W',
      handDescription:
          'Trois doigts sont levés et écartés (index, majeur, annulaire), dessinant les trois branches du W.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents:
          'Trois doigts écartés vers le haut forment le triple sommet du W.',
      handshape: LsqHandshapeType.threeFingersSpreadW,
    ),
    'x': DactylologyLetter(
      letter: 'X',
      name: 'Lettre X',
      handDescription:
          'L\'index est recourbé comme un petit crochet, tous les autres doigts étant fermés.',
      visualIcon: Icons.pan_tool_alt_rounded,
      tipForParents: 'L\'index forme un petit crochet courbé.',
      handshape: LsqHandshapeType.hookedIndexX,
    ),
    'y': DactylologyLetter(
      letter: 'Y',
      name: 'Lettre Y',
      handDescription:
          'Le pouce et le petit doigt sont largement écartés vers l\'extérieur, les 3 doigts du milieu fermés.',
      visualIcon: Icons.pan_tool_rounded,
      tipForParents: 'Les deux cornes extérieures forment le Y.',
      handshape: LsqHandshapeType.hornsThumbLittleY,
    ),
    'z': DactylologyLetter(
      letter: 'Z',
      name: 'Lettre Z',
      handDescription:
          'L\'index est dressé vers l\'avant et trace un Z en zig-zag dans l\'air de gauche à droite.',
      visualIcon: Icons.gesture_rounded,
      tipForParents:
          'L\'enfant trace un éclair en Z dans l\'air avec son index.',
      handshape: LsqHandshapeType.indexZigzagZ,
      hasMovement: true,
    ),
  };

  /// Récupère la lettre dactylologique correspondante (ignorant la casse et les accents)
  static DactylologyLetter? getLetter(String char) {
    if (char.isEmpty) return null;
    final normalized = _removeDiacritics(char.toLowerCase());
    return letters[normalized];
  }

  /// Convertit un mot complet en suite de lettres dactylologiques LSQ
  static List<DactylologyLetter> wordToDactylology(String word) {
    final List<DactylologyLetter> result = [];
    for (int i = 0; i < word.length; i++) {
      final letter = getLetter(word[i]);
      if (letter != null) {
        result.add(letter);
      }
    }
    return result;
  }

  /// Mots-clés incontournables du quotidien scolaire et des premiers récits (LSQ)
  static const List<SchoolSignWord> schoolWords = [
    SchoolSignWord(
      word: 'bonjour',
      title: 'Bonjour',
      meaning: 'Saluer avec la main ouverte qui part du menton vers l\'avant.',
      exampleSentence: 'Bonjour tout le monde !',
      icon: Icons.waving_hand_rounded,
    ),
    SchoolSignWord(
      word: 'merci',
      title: 'Merci',
      meaning:
          'Le bout des doigts effleure les lèvres puis avance avec gratitude.',
      exampleSentence: 'Merci beaucoup pour ton beau partage.',
      icon: Icons.volunteer_activism_rounded,
    ),
    SchoolSignWord(
      word: 'ami',
      title: 'Ami',
      meaning:
          'Deux index qui s\'entrecroisent et s\'accrochent en signe d\'amitié.',
      exampleSentence: 'Mon ami joue avec moi à la récréation.',
      icon: Icons.people_alt_rounded,
    ),
    SchoolSignWord(
      word: 'chat',
      title: 'Chat',
      meaning:
          'Pouce et index effleurent la joue pour dessiner les moustaches du chat.',
      exampleSentence: 'Le petit chat ronronne sur le coussin.',
      icon: Icons.pets_rounded,
    ),
    SchoolSignWord(
      word: 'oiseau',
      title: 'Oiseau',
      meaning:
          'Pouce et index mimant un bec qui s\'ouvre et les bras battant des ailes.',
      exampleSentence: 'L\'oiseau chante une douce mélodie dans l\'arbre.',
      icon: Icons.flutter_dash_rounded,
    ),
    SchoolSignWord(
      word: 'livre',
      title: 'Livre',
      meaning:
          'Deux paumes jointes qui s\'ouvrent comme les pages d\'un livre illustré.',
      exampleSentence: 'J\'ouvre mon livre pour lire une belle histoire.',
      icon: Icons.menu_book_rounded,
    ),
    SchoolSignWord(
      word: 'arbre',
      title: 'Arbre',
      meaning:
          'L\'avant-bras vertical imite le tronc et la main ouverte ondule comme le feuillage.',
      exampleSentence: 'Le grand arbre a de jolies feuilles vertes.',
      icon: Icons.park_rounded,
    ),
    SchoolSignWord(
      word: 'soleil',
      title: 'Soleil',
      meaning:
          'La main en l\'air s\'ouvre largement en projetant des rayons chaleureux.',
      exampleSentence: 'Le soleil brille et réchauffe toute la cour.',
      icon: Icons.wb_sunny_rounded,
    ),
    SchoolSignWord(
      word: 'maison',
      title: 'Maison',
      meaning:
          'Le bout des doigts des deux mains se touche en pointe pour former le toit.',
      exampleSentence: 'Je rentre à la maison après une journée d\'école.',
      icon: Icons.home_rounded,
    ),
    SchoolSignWord(
      word: 'jouer',
      title: 'Jouer',
      meaning: 'Les mains en forme de Y oscillent joyeusement avec énergie.',
      exampleSentence: 'Nous allons jouer ensemble dans la cour.',
      icon: Icons.sports_esports_rounded,
    ),
  ];

  static String _removeDiacritics(String str) {
    const withDia = 'àâäéèêëîïôöùûüÿç';
    const withoutDia = 'aaaeeeeiioouuuyc';
    var result = str;
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }
}
