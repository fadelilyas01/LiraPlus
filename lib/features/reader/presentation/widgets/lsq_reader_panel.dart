import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/dactylology_data.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../alphabet_workshop_screen.dart';
import 'alphabet_quiz_sheet.dart';
import 'lsq_handshape_widget.dart';
import 'lsq_motion_viewer.dart';
import 'lsq_speller_player.dart';

/// Panneau visuel interactif LSQ dédié aux élèves sourds et malentendants :
/// - Bande de sens visuelle des mots-clés de la phrase active
/// - Touches interactives par lettre : toucher une lettre affiche instantanément son signe LSQ et sa position de main
/// - Sens complet du mot en LSQ (pictogramme, explication FALC et mouvement animé)
class LsqReaderPanel extends StatefulWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;

  const LsqReaderPanel({
    super.key,
    required this.provider,
    required this.ttsService,
  });

  @override
  State<LsqReaderPanel> createState() => _LsqReaderPanelState();
}

class _LsqReaderPanelState extends State<LsqReaderPanel> {
  static const Set<String> _stopWords = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'du',
    'de',
    'et',
    'ou',
    'au',
    'aux',
    'en',
    'à',
    'a',
    'dans',
    'sur',
    'par',
    'pour',
    'avec',
    'ce',
    'cette',
    'ces',
    'son',
    'sa',
    'ses',
    'il',
    'elle',
    'ils',
    'elles',
    'on',
    'nous',
    'vous',
    'je',
    'tu',
  };

  bool _isExpanded = true;
  bool _showSpeller = false;
  bool _isMirrorView = false;
  String _lastWord = '';
  int _selectedLetterIndex = 0;

  /// Détermine le mot actif : le mot touché par l'élève, ou le premier mot porteur de sens de la phrase
  String _resolveActiveWord(AccessibilityProvider provider) {
    final analyzedWords = provider.analyzedWords;
    if (analyzedWords.isEmpty) return 'oiseau';

    final highlighted = provider.highlightedWordIndex;
    if (highlighted != null && highlighted < analyzedWords.length) {
      final clean = analyzedWords[highlighted].cleanWord.trim().toLowerCase();
      if (clean.isNotEmpty) return clean;
    }

    // Cherche d'abord un mot porteur de sens dans la phrase active
    final sentences = provider.sentenceWordIndices;
    if (sentences.isNotEmpty) {
      final sIdx = provider.currentSentenceIndex.clamp(0, sentences.length - 1);
      for (final wordIdx in sentences[sIdx]) {
        final clean = analyzedWords[wordIdx].cleanWord.trim().toLowerCase();
        if (clean.length > 2 && !_stopWords.contains(clean)) {
          return clean;
        }
      }
    }

    // Repli sur le premier mot non vide
    for (final w in analyzedWords) {
      final clean = w.cleanWord.trim().toLowerCase();
      if (clean.isNotEmpty) return clean;
    }
    return 'oiseau';
  }

  /// Extrait les mots-clés porteurs de sens de la phrase active pour la Bande de Sens Visuelle
  List<({int wordIndex, String word, IconData icon})> _getSentenceKeyConcepts(
      AccessibilityProvider provider) {
    final analyzedWords = provider.analyzedWords;
    final sentences = provider.sentenceWordIndices;
    if (analyzedWords.isEmpty || sentences.isEmpty) return const [];

    final sIdx = provider.currentSentenceIndex.clamp(0, sentences.length - 1);
    final List<({int wordIndex, String word, IconData icon})> concepts = [];
    final seen = <String>{};

    for (final idx in sentences[sIdx]) {
      final clean = analyzedWords[idx].cleanWord.trim().toLowerCase();
      if (clean.length <= 2 || _stopWords.contains(clean) || seen.contains(clean)) {
        continue;
      }
      seen.add(clean);
      final entry = FalcDictionary.getEntry(clean);
      concepts.add((wordIndex: idx, word: clean, icon: entry.icon));
      if (concepts.length >= 5) break;
    }
    return concepts;
  }

  void _onLetterTapped(int index, DactylologyLetter letter, bool enableHaptics) {
    if (enableHaptics) {
      unawaited(HapticFeedback.selectionClick());
    }
    setState(() {
      _selectedLetterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final settings = provider.settings;
    final colors = settings.colors;

    final activeWord = _resolveActiveWord(provider);
    if (_lastWord != activeWord) {
      _lastWord = activeWord;
      _selectedLetterIndex = 0;
    }

    final dactylologyEntries = DactylologyData.wordToDactylology(activeWord);
    final safeLetterIdx = dactylologyEntries.isEmpty
        ? 0
        : _selectedLetterIndex.clamp(0, dactylologyEntries.length - 1);
    final selectedLetter = dactylologyEntries.isNotEmpty
        ? dactylologyEntries[safeLetterIdx]
        : null;
    final falcEntry = FalcDictionary.getEntry(activeWord);
    final keyConcepts = _getSentenceKeyConcepts(provider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête accessible avec bascule Réduire / Déplier
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sign_language_rounded,
                      color: colors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              'ESPACE SOURD • LSQ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: colors.accent,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                activeWord.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isExpanded
                              ? 'Touche une lettre ou un mot pour voir son signe'
                              : 'Touche ici pour voir les signes LSQ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colors.textPrimary,
                    ),
                    tooltip: _isExpanded
                        ? 'Réduire le panneau LSQ'
                        : 'Déplier le panneau LSQ',
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. BANDE DE SENS VISUELLE : Mots-clés illustrés de la phrase active
                  if (keyConcepts.isNotEmpty) ...[
                    Text(
                      'MOTS-CLÉS DE LA PHRASE (TOUCHE UN MOT)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: keyConcepts.map((concept) {
                          final isSelected = concept.word == activeWord;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                if (settings.hapticFeedbackEnabled) {
                                  unawaited(HapticFeedback.selectionClick());
                                }
                                provider
                                    .setHighlightedWordIndex(concept.wordIndex);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.accent
                                      : colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.accent
                                        : colors.border.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      concept.icon,
                                      size: 16,
                                      color: isSelected
                                          ? colors.background
                                          : colors.accent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      concept.word,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isSelected
                                            ? colors.background
                                            : colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 2. TOUCHES DES LETTRES INTERACTIVES -> VOIR LA MAIN EN SIGNE EN DIRECT
                  if (dactylologyEntries.isNotEmpty && selectedLetter != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 15, color: colors.accent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'TOUCHE UNE LETTRE POUR VOIR SON SIGNE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: colors.accent,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rangée de touches tactiles pour chaque lettre du mot
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: List.generate(dactylologyEntries.length,
                                  (idx) {
                                final entry = dactylologyEntries[idx];
                                final isSelected = idx == safeLetterIdx;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Semantics(
                                    button: true,
                                    selected: isSelected,
                                    label:
                                        'Lettre ${entry.letter}. Toucher pour voir le signe de main LSQ.',
                                    child: InkWell(
                                      onTap: () => _onLetterTapped(
                                        idx,
                                        entry,
                                        settings.hapticFeedbackEnabled,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        constraints: const BoxConstraints(
                                          minWidth: 42,
                                          minHeight: 44,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colors.accent
                                              : colors.surface,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? colors.accent
                                                : colors.border
                                                    .withValues(alpha: 0.5),
                                            width: isSelected ? 2.0 : 1.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            entry.letter,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected
                                                  ? colors.background
                                                  : colors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // AFFICHAGE EN DIRECT DE LA MAIN EN SIGNE POUR LA LETTRE TOUCHÉE
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Grande main LSQ interactive de la lettre sélectionnée
                                Container(
                                  width: 82,
                                  height: 92,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colors.accent.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.accent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: LsqHandshapeWidget(
                                      handshape: selectedLetter.handshape,
                                      color: colors.accent,
                                      size: 70,
                                      isMirrorView: _isMirrorView,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Explication directe de la main pour cette lettre
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lettre ${selectedLetter.letter} en signe LSQ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedLetter.handDescription,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Comme dans : ${selectedLetter.exampleWord}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: colors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // 3. SENS DU MOT COMPLET EN SIGNE LSQ (Pictogramme + Explication simple)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(falcEntry.icon,
                              color: colors.accent, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                falcEntry.lsqSignTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: colors.accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                falcEntry.lsqDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Barre d'outils rapide : Défileur auto, Vue Miroir, Atelier A-Z, Quiz
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showSpeller
                              ? colors.accent
                              : colors.surfaceVariant,
                          foregroundColor: _showSpeller
                              ? colors.background
                              : colors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () =>
                            setState(() => _showSpeller = !_showSpeller),
                        icon: const Icon(Icons.spellcheck_rounded, size: 16),
                        label: Text(
                          _showSpeller ? 'Voir le mouvement' : 'Tout épeler',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(
                              color: colors.border.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () =>
                            setState(() => _isMirrorView = !_isMirrorView),
                        icon: Icon(
                          _isMirrorView
                              ? Icons.pan_tool_rounded
                              : Icons.remove_red_eye_rounded,
                          size: 15,
                          color: colors.accent,
                        ),
                        label: Text(
                          _isMirrorView ? 'Ma main' : 'En face',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AlphabetWorkshopScreen(
                                provider: widget.provider,
                                ttsService: widget.ttsService,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.grid_view_rounded, size: 16),
                        label: const Text('Atelier A-Z',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber.shade800,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
                        onPressed: () =>
                            AlphabetQuizSheet.show(context, widget.provider),
                        icon: const Icon(Icons.stars_rounded, size: 16),
                        label: const Text('Quiz',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 5. Animation du signe complet ou défileur automatique
                  if (_showSpeller)
                    LsqSpellerPlayer(
                      word: activeWord,
                      colors: colors,
                      isMirrorView: _isMirrorView,
                      enableHaptics: settings.hapticFeedbackEnabled,
                      onToggleMirror: () =>
                          setState(() => _isMirrorView = !_isMirrorView),
                    )
                  else
                    LsqMotionViewer(
                      word: activeWord,
                      colors: colors,
                      isLowVision: false,
                      enableHaptics: settings.hapticFeedbackEnabled,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
