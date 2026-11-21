import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/falc_dictionary.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Feuille modale de sélection d'une histoire ou d'un texte d'exemple
class SampleTextSheet extends StatefulWidget {
  final AccessibilityProvider provider;

  const SampleTextSheet({
    super.key,
    required this.provider,
  });

  static Future<void> show(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    final colors = provider.colors;
    final isLowVision =
        provider.currentProfile == AccessibilityProfile.lowVision;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 680),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: isLowVision
            ? BorderSide(color: colors.border, width: 2.5)
            : BorderSide.none,
      ),
      builder: (_) => SampleTextSheet(provider: provider),
    );
  }

  @override
  State<SampleTextSheet> createState() => _SampleTextSheetState();
}

class _SampleTextSheetState extends State<SampleTextSheet> {
  int _selectedTab = 0; // 0 = Récits MEQ, 1 = Mes Textes

  void _promptSaveCurrentText() {
    final colors = widget.provider.colors;
    final textController = TextEditingController(
      text: 'Lecture du ${DateTime.now().day}/${DateTime.now().month}',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enregistrer ce texte',
          style:
              TextStyle(fontWeight: FontWeight.w900, color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donnez un nom à ce texte ou devoir pour le retrouver facilement :',
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              autofocus: true,
              style: TextStyle(
                  color: colors.textPrimary, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceVariant,
                hintText: 'Ex: Page 14 de lecture',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                Text('Annuler', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final title = textController.text.trim();
              widget.provider.saveCurrentText(title);
              Navigator.of(ctx).pop();
              setState(() => _selectedTab = 1);
            },
            child: const Text('Sauvegarder',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final colors = provider.colors;
    final isLowVision =
        provider.currentProfile == AccessibilityProfile.lowVision;
    final savedTexts = provider.savedTexts;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
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

              // Sélecteur d'onglets ergonomique
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLowVision
                        ? colors.border
                        : colors.border.withValues(alpha: 0.5),
                    width: isLowVision ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTab = 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? colors.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Récits MEQ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _selectedTab == 0
                                  ? colors.background
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTab = 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? colors.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Mes Textes (${savedTexts.length})',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _selectedTab == 1
                                  ? colors.background
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contenu défilant selon l'onglet
              Expanded(
                child: _selectedTab == 0
                    ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: FalcDictionary.sampleTexts.length,
                        itemBuilder: (context, index) {
                          final sample = FalcDictionary.sampleTexts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              tileColor: colors.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isLowVision
                                      ? colors.border
                                      : colors.border.withValues(alpha: 0.6),
                                  width: isLowVision ? 2.0 : 1.0,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.menu_book_rounded,
                                    color: colors.accent, size: 22),
                              ),
                              title: Text(
                                sample['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: colors.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  sample['text']!.length > 60
                                      ? '${sample['text']!.substring(0, 60)}...'
                                      : sample['text']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              onTap: () {
                                provider.setText(sample['text']!);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      )
                    : Column(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.accent,
                              side:
                                  BorderSide(color: colors.accent, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _promptSaveCurrentText,
                            icon: const Icon(Icons.bookmark_add_rounded,
                                size: 20),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Enregistrer le texte ouvert dans mes devoirs',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: savedTexts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.collections_bookmark_outlined,
                                          size: 48,
                                          color: colors.textSecondary
                                              .withValues(alpha: 0.4),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Aucun texte sauvegardé pour le moment',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Numérisez un manuel avec la caméra ou enregistrez ce texte.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: savedTexts.length,
                                    itemBuilder: (context, index) {
                                      final entry = savedTexts[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: ListTile(
                                          tileColor: colors.surfaceVariant,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: BorderSide(
                                              color: isLowVision
                                                  ? colors.border
                                                  : colors.border
                                                      .withValues(alpha: 0.6),
                                              width: isLowVision ? 2.0 : 1.0,
                                            ),
                                          ),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: colors.accent
                                                  .withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.bookmark_rounded,
                                                color: colors.accent, size: 22),
                                          ),
                                          title: Text(
                                            entry.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year} • ${entry.text.length > 50 ? "${entry.text.substring(0, 50)}..." : entry.text}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color:
                                                    Colors.redAccent.shade700),
                                            onPressed: () {
                                              provider
                                                  .deleteSavedText(entry.id);
                                            },
                                          ),
                                          onTap: () {
                                            provider.setText(entry.text);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
