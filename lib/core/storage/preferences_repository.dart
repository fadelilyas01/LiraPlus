import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../errors/failures.dart';
import '../theme/accessibility_themes.dart';

/// Entrée d'un texte ou récit sauvegardé par l'élève
class SavedTextEntry {
  final String id;
  final String title;
  final String text;
  final DateTime createdAt;

  const SavedTextEntry({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedTextEntry.fromJson(Map<String, dynamic> json) => SavedTextEntry(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Texte sans titre',
        text: json['text'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Modèle de suivi de progression encourageant et bienveillant pour l'élève (100% hors ligne)
class UserProgression {
  final int totalWordsRead;
  final int totalStoriesCompleted;
  final int stepsCompleted;
  final Set<String> unlockedBadges;
  final Set<String> favoriteWords;

  const UserProgression({
    this.totalWordsRead = 0,
    this.totalStoriesCompleted = 0,
    this.stepsCompleted = 0,
    this.unlockedBadges = const {},
    this.favoriteWords = const {},
  });

  /// Titre honorifique adapté à l'apprentissage de l'enfant
  String get readerLevelTitle {
    if (totalStoriesCompleted >= 10 || totalWordsRead >= 500) {
      return 'Grand Explorateur des Récits';
    } else if (totalStoriesCompleted >= 3 || totalWordsRead >= 150) {
      return 'Lecteur Étoile Courageux';
    } else if (totalWordsRead >= 30 || stepsCompleted >= 5) {
      return 'Apprenti Aventurier des Mots';
    } else {
      return 'Jeune Pousse de Lecture';
    }
  }

  UserProgression copyWith({
    int? totalWordsRead,
    int? totalStoriesCompleted,
    int? stepsCompleted,
    Set<String>? unlockedBadges,
    Set<String>? favoriteWords,
  }) {
    return UserProgression(
      totalWordsRead: totalWordsRead ?? this.totalWordsRead,
      totalStoriesCompleted:
          totalStoriesCompleted ?? this.totalStoriesCompleted,
      stepsCompleted: stepsCompleted ?? this.stepsCompleted,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      favoriteWords: favoriteWords ?? this.favoriteWords,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalWordsRead': totalWordsRead,
        'totalStoriesCompleted': totalStoriesCompleted,
        'stepsCompleted': stepsCompleted,
        'unlockedBadges': unlockedBadges.toList(),
        'favoriteWords': favoriteWords.toList(),
      };

  factory UserProgression.fromJson(Map<String, dynamic> json) {
    final rawBadges = (json['unlockedBadges'] as List<dynamic>?) ?? [];
    final rawFavorites = (json['favoriteWords'] as List<dynamic>?) ?? [];
    return UserProgression(
      totalWordsRead: (json['totalWordsRead'] as num?)?.toInt() ?? 0,
      totalStoriesCompleted:
          (json['totalStoriesCompleted'] as num?)?.toInt() ?? 0,
      stepsCompleted: (json['stepsCompleted'] as num?)?.toInt() ?? 0,
      unlockedBadges: rawBadges.map((e) => e.toString()).toSet(),
      favoriteWords: rawFavorites.map((e) => e.toString()).toSet(),
    );
  }
}

/// Contrat abstrait de persistance locale des réglages de l'élève (Clean Architecture)
abstract class IPreferencesRepository {
  /// Charge les réglages d'accessibilité enregistrés (ou repli par défaut)
  Future<Result<AccessibilitySettings>> loadSettings();

  /// Enregistre de manière atomique et sécurisée les réglages d'accessibilité
  Future<Result<void>> saveSettings(AccessibilitySettings settings);

  /// Charge le dernier texte lu par l'élève
  Future<Result<String?>> loadLastText();

  /// Enregistre le dernier texte lu
  Future<Result<void>> saveLastText(String text);

  /// Charge tous les textes et devoirs sauvegardés par l'élève
  Future<Result<List<SavedTextEntry>>> loadSavedTexts();

  /// Enregistre un nouveau texte personnalisé dans la bibliothèque locale
  Future<Result<void>> saveCustomText(SavedTextEntry entry);

  /// Supprime un texte sauvegardé par son identifiant
  Future<Result<void>> deleteCustomText(String id);

  /// Charge la progression globale de l'élève (mots lus, trophées débloqués)
  Future<Result<UserProgression>> loadProgression();

  /// Enregistre la progression de l'élève de façon atomique
  Future<Result<void>> saveProgression(UserProgression progression);

  /// Réinitialise toutes les préférences
  Future<Result<void>> clear();
}

/// Implémentation locale hors ligne sécurisée (Zero-Cloud, Zero-Vulnerability)
/// avec écriture atomique (.tmp -> rename) pour éliminer tout risque de corruption.
class LocalPreferencesRepository implements IPreferencesRepository {
  static const String _fileName = 'liraplus_preferences.json';
  File? _cachedFile;

  Future<File> _getFile() async {
    if (_cachedFile != null) return _cachedFile!;
    final directory = await getApplicationDocumentsDirectory();
    _cachedFile = File('${directory.path}/$_fileName');
    return _cachedFile!;
  }

  @override
  Future<Result<AccessibilitySettings>> loadSettings() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return Success(
          AccessibilitySettings.forProfile(AccessibilityProfile.standard),
        );
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return Success(
          AccessibilitySettings.forProfile(AccessibilityProfile.standard),
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(content) as Map<String, dynamic>;

      final profileName = json['profile'] as String? ?? 'standard';
      final profile = AccessibilityProfile.values.firstWhere(
        (p) => p.name == profileName,
        orElse: () => AccessibilityProfile.standard,
      );

      final baseSettings = AccessibilitySettings.forProfile(profile);

      final loaded = baseSettings.copyWith(
        fontSize:
            (json['fontSize'] as num?)?.toDouble() ?? baseSettings.fontSize,
        speechRate:
            (json['speechRate'] as num?)?.toDouble() ?? baseSettings.speechRate,
        showReadingRuler:
            json['showReadingRuler'] as bool? ?? baseSettings.showReadingRuler,
        readingRulerY: (json['readingRulerY'] as num?)?.toDouble() ??
            baseSettings.readingRulerY,
        syllableColoringEnabled: json['syllableColoringEnabled'] as bool? ??
            baseSettings.syllableColoringEnabled,
        silentLettersDimmed: json['silentLettersDimmed'] as bool? ??
            baseSettings.silentLettersDimmed,
        liaisonsEnabled:
            json['liaisonsEnabled'] as bool? ?? baseSettings.liaisonsEnabled,
        hapticFeedbackEnabled: json['hapticFeedbackEnabled'] as bool? ??
            baseSettings.hapticFeedbackEnabled,
        complexGraphemesHighlighted:
            json['complexGraphemesHighlighted'] as bool? ??
                baseSettings.complexGraphemesHighlighted,
        visualPictogramsEnabled: json['visualPictogramsEnabled'] as bool? ??
            baseSettings.visualPictogramsEnabled,
        opaqueRulerMask:
            json['opaqueRulerMask'] as bool? ?? baseSettings.opaqueRulerMask,
        giantWordMode:
            json['giantWordMode'] as bool? ?? baseSettings.giantWordMode,
        stepByStepPauses:
            json['stepByStepPauses'] as bool? ?? baseSettings.stepByStepPauses,
      );

      return Success(loaded);
    } catch (e, stackTrace) {
      debugPrint(
          'LiraPlus: Récupération sécurisée suite à erreur de lecture config: $e');
      return FailureResult(
        StorageFailure(
          'Impossible de lire les préférences sauvegardées.',
          stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveSettings(AccessibilitySettings settings) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            existingData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      existingData['profile'] = settings.profile.name;
      existingData['fontSize'] = settings.fontSize;
      existingData['speechRate'] = settings.speechRate;
      existingData['showReadingRuler'] = settings.showReadingRuler;
      existingData['readingRulerY'] = settings.readingRulerY;
      existingData['syllableColoringEnabled'] =
          settings.syllableColoringEnabled;
      existingData['silentLettersDimmed'] = settings.silentLettersDimmed;
      existingData['liaisonsEnabled'] = settings.liaisonsEnabled;
      existingData['hapticFeedbackEnabled'] = settings.hapticFeedbackEnabled;
      existingData['complexGraphemesHighlighted'] =
          settings.complexGraphemesHighlighted;
      existingData['visualPictogramsEnabled'] =
          settings.visualPictogramsEnabled;
      existingData['opaqueRulerMask'] = settings.opaqueRulerMask;
      existingData['giantWordMode'] = settings.giantWordMode;
      existingData['stepByStepPauses'] = settings.stepByStepPauses;
      existingData['updatedAt'] = DateTime.now().toIso8601String();

      // Écriture atomique sécurisée : d'abord sur .tmp puis remplacement
      await tempFile.writeAsString(jsonEncode(existingData), flush: true);
      await tempFile.rename(file.path);

      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure(
          'Impossible de sauvegarder les préférences utilisateur.',
          stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<String?>> loadLastText() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return const Success(null);

      final content = await file.readAsString();
      if (content.trim().isEmpty) return const Success(null);

      final Map<String, dynamic> json =
          jsonDecode(content) as Map<String, dynamic>;
      final text = json['lastText'] as String?;
      return Success(text);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure('Erreur lors du chargement du dernier texte.',
            stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<void>> saveLastText(String text) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            existingData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      existingData['lastText'] = text;
      await tempFile.writeAsString(jsonEncode(existingData), flush: true);
      await tempFile.rename(file.path);

      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure('Erreur de sauvegarde du texte.', stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<List<SavedTextEntry>>> loadSavedTexts() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return const Success([]);

      final content = await file.readAsString();
      if (content.trim().isEmpty) return const Success([]);

      final Map<String, dynamic> json =
          jsonDecode(content) as Map<String, dynamic>;
      final rawList = json['savedTexts'] as List<dynamic>? ?? [];

      final list = rawList
          .map((item) => SavedTextEntry.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Success(list);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure(
            'Erreur lors du chargement des textes.', stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<void>> saveCustomText(SavedTextEntry entry) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            existingData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      final rawList = (existingData['savedTexts'] as List<dynamic>?) ?? [];
      final list = rawList
          .map((item) => SavedTextEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      list.removeWhere((item) => item.id == entry.id);
      list.insert(0, entry);

      existingData['savedTexts'] = list.map((item) => item.toJson()).toList();

      await tempFile.writeAsString(jsonEncode(existingData), flush: true);
      await tempFile.rename(file.path);

      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure('Erreur lors de l\'enregistrement du texte.',
            stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteCustomText(String id) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            existingData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      final rawList = (existingData['savedTexts'] as List<dynamic>?) ?? [];
      final list = rawList
          .map((item) => SavedTextEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      list.removeWhere((item) => item.id == id);
      existingData['savedTexts'] = list.map((item) => item.toJson()).toList();

      await tempFile.writeAsString(jsonEncode(existingData), flush: true);
      await tempFile.rename(file.path);

      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure(
            'Erreur lors de la suppression du texte.', stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<UserProgression>> loadProgression() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return const Success(UserProgression());
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return const Success(UserProgression());
      }

      final Map<String, dynamic> json =
          jsonDecode(content) as Map<String, dynamic>;
      final rawProgression = json['progression'] as Map<String, dynamic>?;
      if (rawProgression == null) {
        return const Success(UserProgression());
      }

      return Success(UserProgression.fromJson(rawProgression));
    } catch (e, stackTrace) {
      debugPrint('LiraPlus: Récupération par défaut progression: $e');
      return FailureResult(
        StorageFailure('Erreur lors du chargement de la progression.',
            stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<void>> saveProgression(UserProgression progression) async {
    try {
      final file = await _getFile();
      final tempFile = File('${file.path}.tmp');

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            existingData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      existingData['progression'] = progression.toJson();
      existingData['updatedAt'] = DateTime.now().toIso8601String();

      await tempFile.writeAsString(jsonEncode(existingData), flush: true);
      await tempFile.rename(file.path);

      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure('Erreur lors de l\'enregistrement de la progression.',
            stackTrace.toString()),
      );
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
      return const Success(null);
    } catch (e, stackTrace) {
      return FailureResult(
        StorageFailure(
            'Erreur lors de la réinitialisation.', stackTrace.toString()),
      );
    }
  }
}
