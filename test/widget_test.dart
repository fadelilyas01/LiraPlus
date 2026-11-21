import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liraplus/core/errors/failures.dart';
import 'package:liraplus/core/models/dactylology_data.dart';
import 'package:liraplus/core/models/falc_dictionary.dart';
import 'package:liraplus/core/nlp/french_syllabifier.dart';
import 'package:liraplus/core/nlp/lsq_semantic_engine.dart';
import 'package:liraplus/core/providers/accessibility_provider.dart';
import 'package:liraplus/core/services/tts_haptic_service.dart';
import 'package:liraplus/core/storage/preferences_repository.dart';
import 'package:liraplus/core/theme/accessibility_themes.dart';
import 'package:liraplus/core/utils/accessibility_announcer.dart';
import 'package:liraplus/core/widgets/error_boundary_widget.dart';
import 'package:liraplus/features/faq/faq_screen.dart';
import 'package:liraplus/features/reader/presentation/alphabet_workshop_screen.dart';
import 'package:liraplus/features/reader/presentation/widgets/alphabet_quiz_sheet.dart';
import 'package:liraplus/features/reader/presentation/widgets/lsq_handshape_widget.dart';
import 'package:liraplus/features/reader/presentation/widgets/lsq_motion_viewer.dart';
import 'package:liraplus/features/reader/presentation/widgets/lsq_reader_panel.dart';
import 'package:liraplus/features/reader/presentation/widgets/lsq_speller_player.dart';
import 'package:liraplus/features/reader/presentation/widgets/profile_selector_bar.dart';
import 'package:liraplus/features/reader/presentation/widgets/reader_bottom_bar.dart';
import 'package:liraplus/features/reader/presentation/widgets/reading_celebration_sheet.dart';
import 'package:liraplus/features/reader/presentation/widgets/syllable_puzzle_game.dart';
import 'package:liraplus/features/reader/presentation/widgets/word_item_widget.dart';
import 'package:liraplus/features/reader/presentation/widgets/giant_word_teleprompter.dart';
import 'package:liraplus/features/reader/presentation/widgets/word_vault_sheet.dart';
import 'package:liraplus/main.dart';

/// Dépôt en mémoire pour les tests unitaires isolés
class InMemoryPreferencesRepository implements IPreferencesRepository {
  AccessibilitySettings? savedSettings;
  String? savedText;
  final List<SavedTextEntry> customTexts = [];

  @override
  Future<Result<AccessibilitySettings>> loadSettings() async {
    return Success(
      savedSettings ??
          AccessibilitySettings.forProfile(AccessibilityProfile.standard),
    );
  }

  @override
  Future<Result<void>> saveSettings(AccessibilitySettings settings) async {
    savedSettings = settings;
    return const Success(null);
  }

  @override
  Future<Result<String?>> loadLastText() async {
    return Success(savedText);
  }

  @override
  Future<Result<void>> saveLastText(String text) async {
    savedText = text;
    return const Success(null);
  }

  @override
  Future<Result<List<SavedTextEntry>>> loadSavedTexts() async {
    return Success(List.from(customTexts));
  }

  @override
  Future<Result<void>> saveCustomText(SavedTextEntry entry) async {
    customTexts.removeWhere((item) => item.id == entry.id);
    customTexts.insert(0, entry);
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteCustomText(String id) async {
    customTexts.removeWhere((item) => item.id == id);
    return const Success(null);
  }

  UserProgression progression = const UserProgression();

  @override
  Future<Result<UserProgression>> loadProgression() async {
    return Success(progression);
  }

  @override
  Future<Result<void>> saveProgression(UserProgression p) async {
    progression = p;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    savedSettings = null;
    savedText = null;
    customTexts.clear();
    progression = const UserProgression();
    return const Success(null);
  }
}

class FakeTtsService implements ITtsHapticService {
  double currentRate = 0.85;
  String? lastSpokenWord;
  List<String>? lastSpokenSyllables;
  bool isSpeakingSingleWordInternal = false;

  @override
  bool get isSpeakingSingleWord => isSpeakingSingleWordInternal;

  @override
  void Function()? onComplete;
  @override
  void Function(String error)? onError;
  @override
  void Function(String text, int start, int end, String word)? onProgress;
  @override
  void Function()? onStart;

  @override
  bool get isPlaying => false;

