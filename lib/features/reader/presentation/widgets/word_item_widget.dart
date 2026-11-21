import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/nlp/french_syllabifier.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Composant unitaire représentant un mot analysé, interactif avec auto-scroll karaoké
class WordItemWidget extends StatefulWidget {
  final AnalyzedWord word;
  final int index;
  final bool isHighlighted;
  final AccessibilitySettings settings;
  final AccessibilityColors colors;
  final ITtsHapticService ttsService;
  final void Function(int index) onWordTapped;
  final void Function(AnalyzedWord word) onWordLongPressed;

  const WordItemWidget({
    super.key,
    required this.word,
    required this.index,
    required this.isHighlighted,
    required this.settings,
    required this.colors,
    required this.ttsService,
    required this.onWordTapped,
    required this.onWordLongPressed,
  });

  @override
  State<WordItemWidget> createState() => _WordItemWidgetState();
}

class _WordItemWidgetState extends State<WordItemWidget> {
  bool _wasTappedByUser = false;

  @override
  void initState() {
    super.initState();
    if (widget.isHighlighted) {
      _ensureVisible();
    }
  }

  @override
  void didUpdateWidget(WordItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-Scroll Karaoké : quand le mot devient surligné automatiquement par la lecture vocale continue,
    // on l'amène doucement au centre du champ de vision. Si le mot a été touché directement par l'élève,
    // l'écran reste parfaitement stable sous son doigt.
    if (!oldWidget.isHighlighted && widget.isHighlighted) {
      if (_wasTappedByUser) {
        _wasTappedByUser = false;
      } else {
        _ensureVisible();
      }
    }
  }

  void _ensureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment:
            0.45, // Légèrement au-dessus du centre pour anticiper la lecture
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final colors = widget.colors;
    final word = widget.word;
    final isHighlighted = widget.isHighlighted;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;

    final isLsqProfile = settings.profile == AccessibilityProfile.lsqVisual;
    final hasVisualPicto = settings.visualPictogramsEnabled &&
        FalcDictionary.hasEntry(word.cleanWord);
    final pictoIcon =
        hasVisualPicto ? FalcDictionary.getEntry(word.cleanWord).icon : null;

    return Semantics(
      button: true,
      label:
          'Mot : ${word.cleanWord}. Découpé en ${word.syllables.length} syllabes : ${word.syllables.join("-")}. Appuyer pour écouter. Appui prolongé pour ouvrir le coach mot.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _wasTappedByUser = true;
          final spokenWord = word.cleanWord.trim().isNotEmpty
              ? word.cleanWord.trim()
              : word.originalToken.trim();
          widget.onWordTapped(widget.index);
          if (spokenWord.isNotEmpty) {
            unawaited(
              widget.ttsService.speakWordWithHaptic(
                spokenWord,
                word.syllables,
                enableHaptics: settings.hapticFeedbackEnabled,
              ),
            );
          }
        },
        onLongPress: () => widget.onWordLongPressed(word),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color:
                isHighlighted ? colors.highlightBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(
                    color: colors.accent,
                    width: isLowVision || isLsqProfile ? 2.5 : 1.5,
                  )
                : null,
            // Métronome silencieux (LSQ) : halo lumineux doux synchronisé sur le mot actif
            boxShadow: isHighlighted && isLsqProfile
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pont Visuel (Enfants Sourds / LSQ) : pictogramme clair au-dessus des mots-clés
              if (pictoIcon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? colors.highlightText.withValues(alpha: 0.12)
                          : colors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      pictoIcon,
                      size: (settings.fontSize * 0.62).clamp(14.0, 24.0),
                      color:
                          isHighlighted ? colors.highlightText : colors.accent,
                    ),
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Ponctuation initiale (ex: guillemet ouvrant)
                    if (word.leadingPunctuation.isNotEmpty)
                      Text(
                        word.leadingPunctuation,
                        style: settings.getReadingTextStyle(
                            color: colors.textSecondary),
                      ),

