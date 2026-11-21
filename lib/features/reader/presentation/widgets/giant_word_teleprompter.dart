import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/nlp/french_syllabifier.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Mode Mot Géant / Téléprompteur conçu pour les élèves malvoyants (Basse Vision)
/// Affiche un seul mot en taille géante plein écran avec navigation tactile,
/// réglage direct de la vitesse de lecture et découpage syllabique haptique interactif.
class GiantWordTeleprompter extends StatefulWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;
  final void Function(AnalyzedWord word) onOpenWordCoach;

  const GiantWordTeleprompter({
    super.key,
    required this.provider,
    required this.ttsService,
    required this.onOpenWordCoach,
  });

  @override
  State<GiantWordTeleprompter> createState() => _GiantWordTeleprompterState();
}

class _GiantWordTeleprompterState extends State<GiantWordTeleprompter> {
  int? _activeSyllableIndex;
  Timer? _syllableTimer;

  @override
  void dispose() {
    _syllableTimer?.cancel();
    super.dispose();
  }

  void _stepWord(int delta) {
    final words = widget.provider.analyzedWords;
    if (words.isEmpty) return;
    final current = widget.provider.highlightedWordIndex ?? 0;
    final next = (current + delta).clamp(0, words.length - 1);
    widget.provider.setHighlightedWordIndex(next);
    unawaited(HapticFeedback.selectionClick());

    final word = words[next];
    final spoken = word.cleanWord.trim().isNotEmpty
        ? word.cleanWord.trim()
        : word.originalToken.trim();
    if (spoken.isNotEmpty) {
      unawaited(
        widget.ttsService.speakWordWithHaptic(
          spoken,
          word.syllables,
          enableHaptics: widget.provider.settings.hapticFeedbackEnabled,
        ),
      );
    }
  }

  void _playSyllable(int index, String syllable, bool isLast) {
    setState(() => _activeSyllableIndex = index);
    unawaited(widget.ttsService.speakWordWithHaptic(
      syllable,
      [syllable],
      enableHaptics: false,
    ));
    if (widget.provider.settings.hapticFeedbackEnabled) {
      unawaited(
        widget.ttsService.triggerSingleSyllableHaptic(isStressed: isLast),
      );
    }
    _syllableTimer?.cancel();
    _syllableTimer = Timer(const Duration(milliseconds: 380), () {
      if (mounted) {
        setState(() => _activeSyllableIndex = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.provider.analyzedWords;
    if (words.isEmpty) return const SizedBox.shrink();

    final index =
        (widget.provider.highlightedWordIndex ?? 0).clamp(0, words.length - 1);
    final word = words[index];
    final settings = widget.provider.settings;
    final colors = settings.colors;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;
    final hasPicto = FalcDictionary.hasEntry(word.cleanWord);
    final pictoIcon =
        hasPicto ? FalcDictionary.getEntry(word.cleanWord).icon : null;

    final speechRateLabel = settings.speechRate < 0.7
        ? '0.5x'
        : settings.speechRate < 0.95
            ? '0.75x'
            : '1.0x';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLowVision ? colors.border : colors.accent,
          width: isLowVision ? 3.0 : 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête adaptatif avec Compteur, Sélecteur de tempo rapide et Fermeture
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Mot ${index + 1} sur ${words.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: colors.accent,
                  ),
                ),
              ),

              // Suggestion 2 : Indicateur et bouton de vitesse directement dans le mode géant
              Semantics(
                button: true,
                label: 'Vitesse de lecture $speechRateLabel. Toucher pour changer.',
                child: InkWell(
                  onTap: () async {
                    unawaited(HapticFeedback.selectionClick());
                    await widget.provider.cycleSpeechRate(widget.ttsService);
                    if (mounted) setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_rounded,
                            size: 16, color: colors.accent),
                        const SizedBox(width: 4),
                        Text(
                          speechRateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: widget.provider.toggleGiantWordMode,
                icon: Icon(Icons.close_fullscreen_rounded,
                    size: 18, color: colors.textSecondary),
                label: Text(
                  'Vue normale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Pictogramme visuel géant si disponible
          if (pictoIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(pictoIcon, size: 42, color: colors.accent),
            ),
            const SizedBox(height: 16),
          ],

          // Zone tactile géante : tap à gauche = reculer, tap à droite = avancer, appui long = Coach Mot
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => widget.onOpenWordCoach(word),
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width * 0.35) {
                _stepWord(-1);
              } else {
                _stepWord(1);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(word.syllables.length, (i) {
                    final syllable = word.syllables[i];
                    final isLast = i == word.syllables.length - 1;
                    final isActive = _activeSyllableIndex == i;
                    final sylColor = i.isEven
                        ? colors.syllableColorA
                        : colors.syllableColorB;

                    // Suggestion 3 : Syllabes tactiles interactives avec pulsation haptique synchronisée
                    return Semantics(
                      button: true,
                      label: 'Syllabe $syllable. Toucher pour écouter.',
                      child: InkWell(
                        onTap: () => _playSyllable(i, syllable, isLast),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? colors.accent.withValues(alpha: 0.22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isActive
                                ? Border.all(color: colors.accent, width: 2)
                                : null,
                          ),
                          child: Text(
                            syllable,
                            style: settings
                                .getReadingTextStyle(
                                  color: settings.syllableColoringEnabled
                                      ? sylColor
                                      : colors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                )
                                .copyWith(fontSize: 64),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
          Text(
            'Touche une syllabe pour l\'écouter • Appui long pour l\'aide LSQ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Gros boutons tactiles Précédent / Écouter / Suivant
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: index > 0 ? () => _stepWord(-1) : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Avant',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _stepWord(0),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Dire',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      index < words.length - 1 ? () => _stepWord(1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Après',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
