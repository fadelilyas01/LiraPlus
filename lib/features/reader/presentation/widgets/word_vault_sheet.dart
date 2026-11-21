import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/services/tts_haptic_service.dart';
import 'lsq_motion_viewer.dart';

/// Coffre à Mots LSQ personnel avec mode Cartes Mémoire (Flashcards 100 % hors ligne)
class WordVaultSheet extends StatefulWidget {
  final AccessibilityProvider provider;
  final ITtsHapticService ttsService;

  const WordVaultSheet({
    super.key,
    required this.provider,
    required this.ttsService,
  });

  static Future<void> show(
    BuildContext context, {
    required AccessibilityProvider provider,
    required ITtsHapticService ttsService,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WordVaultSheet(
        provider: provider,
        ttsService: ttsService,
      ),
    );
  }

  @override
  State<WordVaultSheet> createState() => _WordVaultSheetState();
}

class _WordVaultSheetState extends State<WordVaultSheet> {
  bool _isFlashcardMode = false;
  int _cardIndex = 0;
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.provider.colors;
    final favorites = widget.provider.progression.favoriteWords.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            // En-tête du Coffre à Mots
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: colors.accent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MON COFFRE À MOTS LSQ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: colors.accent,
                        ),
                      ),
                      Text(
                        '${favorites.length} mot${favorites.length > 1 ? 's' : ''} à réviser',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (favorites.isNotEmpty)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.accent,
                      side: BorderSide(color: colors.accent),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isFlashcardMode = !_isFlashcardMode;
                        _cardIndex = 0;
                        _isRevealed = false;
                      });
                    },
                    icon: Icon(
                      _isFlashcardMode
                          ? Icons.list_rounded
                          : Icons.style_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _isFlashcardMode ? 'Liste' : 'Cartes',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // État vide pédagogique
            if (favorites.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star_border_rounded,
                        size: 48, color: colors.accent),
                    const SizedBox(height: 12),
                    Text(
                      'Ton coffre est encore vide !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maintiens ton doigt sur un mot difficile pour ouvrir sa fiche, puis touche l\'étoile pour l\'ajouter ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        unawaited(HapticFeedback.mediumImpact());
                        const starterWords = [
                          'école',
                          'ami',
                          'livre',
                          'soleil',
                          'arbre',
                          'maison',
                        ];
                        await widget.provider.addFavoriteWords(starterWords);
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.school_rounded, size: 20),
                      label: const Text(
                        'Découvrir les mots de l\'école',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_isFlashcardMode)
              _buildFlashcardView(favorites)
            else
              Column(
                children: favorites.map((word) {
                  final entry = FalcDictionary.getEntry(word);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(entry.icon, color: colors.accent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                word,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.lsqSignTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up_rounded,
                              color: colors.accent),
                          tooltip: 'Écouter $word',
                          onPressed: () {
                            unawaited(widget.ttsService.speak(word));
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.star_rounded,
                              color: Colors.amber.shade700),
                          tooltip: 'Retirer des favoris',
                          onPressed: () async {
                            await widget.provider.toggleFavoriteWord(word);
                            if (mounted) setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fermer mon coffre',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardView(List<String> favorites) {
    final colors = widget.provider.colors;
    final safeIndex = _cardIndex.clamp(0, favorites.length - 1);
    final word = favorites[safeIndex];
    final entry = FalcDictionary.getEntry(word);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.accent, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'Carte ${safeIndex + 1} sur ${favorites.length} — Devines-tu ce mot ?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 12),

          // Indice visuel : signe LSQ + pictogramme + définition
          LsqMotionViewer(
            word: word,
            colors: colors,
            isLowVision: false,
            enableHaptics: widget.provider.settings.hapticFeedbackEnabled,
          ),
          const SizedBox(height: 10),
          Text(
            entry.falcDefinition,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          if (_isRevealed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(entry.icon, color: colors.accent, size: 26),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      word.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                unawaited(widget.ttsService.speak(word));
                setState(() => _isRevealed = true);
              },
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('Voir le mot',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: safeIndex > 0
                    ? () => setState(() {
                          _cardIndex = safeIndex - 1;
                          _isRevealed = false;
                        })
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Précédente'),
              ),
              TextButton.icon(
                onPressed: safeIndex < favorites.length - 1
                    ? () => setState(() {
                          _cardIndex = safeIndex + 1;
                          _isRevealed = false;
                        })
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Suivante'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