  @override
  TtsPlaybackState get state => TtsPlaybackState.stopped;

  @override
  void dispose() {}

  @override
  Future<void> init() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playSyllableHapticPattern(List<String> syllables) async {}

  @override
  Future<void> setRate(double rate) async {
    currentRate = rate;
  }

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> speakWordWithHaptic(String word, List<String> syllables,
      {bool enableHaptics = true}) async {
    lastSpokenWord = word;
    lastSpokenSyllables = syllables;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> triggerSingleSyllableHaptic({required bool isStressed}) async {}
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Result & Failure Pattern Tests (Architecture & Dart 3)', () {
    test('Success encapsule les données et fold exécute onSuccess', () {
      const Result<int> result = Success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.failureOrNull, isNull);

      final val = result.fold(
        onSuccess: (data) => 'Valeur: $data',
        onFailure: (failure) => 'Erreur: ${failure.message}',
      );
      expect(val, equals('Valeur: 42'));
    });

    test('FailureResult encapsule l\'erreur et fold exécute onFailure', () {
      const Result<int> result =
          FailureResult(TtsFailure('Moteur audio indisponible'));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, isA<TtsFailure>());

      final val = result.fold(
        onSuccess: (data) => 'Valeur: $data',
        onFailure: (failure) => 'Erreur: ${failure.message}',
      );
      expect(val, equals('Erreur: Moteur audio indisponible'));
    });

