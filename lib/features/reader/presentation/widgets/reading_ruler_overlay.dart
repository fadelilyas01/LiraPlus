import 'package:flutter/material.dart';
import '../../../../core/providers/accessibility_provider.dart';

/// Règle de lecture horizontale fluide et accélérée GPU (Anti-Jank 60/120 FPS)
class ReadingRulerOverlay extends StatefulWidget {
  final AccessibilityProvider provider;

  const ReadingRulerOverlay({
    super.key,
    required this.provider,
  });

  @override
  State<ReadingRulerOverlay> createState() => _ReadingRulerOverlayState();
}

class _ReadingRulerOverlayState extends State<ReadingRulerOverlay> {
  late double _currentY;

  @override
  void initState() {
    super.initState();
    _currentY = widget.provider.settings.readingRulerY;
  }

  @override
  void didUpdateWidget(covariant ReadingRulerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.settings.readingRulerY !=
        widget.provider.settings.readingRulerY) {
      _currentY = widget.provider.settings.readingRulerY;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.provider.settings;
    final colors = settings.colors;
    final isOpaqueMask = settings.opaqueRulerMask;
    const double rulerHeight = 52.0;

    return Stack(
      children: [
        // 1. Cache-Lignes TDAH supérieur (assombrit les lignes au-dessus sans bloquer le toucher)
        if (isOpaqueMask && _currentY > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _currentY,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                color: Colors.black.withValues(alpha: 0.52),
              ),
            ),
          ),

        // 2. Cache-Lignes TDAH inférieur (assombrit les lignes en dessous sans bloquer le toucher)
        if (isOpaqueMask)
          Positioned(
            top: _currentY + rulerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                color: Colors.black.withValues(alpha: 0.52),
              ),
            ),
          ),

        // 3. Fenêtre / Règle de lecture horizontale déplaçable à 60 FPS
        Positioned(
          top: _currentY,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                final maxHeight = (MediaQuery.of(context).size.height - 140.0)
                    .clamp(120.0, 2400.0);
                setState(() {
                  _currentY =
                      (_currentY + details.delta.dy).clamp(60.0, maxHeight);
                });
              },
              onVerticalDragEnd: (_) {
                widget.provider.setReadingRulerY(_currentY);
              },
              child: Semantics(
                label:
                    'Règle de lecture horizontale. Glisser vers le haut ou le bas pour suivre la ligne.',
                child: Container(
                  height: rulerHeight,
                  decoration: BoxDecoration(
                    color: isOpaqueMask
                        ? Colors.transparent
                        : colors.readingRulerColor,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: colors.accent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.drag_indicator_rounded,
                            color: colors.accent, size: 22),
                      ),
                      Text(
                        'GUIDE DE LECTURE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: colors.accent,
                        ),
                      ),
                      // Bouton rapide pour basculer entre Règle transparente et Cache-Lignes TDAH
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: widget.provider.toggleOpaqueRulerMask,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.accent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOpaqueMask
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  size: 14,
                                  color: colors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOpaqueMask ? 'Cache' : 'Règle',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
