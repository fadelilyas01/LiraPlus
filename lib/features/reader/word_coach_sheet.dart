import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/falc_dictionary.dart';
import '../../core/nlp/french_syllabifier.dart';
import '../../core/providers/accessibility_provider.dart';
import '../../core/services/tts_haptic_service.dart';
import '../../core/theme/accessibility_themes.dart';
import 'presentation/widgets/dactylology_viewer.dart';
import 'presentation/widgets/lsq_motion_viewer.dart';
import 'presentation/widgets/syllable_puzzle_game.dart';

/// Fiche pédagogique modale d'aide multimodale (Coach Mot)
class WordCoachSheet extends StatefulWidget {
  final AnalyzedWord word;
  final AccessibilitySettings settings;
  final ITtsHapticService ttsService;

  const WordCoachSheet({
    super.key,
    required this.word,
    required this.settings,
    required this.ttsService,
  });

  /// Ouvre la fiche modale avec un design adapté au profil
  static Future<void> show(
    BuildContext context, {
    required AnalyzedWord word,
    required AccessibilitySettings settings,
    required ITtsHapticService ttsService,
  }) {
    final colors = settings.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      constraints: const BoxConstraints(maxWidth: 680),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        side: settings.profile == AccessibilityProfile.lowVision
            ? BorderSide(color: colors.border, width: 3.0)
            : BorderSide.none,
      ),
      builder: (ctx) => WordCoachSheet(
        word: word,
        settings: settings,
        ttsService: ttsService,
      ),
    );
  }

  @override
  State<WordCoachSheet> createState() => _WordCoachSheetState();
}

class _WordCoachSheetState extends State<WordCoachSheet> {
  int? _activeSyllableIndex;
  bool _isPlayingSyllables = false;
  late final FalcWordEntry _falcEntry;

  @override
  void initState() {
    super.initState();
    _falcEntry = FalcDictionary.getEntry(widget.word.cleanWord);
  }

  Future<void> _playSyllablesStepByStep() async {
    if (_isPlayingSyllables) return;
    setState(() => _isPlayingSyllables = true);

    final syllables = widget.word.syllables;
    for (int i = 0; i < syllables.length; i++) {
      if (!mounted) break;
      setState(() => _activeSyllableIndex = i);

      final isLast = (i == syllables.length - 1);
      final syllable = syllables[i];

      // Déclenchement de la prononciation et du retour haptique adapté
      await widget.ttsService
          .speakWordWithHaptic(syllable, [syllable], enableHaptics: false);
      if (widget.settings.hapticFeedbackEnabled) {
        await widget.ttsService.triggerSingleSyllableHaptic(isStressed: isLast);
      }

      await Future<void>.delayed(const Duration(milliseconds: 650));
    }

    if (mounted) {
      setState(() {
        _activeSyllableIndex = null;
        _isPlayingSyllables = false;
      });
    }
  }

