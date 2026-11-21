import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/nlp/french_syllabifier.dart';
import '../../core/providers/accessibility_provider.dart';
import '../../core/services/tts_haptic_service.dart';
import '../../core/theme/accessibility_themes.dart';
import '../faq/faq_screen.dart';
import '../scanner/ocr_camera_screen.dart';
import 'presentation/widgets/display_settings_sheet.dart';
import 'presentation/widgets/giant_word_teleprompter.dart';
import 'presentation/widgets/interactive_text_flow.dart';
import 'presentation/widgets/lsq_reader_panel.dart';
import 'presentation/widgets/profile_selector_bar.dart';
import 'presentation/widgets/progression_dashboard_sheet.dart';
import 'presentation/widgets/reader_bottom_bar.dart';
import 'presentation/widgets/reading_celebration_sheet.dart';
import 'presentation/widgets/reading_ruler_overlay.dart';
import 'presentation/widgets/sample_text_sheet.dart';
import 'presentation/widgets/word_vault_sheet.dart';
import 'word_coach_sheet.dart';

/// Écran principal de lecture interactive et inclusive LiraPlus
class ReaderScreen extends StatefulWidget {
  final ITtsHapticService? ttsService;

  const ReaderScreen({super.key, this.ttsService});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  late final ITtsHapticService _ttsService;
  bool _isAudioLoading = false;
  bool _isStepPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ttsService = widget.ttsService ?? TtsHapticService();
    _initTts();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sécurité de cycle de vie : Arrêt immédiat de l'audio si l'application passe en arrière-plan
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _ttsService.stop();
      if (mounted) {
        setState(() => _isAudioLoading = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    final provider = context.read<AccessibilityProvider>();

    _ttsService.onStart = () {
      if (!mounted) return;
      setState(() => _isAudioLoading = false);
    };

    _ttsService.onProgress = (String text, int start, int end, String word) {
      if (!mounted) return;
      provider.updateHighlightFromCharOffset(start);
    };

    _ttsService.onComplete = () {
      if (!mounted) return;
      if (_ttsService.isSpeakingSingleWord) return;

      final wasAtEnd = provider.highlightedWordIndex != null &&
          provider.highlightedWordIndex! >= provider.analyzedWords.length - 2;
      provider.setHighlightedWordIndex(null);
      setState(() => _isAudioLoading = false);

      if (wasAtEnd && provider.analyzedWords.isNotEmpty) {
        unawaited(provider.recordStoryCompleted());
        unawaited(provider.recordWordsRead(provider.analyzedWords.length));
        ReadingCelebrationSheet.show(
          context,
          wordsCount: provider.analyzedWords.length,
          colors: provider.colors,
          storyText: provider.currentText,
          onReplay: _togglePlayPause,
          onChooseAnother: _showSampleSelector,
        );
      }
    };

    // Gestion d'erreur fail-secure sans divulgation technique (CWE-209 & Règle 10/7)
    _ttsService.onError = (String error) {
      if (!mounted) return;
      setState(() => _isAudioLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.contains('Impossible') || error.contains('refusé')
                ? error
                : 'La synthèse vocale n\'a pas pu démarrer. Vérifiez que le volume multimédia de l\'appareil est activé.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    };

    await _ttsService.init();
    await _ttsService.setRate(provider.settings.speechRate);
  }

  Future<void> _togglePlayPause() async {
    final provider = context.read<AccessibilityProvider>();
    if (_ttsService.isPlaying || _isStepPlaying) {
      _isStepPlaying = false;
      await _ttsService.stop();
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    } else {
      setState(() => _isAudioLoading = true);
      await _ttsService.setRate(provider.settings.speechRate);

      if (provider.settings.stepByStepPauses) {
        // Lecture académique pas-à-pas avec pause respiratoire entre chaque mot
        unawaited(_playActiveSentenceWithWordPauses(provider));
        return;
      }

      if (provider.isFocusSentenceMode) {
        // En mode Focus Phrase (Pédagogique) : lecture de la phrase active uniquement
        await provider.repeatCurrentSentence(_ttsService);
      } else {
        // En mode Page entière : lecture continue à partir de la phrase active
        await provider.playFromCurrentSentence(_ttsService);
      }

      // Timeout de sécurité pour réactiver le bouton si le moteur tarde à répondre
      Future<void>.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _isAudioLoading) {
          setState(() => _isAudioLoading = false);
        }
      });
    }
  }

