import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/accessibility_provider.dart';
import '../../core/theme/accessibility_themes.dart';
import 'presentation/widgets/ocr_shimmer_skeleton.dart';

/// Écran de numérisation OCR locale et sécurisée de page de manuel scolaire
class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  late final TextRecognizer _textRecognizer;

  bool _isProcessing = false;
  String _recognizedText = '';
  File? _capturedImage;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _textController.dispose();
    super.dispose();
  }

  /// Prise de photo ou sélection d'image avec protection anti-double tap
  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isProcessing) return;

    try {
      await HapticFeedback.lightImpact();
      setState(() => _isProcessing = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      if (!mounted) return;
      setState(() {
        _capturedImage = File(pickedFile.path);
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedTextResult =
          await _textRecognizer.processImage(inputImage);

      final cleanedText = _cleanOcrText(recognizedTextResult.text);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _recognizedText = cleanedText;
        _textController.text = cleanedText;
      });

      if (cleanedText.isEmpty) {
        _showNotification(
          'Aucun texte détecté sur cette page. Assurez-vous d\'un bon éclairage et d\'un cadrage net.',
          isError: true,
        );
      } else {
        await HapticFeedback.mediumImpact();
        _showNotification('Page numérisée avec succès en local !');
      }
    } catch (_) {
      // Masquage strict des détails internes (CWE-209 & Règle 10/7)
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showNotification(
        'L\'appareil photo n\'a pas pu être ouvert ou l\'image n\'a pas pu être lue. Vérifiez les autorisations de l\'appareil.',
        isError: true,
      );
    }
  }

  /// Nettoie les césures, tirets et sauts de ligne intempestifs de l'OCR
  String _cleanOcrText(String rawText) {
    if (rawText.trim().isEmpty) return '';

    // Recomposition des mots coupés par un tiret en fin de ligne (ex: "ap-\npeler" -> "appeler")
    final cleaned = rawText.replaceAll(
      RegExp(r'(\p{L}+)[-\u2010\u2013\u2014]\s*\n\s*(\p{L}+)', unicode: true),
      r'$1$2',
    );

    // Séparation par blocs de paragraphes
    final lines = cleaned.split('\n');
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        buffer.write('\n\n');
        continue;
      }

      buffer.write(line);

      if (i < lines.length - 1) {
        if (line.endsWith('.') ||
            line.endsWith('!') ||
            line.endsWith('?') ||
            line.endsWith(':')) {
          buffer.write('\n\n');
        } else {
          buffer.write(' ');
        }
      }
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            isError ? Colors.redAccent.shade700 : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// Transfère le texte numérisé dans le lecteur interactif
  Future<void> _applyToReader() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showNotification('Veuillez d\'abord numériser un texte.', isError: true);
      return;
    }

    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    context.read<AccessibilityProvider>().setText(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AccessibilityProvider>().settings;
    final colors = settings.colors;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Scanner un livre (Hors ligne)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isLowVision ? 22 : 18,
          ),
        ),
        leading: Semantics(
          label: 'Retourner au lecteur',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bannière informative Edge AI & Confidentialité
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isLowVision
                            ? colors.border
                            : colors.border.withValues(alpha: 0.5),
                        width: isLowVision ? 2.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: colors.accent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Traitement 100% sur l\'appareil (Edge AI). Aucune image ni donnée scolaire n\'est transmise sur internet.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Boutons d'action pour numériser (Loi de Fitts, min 52 dp)
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Prendre une photo de la page avec la caméra',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 52),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.accent,
                                foregroundColor: colors.background,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: isLowVision
                                      ? BorderSide(
                                          color: colors.border, width: 2)
                                      : BorderSide.none,
                                ),
                              ),
                              onPressed: _isProcessing
                                  ? null
                                  : () =>
                                      _pickAndProcessImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded,
                                  size: 22),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Prendre photo',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Choisir une image existante dans la galerie',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 52),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.textPrimary,
                                side: BorderSide(
                                  color: colors.border,
                                  width: isLowVision ? 2.5 : 1.5,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isProcessing
                                  ? null
                                  : () =>
                                      _pickAndProcessImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded,
                                  size: 22),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Galerie',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Skeleton Shimmer d'extraction en cours
                  if (_isProcessing)
                    OcrShimmerSkeleton(
                      surfaceColor: colors.surfaceVariant,
                      highlightColor: colors.accent,
                    ),

                  // Prévisualisation de l'image capturée
                  if (_capturedImage != null && !_isProcessing) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.black26,
                        child: Image.file(
                          _capturedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Champ de texte reconnu et modifiable
                  if (_recognizedText.isNotEmpty && !_isProcessing) ...[
                    Text(
                      'TEXTE EXTRAIT DE LA PAGE :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colors.border,
                            width: isLowVision ? 2.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: colors.accent, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bouton d'injection vers le lecteur LiraPlus
                    Semantics(
                      button: true,
                      label: 'Transférer ce texte dans le lecteur adaptatif',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 54),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.background,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: isLowVision
                                  ? BorderSide(color: colors.border, width: 2.5)
                                  : BorderSide.none,
                            ),
                          ),
                          onPressed: _applyToReader,
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 26),
                          label: const Text(
                            'Lire ce texte dans LiraPlus',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
