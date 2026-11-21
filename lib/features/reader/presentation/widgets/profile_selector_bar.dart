import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Barre de sélection rapide et tactile des 4 profils d'accessibilité inclusifs
class ProfileSelectorBar extends StatelessWidget {
  final AccessibilityProvider provider;

  const ProfileSelectorBar({
    super.key,
    required this.provider,
  });

  static const List<(AccessibilityProfile, String, IconData, String)>
      _profiles = [
    (
      AccessibilityProfile.standard,
      'Standard',
      Icons.auto_stories_rounded,
      'Profil standard fond titane doux anti-éblouissement',
    ),
    (
      AccessibilityProfile.lowVision,
      'Basse Vision',
      Icons.visibility_rounded,
      'Profil basse vision fond noir et texte jaune contraste maximal',
    ),
    (
      AccessibilityProfile.dyslexia,
      'Dyslexie',
      Icons.spellcheck_rounded,
      'Profil dyslexie fond crème chaud, grand espacement et colorisation',
    ),
    (
      AccessibilityProfile.lsqVisual,
      'LSQ / Sourd',
      Icons.sign_language_rounded,
      'Profil visuel et retours haptiques pour élèves sourds ou malentendants',
    ),
    (
      AccessibilityProfile.nightReading,
      'Soir',
      Icons.nightlight_round,
      'Profil lecture du soir lumière douce sans éblouissement',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = provider.colors;
    final currentProfile = provider.currentProfile;
    final isLowVision = currentProfile == AccessibilityProfile.lowVision;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: isLowVision
                ? colors.border
                : colors.border.withValues(alpha: 0.6),
            width: isLowVision ? 2.5 : 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _profiles.map((item) {
            final profile = item.$1;
            final label = item.$2;
            final icon = item.$3;
            final semanticsDesc = item.$4;
            final isSelected = currentProfile == profile;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: semanticsDesc,
                child: InkWell(
                  onTap: () {
                    unawaited(HapticFeedback.selectionClick());
                    provider.setProfile(profile);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? colors.accent : colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colors.accent
                              : (isLowVision
                                  ? colors.border
                                  : colors.border.withValues(alpha: 0.7)),
                          width: isSelected || isLowVision ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: isSelected
                                ? colors.background
                                : colors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected
                                  ? colors.background
                                  : colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