  /// Lit chaque mot de la phrase active avec une pause respiratoire pédagogique (550 ms)
  Future<void> _playActiveSentenceWithWordPauses(
      AccessibilityProvider provider) async {
    final sentences = provider.sentenceWordIndices;
    if (sentences.isEmpty) {
      if (mounted) setState(() => _isAudioLoading = false);
      return;
    }

    final sIndex = provider.currentSentenceIndex.clamp(0, sentences.length - 1);
    final wordIndices = sentences[sIndex];
    _isStepPlaying = true;
    if (mounted) setState(() => _isAudioLoading = false);

    for (final wordIdx in wordIndices) {
      if (!mounted || !_isStepPlaying) break;
      final word = provider.analyzedWords[wordIdx];
      provider.setHighlightedWordIndex(wordIdx);

      final spoken = word.cleanWord.trim().isNotEmpty
          ? word.cleanWord.trim()
          : word.originalToken.trim();
      if (spoken.isNotEmpty) {
        await _ttsService.speakWordWithHaptic(
          spoken,
          word.syllables,
          enableHaptics: provider.settings.hapticFeedbackEnabled,
        );
      }

      // Temps respiratoire pédagogique calibré selon la longueur du mot
      final pauseMs = (550 + (word.syllables.length * 180)).clamp(650, 1450);
      await Future<void>.delayed(Duration(milliseconds: pauseMs));
    }

    if (mounted) {
      setState(() => _isStepPlaying = false);
    }
  }

  Future<void> _handlePreviousSentence() async {
    final provider = context.read<AccessibilityProvider>();
    _isStepPlaying = false;
    await _ttsService.stop();
    if (!mounted) return;
    if (provider.settings.stepByStepPauses) {
      provider.goToPreviousSentence();
      unawaited(_playActiveSentenceWithWordPauses(provider));
    } else {
      await provider.playPreviousSentence(_ttsService);
    }
  }

  Future<void> _handleNextSentence() async {
    final provider = context.read<AccessibilityProvider>();
    _isStepPlaying = false;
    await _ttsService.stop();
    if (!mounted) return;
    if (provider.settings.stepByStepPauses) {
      provider.goToNextSentence();
      unawaited(_playActiveSentenceWithWordPauses(provider));
    } else {
      await provider.playNextSentence(_ttsService);
    }
  }

  void _openWordVault() {
    unawaited(HapticFeedback.lightImpact());
    final provider = context.read<AccessibilityProvider>();
    WordVaultSheet.show(
      context,
      provider: provider,
      ttsService: _ttsService,
    );
  }

  Future<void> _handleCycleSpeed() async {
    final provider = context.read<AccessibilityProvider>();
    final isCurrentlyPlaying = _ttsService.isPlaying;
    final currentWordIdx = provider.highlightedWordIndex;

    // Bascule la vitesse (0.5x -> 0.75x -> 1.0x -> 0.5x)
    await provider.cycleSpeechRate(_ttsService);

    // Si la lecture est en cours, réapplique immédiatement la nouvelle vitesse
    if (isCurrentlyPlaying) {
      final words = provider.analyzedWords;
      if (currentWordIdx != null && currentWordIdx < words.length) {
        final remainingText =
            words.sublist(currentWordIdx).map((w) => w.originalToken).join(' ');
        await _ttsService.speak(remainingText);
      } else {
        await _ttsService.speak(provider.currentText);
      }
    }
  }

  void _openWordCoach(AnalyzedWord word) {
    final provider = context.read<AccessibilityProvider>();
    unawaited(HapticFeedback.lightImpact());
    WordCoachSheet.show(
      context,
      word: word,
      settings: provider.settings,
      ttsService: _ttsService,
    );
  }

  void _showSampleSelector() {
    unawaited(HapticFeedback.selectionClick());
    final provider = context.read<AccessibilityProvider>();
    SampleTextSheet.show(context, provider);
  }

  void _showSettings() {
    unawaited(HapticFeedback.selectionClick());
    final provider = context.read<AccessibilityProvider>();
    DisplaySettingsSheet.show(context,
        provider: provider, ttsService: _ttsService);
  }

