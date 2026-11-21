import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/dactylology_data.dart';
import '../../../../core/nlp/lsq_semantic_engine.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../alphabet_workshop_screen.dart';
import 'alphabet_quiz_sheet.dart';
import 'lsq_handshape_widget.dart';
import 'lsq_motion_viewer.dart';
import 'lsq_speller_player.dart';

/// Panneau LSQ compact et fixe (zéro scroll requis) pour enfants sourds et malentendants :
/// - L'enfant voit le texte en bas ET les signes en haut EN MÊME TEMPS sur le même écran
/// - Touche un mot dans le texte -> ses lettres et son sens en signe apparaissent immédiatement
/// - Touche une lettre -> la grande main LSQ correspondante s'affiche en direct juste à côté
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
  };

  bool _isMirrorView = false;
  String _lastWord = '';
  int _selectedLetterIndex = 0;

  String _resolveActiveWord(AccessibilityProvider provider) {
    final analyzedWords = provider.analyzedWords;
    if (analyzedWords.isEmpty) return 'oiseau';

    final highlighted = provider.highlightedWordIndex;
    if (highlighted != null && highlighted < analyzedWords.length) {
      final clean = analyzedWords[highlighted].cleanWord.trim().toLowerCase();
      if (clean.isNotEmpty) return clean;
    }

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

    for (final w in analyzedWords) {
      final clean = w.cleanWord.trim().toLowerCase();
      if (clean.isNotEmpty) return clean;
    }
    return 'oiseau';
  }

  void _openFullMotionModal(
      BuildContext context, String word, AccessibilityProvider provider) {
    final colors = provider.colors;
    final semanticMatch = LsqSemanticEngine.analyze(word);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 14),
              // Si le mot est reconnu par le moteur sémantique LSQ -> Mouvement LSQ dédié
              // Sinon (nom propre ou mot rare issu d'une photo) -> Épellation automatique en mains LSQ
              if (semanticMatch.isKnownSign)
                LsqMotionViewer(
                  word: word,
                  colors: colors,
                  isLowVision: false,
                  enableHaptics: provider.settings.hapticFeedbackEnabled,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Épellation LSQ : ${word.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ce mot est un nom propre ou un mot spécifique : en LSQ, on l\'épelle lettre par lettre.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LsqSpellerPlayer(
                      word: word,
                      colors: colors,
                      isMirrorView: _isMirrorView,
                      enableHaptics: provider.settings.hapticFeedbackEnabled,
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
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
    final semanticMatch = LsqSemanticEngine.analyze(activeWord);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ligne 1 : Titre compact + Mot actif + Raccourcis (Miroir, Geste, A-Z, Quiz)
          Row(
            children: [
              Icon(Icons.sign_language_rounded, color: colors.accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'ESPACE SOURD • LSQ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: colors.accent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeWord.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton Miroir (Ma main / En face)
              IconButton(
                icon: Icon(
                  _isMirrorView
                      ? Icons.pan_tool_rounded
                      : Icons.remove_red_eye_rounded,
                  size: 18,
                  color: colors.accent,
                ),
                tooltip: _isMirrorView ? 'Vue : Ma main' : 'Vue : En face',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => setState(() => _isMirrorView = !_isMirrorView),
              ),
              // Bouton Animation du mouvement complet
              IconButton(
                icon: Icon(Icons.play_circle_outline_rounded,
                    size: 19, color: colors.accent),
                tooltip: 'Voir le mouvement du signe en grand',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () =>
                    _openFullMotionModal(context, activeWord, provider),
              ),
              // Bouton Atelier A-Z
              IconButton(
                icon: Icon(Icons.grid_view_rounded,
                    size: 18, color: colors.textPrimary),
                tooltip: 'Atelier Alphabet A-Z',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AlphabetWorkshopScreen(
                        provider: provider,
                        ttsService: widget.ttsService,
                      ),
                    ),
                  );
                },
              ),
              // Bouton Quiz
              IconButton(
                icon: Icon(Icons.stars_rounded,
                    size: 19, color: Colors.amber.shade700),
                tooltip: 'Quiz des mains LSQ',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => AlphabetQuizSheet.show(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Ligne 2 : CÔTE À CÔTE (Main LSQ en direct à gauche | Lettres tactiles + Sens à droite)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // À gauche : Grande main LSQ de la lettre touchée (toujours visible !)
              if (selectedLetter != null)
                Container(
                  width: 72,
                  height: 82,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.accent, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LsqHandshapeWidget(
                          handshape: selectedLetter.handshape,
                          color: colors.accent,
                          size: 52,
                          isMirrorView: _isMirrorView,
                        ),
                      ),
                      Text(
                        'Signe ${selectedLetter.letter}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 10),

              // À droite : Touches des lettres + Sens du signe en 1 coup d'œil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lettres tactiles du mot : toucher une lettre change la main à gauche en direct !
                    if (dactylologyEntries.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children:
                              List.generate(dactylologyEntries.length, (idx) {
                            final entry = dactylologyEntries[idx];
                            final isSelected = idx == safeLetterIdx;
                            return Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Semantics(
                                button: true,
                                selected: isSelected,
                                label: 'Lettre ${entry.letter} en signe LSQ',
                                child: InkWell(
                                  onTap: () {
                                    if (settings.hapticFeedbackEnabled) {
                                      unawaited(
                                          HapticFeedback.selectionClick());
                                    }
                                    setState(() => _selectedLetterIndex = idx);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    constraints: const BoxConstraints(
                                      minWidth: 34,
                                      minHeight: 36,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.accent
                                          : colors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.accent
                                            : colors.border
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.letter,
                                        style: TextStyle(
                                          fontSize: 15,
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
                    const SizedBox(height: 6),

                    // Sens du signe du mot ou description de la main (2 lignes max, zéro débordement)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(semanticMatch.icon,
                            size: 15, color: colors.accent),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            selectedLetter != null
                                ? '${selectedLetter.letter} : ${selectedLetter.handDescription}'
                                : semanticMatch.trajectoryDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
