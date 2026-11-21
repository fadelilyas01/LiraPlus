import 'package:flutter/material.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Barre de contrôle inférieure accessible et unifiée (Pupitre Magique de l'Élève)
class ReaderBottomBar extends StatelessWidget {
  final AccessibilityProvider provider;
  final bool isPlaying;
  final bool isAudioLoading;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onPreviousSentence;
  final VoidCallback onNextSentence;
  final VoidCallback onOpenScanner;
  final VoidCallback onCycleSpeed;
  final VoidCallback onToggleFocusMode;

  const ReaderBottomBar({
    super.key,
    required this.provider,
    required this.isPlaying,
    required this.isAudioLoading,
    required this.onTogglePlayPause,
    required this.onPreviousSentence,
    required this.onNextSentence,
    required this.onOpenScanner,
    required this.onCycleSpeed,
    required this.onToggleFocusMode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = provider.colors;
    final isLowVision =
        provider.currentProfile == AccessibilityProfile.lowVision;
    final currentRate = provider.settings.speechRate;
    final totalSteps = provider.totalSteps;
    final currentStep = provider.currentStep;
    final isFocusMode = provider.isFocusSentenceMode;

    final (speedText, speedIcon, speedLabel) = switch (currentRate) {
      < 0.7 => (
          '0.5x Lente',
          Icons.slow_motion_video_rounded,
          '0.5 fois lente apprentissage'
        ),
      < 0.95 => (
          '0.75x Confort',
          Icons.directions_walk_rounded,
          '0.75 fois tempo confort'
        ),
      _ => ('1.0x Normale', Icons.bolt_rounded, '1.0 fois cadence standard'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: isLowVision
                ? colors.border
                : colors.border.withValues(alpha: 0.6),
            width: isLowVision ? 2.5 : 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Frise visuelle bienveillante « De la graine au trophée » (🌱 -> 🏆)
                if (totalSteps > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text('🌱',
                            style: TextStyle(fontSize: isLowVision ? 18 : 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: provider.readingProgressPercent,
                              minHeight: 6,
                              backgroundColor: colors.surfaceVariant,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(colors.accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('🏆',
                            style: TextStyle(fontSize: isLowVision ? 18 : 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Phrase $currentStep/$totalSteps',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Pupitre Magique : [ ◀ Phrase ] [ ▶ Écouter ] [ Phrase ▶ ]
                Row(
                  children: [
                    // Bouton ◀ Phrase précédente
                    Semantics(
                      button: true,
                      label: 'Phrase précédente',
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minHeight: 52, minWidth: 52),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(
                              color: colors.border,
                              width: isLowVision ? 2.5 : 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              currentStep > 1 ? onPreviousSentence : null,
                          child: const Icon(Icons.arrow_back_ios_rounded,
                              size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Principal Central : ▶ ÉCOUTER LE TEXTE
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: isPlaying
                            ? 'Arrêter la lecture'
                            : 'Écouter cette phrase avec tempo doux et posé',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.accent,
                              foregroundColor: colors.background,
                              elevation: isLowVision ? 0 : 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: isLowVision
                                    ? BorderSide(
                                        color: colors.border, width: 2.5)
                                    : BorderSide.none,
                              ),
                            ),
                            onPressed:
                                isAudioLoading ? null : onTogglePlayPause,
                            icon: isAudioLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colors.background,
                                    ),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 32,
                                  ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isPlaying ? 'Pause' : 'Écouter',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Phrase suivante ▶
                    Semantics(
                      button: true,
                      label: 'Phrase suivante',
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minHeight: 52, minWidth: 52),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(
                              color: colors.border,
                              width: isLowVision ? 2.5 : 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              currentStep < totalSteps ? onNextSentence : null,
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 3. Barre d'outils secondaires bienveillants (Wrap anti-overflow garanti sur 320px)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Sélecteur de tempo doux
                    Semantics(
                      button: true,
                      label:
                          'Vitesse de lecture : $speedLabel. Toucher pour changer.',
                      child: InkWell(
                        onTap: onCycleSpeed,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(speedIcon, size: 16, color: colors.accent),
                              const SizedBox(width: 6),
                              Text(
                                speedText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bascule Mode Focus Phrase vs Mode Livre
                    Semantics(
                      button: true,
                      label: isFocusMode
                          ? 'Mode Focus Phrase activé'
                          : 'Mode Page complète activé',
                      child: InkWell(
                        onTap: onToggleFocusMode,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFocusMode
                                ? colors.accent.withValues(alpha: 0.15)
                                : colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFocusMode
                                  ? colors.accent
                                  : colors.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFocusMode
                                    ? Icons.filter_center_focus_rounded
                                    : Icons.menu_book_rounded,
                                size: 16,
                                color: colors.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isFocusMode ? 'Focus Phrase' : 'Page entière',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bouton Scanner une page
                    Semantics(
                      button: true,
                      label: 'Scanner un livre avec la caméra',
                      child: InkWell(
                        onTap: onOpenScanner,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  size: 16, color: colors.accent),
                              const SizedBox(width: 6),
                              Text(
                                'Scanner',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
