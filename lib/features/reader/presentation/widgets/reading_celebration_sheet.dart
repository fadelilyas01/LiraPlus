import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Feuille modale festive et encourageante félicitant l'élève qui termine une histoire
/// Inclut une Question Éclair de compréhension bienveillante avec choix illustrés
class ReadingCelebrationSheet extends StatefulWidget {
  final int wordsCount;
  final AccessibilityColors colors;
  final VoidCallback onReplay;
  final VoidCallback onChooseAnother;
  final String? storyText;

  const ReadingCelebrationSheet({
    super.key,
    required this.wordsCount,
    required this.colors,
    required this.onReplay,
    required this.onChooseAnother,
    this.storyText,
  });

  /// Affiche la fête de fin de lecture
  static Future<void> show(
    BuildContext context, {
    required int wordsCount,
    required AccessibilityColors colors,
    required VoidCallback onReplay,
    required VoidCallback onChooseAnother,
    String? storyText,
  }) {
    HapticFeedback.heavyImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      constraints: const BoxConstraints(maxWidth: 580),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => ReadingCelebrationSheet(
        wordsCount: wordsCount,
        colors: colors,
        onReplay: onReplay,
        onChooseAnother: onChooseAnother,
        storyText: storyText,
      ),
    );
  }

  @override
  State<ReadingCelebrationSheet> createState() =>
      _ReadingCelebrationSheetState();
}

class _ReadingCelebrationSheetState extends State<ReadingCelebrationSheet> {
  int? _selectedChoice;
  late final ComprehensionQuestion _question;

  @override
  void initState() {
    super.initState();
    _question = FalcDictionary.getQuestionForText(widget.storyText ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final wordsCount = widget.wordsCount;
    final isCorrect = _selectedChoice == _question.correctIndex;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),

            // Étoiles dorées de félicitation
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 36),
                SizedBox(width: 8),
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 50),
                SizedBox(width: 8),
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 36),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Bravo champion !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Badge du nombre de mots lus
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories_rounded,
                      color: colors.accent, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$wordsCount mots décodés aujourd\'hui',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Question Éclair de compréhension (active & bienveillante)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'QUESTION ÉCLAIR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _question.question,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_question.choices.length, (idx) {
                    final choice = _question.choices[idx];
                    final isPicked = _selectedChoice == idx;
                    final isRightChoice = idx == _question.correctIndex;
                    final borderColor = isPicked
                        ? (isRightChoice
                            ? Colors.green.shade600
                            : Colors.amber.shade700)
                        : colors.border.withValues(alpha: 0.4);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedChoice = idx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isPicked
                                ? borderColor.withValues(alpha: 0.16)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor,
                              width: isPicked ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(choice.icon, color: colors.accent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  choice.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isPicked)
                                Icon(
                                  isRightChoice
                                      ? Icons.check_circle_rounded
                                      : Icons.refresh_rounded,
                                  color: borderColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_selectedChoice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isCorrect
                            ? _question.encouragement
                            : 'Bien essayé ! Regarde les autres choix, tu vas trouver.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color:
                              isCorrect ? Colors.green.shade600 : colors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions pour l'élève
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.maybePop(context);
                      widget.onReplay();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Relire',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                    onPressed: () {
                      Navigator.maybePop(context);
                      widget.onChooseAnother();
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Autre histoire',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
