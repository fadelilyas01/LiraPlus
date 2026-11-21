import 'package:flutter/material.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Fiche du carnet de progression et des trophées de l'élève
class ProgressionDashboardSheet extends StatelessWidget {
  final AccessibilityProvider provider;

  const ProgressionDashboardSheet({
    super.key,
    required this.provider,
  });

  static Future<void> show(
      BuildContext context, AccessibilityProvider provider) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProgressionDashboardSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = provider.colors;
    final progression = provider.progression;

    final List<Map<String, dynamic>> badges = [
      {
        'key': 'first_words',
        'title': 'Premier Mot Exploré',
        'desc': 'Tu as touché et écouté un premier mot',
        'icon': Icons.touch_app_rounded,
        'unlocked': progression.totalWordsRead > 0 ||
            progression.unlockedBadges.contains('first_words'),
      },
      {
        'key': 'first_story',
        'title': 'Première Victoire',
        'desc': 'Tu as lu une histoire jusqu\'au bout',
        'icon': Icons.auto_stories_rounded,
        'unlocked': progression.totalStoriesCompleted > 0 ||
            progression.unlockedBadges.contains('first_story'),
      },
      {
        'key': 'lsq_explorer',
        'title': 'Ami de la LSQ',
        'desc': 'Tu as découvert la langue des signes québécoise',
        'icon': Icons.sign_language_rounded,
        'unlocked': progression.unlockedBadges.contains('lsq_explorer'),
      },
      {
        'key': 'story_master',
        'title': 'Grand Lecteur',
        'desc': 'Tu as complété 3 histoires avec brio',
        'icon': Icons.military_tech_rounded,
        'unlocked': progression.totalStoriesCompleted >= 3 ||
            progression.unlockedBadges.contains('story_master'),
      },
      {
        'key': 'night_reader',
        'title': 'Lecteur des Étoiles',
        'desc': 'Lecture du soir apaisante sans écran bleu',
        'icon': Icons.nightlight_round,
        'unlocked': progression.unlockedBadges.contains('night_reader'),
      },
    ];

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
            const SizedBox(height: 16),

            // Titre et écusson de niveau
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      color: Colors.amber.shade900, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MON CARNET DE PROGRESSION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.levelTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Statistiques globales
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Mots découverts',
                    value: '${progression.totalWordsRead}',
                    icon: Icons.record_voice_over_rounded,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Histoires lues',
                    value: '${progression.totalStoriesCompleted}',
                    icon: Icons.menu_book_rounded,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Badges gagnés',
                    value:
                        '${progression.unlockedBadges.length}/${badges.length}',
                    icon: Icons.stars_rounded,
                    colors: colors,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'MES BADGES DE RÉUSSITE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Liste des badges
            ...badges.map((badge) {
              final isUnlocked = badge['unlocked'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked
                        ? colors.accent
                        : colors.border.withValues(alpha: 0.4),
                    width: isUnlocked ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? colors.accent
                            : colors.border.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        size: 20,
                        color: isUnlocked
                            ? colors.background
                            : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                badge['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isUnlocked
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                              if (isUnlocked) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.check_circle_rounded,
                                    size: 14, color: Colors.green.shade600),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge['desc'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.border.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'À débloquer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 14),

            // Bouton Fermer accessible
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continuer ma lecture',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final AccessibilityColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: colors.accent),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
