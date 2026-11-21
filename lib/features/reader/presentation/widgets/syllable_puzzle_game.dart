import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/nlp/french_syllabifier.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Mini-jeu pédagogique et ludique de recomposition d'un mot par ses syllabes
class SyllablePuzzleGame extends StatefulWidget {
  final AnalyzedWord word;
  final AccessibilityColors colors;
  final AccessibilitySettings settings;
  final ITtsHapticService ttsService;

  const SyllablePuzzleGame({
    super.key,
    required this.word,
    required this.colors,
    required this.settings,
    required this.ttsService,
  });

  /// Ouvre le jeu des syllabes dans une feuille modale
  static Future<void> show(
    BuildContext context, {
    required AnalyzedWord word,
    required AccessibilityColors colors,
    required AccessibilitySettings settings,
    required ITtsHapticService ttsService,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SyllablePuzzleGame(
        word: word,
        colors: colors,
        settings: settings,
        ttsService: ttsService,
      ),
    );
  }

  @override
  State<SyllablePuzzleGame> createState() => _SyllablePuzzleGameState();
}

class _SyllablePuzzleGameState extends State<SyllablePuzzleGame> {
  late final List<String> _expectedSyllables;
  late List<String> _shuffledSyllables;
  final List<String> _placedSyllables = [];
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _expectedSyllables = widget.word.syllables.isNotEmpty
        ? List.from(widget.word.syllables)
        : [widget.word.cleanWord];

    _shuffledSyllables = List.from(_expectedSyllables);
    // Si le mot a plus d'une syllabe, on s'assure qu'elles sont mélangées
    if (_shuffledSyllables.length > 1) {
      int attempts = 0;
      while (_listsEqual(_shuffledSyllables, _expectedSyllables) &&
          attempts < 10) {
        _shuffledSyllables.shuffle();
        attempts++;
      }
    }
    _placedSyllables.clear();
    _isSuccess = false;
    _errorMessage = null;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _onSyllableTapped(String syllable, int index) async {
    if (_isSuccess) return;

    final nextExpectedIndex = _placedSyllables.length;
    if (nextExpectedIndex < _expectedSyllables.length &&
        syllable.toLowerCase() ==
            _expectedSyllables[nextExpectedIndex].toLowerCase()) {
      // Bonne syllabe placée !
      unawaited(HapticFeedback.mediumImpact());
      setState(() {
        _placedSyllables.add(syllable);
        _shuffledSyllables.removeAt(index);
        _errorMessage = null;
      });

      // Mot entièrement recomposé avec succès !
      if (_placedSyllables.length == _expectedSyllables.length) {
        unawaited(HapticFeedback.heavyImpact());
        setState(() => _isSuccess = true);
        unawaited(widget.ttsService.speak(widget.word.cleanWord));
      }
    } else {
      // Mauvaise syllabe
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _errorMessage = 'Écoute bien le début du mot et réessaie doucement !';
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isLowVision =
        widget.settings.profile == AccessibilityProfile.lowVision;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // En-tête du jeu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.extension_rounded,
                          color: colors.accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Jeu des syllabes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 28),
                  color: colors.accent,
                  tooltip: 'Écouter le mot',
                  onPressed: () {
                    widget.ttsService.speak(widget.word.cleanWord);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Touche les syllabes dans le bon ordre pour reformer le mot :',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Zone cible des syllabes placées
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isLowVision
                      ? colors.border
                      : colors.border.withValues(alpha: 0.6),
                  width: isLowVision ? 2.5 : 1.5,
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(_expectedSyllables.length, (index) {
                  final hasPlaced = index < _placedSyllables.length;
                  final syllableText =
                      hasPlaced ? _placedSyllables[index] : '?';

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: hasPlaced ? colors.accent : colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasPlaced ? colors.accent : colors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      syllableText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: hasPlaced
                            ? colors.background
                            : colors.textSecondary,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Message d'aide ou d'encouragement
            if (_errorMessage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),

            // Bulles de syllabes mélangées à toucher
            if (!_isSuccess) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_shuffledSyllables.length, (index) {
                  final syllable = _shuffledSyllables[index];

                  return ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 52, minWidth: 60),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: colors.textPrimary,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colors.accent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onPressed: () => _onSyllableTapped(syllable, index),
                      child: Text(
                        syllable,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else ...[
              // Écran de victoire félicitations
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade700, width: 2),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 36),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 46),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 36),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bravo champion !',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu as parfaitement recomposé « ${widget.word.cleanWord} » !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _initGame();
                        });
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text(
                        'Rejouer avec ce mot',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
