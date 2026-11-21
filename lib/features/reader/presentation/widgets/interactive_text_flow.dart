import 'package:flutter/material.dart';
import '../../../../core/nlp/french_syllabifier.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../../../../core/theme/accessibility_themes.dart';
import 'word_item_widget.dart';

/// Zone centrale interactive affichant le texte mot par mot ou l'état vide
class InteractiveTextFlow extends StatelessWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;
  final VoidCallback onOpenSampleSelector;
  final VoidCallback onOpenScanner;
  final void Function(AnalyzedWord word) onOpenWordCoach;

  const InteractiveTextFlow({
    super.key,
    required this.provider,
    required this.ttsService,
    required this.onOpenSampleSelector,
    required this.onOpenScanner,
    required this.onOpenWordCoach,
  });

  @override
  Widget build(BuildContext context) {
    final words = provider.analyzedWords;
    final settings = provider.settings;
    final colors = settings.colors;
    final highlightedIndex = provider.highlightedWordIndex;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;

    // 1. État Vide (Empty State) avec illustration et boutons d'action
    if (words.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLowVision
                  ? colors.border
                  : colors.border.withValues(alpha: 0.6),
              width: isLowVision ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 38,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Prêt pour la lecture !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez une histoire d\'exemple ou numérisez une page de livre scolaire avec la caméra.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onOpenSampleSelector,
                    icon: const Icon(Icons.collections_bookmark_rounded,
                        size: 20),
                    label: const Text(
                      'Histoires d\'exemple',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onOpenScanner,
                    icon: const Icon(Icons.document_scanner_rounded, size: 20),
                    label: const Text(
                      'Scanner une page',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 2. État Nominal : Rendu des mots analysés isolé avec RepaintBoundary (Anti-Jank 60/120 FPS)
    final sentences = provider.sentenceWordIndices;
    final activeSentenceWordIndices =
        sentences.isNotEmpty && provider.currentSentenceIndex < sentences.length
            ? sentences[provider.currentSentenceIndex]
            : <int>[];
    final isFocusMode = provider.isFocusSentenceMode && sentences.length > 1;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLowVision
                ? colors.border
                : colors.border.withValues(alpha: 0.5),
            width: isLowVision ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          spacing: settings.letterSpacing * 6.0,
          runSpacing: settings.lineSpacing * 12.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(words.length, (index) {
            final word = words[index];
            final isHighlighted = highlightedIndex == index;
            final isCurrentSentence =
                !isFocusMode || activeSentenceWordIndices.contains(index);

            final wordWidget = WordItemWidget(
              word: word,
              index: index,
              isHighlighted: isHighlighted,
              settings: settings,
              colors: colors,
              ttsService: ttsService,
              onWordTapped: (idx) {
                provider.setHighlightedWordIndex(idx);
                provider.recordWordsRead(1);
              },
              onWordLongPressed: onOpenWordCoach,
            );

            if (!isCurrentSentence) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: 0.25,
                child: wordWidget,
              );
            }

            return wordWidget;
          }),
        ),
      ),
    );
  }
}
