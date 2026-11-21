import 'dart:async';
import 'package:flutter/material.dart';
import '../models/falc_dictionary.dart';
import '../nlp/french_syllabifier.dart';
import '../services/tts_haptic_service.dart';
import '../storage/preferences_repository.dart';
import '../theme/accessibility_themes.dart';
import '../utils/accessibility_announcer.dart';

/// Provider réactif centralisant les réglages d'accessibilité, la persistance et l'état de lecture
class AccessibilityProvider extends ChangeNotifier {
  final IPreferencesRepository _preferencesRepository;

  AccessibilitySettings _settings =
      AccessibilitySettings.forProfile(AccessibilityProfile.standard);

  String _currentText = FalcDictionary.sampleTexts.first['text']!;
  List<AnalyzedWord> _analyzedWords = [];
  List<SavedTextEntry> _savedTexts = [];
  int? _highlightedWordIndex;
  bool _isInitialized = false;
  bool _isSettingsExplicitlyModified = false;
  Future<void>? _initFuture;

  /// Future complété lorsque le chargement initial depuis le stockage persistant est achevé
  Future<void> get initializationDone => _initFuture ?? Future.value();

  AccessibilityProvider({
    IPreferencesRepository? preferencesRepository,
    bool autoLoad = true,
  }) : _preferencesRepository =
            preferencesRepository ?? LocalPreferencesRepository() {
    _analyzeCurrentText();
    if (autoLoad) {
      _initFuture = _loadSavedState();
    } else {
      _isInitialized = true;
      _initFuture = Future.value();
    }
  }

  AccessibilitySettings get settings => _settings;
  AccessibilityProfile get currentProfile => _settings.profile;
  AccessibilityColors get colors => _settings.colors;
  String get currentText => _currentText;
  List<AnalyzedWord> get analyzedWords => _analyzedWords;
  List<SavedTextEntry> get savedTexts => _savedTexts;
  int? get highlightedWordIndex => _highlightedWordIndex;
  bool get isInitialized => _isInitialized;
  UserProgression _progression = const UserProgression();
  UserProgression get progression => _progression;

  /// Nombre total d'étapes (phrases ou paliers de lecture)
  int get totalSteps =>
      sentenceWordIndices.isEmpty ? 1 : sentenceWordIndices.length;

  /// Étape de lecture courante (commence à 1 pour l'élève)
  int get currentStep => (currentSentenceIndex + 1).clamp(1, totalSteps);

  /// Pourcentage d'accomplissement de la lecture (0.0 à 1.0)
  double get readingProgressPercent =>
      totalSteps <= 0 ? 0.0 : (currentStep / totalSteps).clamp(0.0, 1.0);

  /// Titre honorifique du niveau de lecture de l'enfant
  String get levelTitle => _progression.readerLevelTitle;

  /// Message d'encouragement dynamique et bienveillant selon l'étape
  String get stepEncouragementMessage {
    if (totalSteps <= 1) {
      return 'Bonne lecture ! Prends tout ton temps.';
    }
    if (currentStep == 1) {
      return 'C\'est parti pour l\'aventure ! Étape 1';
    }
    if (currentStep == totalSteps) {
      return 'Bravo champion ! Tu as terminé l\'histoire !';
    }
    if (currentStep >= (totalSteps * 0.75).round()) {
      return 'Plus que quelques phrases, tu y es presque !';
    }
    if (currentStep >= (totalSteps * 0.5).round()) {
      return 'Super ! Tu as franchi la moitié de l\'histoire !';
    }
    return 'Merveilleux ! Continue pas à pas.';
  }

  /// Charge de manière asynchrone les réglages sauvegardés de l'élève
  Future<void> _loadSavedState() async {
    final settingsResult = await _preferencesRepository.loadSettings();
    settingsResult.fold(
      onSuccess: (loadedSettings) {
        if (!_isSettingsExplicitlyModified) {
          _settings = loadedSettings;
        }
      },
      onFailure: (_) {
        // En cas d'erreur de lecture, conservation du profil standard par défaut
      },
    );

    final textResult = await _preferencesRepository.loadLastText();
    textResult.fold(
      onSuccess: (savedText) {
        if (!_isInitialized &&
            savedText != null &&
            savedText.trim().isNotEmpty) {
          _currentText = savedText.trim();
          _analyzeCurrentText();
        }
      },
      onFailure: (_) {},
    );

    final savedTextsResult = await _preferencesRepository.loadSavedTexts();
    savedTextsResult.fold(
      onSuccess: (list) {
        if (_savedTexts.isEmpty && list.isNotEmpty) {
          _savedTexts = list;
        }
      },
      onFailure: (_) {},
    );

    final progResult = await _preferencesRepository.loadProgression();
    progResult.fold(
      onSuccess: (prog) {
        if (_progression == const UserProgression()) {
          _progression = prog;
        }
      },
      onFailure: (_) {},
    );

    _isInitialized = true;
    notifyListeners();
  }