                    // Rendu des syllabes, sons complexes et lettres muettes
                    ..._buildSyllablesOrWordSpans(),

                    // Ponctuation finale (ex: virgule, point)
                    if (word.trailingPunctuation.isNotEmpty)
                      Text(
                        word.trailingPunctuation,
                        style: settings.getReadingTextStyle(
                            color: colors.textSecondary),
                      ),

                    // Arc de liaison visuel avec le mot suivant (ex: les‿oiseaux)
                    if (settings.liaisonsEnabled && word.hasLiaisonWithNext)
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          FrenchSyllabifier.liaisonArc,
                          style: TextStyle(
                            fontSize: settings.fontSize * 1.1,
                            fontWeight: FontWeight.w900,
                            color: colors.accent,
                          ),
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
  }

  List<Widget> _buildSyllablesOrWordSpans() {
    final List<Widget> widgets = [];
    final word = widget.word;
    final settings = widget.settings;
    final colors = widget.colors;
    final isHighlighted = widget.isHighlighted;
    final syllables = word.syllables;

    if (!settings.syllableColoringEnabled || syllables.length <= 1) {
      if (settings.silentLettersDimmed && word.hasSilentEnding) {
        widgets.add(
          Text(
            word.basePart,
            style: settings.getReadingTextStyle(
              color: isHighlighted ? colors.highlightText : colors.textPrimary,
            ),
          ),
        );
        widgets.add(
          Text(
            word.silentEnding,
            style: settings.getReadingTextStyle(
              color: isHighlighted
                  ? colors.highlightText.withValues(alpha: 0.4)
                  : colors.silentLetterColor,
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            word.cleanWord,
            style: settings.getReadingTextStyle(
              color: isHighlighted ? colors.highlightText : colors.textPrimary,
            ),
          ),
        );
      }
      return widgets;
    }

    // Affichage avec alternance de couleur par syllabe
    for (int i = 0; i < syllables.length; i++) {
      final isLast = (i == syllables.length - 1);
      final syllable = syllables[i];
      final syllableColor =
          i.isEven ? colors.syllableColorA : colors.syllableColorB;

      if (isLast && settings.silentLettersDimmed && word.hasSilentEnding) {
        final (base, silent) = FrenchSyllabifier.detectSilentEnding(syllable);
        if (silent.isNotEmpty) {
          widgets.add(
            Text(
              base,
              style: settings.getReadingTextStyle(
                color: isHighlighted ? colors.highlightText : syllableColor,
              ),
            ),
          );
          widgets.add(
            Text(
              silent,
              style: settings.getReadingTextStyle(
                color: isHighlighted
                    ? colors.highlightText.withValues(alpha: 0.4)
                    : colors.silentLetterColor,
              ),
            ),
          );
          continue;
        }
      }

      widgets.add(
        _buildStyledSegment(
          syllable,
          isHighlighted ? colors.highlightText : syllableColor,
        ),
      );
    }

    return widgets;
  }

  static final RegExp _complexGraphemeRegex = RegExp(
    r'(eau|ain|ein|ill|ou|oi|on|an|en|in|au|ch|gn|ph)',
    caseSensitive: false,
  );

  /// Met en lumière les graphèmes complexes du français (ou, oi, ch, eau...) par un soulignement doux
  Widget _buildStyledSegment(String text, Color baseColor) {
    final settings = widget.settings;
    final colors = widget.colors;
    final baseStyle = settings.getReadingTextStyle(color: baseColor);

    if (!settings.complexGraphemesHighlighted || text.length < 2) {
      return Text(text, style: baseStyle);
    }

    final matches = _complexGraphemeRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final List<InlineSpan> spans = [];
    int cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          decorationColor:
              widget.isHighlighted ? colors.highlightText : colors.accent,
          decorationThickness: 2.2,
        ),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(
        text: text.substring(cursor),
        style: baseStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }
}