  void _openScanner() {
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OcrCameraScreen(),
      ),
    );
  }

  void _openFaq() {
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FaqScreen(),
      ),
    );
  }

  void _openCarnet() {
    unawaited(HapticFeedback.lightImpact());
    final provider = context.read<AccessibilityProvider>();
    ProgressionDashboardSheet.show(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccessibilityProvider>();
    final settings = provider.settings;
    final colors = settings.colors;
    final isLowVision = settings.profile == AccessibilityProfile.lowVision;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        titleSpacing: 12,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LiraPlus',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  fontSize: isLowVision ? 24 : 20,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'Hors Ligne',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: colors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // 1. Ouvrir le carnet de progression / trophées
          Semantics(
            button: true,
            label: 'Ouvrir mon carnet de lecture et voir mes trophées',
            child: IconButton(
              icon: const Icon(Icons.emoji_events_rounded, size: 22),
              color: Colors.amber.shade700,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              padding: EdgeInsets.zero,
              onPressed: _openCarnet,
            ),
          ),

          // 2. Sélectionner une histoire ou un texte
          Semantics(
            button: true,
            label: 'Sélectionner une histoire d\'exemple ou un devoir',
            child: IconButton(
              icon: const Icon(Icons.collections_bookmark_rounded, size: 22),
              color: colors.textPrimary,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              padding: EdgeInsets.zero,
              onPressed: _showSampleSelector,
            ),
          ),

          // 3. Réglages d'affichage et aides visuelles
          Semantics(
            button: true,
            label: 'Ouvrir les réglages d\'affichage et aides de lecture',
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, size: 22),
              color: colors.textPrimary,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              padding: EdgeInsets.zero,
              onPressed: _showSettings,
            ),
          ),

          // 4. Menu déroulant sécurisé pour les fonctionnalités complémentaires (Anti-Overflow garanti)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: colors.textPrimary, size: 22),
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border, width: 1.5),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            onSelected: (value) {
              if (value == 'vault') {
                _openWordVault();
              } else if (value == 'giant') {
                provider.toggleGiantWordMode();
              } else if (value == 'faq') {
                _openFaq();
              } else if (value == 'celebration') {
                ReadingCelebrationSheet.show(
                  context,
                  wordsCount: provider.analyzedWords.length,
                  colors: colors,
                  storyText: provider.currentText,
                  onReplay: _togglePlayPause,
                  onChooseAnother: _showSampleSelector,
                );
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'vault',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: colors.accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Coffre à Mots LSQ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'giant',
                child: Row(
                  children: [
                    Icon(
                      settings.giantWordMode
                          ? Icons.close_fullscreen_rounded
                          : Icons.zoom_in_rounded,
                      color: colors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      settings.giantWordMode
                          ? 'Quitter Mot Géant'
                          : 'Mode Mot Géant',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'faq',
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded,
                        color: colors.accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Guide & FAQ Parents',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'celebration',
                child: Row(
                  children: [
                    Icon(Icons.celebration_rounded,
                        color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Question Éclair & Bravo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Barre de sélection rapide des profils d'accessibilité (Standard, Basse Vision, Dyslexie, LSQ, Soir)
              ProfileSelectorBar(provider: provider),

              // 2. Carte LSQ compacte et FIXE en haut en mode Portrait (zéro scroll pour voir signe + texte ensemble)
              if (settings.profile == AccessibilityProfile.lsqVisual &&
                  provider.analyzedWords.isNotEmpty &&
                  !settings.giantWordMode &&
                  MediaQuery.of(context).size.height >= 480)
                LsqReaderPanel(
                  provider: provider,
                  ttsService: _ttsService,
                ),

              // 3. Zone interactive centrale (Texte aéré ou Mode Mot Géant avec gestes swipe)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < -300) {
                      unawaited(_handleNextSentence());
                    } else if (velocity > 300) {
                      unawaited(_handlePreviousSentence());
                    }
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // En mode Paysage très bas (< 480 dp), le panneau LSQ défile avec le texte (0 overflow)
                              if (settings.profile ==
                                      AccessibilityProfile.lsqVisual &&
                                  provider.analyzedWords.isNotEmpty &&
                                  !settings.giantWordMode &&
                                  MediaQuery.of(context).size.height < 480)
                                LsqReaderPanel(
                                  provider: provider,
                                  ttsService: _ttsService,
                                ),
                              if (settings.giantWordMode &&
                                  provider.analyzedWords.isNotEmpty)
                                GiantWordTeleprompter(
                                  provider: provider,
                                  ttsService: _ttsService,
                                  onOpenWordCoach: _openWordCoach,
                                )
                              else
                                InteractiveTextFlow(
                                  provider: provider,
                                  ttsService: _ttsService,
                                  onOpenSampleSelector: _showSampleSelector,
                                  onOpenScanner: _openScanner,
                                  onOpenWordCoach: _openWordCoach,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Pupitre Magique Unifié en bas (Thumb Zone)
              ReaderBottomBar(
                provider: provider,
                isPlaying: _ttsService.isPlaying || _isStepPlaying,
                isAudioLoading: _isAudioLoading,
                onTogglePlayPause: _togglePlayPause,
                onPreviousSentence: _handlePreviousSentence,
                onNextSentence: _handleNextSentence,
                onOpenScanner: _openScanner,
                onCycleSpeed: _handleCycleSpeed,
                onToggleFocusMode: provider.toggleFocusSentenceMode,
              ),
            ],
          ),

          // 5. Guide / Règle de lecture horizontale avec Cache-Lignes TDAH
          if (settings.showReadingRuler && !settings.giantWordMode)
            ReadingRulerOverlay(provider: provider),
        ],
      ),
    );
  }
}