  void _analyzeCurrentText() {
    _analyzedWords = FrenchSyllabifier.analyzeText(_currentText);
    _highlightedWordIndex = null;
    _manualSentenceIndex = 0;
    _ttsStartWordIndex = 0;
  }

  Future<void> _persistSettings() async {
    _isSettingsExplicitlyModified = true;
    await _preferencesRepository.saveSettings(_settings);
  }

  /// Change le profil d'accessibilité complet avec annonce vocale d'accessibilité
  void setProfile(AccessibilityProfile profile) {
    if (_settings.profile == profile) return;

    _settings = AccessibilitySettings.forProfile(profile);
    notifyListeners();
    unawaited(_persistSettings());

    final profileLabel = switch (profile) {
      AccessibilityProfile.standard => 'Standard Titane',
      AccessibilityProfile.lowVision => 'Basse Vision contraste élevé',
      AccessibilityProfile.dyslexia => 'Dyslexie espacement confort',
      AccessibilityProfile.lsqVisual =>
        'Langue des signes québécoise et retours haptiques',
      AccessibilityProfile.nightReading =>
        'Lecture du soir lumière douce sans écran bleu',
    };
    unawaited(AccessibilityAnnouncer.announce('Profil $profileLabel activé'));

    if (profile == AccessibilityProfile.lsqVisual) {
      unawaited(unlockBadge('lsq_explorer'));
    } else if (profile == AccessibilityProfile.nightReading) {
      unawaited(unlockBadge('night_reader'));
    }
  }

  /// Enregistre les mots lus pour faire grandir la progression de l'élève
  Future<void> recordWordsRead(int count) async {
    if (count <= 0) return;
    final updatedBadges = Set<String>.from(_progression.unlockedBadges)
      ..add('first_words');
    final updated = _progression.copyWith(
      totalWordsRead: _progression.totalWordsRead + count,
      stepsCompleted: _progression.stepsCompleted + 1,
      unlockedBadges: updatedBadges,
    );
    _progression = updated;
    notifyListeners();
    await _preferencesRepository.saveProgression(_progression);
  }

  /// Marque une histoire comme terminée avec attribution de trophée
  Future<void> recordStoryCompleted() async {
    final updatedBadges = Set<String>.from(_progression.unlockedBadges)
      ..add('first_story');
    if (_progression.totalStoriesCompleted + 1 >= 3) {
      updatedBadges.add('story_master');
    }
    final updated = _progression.copyWith(
      totalStoriesCompleted: _progression.totalStoriesCompleted + 1,
      unlockedBadges: updatedBadges,
    );
    _progression = updated;
    notifyListeners();
    await _preferencesRepository.saveProgression(_progression);
  }

  /// Débloque un badge pédagogique particulier
  Future<void> unlockBadge(String badgeKey) async {
    if (_progression.unlockedBadges.contains(badgeKey)) return;
    final updatedBadges = Set<String>.from(_progression.unlockedBadges)
      ..add(badgeKey);
    _progression = _progression.copyWith(unlockedBadges: updatedBadges);
    notifyListeners();
    await _preferencesRepository.saveProgression(_progression);
  }

  /// Charge un nouveau texte (ex: issu du scanner OCR ou de la liste d'exemples)
  void setText(String newText) {
    if (newText.trim().isEmpty) return;
    _isInitialized = true;
    _currentText = newText.trim();
    _analyzeCurrentText();
    notifyListeners();
    unawaited(_preferencesRepository.saveLastText(_currentText));
    unawaited(
        AccessibilityAnnouncer.announce('Nouveau texte prêt pour la lecture'));
  }

  /// Met à jour l'index du mot mis en valeur par la synthèse vocale
  void setHighlightedWordIndex(int? index) {
    if (_highlightedWordIndex != index) {
      _highlightedWordIndex = index;
      notifyListeners();
    }
  }

