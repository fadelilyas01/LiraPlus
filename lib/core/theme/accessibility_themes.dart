import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Les 4 profils d'accessibilité inclusifs de LiraPlus
enum AccessibilityProfile {
  /// Interface claire et moderne standard
  standard,

  /// Contraste maximal : fond noir, texte jaune vif, guide de lecture, haute visibilité
  lowVision,

  /// Fond crème chaud anti-fatigue visuelle, grand espacement et colorisation des syllabes
  dyslexia,

  /// Profil adapté aux personnes sourdes ou malentendantes : retours haptiques et contrastes visuels
  lsqVisual,

  /// Profil lecture du soir : tons ambrés et chaleureux reposants sans lumière bleue
  nightReading,
}

/// Palette de couleurs accessible spécifique à chaque profil
class AccessibilityColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color border;
  final Color syllableColorA;
  final Color syllableColorB;
  final Color silentLetterColor;
  final Color highlightBackground;
  final Color highlightText;
  final Color readingRulerColor;

  const AccessibilityColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.border,
    required this.syllableColorA,
    required this.syllableColorB,
    required this.silentLetterColor,
    required this.highlightBackground,
    required this.highlightText,
    required this.readingRulerColor,
  });

  /// Mode Standard - Palette Titane Anti-Fatigue (Anti-Glare)
  factory AccessibilityColors.standard() => const AccessibilityColors(
        background: Color(0xFFE5E9EE), // Gris titane doux anti-éblouissement
        surface: Color(0xFFF1F4F7), // Surface carte légèrement surélevée
        surfaceVariant: Color(0xFFDBE2E8), // Surface d'interaction et badges
        textPrimary: Color(0xFF0F172A), // Ardoise 900 profond (contraste AAA)
        textSecondary: Color(0xFF475569), // Ardoise 600 lisible
        accent: Color(0xFF2563EB), // Bleu cobalt accessible
        border: Color(0xFFCBD5E1), // Bordure fine ardoise 300
        syllableColorA: Color(0xFF1D4ED8),
        syllableColorB: Color(0xFF7C3AED),
        silentLetterColor: Color(0xFF64748B),
        highlightBackground: Color(0xFFFEF08A),
        highlightText: Color(0xFF0F172A),
        readingRulerColor: Color(0x332563EB),
      );

  /// Mode Basse Vision (fond noir pur #000000, texte jaune vif #FFEA00)
  factory AccessibilityColors.lowVision() => const AccessibilityColors(
        background: Color(0xFF000000),
        surface: Color(0xFF121212),
        surfaceVariant: Color(0xFF1E1E1E),
        textPrimary: Color(0xFFFFEA00),
        textSecondary: Color(0xFFFFF59D),
        accent: Color(0xFFFFEA00),
        border: Color(0xFFFFEA00),
        syllableColorA: Color(0xFFFFEA00),
        syllableColorB: Color(0xFF00E5FF),
        silentLetterColor: Color(0xFF616161),
        highlightBackground: Color(0xFFFFFFFF),
        highlightText: Color(0xFF000000),
        readingRulerColor: Color(0x66FFEA00),
      );

  /// Mode Dyslexie (fond crème chaud #FAF6EE anti-fatigue visuelle)
  factory AccessibilityColors.dyslexia() => const AccessibilityColors(
        background: Color(0xFFFAF6EE),
        surface: Color(0xFFFFFDF8),
        surfaceVariant: Color(0xFFF1ECE0),
        textPrimary: Color(0xFF1C1917),
        textSecondary: Color(0xFF44403C),
        accent: Color(0xFF0D9488),
        border: Color(0xFFD6CEBE),
        syllableColorA: Color(0xFF1E40AF),
        syllableColorB: Color(0xFF9333EA),
        silentLetterColor: Color(0xFFA8A29E),
        highlightBackground: Color(0xFFBAE6FD),
        highlightText: Color(0xFF0C4A6E),
        readingRulerColor: Color(0x330D9488),
      );

  /// Mode LSQ / Visuel pour élèves sourds ou malentendants
  factory AccessibilityColors.lsqVisual() => const AccessibilityColors(
        background: Color(0xFF0F172A),
        surface: Color(0xFF1E293B),
        surfaceVariant: Color(0xFF334155),
        textPrimary: Color(0xFFF8FAFC),
        textSecondary: Color(0xFFCBD5E1),
        accent: Color(0xFF38BDF8),
        border: Color(0xFF38BDF8),
        syllableColorA: Color(0xFF38BDF8),
        syllableColorB: Color(0xFFFACC15),
        silentLetterColor: Color(0xFF64748B),
        highlightBackground: Color(0xFFFDE047),
        highlightText: Color(0xFF0F172A),
        readingRulerColor: Color(0x4438BDF8),
      );

  /// Mode Lecture du soir : lumière douce ambrée et reposante anti-lumière bleue
  factory AccessibilityColors.nightReading() => const AccessibilityColors(
        background: Color(0xFF1C1917),
        surface: Color(0xFF292524),
        surfaceVariant: Color(0xFF3C3632),
        textPrimary: Color(0xFFFEF3C7),
        textSecondary: Color(0xFFD6D3D1),
        accent: Color(0xFFF59E0B),
        border: Color(0xFFB45309),
        syllableColorA: Color(0xFFFBBF24),
        syllableColorB: Color(0xFFFB923C),
        silentLetterColor: Color(0xFF78716C),
        highlightBackground: Color(0xFF78350F),
        highlightText: Color(0xFFFFFBEB),
        readingRulerColor: Color(0x33F59E0B),
      );
}

