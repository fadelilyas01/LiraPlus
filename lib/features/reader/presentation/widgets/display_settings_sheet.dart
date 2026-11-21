import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Feuille modale des réglages d'accessibilité visuelle et vocale
class DisplaySettingsSheet extends StatelessWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;

  const DisplaySettingsSheet({
    super.key,
    required this.provider,
    required this.ttsService,
  });

  static Future<void> show(
    BuildContext context, {
    required AccessibilityProvider provider,
    required ITtsHapticService ttsService,
  }) {
    final colors = provider.colors;
    final isLowVision =
        provider.currentProfile == AccessibilityProfile.lowVision;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: isLowVision
            ? BorderSide(color: colors.border, width: 2.5)
            : BorderSide.none,
      ),
      builder: (_) => DisplaySettingsSheet(
        provider: provider,
        ttsService: ttsService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = provider.colors;
    final s = provider.settings;

    return StatefulBuilder(
      builder: (ctx, setStateSheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
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
                  Text(
                    'RÉGLAGES D\'AFFICHAGE & AIDES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Taille de police
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Taille du texte (${s.fontSize.toInt()})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.remove_circle_outline_rounded),
                            color: colors.accent,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              provider.setFontSize(s.fontSize - 2);
                              setStateSheet(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: colors.accent,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              provider.setFontSize(s.fontSize + 2);
                              setStateSheet(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // Vitesse de lecture vocale
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Vitesse vocale (${s.speechRate.toStringAsFixed(1)}x)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            color: colors.accent,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              final newRate = s.speechRate - 0.1;
                              provider.setSpeechRate(newRate);
                              ttsService.setRate(newRate);
                              setStateSheet(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            color: colors.accent,
                            onPressed: () {
                              unawaited(HapticFeedback.lightImpact());
                              final newRate = s.speechRate + 0.1;
                              provider.setSpeechRate(newRate);
                              ttsService.setRate(newRate);
                              setStateSheet(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // Bascule guide de lecture
                  SwitchListTile(
                    title: Text(
                      'Règle de lecture horizontale',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.showReadingRuler,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleReadingRuler();
                      setStateSheet(() {});
                    },
                  ),

                  // Bascule coloration des syllabes
                  SwitchListTile(
                    title: Text(
                      'Couleurs des syllabes alternées',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.syllableColoringEnabled,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleSyllableColoring();
                      setStateSheet(() {});
                    },
                  ),

                  // Bascule lettres muettes
                  SwitchListTile(
                    title: Text(
                      'Atténuation des lettres muettes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.silentLettersDimmed,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleSilentLettersDimmed();
                      setStateSheet(() {});
                    },
                  ),

                  // Bascule arcs de liaison
                  SwitchListTile(
                    title: Text(
                      'Arcs de liaison (ex: les‿oiseaux)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.liaisonsEnabled,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleLiaisons();
                      setStateSheet(() {});
                    },
                  ),

                  // Bascule retour haptique
                  SwitchListTile(
                    title: Text(
                      'Vibrations haptiques rythmées',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.hapticFeedbackEnabled,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleHapticFeedback();
                      setStateSheet(() {});
                    },
                  ),

                  const Divider(),

                  // Mise en lumière des sons complexes (Dyslexie / Débutants)
                  SwitchListTile(
                    title: Text(
                      'Sons complexes soulignés (ou, oi, ch, eau)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.complexGraphemesHighlighted,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleComplexGraphemes();
                      setStateSheet(() {});
                    },
                  ),

                  // Pont Visuel : pictogrammes au-dessus des mots-clés (Enfants Sourds / LSQ)
                  SwitchListTile(
                    title: Text(
                      'Pictogrammes visuels au-dessus des mots (LSQ)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.visualPictogramsEnabled,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleVisualPictograms();
                      setStateSheet(() {});
                    },
                  ),

                  // Lecture académique pas-à-pas avec pause entre les mots
                  SwitchListTile(
                    title: Text(
                      'Pause respiratoire entre chaque mot',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.stepByStepPauses,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleStepByStepPauses();
                      setStateSheet(() {});
                    },
                  ),

                  // Cache-Lignes TDAH anti-distraction
                  SwitchListTile(
                    title: Text(
                      'Cache-Lignes opaque anti-distraction (TDAH)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.opaqueRulerMask,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleOpaqueRulerMask();
                      setStateSheet(() {});
                    },
                  ),

                  // Mode Mot Géant / Téléprompteur (Basse Vision)
                  SwitchListTile(
                    title: Text(
                      'Mode Mot Géant plein écran (Basse Vision)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    value: s.giantWordMode,
                    activeThumbColor: colors.accent,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      provider.toggleGiantWordMode();
                      setStateSheet(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
