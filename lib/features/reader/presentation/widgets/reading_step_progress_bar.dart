import 'package:flutter/material.dart';
import '../../../../core/providers/accessibility_provider.dart';

/// Barre de progression étape par étape valorisante et stimulante pour l'enfant
class ReadingStepProgressBar extends StatelessWidget {
  final AccessibilityProvider provider;
  final VoidCallback onOpenCarnet;

  const ReadingStepProgressBar({
    super.key,
    required this.provider,
    required this.onOpenCarnet,
  });

  @override
  Widget build(BuildContext context) {
    final colors = provider.colors;
    final totalSteps = provider.totalSteps;
    final currentStep = provider.currentStep;
    final percent = provider.readingProgressPercent;
    final encouragement = provider.stepEncouragementMessage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ligne 1 : Titre de l'étape + Bouton Mon Carnet (Wrap anti-overflow sur petits écrans)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Étape $currentStep sur $totalSteps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: colors.accent,
                      ),
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}% accompli',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Bouton Carnet de progression
              Semantics(
                button: true,
                label: 'Ouvrir mon carnet de lecture et voir mes trophées',
                child: InkWell(
                  onTap: onOpenCarnet,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Mon Carnet',
                          style: TextStyle(
                            fontSize: 11,
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

          const SizedBox(height: 6),

          // Ligne 2 : Barre de progression animée
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: percent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: colors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          // Ligne 3 : Message d'encouragement bienveillant
          Text(
            encouragement,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