  Future<void> _playSingleSyllable(int index, String syllable) async {
    setState(() => _activeSyllableIndex = index);
    final isLast = (index == widget.word.syllables.length - 1);

    await widget.ttsService
        .speakWordWithHaptic(syllable, [syllable], enableHaptics: false);
    if (widget.settings.hapticFeedbackEnabled) {
      await widget.ttsService.triggerSingleSyllableHaptic(isStressed: isLast);
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _activeSyllableIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.settings.colors;
    final isLowVision =
        widget.settings.profile == AccessibilityProfile.lowVision;

    return Semantics(
      label: 'Fiche pédagogique du mot ${widget.word.cleanWord}',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barre de poignée accessible
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête : Mot en grand avec bouton écoute globale
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COACH DU MOT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: colors.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.word.cleanWord,
                            style: widget.settings
                                .getReadingTextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                )
                                .copyWith(fontSize: 34),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      button: true,
                      label:
                          'Ajouter ou retirer ${widget.word.cleanWord} du coffre à mots',
                      child: Builder(
                        builder: (btnCtx) {
                          AccessibilityProvider? provider;
                          try {
                            provider = btnCtx.watch<AccessibilityProvider>();
                          } catch (_) {
                            provider = null;
                          }
                          if (provider == null) return const SizedBox.shrink();
                          final isFav =
                              provider.isFavoriteWord(widget.word.cleanWord);
                          return IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 30,
                              color: isFav
                                  ? Colors.amber.shade700
                                  : colors.textSecondary,
                            ),
                            tooltip: isFav
                                ? 'Retirer de mon coffre à mots'
                                : 'Ajouter à mon coffre à mots LSQ',
                            onPressed: () {
                              unawaited(HapticFeedback.selectionClick());
                              unawaited(provider!
                                  .toggleFavoriteWord(widget.word.cleanWord));
                            },
                          );
                        },
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Écouter le mot complet ${widget.word.cleanWord}',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.background,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isLowVision
                                ? BorderSide(color: colors.border, width: 2)
                                : BorderSide.none,
                          ),
                        ),
                        onPressed: () {
                          unawaited(
                            widget.ttsService.speakWordWithHaptic(
                              widget.word.cleanWord,
                              widget.word.syllables,
                              enableHaptics:
                                  widget.settings.hapticFeedbackEnabled,
                            ),
                          );
                        },
                        icon: const Icon(Icons.volume_up, size: 24),
                        label: const Text(
                          'Écouter',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Section 1 : Décomposition syllabique géante interactive
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLowVision
                          ? colors.border
                          : colors.border.withValues(alpha: 0.5),
                      width: isLowVision ? 2.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DÉCOUPAGE EN SYLLABES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: colors.textSecondary,
                            ),
                          ),
                          if (widget.settings.hapticFeedbackEnabled)
                            Row(
                              children: [
                                Icon(Icons.vibration,
                                    size: 16, color: colors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  'Vibration rythmée',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.accent,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          widget.word.syllables.length,
                          (idx) {
                            final syllable = widget.word.syllables[idx];
                            final isActive = _activeSyllableIndex == idx;
                            final isLast =
                                idx == widget.word.syllables.length - 1;
                            final sylColor = idx.isEven
                                ? colors.syllableColorA
                                : colors.syllableColorB;

                            return Semantics(
                              button: true,
                              label:
                                  'Syllabe ${idx + 1} : $syllable. Appuyer pour écouter.',
                              child: InkWell(
                                onTap: () => _playSingleSyllable(idx, syllable),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? colors.highlightBackground
                                        : (isLowVision
                                            ? Colors.black
                                            : colors.surface),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isActive
                                          ? colors.accent
                                          : (isLowVision
                                              ? colors.border
                                              : colors.border),
                                      width:
                                          isActive || isLowVision ? 2.5 : 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        syllable,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: isActive
                                              ? colors.highlightText
                                              : (isLowVision
                                                  ? sylColor
                                                  : sylColor),
                                        ),
                                      ),
                                      if (isLast &&
                                          widget.word.hasSilentEnding) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: colors.border
                                                .withValues(alpha: 0.3),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'muette : ${widget.word.silentEnding}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: colors.silentLetterColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Semantics(
                        button: true,
                        label: 'Écouter le mot découpé syllabe par syllabe',
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.accent,
                            side: BorderSide(
                              color: colors.accent,
                              width: isLowVision ? 2.5 : 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isPlayingSyllables
                              ? null
                              : _playSyllablesStepByStep,
                          icon: _isPlayingSyllables
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colors.accent,
                                  ),
                                )
                              : const Icon(Icons.slow_motion_video),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _isPlayingSyllables
                                  ? 'Lecture syllabe par syllabe...'
                                  : 'Écouter au ralenti (syllabe par syllabe)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        button: true,
                        label:
                            'Jouer au jeu des syllabes pour recomposer le mot',
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.background,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            SyllablePuzzleGame.show(
                              context,
                              word: widget.word,
                              colors: colors,
                              settings: widget.settings,
                              ttsService: widget.ttsService,
                            );
                          },
                          icon: const Icon(Icons.extension_rounded, size: 22),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '🎮 Jouer avec ce mot (Jeu des syllabes)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Section 2 : Dictionnaire visuel et capsule LSQ (Langue des Signes Québécoise)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLowVision
                          ? colors.border
                          : colors.border.withValues(alpha: 0.5),
                      width: isLowVision ? 2.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sign_language,
                              color: colors.accent, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _falcEntry.lsqSignTitle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: colors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge visuel du signe LSQ
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.accent,
                                width: isLowVision ? 2.5 : 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.sign_language_rounded,
                              size: 34,
                              color: colors.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Geste et sens en LSQ :',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _falcEntry.lsqDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Animation 60 FPS du mouvement pour les élèves sourds
                      LsqMotionViewer(
                        word: widget.word.cleanWord,
                        colors: colors,
                        isLowVision: isLowVision,
                        enableHaptics: widget.settings.hapticFeedbackEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Section 3 : Dactylologie interactive (Alphabet en Langue des Signes Québécoise - LSQ)
                DactylologyViewer(
                  word: widget.word.cleanWord,
                  colors: colors,
                  isLowVision: isLowVision,
                  hapticEnabled: widget.settings.hapticFeedbackEnabled,
                ),
                const SizedBox(height: 18),

                // Section 4 : Définition simplifiée en FALC (Facile à Lire et à Comprendre)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLowVision
                          ? colors.border
                          : colors.border.withValues(alpha: 0.5),
                      width: isLowVision ? 2.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: colors.accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'CE QUE CE MOT VEUT DIRE (FALC)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: colors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _falcEntry.falcDefinition,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.format_quote,
                                size: 20, color: colors.accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _falcEntry.exampleSentence,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton de fermeture accessible
                Semantics(
                  button: true,
                  label: 'Fermer la fiche coach du mot',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surfaceVariant,
                      foregroundColor: colors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colors.border,
                          width: isLowVision ? 2.5 : 1.0,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Fermer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
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