/// Configuration globale d'accessibilité de l'application
class AccessibilitySettings {
  final AccessibilityProfile profile;
  final double fontSize;
  final double letterSpacing;
  final double lineSpacing;
  final bool showReadingRuler;
  final double readingRulerY;
  final bool hapticFeedbackEnabled;
  final bool syllableColoringEnabled;
  final bool silentLettersDimmed;
  final bool liaisonsEnabled;
  final double speechRate;
  final bool complexGraphemesHighlighted;
  final bool visualPictogramsEnabled;
  final bool opaqueRulerMask;
  final bool giantWordMode;
  final bool stepByStepPauses;

  const AccessibilitySettings({
    this.profile = AccessibilityProfile.standard,
    this.fontSize = 22.0,
    this.letterSpacing = 1.0,
    this.lineSpacing = 1.8,
    this.showReadingRuler = false,
    this.readingRulerY = 250.0,
    this.hapticFeedbackEnabled = false,
    this.syllableColoringEnabled = true,
    this.silentLettersDimmed = true,
    this.liaisonsEnabled = true,
    this.speechRate = 0.65,
    this.complexGraphemesHighlighted = true,
    this.visualPictogramsEnabled = false,
    this.opaqueRulerMask = false,
    this.giantWordMode = false,
    this.stepByStepPauses = false,
  });

