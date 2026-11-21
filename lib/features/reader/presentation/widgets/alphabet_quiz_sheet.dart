import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/dactylology_data.dart';
import '../../../../core/providers/accessibility_provider.dart';
import 'lsq_handshape_widget.dart';

/// Fiche de mini-jeu éducatif et bienveillant « Trouve la bonne main » (Quiz LSQ)
class AlphabetQuizSheet extends StatefulWidget {
  final AccessibilityProvider provider;

  const AlphabetQuizSheet({
    super.key,
    required this.provider,
  });

  static Future<void> show(
      BuildContext context, AccessibilityProvider provider) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlphabetQuizSheet(provider: provider),
    );
  }

  @override
  State<AlphabetQuizSheet> createState() => _AlphabetQuizSheetState();
}

class _AlphabetQuizSheetState extends State<AlphabetQuizSheet> {
  final Random _random = Random();
  late List<DactylologyLetter> _allLetters;
  late DactylologyLetter _targetLetter;
  late List<DactylologyLetter> _options;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  int? _selectedOptionIndex;
  int _starsEarned = 0;
  bool _modeLetterToHand =
      true; // true: lettre -> 3 mains, false: main -> 3 lettres

  @override
  void initState() {
    super.initState();
    _allLetters = DactylologyData.letters.values.toList();
    _generateNewRound();
  }

  void _generateNewRound() {
    _isAnswerChecked = false;
    _isCorrect = false;
    _selectedOptionIndex = null;
    _modeLetterToHand = _random.nextBool();

    _targetLetter = _allLetters[_random.nextInt(_allLetters.length)];

    final distractors = List<DactylologyLetter>.from(_allLetters)
      ..removeWhere((l) => l.letter == _targetLetter.letter);
    distractors.shuffle(_random);

    _options = [
      _targetLetter,
      distractors[0],
      distractors[1],
    ]..shuffle(_random);
  }

  void _handleSelectOption(int index) {
    if (_isAnswerChecked) return;

    final selected = _options[index];
    final isCorrect = selected.letter == _targetLetter.letter;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswerChecked = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _starsEarned++;
        unawaited(widget.provider.recordWordsRead(1));
        unawaited(widget.provider.unlockBadge('quiz_explorer'));
        unawaited(HapticFeedback.heavyImpact());
      } else {
        unawaited(HapticFeedback.lightImpact());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.provider.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de préhension
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

            // En-tête : Titre + Étoiles gagnées
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.stars_rounded,
                            color: colors.accent, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JEU DES MAINS LSQ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                                color: colors.accent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Trouve la bonne main !',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: colors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Étoiles accumulées
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber.shade900, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_starsEarned',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Question posée à l'élève
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    _modeLetterToHand
                        ? 'Quelle main fait la lettre :'
                        : 'Quelle est la lettre de cette main ?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (_modeLetterToHand)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _targetLetter.letter,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: colors.background,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: 70,
                      height: 80,
                      child: LsqHandshapeWidget(
                        handshape: _targetLetter.handshape,
                        color: colors.accent,
                        size: 70,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Choix multiples (3 options)
            if (_modeLetterToHand)
              Row(
                children: List.generate(_options.length, (idx) {
                  final option = _options[idx];
                  final isSelected = _selectedOptionIndex == idx;
                  final isTarget = option.letter == _targetLetter.letter;

                  Color borderColor = colors.border.withValues(alpha: 0.4);
                  Color bgColor = colors.surfaceVariant;

                  if (_isAnswerChecked) {
                    if (isTarget) {
                      borderColor = Colors.green.shade600;
                      bgColor = Colors.green.withValues(alpha: 0.15);
                    } else if (isSelected) {
                      borderColor = Colors.orange.shade700;
                      bgColor = Colors.orange.withValues(alpha: 0.15);
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () => _handleSelectOption(idx),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2.0),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 60,
                                child: LsqHandshapeWidget(
                                  handshape: option.handshape,
                                  color: colors.textPrimary,
                                  size: 50,
                                ),
                              ),
                              if (_isAnswerChecked && isTarget)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(Icons.check_circle_rounded,
                                      color: Colors.green, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              )
            else
              Row(
                children: List.generate(_options.length, (idx) {
                  final option = _options[idx];
                  final isSelected = _selectedOptionIndex == idx;
                  final isTarget = option.letter == _targetLetter.letter;

                  Color borderColor = colors.border.withValues(alpha: 0.4);
                  Color bgColor = colors.surfaceVariant;

                  if (_isAnswerChecked) {
                    if (isTarget) {
                      borderColor = Colors.green.shade600;
                      bgColor = Colors.green.withValues(alpha: 0.15);
                    } else if (isSelected) {
                      borderColor = Colors.orange.shade700;
                      bgColor = Colors.orange.withValues(alpha: 0.15);
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () => _handleSelectOption(idx),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2.0),
                          ),
                          child: Center(
                            child: Text(
                              option.letter,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 16),

            // Message de retour après réponse
            if (_isAnswerChecked)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect
                          ? Icons.celebration_rounded
                          : Icons.lightbulb_rounded,
                      color: _isCorrect
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? 'Bravo ! C\'est la bonne réponse !'
                            : 'Bien essayé ! La bonne lettre était ${_targetLetter.letter}.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _isCorrect
                              ? Colors.green.shade800
                              : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Bouton Question Suivante
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                setState(() => _generateNewRound());
              },
              child: const Text(
                'Question suivante ➔',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