  /// Associe un offset de caractère (fourni par flutter_tts setProgressHandler) à un mot
  /// en tenant compte de l'index de départ du segment lu (_ttsStartWordIndex)
  void updateHighlightFromCharOffset(int charStart) {
    if (_analyzedWords.isEmpty) return;

    final startIndex = _ttsStartWordIndex.clamp(0, _analyzedWords.length - 1);
    int runningLength = 0;
    for (int i = startIndex; i < _analyzedWords.length; i++) {
      final tokenLen = _analyzedWords[i].originalToken.length;
      if (charStart >= runningLength &&
          charStart < runningLength + tokenLen + 1) {
        setHighlightedWordIndex(i);
        return;
      }
      runningLength += tokenLen + 1; // +1 pour l'espace
    }
  }

  /// Modifie la taille de la police de lecture
  void setFontSize(double size) {
    _settings = _settings.copyWith(fontSize: size.clamp(16.0, 42.0));
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Modifie la vitesse de lecture vocale
  void setSpeechRate(double rate) {
    _settings = _settings.copyWith(speechRate: rate.clamp(0.4, 1.2));
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Active ou désactive le guide / règle de lecture
  void toggleReadingRuler() {
    final nextState = !_settings.showReadingRuler;
    _settings = _settings.copyWith(showReadingRuler: nextState);
    notifyListeners();
    unawaited(_persistSettings());
    unawaited(
      AccessibilityAnnouncer.announce(
        nextState ? 'Règle de lecture activée' : 'Règle de lecture masquée',
      ),
    );
  }

  /// Déplace la position verticale du guide de lecture
  void setReadingRulerY(double y) {
    _settings = _settings.copyWith(readingRulerY: y);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Bascule la coloration alternée des syllabes
  void toggleSyllableColoring() {
    final nextState = !_settings.syllableColoringEnabled;
    _settings = _settings.copyWith(syllableColoringEnabled: nextState);
    notifyListeners();
    unawaited(_persistSettings());
    unawaited(
      AccessibilityAnnouncer.announce(
        nextState
            ? 'Coloration des syllabes activée'
            : 'Coloration des syllabes désactivée',
      ),
    );
  }

  /// Bascule l'atténuation des lettres muettes
  void toggleSilentLettersDimmed() {
    final nextState = !_settings.silentLettersDimmed;
    _settings = _settings.copyWith(silentLettersDimmed: nextState);
    notifyListeners();
    unawaited(_persistSettings());
    unawaited(
      AccessibilityAnnouncer.announce(
        nextState
            ? 'Atténuation des lettres muettes activée'
            : 'Atténuation désactivée',
      ),
    );
  }

  /// Bascule l'affichage des arcs de liaison
  void toggleLiaisons() {
    final nextState = !_settings.liaisonsEnabled;
    _settings = _settings.copyWith(liaisonsEnabled: nextState);
    notifyListeners();
    unawaited(_persistSettings());
    unawaited(
      AccessibilityAnnouncer.announce(
        nextState ? 'Arcs de liaison activés' : 'Arcs de liaison masqués',
      ),
    );
  }

  /// Bascule le retour haptique
  void toggleHapticFeedback() {
    final nextState = !_settings.hapticFeedbackEnabled;
    _settings = _settings.copyWith(hapticFeedbackEnabled: nextState);
    notifyListeners();
    unawaited(_persistSettings());
    unawaited(
      AccessibilityAnnouncer.announce(
        nextState
            ? 'Retours haptiques activés'
            : 'Retours haptiques désactivés',
      ),
    );
  }

  /// Bascule la mise en lumière des sons complexes (ou, oi, on, an, ch, eau...)
  void toggleComplexGraphemes() {
    final nextState = !_settings.complexGraphemesHighlighted;
    _settings = _settings.copyWith(complexGraphemesHighlighted: nextState);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Bascule les pictogrammes visuels au-dessus des mots (Pont Visuel LSQ)
  void toggleVisualPictograms() {
    final nextState = !_settings.visualPictogramsEnabled;
    _settings = _settings.copyWith(visualPictogramsEnabled: nextState);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Bascule le Cache-Lignes opaque TDAH autour de la règle de lecture
  void toggleOpaqueRulerMask() {
    final nextState = !_settings.opaqueRulerMask;
    _settings = _settings.copyWith(opaqueRulerMask: nextState);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Bascule le mode Mot Géant / Téléprompteur (Basse Vision)
  void toggleGiantWordMode() {
    final nextState = !_settings.giantWordMode;
    _settings = _settings.copyWith(giantWordMode: nextState);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Bascule la lecture académique avec pause respiratoire entre chaque mot
  void toggleStepByStepPauses() {
    final nextState = !_settings.stepByStepPauses;
    _settings = _settings.copyWith(stepByStepPauses: nextState);
    notifyListeners();
    unawaited(_persistSettings());
  }

  /// Vérifie si un mot est dans le Coffre à Mots personnel (LSQ)
  bool isFavoriteWord(String rawWord) {
    final clean = rawWord.toLowerCase().trim();
    return _progression.favoriteWords.contains(clean);
  }

  /// Ajoute ou retire un mot du Coffre à Mots personnel (100 % hors ligne)
  Future<void> toggleFavoriteWord(String rawWord) async {
    final clean = rawWord.toLowerCase().trim();
    if (clean.isEmpty) return;
    final updatedFavorites = Set<String>.from(_progression.favoriteWords);
    final bool added;
    if (updatedFavorites.contains(clean)) {
      updatedFavorites.remove(clean);
      added = false;
    } else {
      updatedFavorites.add(clean);
      added = true;
    }
    _progression = _progression.copyWith(favoriteWords: updatedFavorites);
    notifyListeners();
    await _preferencesRepository.saveProgression(_progression);
    unawaited(
      AccessibilityAnnouncer.announce(
        added
            ? 'Mot ajouté à ton coffre à mots'
            : 'Mot retiré du coffre à mots',
      ),
    );
  }

  /// Ajoute une liste de mots au Coffre à Mots (ex: mots scolaires d'initiation)
  Future<void> addFavoriteWords(Iterable<String> words) async {
    final updatedFavorites = Set<String>.from(_progression.favoriteWords);
    for (final raw in words) {
      final clean = raw.toLowerCase().trim();
      if (clean.isNotEmpty) {
        updatedFavorites.add(clean);
      }
    }
    _progression = _progression.copyWith(favoriteWords: updatedFavorites);
    notifyListeners();
    await _preferencesRepository.saveProgression(_progression);
    unawaited(
      AccessibilityAnnouncer.announce(
        'Mots de l\'école ajoutés au coffre avec succès',
      ),
    );
  }

  /// Fait défiler rapidement la vitesse de lecture vocale (0.5x -> 0.75x -> 1.0x -> 0.5x)
  Future<void> cycleSpeechRate(ITtsHapticService ttsService) async {
    final current = _settings.speechRate;
    final double nextRate;
    final String label;

    if (current < 0.7) {
      nextRate = 0.75;
      label = 'Vitesse confort 0.75 fois';
    } else if (current < 0.95) {
      nextRate = 1.0;
      label = 'Vitesse normale 1.0 fois';
    } else {
      nextRate = 0.5;
      label = 'Vitesse lente 0.5 fois pour apprentissage';
    }

    setSpeechRate(nextRate);
    await ttsService.setRate(nextRate);
    unawaited(AccessibilityAnnouncer.announce(label, withHaptic: true));
  }

  /// Sauvegarde le texte actuellement ouvert dans la bibliothèque locale de l'élève
  Future<void> saveCurrentText(String title) async {
    final entry = SavedTextEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Page scannée sans titre' : title.trim(),
      text: _currentText,
      createdAt: DateTime.now(),
    );

    await _preferencesRepository.saveCustomText(entry);
    _savedTexts.removeWhere((item) => item.id == entry.id);
    _savedTexts.insert(0, entry);
    notifyListeners();
    unawaited(AccessibilityAnnouncer.announce(
        'Texte sauvegardé dans votre bibliothèque'));
  }

  /// Supprime un texte de la bibliothèque locale
  Future<void> deleteSavedText(String id) async {
    await _preferencesRepository.deleteCustomText(id);
    _savedTexts.removeWhere((item) => item.id == id);
    notifyListeners();
    unawaited(AccessibilityAnnouncer.announce('Texte supprimé'));
  }

  /// Découpe les mots en phrases selon la ponctuation finale (. ! ? ou saut de ligne)
  List<List<int>> get sentenceWordIndices {
    if (_analyzedWords.isEmpty) return const [];
    final List<List<int>> sentences = [];
    final List<int> currentSentence = [];

    for (int i = 0; i < _analyzedWords.length; i++) {
      currentSentence.add(i);
      final punct = _analyzedWords[i].trailingPunctuation;
      if (punct.contains('.') ||
          punct.contains('!') ||
          punct.contains('?') ||
          punct.contains('\n')) {
        sentences.add(List.from(currentSentence));
        currentSentence.clear();
      }
    }
    if (currentSentence.isNotEmpty) {
      sentences.add(currentSentence);
    }
    return sentences;
  }

  bool _isFocusSentenceMode = true;
  bool _isAcademicSyllabicReading = false;
  int _manualSentenceIndex = 0;
  int _ttsStartWordIndex = 0;

  bool get isFocusSentenceMode => _isFocusSentenceMode;
  bool get isAcademicSyllabicReading => _isAcademicSyllabicReading;

  /// Bascule entre le mode Carte Phrase Focus (idéal enfants/dyslexie) et le mode Livre Complet
  void toggleFocusSentenceMode() {
    _isFocusSentenceMode = !_isFocusSentenceMode;
    notifyListeners();
    unawaited(
      AccessibilityAnnouncer.announce(
        _isFocusSentenceMode
            ? 'Mode Carte Phrase active activé'
            : 'Mode Page de livre complète activé',
      ),
    );
  }

  /// Bascule le mode de lecture académique syllabique pas-à-pas
  void toggleAcademicSyllabicReading() {
    _isAcademicSyllabicReading = !_isAcademicSyllabicReading;
    notifyListeners();
    unawaited(
      AccessibilityAnnouncer.announce(
        _isAcademicSyllabicReading
            ? 'Mode d\'apprentissage syllabique pas-à-pas activé'
            : 'Mode de lecture fluide activé',
      ),
    );
  }

  /// Récupère l'index de la phrase active en cours de lecture
  int get currentSentenceIndex {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return 0;
    final currentWord = _highlightedWordIndex;
    if (currentWord != null) {
      for (int s = 0; s < sentences.length; s++) {
        if (sentences[s].contains(currentWord)) {
          _manualSentenceIndex = s;
          return s;
        }
      }
    }
    return _manualSentenceIndex.clamp(0, sentences.length - 1);
  }

  /// Va manuellement à la phrase précédente sans forcer la lecture
  void goToPreviousSentence() {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return;
    _manualSentenceIndex =
        (_manualSentenceIndex - 1).clamp(0, sentences.length - 1);
    final firstWord = sentences[_manualSentenceIndex].first;
    setHighlightedWordIndex(firstWord);
  }

  /// Va manuellement à la phrase suivante sans forcer la lecture
  void goToNextSentence() {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return;
    _manualSentenceIndex =
        (_manualSentenceIndex + 1).clamp(0, sentences.length - 1);
    final firstWord = sentences[_manualSentenceIndex].first;
    setHighlightedWordIndex(firstWord);
  }

  /// Écoute la phrase précédente
  Future<void> playPreviousSentence(ITtsHapticService ttsService) async {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return;
    final currentIndex = currentSentenceIndex;
    final targetIndex = (currentIndex - 1).clamp(0, sentences.length - 1);
    _manualSentenceIndex = targetIndex;
    await _playSentenceAtIndex(targetIndex, ttsService);
  }

  /// Répète la phrase actuelle
  Future<void> repeatCurrentSentence(ITtsHapticService ttsService) async {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return;
    await _playSentenceAtIndex(currentSentenceIndex, ttsService);
  }

  /// Écoute la phrase suivante
  Future<void> playNextSentence(ITtsHapticService ttsService) async {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) return;
    final currentIndex = currentSentenceIndex;
    final targetIndex = (currentIndex + 1).clamp(0, sentences.length - 1);
    _manualSentenceIndex = targetIndex;
    await _playSentenceAtIndex(targetIndex, ttsService);
  }

  /// Lit en continu à partir de la phrase active jusqu'à la fin du texte
  Future<void> playFromCurrentSentence(ITtsHapticService ttsService) async {
    final sentences = sentenceWordIndices;
    if (sentences.isEmpty) {
      _ttsStartWordIndex = 0;
      await ttsService.speak(_currentText);
      return;
    }
    final sIndex = currentSentenceIndex.clamp(0, sentences.length - 1);
    final startWordIdx = sentences[sIndex].first;
    _manualSentenceIndex = sIndex;
    _ttsStartWordIndex = startWordIdx;
    setHighlightedWordIndex(startWordIdx);

    final remainingText = _analyzedWords
        .sublist(startWordIdx)
        .map((w) => w.originalToken)
        .join(' ');
    await ttsService.speak(remainingText);
  }

  Future<void> _playSentenceAtIndex(
      int sIndex, ITtsHapticService ttsService) async {
    final sentences = sentenceWordIndices;
    if (sIndex < 0 || sIndex >= sentences.length) return;
    final wordIndices = sentences[sIndex];
    if (wordIndices.isEmpty) return;

    _manualSentenceIndex = sIndex;
    _ttsStartWordIndex = wordIndices.first;
    setHighlightedWordIndex(wordIndices.first);
    final sentenceText =
        wordIndices.map((i) => _analyzedWords[i].originalToken).join(' ');
    await ttsService.speak(sentenceText);
  }
}