  /// Paramètres initiaux par profil
  factory AccessibilitySettings.forProfile(AccessibilityProfile profile) {
    switch (profile) {
      case AccessibilityProfile.standard:
        return const AccessibilitySettings(
          profile: AccessibilityProfile.standard,
          fontSize: 22.0,
          letterSpacing: 1.0,
          lineSpacing: 1.8,
          showReadingRuler: false,
          hapticFeedbackEnabled: false,
          syllableColoringEnabled: true,
          silentLettersDimmed: true,
          liaisonsEnabled: true,
          speechRate: 0.65,
          complexGraphemesHighlighted: true,
          visualPictogramsEnabled: false,
          opaqueRulerMask: false,
          giantWordMode: false,
          stepByStepPauses: false,
        );
      case AccessibilityProfile.lowVision:
        return const AccessibilitySettings(
          profile: AccessibilityProfile.lowVision,
          fontSize: 32.0,
          letterSpacing: 1.8,
          lineSpacing: 2.2,
          showReadingRuler: true,
          hapticFeedbackEnabled: true,
          syllableColoringEnabled: true,
          silentLettersDimmed: true,
          liaisonsEnabled: true,
          speechRate: 0.60,
          complexGraphemesHighlighted: false,
          visualPictogramsEnabled: false,
          opaqueRulerMask: true,
          giantWordMode: false,
          stepByStepPauses: false,
        );
      case AccessibilityProfile.dyslexia:
        return const AccessibilitySettings(
          profile: AccessibilityProfile.dyslexia,
          fontSize: 24.0,
          letterSpacing: 2.2,
          lineSpacing: 2.3,
          showReadingRuler: true,
          hapticFeedbackEnabled: true,
          syllableColoringEnabled: true,
          silentLettersDimmed: true,
          liaisonsEnabled: true,
          speechRate: 0.55,
          complexGraphemesHighlighted: true,
          visualPictogramsEnabled: true,
          opaqueRulerMask: true,
          giantWordMode: false,
          stepByStepPauses: true,
        );
      case AccessibilityProfile.lsqVisual:
        return const AccessibilitySettings(
          profile: AccessibilityProfile.lsqVisual,
          fontSize: 24.0,
          letterSpacing: 1.5,
          lineSpacing: 2.0,
          showReadingRuler: false,
          hapticFeedbackEnabled: true,
          syllableColoringEnabled: true,
          silentLettersDimmed: true,
          liaisonsEnabled: true,
          speechRate: 0.55,
          complexGraphemesHighlighted: true,
          visualPictogramsEnabled: true,
          opaqueRulerMask: false,
          giantWordMode: false,
          stepByStepPauses: true,
        );
      case AccessibilityProfile.nightReading:
        return const AccessibilitySettings(
          profile: AccessibilityProfile.nightReading,
          fontSize: 23.0,
          letterSpacing: 1.2,
          lineSpacing: 1.9,
          showReadingRuler: false,
          hapticFeedbackEnabled: true,
          syllableColoringEnabled: true,
          silentLettersDimmed: true,
          liaisonsEnabled: true,
          speechRate: 0.55,
          complexGraphemesHighlighted: false,
          visualPictogramsEnabled: false,
          opaqueRulerMask: false,
          giantWordMode: false,
          stepByStepPauses: false,
        );
    }
  }

  AccessibilityColors get colors {
    switch (profile) {
      case AccessibilityProfile.standard:
        return AccessibilityColors.standard();
      case AccessibilityProfile.lowVision:
        return AccessibilityColors.lowVision();
      case AccessibilityProfile.dyslexia:
        return AccessibilityColors.dyslexia();
      case AccessibilityProfile.lsqVisual:
        return AccessibilityColors.lsqVisual();
      case AccessibilityProfile.nightReading:
        return AccessibilityColors.nightReading();
    }
  }

  AccessibilitySettings copyWith({
    AccessibilityProfile? profile,
    double? fontSize,
    double? letterSpacing,
    double? lineSpacing,
    bool? showReadingRuler,
    double? readingRulerY,
    bool? hapticFeedbackEnabled,
    bool? syllableColoringEnabled,
    bool? silentLettersDimmed,
    bool? liaisonsEnabled,
    double? speechRate,
    bool? complexGraphemesHighlighted,
    bool? visualPictogramsEnabled,
    bool? opaqueRulerMask,
    bool? giantWordMode,
    bool? stepByStepPauses,
  }) {
    return AccessibilitySettings(
      profile: profile ?? this.profile,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      showReadingRuler: showReadingRuler ?? this.showReadingRuler,
      readingRulerY: readingRulerY ?? this.readingRulerY,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      syllableColoringEnabled:
          syllableColoringEnabled ?? this.syllableColoringEnabled,
      silentLettersDimmed: silentLettersDimmed ?? this.silentLettersDimmed,
      liaisonsEnabled: liaisonsEnabled ?? this.liaisonsEnabled,
      speechRate: speechRate ?? this.speechRate,
      complexGraphemesHighlighted:
          complexGraphemesHighlighted ?? this.complexGraphemesHighlighted,
      visualPictogramsEnabled:
          visualPictogramsEnabled ?? this.visualPictogramsEnabled,
      opaqueRulerMask: opaqueRulerMask ?? this.opaqueRulerMask,
      giantWordMode: giantWordMode ?? this.giantWordMode,
      stepByStepPauses: stepByStepPauses ?? this.stepByStepPauses,
    );
  }

  /// Génère le style de texte avec police Atkinson Hyperlegible (référence basse vision)
  TextStyle getReadingTextStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final effectiveColor = color ?? colors.textPrimary;
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: lineSpacing,
      color: effectiveColor,
    );
  }
}
