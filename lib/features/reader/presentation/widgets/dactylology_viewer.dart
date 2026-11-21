import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/dactylology_data.dart';
import '../../../../core/theme/accessibility_themes.dart';

import 'lsq_handshape_widget.dart';

/// Composant interactif d'épellation en Dactylologie LSQ (Québec) pour élèves sourds
class DactylologyViewer extends StatefulWidget {
  final String word;
  final AccessibilityColors colors;
  final bool isLowVision;
  final bool hapticEnabled;

  const DactylologyViewer({
    super.key,
    required this.word,
    required this.colors,
    required this.isLowVision,
    required this.hapticEnabled,
  });

  @override
  State<DactylologyViewer> createState() => _DactylologyViewerState();
}

class _DactylologyViewerState extends State<DactylologyViewer> {
  int? _activeLetterIndex;
  bool _isSpelling = false;

  List<String> get _cleanLetters {
    return widget.word
        .replaceAll(RegExp(r'[^\p{L}]+', unicode: true), '')
        .split('');
  }

  Future<void> _stepThroughLetters() async {
    if (_isSpelling) return;
    setState(() => _isSpelling = true);

    final letters = _cleanLetters;
    for (int i = 0; i < letters.length; i++) {
      if (!mounted) break;
      setState(() => _activeLetterIndex = i);

      if (widget.hapticEnabled) {
        final isLast = (i == letters.length - 1);
        if (isLast) {
          await HapticFeedback.heavyImpact();
        } else {
          await HapticFeedback.mediumImpact();
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    if (mounted) {
      setState(() {
        _activeLetterIndex = null;
        _isSpelling = false;
      });
    }
  }

  void _selectLetter(int index) {
    if (widget.hapticEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() {
      _activeLetterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final letters = _cleanLetters;
    final colors = widget.colors;
    final isLowVision = widget.isLowVision;

    if (letters.isEmpty) return const SizedBox.shrink();

    final activeLetter =
        _activeLetterIndex != null && _activeLetterIndex! < letters.length
            ? DactylologyData.getLetter(letters[_activeLetterIndex!])
            : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLowVision
              ? colors.border
              : colors.border.withValues(alpha: 0.6),
          width: isLowVision ? 2.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.sign_language_rounded,
                        color: colors.accent, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DACTYLOLOGIE (ALPHABET EN SIGNES)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: colors.accent,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Semantics(
                label:
                    'Profil sourd : Épellation manuelle en Langue des Signes',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LSQ (Québec)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Ruban horizontal des lettres épelées
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(letters.length, (idx) {
                final char = letters[idx];
                final dactLetter = DactylologyData.getLetter(char);
                final isActive = _activeLetterIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Semantics(
                    button: true,
                    label:
                        'Lettre ${char.toUpperCase()} en langue des signes. Appuyer pour voir le geste.',
                    child: InkWell(
                      onTap: () => _selectLetter(idx),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors.highlightBackground
                              : colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? colors.accent
                                : colors.border.withValues(alpha: 0.7),
                            width: isActive || isLowVision ? 2.5 : 1.2,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        colors.accent.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              char.toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isActive
                                    ? colors.highlightText
                                    : colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LsqHandshapeWidget(
                              handshape: dactLetter?.handshape ??
                                  LsqHandshapeType.fistWithSideThumb,
                              color: isActive
                                  ? colors.highlightText
                                  : colors.accent,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Bouton d'animation de l'épellation pas à pas
          Semantics(
            button: true,
            label: 'Épeler tout le mot lettre par lettre en langue des signes',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.accent,
                  side: BorderSide(
                    color: colors.accent,
                    width: isLowVision ? 2.5 : 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSpelling ? null : _stepThroughLetters,
                icon: _isSpelling
                    ? Icon(Icons.motion_photos_paused_rounded,
                        color: colors.accent)
                    : const Icon(Icons.play_circle_fill_rounded),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _isSpelling
                        ? 'Épellation en cours...'
                        : 'Épeler lettre par lettre (avec vibrations)',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),

          // 3. Zoom sur la lettre active et astuce pédagogique parent/enfant
          if (activeLetter != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.accent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeLetter.letter,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LsqHandshapeWidget(
                          handshape: activeLetter.handshape,
                          color: colors.accent,
                          size: 38,
                          animateMotion: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Position de la main (${activeLetter.name}) :',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeLetter.handDescription,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (activeLetter.hasMovement) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  Colors.amber.shade900.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.amber.shade800, width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.motion_photos_on_rounded,
                                    size: 14, color: Colors.amber.shade800),
                                const SizedBox(width: 4),
                                Text(
                                  'Geste actif : mouvement tracé dans l\'air',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.lightbulb_rounded,
                                size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                activeLetter.tipForParents,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
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
            ),
          ],
        ],
      ),
    );
  }
}
