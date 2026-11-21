import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/dactylology_data.dart';
import '../../../../core/theme/accessibility_themes.dart';
import 'lsq_handshape_widget.dart';

/// Défileur automatique « Épelle avec mes mains » (Lettre par lettre en LSQ)
class LsqSpellerPlayer extends StatefulWidget {
  final String word;
  final AccessibilityColors colors;
  final bool isMirrorView;
  final bool enableHaptics;
  final VoidCallback? onToggleMirror;

  const LsqSpellerPlayer({
    super.key,
    required this.word,
    required this.colors,
    this.isMirrorView = false,
    this.enableHaptics = true,
    this.onToggleMirror,
  });

  @override
  State<LsqSpellerPlayer> createState() => _LsqSpellerPlayerState();
}

class _LsqSpellerPlayerState extends State<LsqSpellerPlayer> {
  late List<DactylologyLetter> _letters;
  int _currentIndex = 0;
  bool _isPlaying = true;
  Timer? _timer;
  bool _isMirror = false;

  @override
  void initState() {
    super.initState();
    _isMirror = widget.isMirrorView;
    _letters = DactylologyData.wordToDactylology(widget.word);
    if (_letters.isEmpty && widget.word.isNotEmpty) {
      final firstLetter = DactylologyData.getLetter(widget.word[0]);
      if (firstLetter != null) _letters = [firstLetter];
    }
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant LsqSpellerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) {
      _letters = DactylologyData.wordToDactylology(widget.word);
      _currentIndex = 0;
      _startAutoPlay();
    }
    if (oldWidget.isMirrorView != widget.isMirrorView) {
      setState(() => _isMirror = widget.isMirrorView);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (!_isPlaying || _letters.isEmpty) return;

    _timer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) return;
      if (_letters.isEmpty) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _letters.length;
      });

      if (widget.enableHaptics) {
        unawaited(HapticFeedback.selectionClick());
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startAutoPlay();
    } else {
      _timer?.cancel();
    }
  }

  void _previousLetter() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentIndex = (_currentIndex - 1 + _letters.length) % _letters.length;
    });
    if (widget.enableHaptics) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  void _nextLetter() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentIndex = (_currentIndex + 1) % _letters.length;
    });
    if (widget.enableHaptics) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    if (_letters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Aucune lettre dactylologique disponible pour ce mot.',
          style: TextStyle(
              color: colors.textSecondary, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      );
    }

    final current = _letters[_currentIndex];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête : mot complet avec la lettre active surlignée
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: List.generate(_letters.length, (idx) {
              final isCurrent = idx == _currentIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = idx;
                    _isPlaying = false;
                    _timer?.cancel();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? colors.accent : colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? colors.accent
                          : colors.border.withValues(alpha: 0.4),
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: Text(
                    _letters[idx].letter,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isCurrent ? colors.background : colors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Zone d'affichage grand format de la main active
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Bouton Lettre précédente
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  color: colors.textPrimary,
                  tooltip: 'Lettre précédente',
                  onPressed: _previousLetter,
                ),

                // Main LSQ avec lettre
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 82,
                      child: LsqHandshapeWidget(
                        handshape: current.handshape,
                        color: colors.accent,
                        size: 72,
                        isMirrorView: _isMirror,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lettre ${current.letter}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      _isMirror ? 'Vue : Ma main' : 'Vue : En face',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Bouton Lettre suivante
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  color: colors.textPrimary,
                  tooltip: 'Lettre suivante',
                  onPressed: _nextLetter,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Barre de commandes : Lecture/Pause, Miroir, Indicateur d'étape
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              // Bouton Lecture / Pause du défilement
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPlaying ? Colors.amber.shade800 : colors.accent,
                  foregroundColor: colors.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _togglePlayPause,
                icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18),
                label: Text(
                  _isPlaying ? 'Pause' : 'Épeler',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),

              // Bouton Vue Miroir
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() => _isMirror = !_isMirror);
                  widget.onToggleMirror?.call();
                },
                icon: Icon(
                  _isMirror
                      ? Icons.pan_tool_rounded
                      : Icons.remove_red_eye_rounded,
                  size: 16,
                  color: colors.accent,
                ),
                label: Text(
                  _isMirror ? 'Ma main' : 'En face',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),

              // Indicateur textuel
              Text(
                'Lettre ${_currentIndex + 1} / ${_letters.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
