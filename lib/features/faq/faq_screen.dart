import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/accessibility_provider.dart';
import '../../core/theme/accessibility_themes.dart';

/// Modèle d'un élément de FAQ pour parents et éducateurs
class FaqItem {
  final String category;
  final String question;
  final String shortAnswer;
  final List<String> steps;
  final IconData icon;

  const FaqItem({
    required this.category,
    required this.question,
    required this.shortAnswer,
    required this.steps,
    required this.icon,
  });
}

/// Écran complet du Guide & FAQ Parents pour résoudre les difficultés d'apprentissage
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'Tous',
    '🔊 Son & Voix',
    '🤟 Enfant Sourd',
    '📖 Dyslexie',
    '📷 Scanner Livre',
    '🔒 Sécurité & Hors-Ligne',
  ];

  static const List<FaqItem> _faqList = [
    // --- 🔊 SON & SYNTHÈSE VOCALE ---
    FaqItem(
      category: '🔊 Son & Voix',
      icon: Icons.volume_off_rounded,
      question: 'Le son ne sort pas / Mon enfant n\'entend rien',
      shortAnswer:
          'Dans 95 % des cas, le volume des médias est à zéro ou le pack de voix française n\'est pas installé sur Android.',
      steps: [
        'Sur Android : Appuyez sur le bouton volume, touchez les trois points « ... » et montez la jauge « Multimédia / Média » (et pas seulement la sonnerie).',
        'Sur Android : Allez dans Paramètres > Système > Langues et saisie > Sortie de synthèse vocale. Choisissez « Services pour la parole de Google » et téléchargez la voix Français (Canada).',
        'Sur iPhone / iPad : Vérifiez que le volume multimédia est monté dans le Centre de contrôle.',
        'Vérifiez que votre casque ou écouteurs Bluetooth ne sont pas connectés dans une autre pièce.',
      ],
    ),
    FaqItem(
      category: '🔊 Son & Voix',
      icon: Icons.speed_rounded,
      question: 'La voix parle trop vite ou trop lentement pour mon enfant',
      shortAnswer:
          'Vous pouvez ajuster la vitesse vocale de 0.4x (très lent pour débuter) jusqu\'à 1.2x.',
      steps: [
        'Dans le lecteur, appuyez sur l\'icône des réglages (les curseurs en haut à droite).',
        'Repérez la ligne « Vitesse vocale » et utilisez les boutons « - » ou « + » pour trouver le tempo idéal.',
        'Pour un enfant qui débute l\'apprentissage, nous recommandons une vitesse entre 0.6x et 0.8x.',
      ],
    ),
    FaqItem(
      category: '🔊 Son & Voix',
      icon: Icons.replay_rounded,
      question: 'Comment faire répéter un seul mot difficile ?',
      shortAnswer:
          'LiraPlus permet une écoute ciblée mot par mot sans relire tout le texte.',
      steps: [
        'Touchez simplement le mot avec le doigt : il sera prononcé lentement avec une vibration rythmée par syllabe.',
        'Pour une analyse complète : maintenez votre doigt appuyé sur le mot pendant une seconde pour ouvrir la fiche pédagogique « Coach Mot ».',
      ],
    ),

    // --- 🤟 ENFANT SOURD / LSQ ---
    FaqItem(
      category: '🤟 Enfant Sourd',
      icon: Icons.sign_language_rounded,
      question:
          'Mon enfant est sourd, comment LiraPlus peut-il l\'aider à lire ?',
      shortAnswer:
          'Pour un enfant sourd, le français écrit est appris par la vision, la dactylologie et le toucher, et non par le son.',
      steps: [
        'Activez le profil « LSQ / Sourd » dans la barre du haut : l\'interface passe en contraste sombre reposant et active les retours haptiques.',
        'Ouvrez la fiche d\'un mot : l\'onglet « Dactylologie » affiche chaque lettre avec sa véritable position de main en langue des signes.',
        'L\'enfant peut appuyer sur « Épeler lettre par lettre » pour mémoriser l\'orthographe visuelle du mot.',
        'La fiche fournit également la description du signe complet en LSQ (Langue des Signes Québécoise) et un pictogramme universel.',
      ],
    ),
    FaqItem(
      category: '🤟 Enfant Sourd',
      icon: Icons.vibration_rounded,
      question: 'À quoi servent les vibrations haptiques pour un élève sourd ?',
      shortAnswer:
          'Les vibrations remplacent la voix et permettent à l\'enfant de ressentir physiquement le rythme des syllabes.',
      steps: [
        'Lorsqu\'un mot est épelé ou lu, le téléphone émet une vibration légère pour les syllabes douces et une vibration plus forte sur la dernière syllabe.',
        'Cela aide l\'enfant à comprendre la structure rythmique du français écrit sans avoir besoin d\'entendre.',
      ],
    ),

    // --- 📖 DYSLEXIE & BASSE VISION ---
    FaqItem(
      category: '📖 Dyslexie',
      icon: Icons.spellcheck_rounded,
      question: 'Pourquoi les syllabes changent-elles de couleur ?',
      shortAnswer:
          'L\'alternance bleu et violet aide le cerveau dyslexique à segmenter les sons et supprime l\'effet d\'embouteillage visuel.',
      steps: [
        'Les enfants dyslexiques confondent souvent les lettres proches (b/d, p/q) dans les longs mots.',
        'La coloration syllabique découpe visuellement le mot en morceaux faciles à décoder l\'un après l\'autre.',
        'Vous pouvez désactiver cette option à tout moment dans les réglages si votre enfant préfère un texte uni.',
      ],
    ),
    FaqItem(
      category: '📖 Dyslexie',
      icon: Icons.view_headline_rounded,
      question: 'Mon enfant saute souvent des lignes en lisant',
      shortAnswer:
          'Activez la « Règle de lecture horizontale » pour canaliser son attention visuelle.',
      steps: [
        'Dans les réglages, cochez « Règle de lecture horizontale » (elle est active d\'office en mode Dyslexie et Basse Vision).',
        'Une bande lumineuse apparaît sur le texte : votre enfant peut la déplacer avec son doigt pour suivre la ligne exacte en cours de lecture.',
      ],
    ),
    FaqItem(
      category: '📖 Dyslexie',
      icon: Icons.visibility_off_rounded,
      question: 'Pourquoi certaines lettres sont-elles grisées ou atténuées ?',
      shortAnswer:
          'Les lettres muettes finales (comme le « s » du pluriel ou « ent » des verbes) sont grisées pour éviter les erreurs de prononciation.',
      steps: [
        'En français, beaucoup de lettres écrites ne se prononcent pas (chats, chantent, oiseau).',
        'LiraPlus atténue automatiquement ces lettres pour rassurer l\'enfant : il sait immédiatement quelles lettres font du son et lesquelles sont silencieuses.',
      ],
    ),

    // --- 📷 SCANNER UN LIVRE SCOLAIRE ---
    FaqItem(
      category: '📷 Scanner Livre',
      icon: Icons.camera_alt_rounded,
      question: 'La caméra ne détecte pas le texte de la page',
      shortAnswer:
          'La reconnaissance de texte sur l\'appareil (Edge AI) nécessite un bon éclairage et une page bien plane.',
      steps: [
        'Posez le livre bien à plat sur une table bien éclairée (évitez les ombres de vos mains ou de votre téléphone).',
        'Tenez l\'appareil parallèle à la page à environ 20-30 cm de distance.',
        'Assurez-vous que le texte n\'est pas flou avant d\'appuyer sur le déclencheur.',
        'Une fois le texte extrait, vous pouvez le modifier au clavier pour corriger un mot avant de lancer la lecture.',
      ],
    ),

    // --- 🔒 SÉCURITÉ & HORS-LIGNE ---
    FaqItem(
      category: '🔒 Sécurité & Hors-Ligne',
      icon: Icons.security_rounded,
      question: 'Les photos ou textes de mon enfant vont-ils sur internet ?',
      shortAnswer:
          'Non, JAMAIS. LiraPlus est 100 % hors ligne et respecte rigoureusement la Loi 25 du Québec sur les renseignements personnels.',
      steps: [
        'Conformité Loi 25 (Québec) : Aucun compte utilisateur, aucun mot de passe et aucun identifiant scolaire ne sont requis.',
        'Traitement 100 % local (Edge AI) : Les photos de pages de manuels et l\'extraction OCR restent enfermées dans la mémoire vive de l\'appareil.',
        'Zéro transfert transfrontalier : Aucune donnée d\'élève n\'est téléversée sur des serveurs externes ou dans le nuage (cloud).',
        'Recommandé pour les plans d\'intervention (PI) des élèves HDAA dans les Centres de services scolaires (CSS) du Québec.',
        'L\'application fonctionne parfaitement en mode avion, dans l\'autobus scolaire ou dans les régions éloignées sans Wi-Fi.',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaq {
    return _faqList.where((item) {
      final matchesCategory =
          _selectedCategory == 'Tous' || item.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.shortAnswer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AccessibilityProvider>().settings;
    final colors = settings.colors;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Guide & FAQ Parents',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isLowVision ? 22 : 18,
          ),
        ),
        leading: Semantics(
          label: 'Fermer le guide et retourner au lecteur',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                // 1. Barre de recherche de question
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: colors.surface,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: TextStyle(color: colors.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText:
                          'Rechercher un problème (ex: son, sourd, règle)...',
                      hintStyle: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.8),
                          fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: colors.accent),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              color: colors.textSecondary,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 2. Filtres par catégorie
                Container(
                  height: 48,
                  color: colors.surface,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected
                                  ? colors.background
                                  : colors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: colors.accent,
                          backgroundColor: colors.surfaceVariant,
                          side: BorderSide(
                            color: isSelected
                                ? colors.accent
                                : colors.border.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),

                // 3. Liste accordéon des questions/réponses
                Expanded(
                  child: _filteredFaq.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.help_outline_rounded,
                                    size: 48, color: colors.textSecondary),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucune réponse trouvée pour cette recherche.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredFaq.length,
                          itemBuilder: (ctx, idx) {
                            final item = _filteredFaq[idx];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Material(
                                color: colors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: isLowVision
                                        ? colors.border
                                        : colors.border.withValues(alpha: 0.6),
                                    width: isLowVision ? 2.0 : 1.0,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colors.accent
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(item.icon,
                                          color: colors.accent, size: 22),
                                    ),
                                    title: Text(
                                      item.question,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item.shortAnswer,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 18,
                                          right: 18,
                                          bottom: 18,
                                          top: 4,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceVariant,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ÉTAPES POUR RÉSOUDRE LE PROBLÈME :',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 1.0,
                                                      color: colors.accent,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...item.steps.map((step) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 6.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '• ',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  colors.accent,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              step,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                height: 1.4,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: colors
                                                                    .textPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
