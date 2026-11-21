import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/dactylology_data.dart';
import '../../../core/providers/accessibility_provider.dart';
import '../../../core/services/tts_haptic_service.dart';
import 'widgets/alphabet_quiz_sheet.dart';
import 'widgets/lsq_handshape_widget.dart';
import 'widgets/lsq_motion_viewer.dart';
import 'widgets/lsq_speller_player.dart';

/// Grand écran d'étude interactive de l'alphabet manuel LSQ et des mots de l'école
class AlphabetWorkshopScreen extends StatefulWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;

  const AlphabetWorkshopScreen({
    super.key,
    required this.provider,
    required this.ttsService,
  });

  @override
  State<AlphabetWorkshopScreen> createState() => _AlphabetWorkshopScreenState();
}

class _AlphabetWorkshopScreenState extends State<AlphabetWorkshopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isMirrorView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _speakLetter(DactylologyLetter letter) {
    unawaited(HapticFeedback.lightImpact());
    final textToSpeak =
        'Lettre ${letter.letter}. ${letter.name}. Comme dans ${letter.exampleWord}.';
    widget.ttsService.speakWordWithHaptic(
      textToSpeak,
      [letter.letter],
      enableHaptics: widget.provider.settings.hapticFeedbackEnabled,
    );
  }

  void _showLetterDetail(DactylologyLetter letter) {
    _speakLetter(letter);

    final colors = widget.provider.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // En-tête de la lettre (Anti-Overflow garanti)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            letter.letter,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: colors.background,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                letter.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Exemple : ${letter.exampleWord}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.accent,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Bouton d'écoute vocale
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 28),
                          color: colors.accent,
                          tooltip: 'Écouter la lettre',
                          onPressed: () => _speakLetter(letter),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Affichage géant de la main LSQ
                    Center(
                      child: Container(
                        width: 140,
                        height: 155,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: LsqHandshapeWidget(
                          handshape: letter.handshape,
                          color: colors.accent,
                          size: 110,
                          isMirrorView: _isMirrorView,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bascule Vue Miroir
                    Center(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          setState(() => _isMirrorView = !_isMirrorView);
                          setSheetState(() {});
                        },
                        icon: Icon(
                          _isMirrorView
                              ? Icons.pan_tool_rounded
                              : Icons.remove_red_eye_rounded,
                          color: colors.accent,
                          size: 18,
                        ),
                        label: Text(
                          _isMirrorView
                              ? 'Vue : Ma propre main'
                              : 'Vue : En face de moi',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description et conseil aux parents
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comment placer tes doigts :',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            letter.handDescription,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_rounded,
                                  size: 16, color: Colors.amber.shade700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  letter.tipForParents,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSpellerForWord(String word) {
    final colors = widget.provider.colors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Épellation du mot ${word.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary),
                ),
                const SizedBox(height: 14),
                LsqSpellerPlayer(
                  word: word,
                  colors: colors,
                  isMirrorView: _isMirrorView,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.provider.colors;
    final allLetters = DactylologyData.letters.values.toList();
    const schoolWords = DactylologyData.schoolWords;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Alphabet LSQ',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
        actions: [
          // Bouton Quiz bienveillant compact (anti-overflow)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber.shade900,
                backgroundColor: Colors.amber.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => AlphabetQuizSheet.show(context, widget.provider),
              icon: const Icon(Icons.stars_rounded, size: 18),
              label: const Text('Quiz',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.accent,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.accent,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.spellcheck_rounded), text: 'Alphabet A à Z'),
            Tab(icon: Icon(Icons.school_rounded), text: 'Mots de l\'école'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Grille complète des 26 lettres de l'alphabet
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: allLetters.length,
              itemBuilder: (context, index) {
                final letter = allLetters[index];
                final hasMotion = letter.hasMovement;

                return InkWell(
                  onTap: () => _showLetterDetail(letter),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                letter.letter,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: colors.accent,
                                ),
                              ),
                            ),
                            if (hasMotion)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'MOUV.',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Forme de la main
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 48,
                              height: 56,
                              child: LsqHandshapeWidget(
                                handshape: letter.handshape,
                                color: colors.textPrimary,
                                size: 48,
                              ),
                            ),
                          ),
                        ),

                        Text(
                          letter.exampleWord,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Mots-clés illustrés du quotidien scolaire (Signes complets & Défileur)
          ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: schoolWords.length,
            itemBuilder: (context, index) {
              final item = schoolWords[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre du mot avec icône (Anti-Overflow garanti)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon,
                                    size: 22, color: colors.accent),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.background,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _openSpellerForWord(item.word),
                          icon: const Icon(Icons.pan_tool_rounded, size: 16),
                          label: const Text('Épeler',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Lecteur animé de trajectoire du signe
                    LsqMotionViewer(
                      word: item.word,
                      colors: colors,
                      isLowVision: false,
                      enableHaptics:
                          widget.provider.settings.hapticFeedbackEnabled,
                    ),

                    const SizedBox(height: 10),

                    // Explication du geste et exemple de phrase
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.meaning,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '« ${item.exampleSentence} »',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: colors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