    test('Result map transforme la valeur en cas de succès', () {
      const Result<int> result = Success(10);
      final mapped = result.map((x) => x * 2);
      expect(mapped.dataOrNull, equals(20));

      const Result<int> failure = FailureResult(StorageFailure('Erreur'));
      final failureMapped = failure.map((x) => x * 2);
      expect(failureMapped.isFailure, isTrue);
    });
  });

  group('FrenchSyllabifier Tests (NLP Hors Ligne)', () {
    test('Découpage syllabique des mots clés scolaires', () {
      expect(FrenchSyllabifier.syllabify('oiseaux'), equals(['oi', 'seaux']));
      expect(FrenchSyllabifier.syllabify('doucement'),
          equals(['dou', 'ce', 'ment']));
      expect(FrenchSyllabifier.syllabify('enfants'), equals(['en', 'fants']));
      expect(FrenchSyllabifier.syllabify('liraplus'),
          equals(['li', 'ra', 'plus']));
    });

    test('Découpage syllabique avec élision française (l\'oiseau, d\'arbre)',
        () {
      expect(FrenchSyllabifier.syllabify("l'oiseau"), equals(["l'oi", "seau"]));
      expect(FrenchSyllabifier.syllabify("d'arbre"), equals(["d'ar", "bre"]));
    });

    test('Détection des lettres muettes finales françaises', () {
      final (baseOiseaux, silentOiseaux) =
          FrenchSyllabifier.detectSilentEnding('oiseaux');
      expect(silentOiseaux, equals('x'));
      expect(baseOiseaux, equals('oiseau'));

      final (baseMangent, silentMangent) =
          FrenchSyllabifier.detectSilentEnding('mangent');
      expect(silentMangent, equals('ent'));
      expect(baseMangent, equals('mang'));

      final (baseChats, silentChats) =
          FrenchSyllabifier.detectSilentEnding('chats');
      expect(silentChats, equals('ts'));
      expect(baseChats, equals('cha'));
    });

    test('Détection des liaisons obligatoires avec arc ‿', () {
      final analyzed = FrenchSyllabifier.analyzeText('les oiseaux');
      expect(analyzed.length, equals(2));
      expect(analyzed[0].cleanWord.toLowerCase(), equals('les'));
      expect(analyzed[0].hasLiaisonWithNext, isTrue);
    });

    test('Test de performance et robustesse sur un texte long (Stress Test)',
        () {
      final longStory = List.filled(
              75, 'L\'oiseau vole doucement au-dessus des sapins au Québec.')
          .join(' ');
      final stopwatch = Stopwatch()..start();
      final words = FrenchSyllabifier.analyzeText(longStory);
      stopwatch.stop();

      expect(words.length, greaterThan(500));
      // Vérification que le parsing de 600 mots reste sous 200ms
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });
  });

  group('FalcDictionary & Dactylology Tests', () {
    test('Récupération d\'une entrée FALC existante', () {
      final entry = FalcDictionary.getEntry('oiseaux');
      expect(entry.word, equals('oiseaux'));
      expect(entry.falcDefinition, contains('animal avec deux ailes'));
      expect(entry.lsqSignTitle, contains('LSQ'));
    });

    test('Génération d\'une définition FALC générique pour mot inconnu', () {
      final entry = FalcDictionary.getEntry('mystérieux');
      expect(entry.word, equals('mystérieux'));
      expect(entry.falcDefinition, isNotEmpty);
      expect(entry.lsqDescription, contains('alphabet manuel'));
    });

    test('Récupération des lettres en dactylologie LSQ (Québec)', () {
      final letterA = DactylologyData.getLetter('a');
      expect(letterA, isNotNull);
      expect(letterA!.letter, equals('A'));
      expect(letterA.handDescription, contains('Poing fermé'));

      final letterEAccented = DactylologyData.getLetter('é');
      expect(letterEAccented, isNotNull);
      expect(letterEAccented!.letter, equals('E'));
    });
  });

  group('AccessibilityProvider & Storage Persistence Tests', () {
    test('Bascule entre les profils et persistance dans le dépôt', () async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      expect(provider.currentProfile, equals(AccessibilityProfile.standard));

      provider.setProfile(AccessibilityProfile.lowVision);
      expect(provider.currentProfile, equals(AccessibilityProfile.lowVision));
      expect(provider.settings.fontSize, greaterThanOrEqualTo(30.0));
      expect(provider.settings.showReadingRuler, isTrue);

      // Vérifie que les données sont écrites dans le repo
      expect(
          repo.savedSettings?.profile, equals(AccessibilityProfile.lowVision));

      provider.setProfile(AccessibilityProfile.dyslexia);
      expect(provider.currentProfile, equals(AccessibilityProfile.dyslexia));
      expect(provider.settings.letterSpacing, greaterThanOrEqualTo(2.0));

      provider.setProfile(AccessibilityProfile.lsqVisual);
      expect(provider.currentProfile, equals(AccessibilityProfile.lsqVisual));
      expect(provider.settings.hapticFeedbackEnabled, isTrue);
    });

    test('Chargement de nouveau texte et persistance du dernier texte', () {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      provider.setText('Un bel arbre.');
      expect(provider.analyzedWords.length, equals(3));
      expect(provider.analyzedWords[0].cleanWord, equals('Un'));
      expect(provider.analyzedWords[1].cleanWord, equals('bel'));
      expect(provider.analyzedWords[2].cleanWord, equals('arbre'));

      expect(repo.savedText, equals('Un bel arbre.'));
    });

    test('Cycle de vitesse vocale rapide (0.5x -> 0.75x -> 1.0x)', () async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      await provider.initializationDone;
      provider.setSpeechRate(0.5);
      final fakeTts = FakeTtsService();

      expect(provider.settings.speechRate, equals(0.5));
      await provider.cycleSpeechRate(fakeTts);
      expect(provider.settings.speechRate, equals(0.75));
      expect(fakeTts.currentRate, equals(0.75));

      await provider.cycleSpeechRate(fakeTts);
      expect(provider.settings.speechRate, equals(1.0));

      await provider.cycleSpeechRate(fakeTts);
      expect(provider.settings.speechRate, equals(0.5));
    });

    test(
        'Sauvegarde et suppression d\'un texte personnalisé dans la bibliothèque',
        () async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      provider.setText('Mon devoir scanné.');
      await provider.saveCurrentText('Devoir Page 10');

      expect(provider.savedTexts.length, equals(1));
      expect(provider.savedTexts.first.title, equals('Devoir Page 10'));
      expect(repo.customTexts.length, equals(1));

      final savedId = provider.savedTexts.first.id;
      await provider.deleteSavedText(savedId);

      expect(provider.savedTexts.isEmpty, isTrue);
      expect(repo.customTexts.isEmpty, isTrue);
    });
  });

  group('Accessibility & Error Boundary Tests', () {
    test('AccessibilityAnnouncer accepte les annonces sans planter', () async {
      await AccessibilityAnnouncer.announce('Test d\'annonce');
      // Deuxième annonce identique filtrée par anti-rebond
      await AccessibilityAnnouncer.announce('Test d\'annonce');
    });

    testWidgets(
        'ErrorBoundaryWidget affiche un message rassurant sans jargon technique',
        (tester) async {
      await tester.pumpWidget(const ErrorBoundaryWidget());
      await tester.pumpAndSettle();

      expect(find.text('Un petit instant !'), findsOneWidget);
      expect(
          find.textContaining('LiraPlus a rencontré une difficulté momentanée'),
          findsOneWidget);
      expect(find.text('Reprendre la lecture'), findsOneWidget);
    });
  });

  group('UI & Widget Integration Tests', () {
    testWidgets('Lancement de LiraPlus et présence du lecteur',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      expect(find.text('LiraPlus'), findsOneWidget);
      expect(find.text('Hors Ligne'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Basse Vision'), findsOneWidget);
      expect(find.text('Dyslexie'), findsOneWidget);
      expect(find.text('LSQ / Sourd'), findsOneWidget);
      expect(find.text('Écouter'), findsOneWidget);
    });

    testWidgets('Bascule en profil Basse Vision active la règle de lecture',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Basse Vision'));
      await tester.pumpAndSettle();

      expect(find.text('GUIDE DE LECTURE'), findsOneWidget);
    });

    testWidgets(
        'Validation des dimensions tactiles minimales (Loi de Fitts >= 48dp)',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      final playIcon = find.byIcon(Icons.play_arrow_rounded);
      expect(playIcon, findsOneWidget);

      final playButton = find
          .ancestor(
            of: playIcon,
            matching: find.byType(ConstrainedBox),
          )
          .first;
      final Size buttonSize = tester.getSize(playButton);

      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Ouverture de l\'écran Guide & FAQ Parents',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      final menuButton = find.byType(PopupMenuButton<String>);
      expect(menuButton, findsOneWidget);

      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final faqItem = find.text('Guide & FAQ Parents');
      expect(faqItem, findsOneWidget);

      await tester.tap(faqItem);
      await tester.pumpAndSettle();

      expect(find.byType(FaqScreen), findsOneWidget);
      expect(find.text('Guide & FAQ Parents'), findsOneWidget);
      expect(find.textContaining('Le son ne sort pas'), findsOneWidget);
      expect(find.textContaining('Mon enfant est sourd'), findsOneWidget);
    });

    testWidgets('Bouton de vitesse rapide dans la barre inférieure',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      // Vérifie la présence du badge de vitesse calme par défaut (0.5x Lente)
      final speedBtn = find.textContaining('0.5x');
      expect(speedBtn, findsOneWidget);

      await tester.tap(speedBtn);
      await tester.pumpAndSettle();

      // Après un clic, la vitesse passe à 0.75x Confort
      expect(find.textContaining('0.75x'), findsOneWidget);
    });

    testWidgets(
        'Ouverture de la bibliothèque et bascule d\'onglets MEQ / Mes Textes',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      final bookmarkBtn = find.byIcon(Icons.collections_bookmark_rounded);
      expect(bookmarkBtn, findsOneWidget);

      await tester.tap(bookmarkBtn);
      await tester.pumpAndSettle();

      expect(find.text('Récits MEQ'), findsOneWidget);
      expect(find.textContaining('Mes Textes'), findsOneWidget);

      // Bascule vers l'onglet Mes Textes
      await tester.tap(find.textContaining('Mes Textes'));
      await tester.pumpAndSettle();

      expect(
          find.text('Aucun texte sauvegardé pour le moment'), findsOneWidget);
    });

    testWidgets('Bascule en profil Soir (Lecture du soir)',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      final soirFinder = find.text('Soir');
      await tester.ensureVisible(soirFinder);
      await tester.pumpAndSettle();
      await tester.tap(soirFinder);
      await tester.pumpAndSettle();

      expect(
          provider.currentProfile, equals(AccessibilityProfile.nightReading));
    });

    testWidgets('Affichage et félicitations du ReadingCelebrationSheet',
        (WidgetTester tester) async {
      bool replayClicked = false;
      bool nextStoryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCelebrationSheet(
              wordsCount: 42,
              colors: AccessibilityColors.standard(),
              onReplay: () => replayClicked = true,
              onChooseAnother: () => nextStoryClicked = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bravo champion !'), findsOneWidget);
      expect(
          find.textContaining('42 mots décodés aujourd\'hui'), findsOneWidget);

      await tester.tap(find.text('Relire'));
      expect(replayClicked, isTrue);

      await tester.tap(find.text('Autre histoire'));
      expect(nextStoryClicked, isTrue);
    });

    testWidgets('Rendu du mini-jeu SyllablePuzzleGame',
        (WidgetTester tester) async {
      final analyzed = FrenchSyllabifier.analyzeText('oiseaux').first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyllablePuzzleGame(
              word: analyzed,
              colors: AccessibilityColors.standard(),
              settings: AccessibilitySettings.forProfile(
                  AccessibilityProfile.standard),
              ttsService: FakeTtsService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jeu des syllabes'), findsOneWidget);
      expect(
          find.text(
              'Touche les syllabes dans le bon ordre pour reformer le mot :'),
          findsOneWidget);
    });

    test('Découpage des phrases et navigation phrase par phrase', () async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      final fakeTts = FakeTtsService();

      provider.setText(
          'Le petit oiseau vole. Le ciel est bleu. L\'arbre est grand.');
      expect(provider.sentenceWordIndices.length, equals(3));
      expect(provider.currentSentenceIndex, equals(0));

      await provider.playNextSentence(fakeTts);
      expect(provider.currentSentenceIndex, equals(1));

      await provider.playNextSentence(fakeTts);
      expect(provider.currentSentenceIndex, equals(2));

      await provider.playPreviousSentence(fakeTts);
      expect(provider.currentSentenceIndex, equals(1));

      await provider.repeatCurrentSentence(fakeTts);
      expect(provider.currentSentenceIndex, equals(1));
    });

    testWidgets(
        'Validation Tablette (1024x768) : Rendu ergonomique et zéro overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      expect(find.text('LiraPlus'), findsOneWidget);
      expect(find.text('Hors Ligne'), findsOneWidget);
      expect(find.text('Écouter'), findsOneWidget);
      expect(find.byType(ProfileSelectorBar), findsOneWidget);
      expect(find.byType(ReaderBottomBar), findsOneWidget);
    });

    testWidgets(
        'Validation Petit Écran Mobile (320x568) avec grand texte : Zéro overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.4),
          ),
          child: LiraPlusApp(provider: provider),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LiraPlus'), findsOneWidget);
      expect(find.byType(ReaderBottomBar), findsOneWidget);
    });

    testWidgets(
        'Validation Modalités en mode Paysage (640x360) : Pas de débordement vertical',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCelebrationSheet(
              wordsCount: 25,
              colors: AccessibilityColors.standard(),
              onReplay: () {},
              onChooseAnother: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bravo champion !'), findsOneWidget);
      expect(find.text('Relire'), findsOneWidget);
    });

    testWidgets(
        'LsqHandshapeWidget dessine les configurations sans icônes génériques',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                LsqHandshapeWidget(
                    handshape: LsqHandshapeType.curvedArcC, color: Colors.blue),
                LsqHandshapeWidget(
                    handshape: LsqHandshapeType.littleFingerHookJ,
                    color: Colors.blue),
                LsqHandshapeWidget(
                    handshape: LsqHandshapeType.indexZigzagZ,
                    color: Colors.blue),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LsqHandshapeWidget), findsNWidgets(3));
    });

    testWidgets(
        'LsqMotionViewer anime le mouvement et les trajectoires pour élèves sourds',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LsqMotionViewer(
                word: 'oiseau',
                colors: AccessibilityColors.standard(),
                isLowVision: false,
                enableHaptics: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('MOUVEMENT DU SIGNE (LSQ)'), findsOneWidget);
      expect(find.text('Mouvement actif'), findsOneWidget);
      expect(find.text('Arrêter'), findsOneWidget);
      expect(find.text('Ralenti'), findsOneWidget);

      // Tester l'arrêt du mouvement
      await tester.tap(find.text('Arrêter'));
      await tester.pump();
      expect(find.text('En pause'), findsOneWidget);
      expect(find.text('Animer'), findsOneWidget);
    });

    testWidgets(
        'Toucher un mot prononce le mot et maintient le surlignage sans sauter au début',
        (WidgetTester tester) async {
      final fakeTts = FakeTtsService();
      final words = FrenchSyllabifier.analyzeText('Le petit chat dort.');
      final wordToTap = words[2]; // 'chat'
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordItemWidget(
              word: wordToTap,
              index: 2,
              isHighlighted: false,
              settings: AccessibilitySettings.forProfile(
                  AccessibilityProfile.standard),
              colors: AccessibilityColors.standard(),
              ttsService: fakeTts,
              onWordTapped: (idx) {
                tappedIndex = idx;
              },
              onWordLongPressed: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      final wordWidgetFinder = find.byType(WordItemWidget);
      expect(wordWidgetFinder, findsOneWidget);

      await tester.tap(wordWidgetFinder);
      await tester.pump();

      expect(tappedIndex, equals(2));
      expect(fakeTts.lastSpokenWord, equals('chat'));
      expect(fakeTts.lastSpokenSyllables, equals(['chat']));
    });

    testWidgets(
        'Bascule en profil LSQ affiche le panneau LSQ avec mouvement animé et dactylologie',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      provider.setText('Le petit oiseau vole au-dessus du grand arbre.');

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      // Au départ en profil Standard : le panneau LSQ n'est pas présent
      expect(find.byType(LsqReaderPanel), findsNothing);

      // Bascule vers le profil LSQ / Sourd
      await tester.tap(find.text('LSQ / Sourd'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Le panneau LSQ compact est désormais visible en haut avec la main en signe en direct
      expect(find.byType(LsqReaderPanel), findsOneWidget);
      expect(find.text('ESPACE SOURD • LSQ'), findsOneWidget);
      expect(find.byType(LsqHandshapeWidget), findsOneWidget);
      expect(find.textContaining('Signe '), findsOneWidget);
    });

    testWidgets(
        'Barre de progression par étapes et ouverture du carnet de trophées',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      provider.setText(
          'Première phrase courte. Deuxième phrase magique. Troisième phrase finale.');

      await tester.pumpWidget(LiraPlusApp(provider: provider));
      await tester.pumpAndSettle();

      // Vérifie la présence de la frise de progression dans le Pupitre Magique
      expect(find.byType(ReaderBottomBar), findsOneWidget);
      expect(find.textContaining('Phrase 1/3'), findsOneWidget);

      // Ouverture du carnet de progression via l'icône trophée de l'AppBar
      final carnetBtn = find.byIcon(Icons.emoji_events_rounded);
      expect(carnetBtn, findsOneWidget);

      await tester.tap(carnetBtn);
      await tester.pumpAndSettle();

      // Vérifie le contenu du carnet
      expect(find.text('MON CARNET DE PROGRESSION'), findsOneWidget);
      expect(find.text('Mots découverts'), findsOneWidget);
      expect(find.text('Histoires lues'), findsOneWidget);
      expect(find.text('Badges gagnés'), findsOneWidget);
      expect(find.text('MES BADGES DE RÉUSSITE'), findsOneWidget);

      // Fermeture du carnet
      await tester.tap(find.text('Continuer ma lecture'));
      await tester.pumpAndSettle();

      expect(find.text('MON CARNET DE PROGRESSION'), findsNothing);
    });

    testWidgets(
        'LsqSpellerPlayer fait défiler les lettres et permet de basculer en vue miroir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LsqSpellerPlayer(
              word: 'chat',
              colors: AccessibilityColors.standard(),
              enableHaptics: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Lettre C'), findsOneWidget);
      expect(find.text('Lettre 1 / 4'), findsOneWidget);
      expect(find.text('Vue : En face'), findsOneWidget);

      // Bascule en vue miroir
      await tester.tap(find.text('En face'));
      await tester.pump();

      expect(find.text('Vue : Ma main'), findsOneWidget);
      expect(find.text('Ma main'), findsOneWidget);

      // Avance d'une lettre
      await tester.tap(find.byTooltip('Lettre suivante'));
      await tester.pump();

      expect(find.text('Lettre H'), findsOneWidget);
      expect(find.text('Lettre 2 / 4'), findsOneWidget);
    });

    testWidgets(
        'AlphabetWorkshopScreen affiche les 26 lettres et les mots de l\'école',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      final fakeTts = FakeTtsService();

      await tester.pumpWidget(
        MaterialApp(
          home: AlphabetWorkshopScreen(
            provider: provider,
            ttsService: fakeTts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alphabet LSQ'), findsOneWidget);
      expect(find.text('Alphabet A à Z'), findsOneWidget);
      expect(find.text('Mots de l\'école'), findsOneWidget);

      // Vérifie la présence des premières lettres
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      // Bascule vers l'onglet Mots de l'école (animation de mouvement présente, donc pump ciblé)
      await tester.tap(find.text('Mots de l\'école'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bonjour'), findsOneWidget);
      expect(find.text('Merci'), findsOneWidget);
      expect(find.text('Ami'), findsOneWidget);
    });

    testWidgets(
        'AlphabetQuizSheet propose un choix et valide la réponse bienveillante',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => AlphabetQuizSheet.show(ctx, provider),
                child: const Text('Ouvrir Quiz'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ouvrir Quiz'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('JEU DES MAINS LSQ'), findsOneWidget);
      expect(find.text('Trouve la bonne main !'), findsOneWidget);
      expect(find.text('Question suivante ➔'), findsOneWidget);
    });

    testWidgets(
        'WordVaultSheet pré-remplit les mots scolaires via le bouton de découverte initiale',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      final fakeTts = FakeTtsService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => WordVaultSheet.show(
                  ctx,
                  provider: provider,
                  ttsService: fakeTts,
                ),
                child: const Text('Ouvrir Coffre'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ouvrir Coffre'));
      await tester.pumpAndSettle();

      // État vide initial
      expect(find.text('Ton coffre est encore vide !'), findsOneWidget);
      expect(find.text('Découvrir les mots de l\'école'), findsOneWidget);

      // Clic sur l'action de découverte
      await tester.tap(find.text('Découvrir les mots de l\'école'));
      await tester.pumpAndSettle();

      // Le coffre est maintenant pré-rempli et affiche les mots scolaires
      expect(find.text('Ton coffre est encore vide !'), findsNothing);
      expect(find.text('école'), findsOneWidget);
      expect(find.text('ami'), findsOneWidget);
      expect(find.text('livre'), findsOneWidget);
      expect(find.text('Cartes'), findsOneWidget);
    });

    testWidgets(
        'GiantWordTeleprompter règle la vitesse directement via la pastille de tempo',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      final fakeTts = FakeTtsService();
      provider.setText('Bonjour les amis');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiantWordTeleprompter(
              provider: provider,
              ttsService: fakeTts,
              onOpenWordCoach: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vitesse initiale (par défaut 0.65 -> '0.5x')
      expect(find.text('0.5x'), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);

      // Clic sur la pastille de vitesse
      await tester.tap(find.byIcon(Icons.speed_rounded));
      await tester.pumpAndSettle();

      // Vitesse passe à 0.75x
      expect(find.text('0.75x'), findsOneWidget);
      expect(provider.settings.speechRate, 0.75);
    });

    testWidgets(
        'GiantWordTeleprompter synchronise la prononciation au toucher d\'une syllabe',
        (WidgetTester tester) async {
      final repo = InMemoryPreferencesRepository();
      final provider = AccessibilityProvider(preferencesRepository: repo);
      final fakeTts = FakeTtsService();
      provider.setText('soleil');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiantWordTeleprompter(
              provider: provider,
              ttsService: fakeTts,
              onOpenWordCoach: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Syllabes de soleil : so - leil
      expect(find.text('so'), findsOneWidget);
      expect(find.text('leil'), findsOneWidget);

      // Toucher la première syllabe
      await tester.tap(find.text('so'));
      await tester.pump();

      expect(fakeTts.lastSpokenWord, 'so');
      expect(fakeTts.lastSpokenSyllables, ['so']);

      // Écoulement déterministe du minuteur et de l'animation de retour
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 300));
    });

    test(
        'LsqSemanticEngine reconnaît les mots scannés hors dictionnaire et bascule en dactylologie sur noms propres',
        () {
      final apple = LsqSemanticEngine.analyze('pommes');
      expect(apple.isKnownSign, isTrue);
      expect(apple.kind, LsqMovementKind.handPinch);

      final rain = LsqSemanticEngine.analyze('pluie');
      expect(rain.isKnownSign, isTrue);
      expect(rain.kind, LsqMovementKind.waterWaveFlow);

      final past = LsqSemanticEngine.analyze('hier');
      expect(past.isKnownSign, isTrue);
      expect(past.categoryLabel, contains('Passé'));

      final properNoun = LsqSemanticEngine.analyze('Rimouski');
      expect(properNoun.isKnownSign, isFalse);
      expect(properNoun.categoryLabel, contains('Épellation'));
    });
  });
}
