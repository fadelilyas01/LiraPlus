import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Statut de la lecture vocale
enum TtsPlaybackState {
  stopped,
  playing,
  paused,
}

/// Contrat abstrait de synthèse vocale et d'haptique (Clean Architecture)
abstract class ITtsHapticService {
  TtsPlaybackState get state;
  bool get isPlaying;
  bool get isSpeakingSingleWord;

  void Function()? onStart;
  void Function(String text, int start, int end, String word)? onProgress;
  void Function()? onComplete;
  void Function(String error)? onError;

  Future<void> init();
  Future<void> setRate(double rate);
  Future<void> speak(String text);
  Future<void> speakWordWithHaptic(
    String word,
    List<String> syllables, {
    bool enableHaptics = true,
  });
  Future<void> playSyllableHapticPattern(List<String> syllables);
  Future<void> triggerSingleSyllableHaptic({required bool isStressed});
  Future<void> stop();
  Future<void> pause();
  void dispose();
}

/// Service autonome et résilient de synthèse vocale québécoise/française et de vibration haptique
class TtsHapticService implements ITtsHapticService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsPlaybackState _state = TtsPlaybackState.stopped;
  bool _isSpeakingSingleWord = false;
  double _currentRate = 0.85;

  @override
  void Function()? onStart;
  @override
  void Function(String text, int start, int end, String word)? onProgress;
  @override
  void Function()? onComplete;
  @override
  void Function(String error)? onError;

  @override
  TtsPlaybackState get state => _state;
  @override
  bool get isPlaying => _state == TtsPlaybackState.playing;
  @override
  bool get isSpeakingSingleWord => _isSpeakingSingleWord;

  /// Initialise le moteur TTS avec détection intelligente des voix françaises et routage audio robuste
  @override
  Future<void> init() async {
    try {
      // 1. Ne pas bloquer de façon synchrone le flux principal
      await _flutterTts.awaitSpeakCompletion(false);

      // 2. Configuration spécifique iOS : Forcer le canal 'playback' (joue même en mode silencieux)
      if (Platform.isIOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      // 3. Configuration spécifique Android : Privilégier Google TTS si disponible
      if (Platform.isAndroid) {
        try {
          final dynamic engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      // 4. Détection robuste de la langue avec priorité au français canadien (fr-CA / Québec)
      String selectedLanguage = 'fr-CA';
      try {
        final dynamic languages = await _flutterTts.getLanguages;
        if (languages is List && languages.isNotEmpty) {
          final langList = languages
              .map((e) => e.toString().toLowerCase().replaceAll('_', '-'))
              .toList();

          if (langList.contains('fr-ca')) {
            selectedLanguage = 'fr-CA';
          } else if (langList.contains('fr-fr')) {
            selectedLanguage = 'fr-FR';
          } else if (langList.any((l) => l.startsWith('fr-'))) {
            final matched = langList.firstWhere((l) => l.startsWith('fr-'));
            selectedLanguage = matched;
          } else if (langList.contains('fr')) {
            selectedLanguage = 'fr';
          }
        }
      } catch (_) {}

      await _flutterTts.setLanguage(selectedLanguage);
      await _flutterTts
          .setSpeechRate(0.48); // Vitesse modérée pour l'apprentissage
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // 5. Gestionnaires d'événements
      _flutterTts.setStartHandler(() {
        _state = TtsPlaybackState.playing;
        onStart?.call();
      });

      _flutterTts
          .setProgressHandler((String text, int start, int end, String word) {
        // En mode mot isolé, ne pas transmettre l'offset de progression
        // pour éviter d'écraser l'index du document global et de faire sauter le scroll
        if (_isSpeakingSingleWord) return;
        onProgress?.call(text, start, end, word);
      });

      _flutterTts.setCompletionHandler(() {
        _state = TtsPlaybackState.stopped;
        final wasSingleWord = _isSpeakingSingleWord;
        _isSpeakingSingleWord = false;
        if (!wasSingleWord) {
          onComplete?.call();
        }
      });

      _flutterTts.setCancelHandler(() {
        _state = TtsPlaybackState.stopped;
        final wasSingleWord = _isSpeakingSingleWord;
        _isSpeakingSingleWord = false;
        if (!wasSingleWord) {
          onComplete?.call();
        }
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        _state = TtsPlaybackState.stopped;
        _isSpeakingSingleWord = false;
        onError?.call(msg.toString());
      });
    } catch (e) {
      onError?.call('Erreur initialisation TTS : $e');
    }
  }

  /// Met à jour la vitesse de lecture vocale adaptée selon la plateforme (Android vs iOS)
  /// Calibré spécifiquement pour l'apprentissage de la lecture chez l'enfant :
  /// tempo doux, articulé, apaisant et jamais précipité.
  @override
  Future<void> setRate(double rate) async {
    _currentRate = rate;
    try {
      final double nativeRate;
      if (Platform.isIOS) {
        // Sur iOS : débit doux d'histoire contée (0.5x -> 0.22, 0.75x -> 0.32, 1.0x -> 0.42)
        nativeRate = (rate * 0.42).clamp(0.18, 0.55);
      } else {
        // Sur Android : rythme posé d'album jeunesse (0.5x -> 0.34, 0.75x -> 0.51, 1.0x -> 0.68)
        nativeRate = (rate * 0.68).clamp(0.28, 0.85);
      }
      await _flutterTts.setSpeechRate(nativeRate);
    } catch (_) {}
  }

  /// Lit un texte complet à voix haute
  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      _isSpeakingSingleWord = false;
      await _flutterTts.stop();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await setRate(_currentRate);
      _state = TtsPlaybackState.playing;
      final dynamic result = await _flutterTts.speak(text);

      // Sur Android, 0 indique que le moteur a refusé la lecture (voix manquante ou erreur)
      if (result == 0) {
        _state = TtsPlaybackState.stopped;
        onError
            ?.call('Le moteur vocal de l\'appareil n\'a pas pu lire le texte.');
      }
    } catch (e) {
      _isSpeakingSingleWord = false;
      _state = TtsPlaybackState.stopped;
      onError?.call('Impossible de lire le texte : $e');
    }
  }

  /// Lit un mot unique clairement avec vibration haptique synchronisée
  @override
  Future<void> speakWordWithHaptic(
    String word,
    List<String> syllables, {
    bool enableHaptics = true,
  }) async {
    final clean = word.trim();
    if (clean.isEmpty) return;
    try {
      _isSpeakingSingleWord = true;
      await _flutterTts.stop();
      // Temporisation technique (60ms) pour garantir que le service audio natif
      // a finalisé son arrêt avant d'initier la nouvelle élocution
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await setRate(_currentRate);
      _state = TtsPlaybackState.playing;

      final dynamic result = await _flutterTts.speak(clean);
      if (result == 0) {
        // Secours en cas de refus temporaire du moteur TTS
        await _flutterTts.setVolume(1.0);
        await _flutterTts.speak(clean);
      }

      if (enableHaptics && syllables.isNotEmpty) {
        unawaited(_playSyllableHaptics(syllables));
      }
    } catch (e) {
      _isSpeakingSingleWord = false;
      _state = TtsPlaybackState.stopped;
      onError?.call('Erreur lecture mot : $e');
    }
  }

  /// Émet une vibration rythmée par syllabe (atone légère, tonique finale forte)
  @override
  Future<void> playSyllableHapticPattern(List<String> syllables) async {
    await _playSyllableHaptics(syllables);
  }

  Future<void> _playSyllableHaptics(List<String> syllables) async {
    for (int i = 0; i < syllables.length; i++) {
      final isLastSyllable = (i == syllables.length - 1);
      if (isLastSyllable) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
      await Future<void>.delayed(const Duration(milliseconds: 280));
    }
  }

  /// Émet un retour haptique unique pour une syllabe
  @override
  Future<void> triggerSingleSyllableHaptic({required bool isStressed}) async {
    if (isStressed) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  /// Arrête la lecture vocale
  @override
  Future<void> stop() async {
    _isSpeakingSingleWord = false;
    try {
      await _flutterTts.stop();
      _state = TtsPlaybackState.stopped;
    } catch (_) {}
  }

  /// Met en pause la lecture vocale
  @override
  Future<void> pause() async {
    _isSpeakingSingleWord = false;
    try {
      await _flutterTts.pause();
      _state = TtsPlaybackState.paused;
    } catch (_) {}
  }

  /// Libération des ressources
  @override
  void dispose() {
    _isSpeakingSingleWord = false;
    try {
      _flutterTts.stop();
    } catch (_) {}
  }
}
