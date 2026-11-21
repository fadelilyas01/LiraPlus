import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/providers/accessibility_provider.dart';
import 'core/theme/accessibility_themes.dart';
import 'core/widgets/error_boundary_widget.dart';
import 'features/reader/reader_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Durcissement Enterprise : Capture globale des erreurs de rendu (Zero Red Screen)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(
        'LiraPlus: Erreur interceptée avec sécurité : ${details.exceptionAsString()}');
    if (details.library != null) {
      debugPrint('LiraPlus: Bibliothèque : ${details.library}');
    }
  };

  // 2. Capture des erreurs asynchrones non interceptées hors de la boucle d'événements
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('LiraPlus: Erreur asynchrone interceptée : $error');
    return true; // Empêche le plantage brutal de l'application
  };

  // 3. Widget de repli universel pour tout crash de sous-composant
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorBoundaryWidget(details: details);
  };

  // 4. Autorise le chargement initial avec repli système automatique hors ligne
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const LiraPlusApp());
}

/// Application racine inclusive LiraPlus
class LiraPlusApp extends StatelessWidget {
  final AccessibilityProvider? provider;

  const LiraPlusApp({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider != null) {
      return ChangeNotifierProvider<AccessibilityProvider>.value(
        value: provider!,
        child: Consumer<AccessibilityProvider>(
          builder: (context, accessibilityProvider, _) {
            final settings = accessibilityProvider.settings;
            final colors = settings.colors;

            return MaterialApp(
              title: 'LiraPlus',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: colors.background,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: colors.accent,
                  brightness: settings.profile ==
                              AccessibilityProfile.lowVision ||
                          settings.profile == AccessibilityProfile.lsqVisual ||
                          settings.profile == AccessibilityProfile.nightReading
                      ? Brightness.dark
                      : Brightness.light,
                  surface: colors.surface,
                  primary: colors.accent,
                ),
                textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme().apply(
                  bodyColor: colors.textPrimary,
                  displayColor: colors.textPrimary,
                ),
              ),
              home: const ReaderScreen(),
            );
          },
        ),
      );
    }

    return ChangeNotifierProvider<AccessibilityProvider>(
      create: (_) => AccessibilityProvider(),
      child: Consumer<AccessibilityProvider>(
        builder: (context, accessibilityProvider, _) {
          final settings = accessibilityProvider.settings;
          final colors = settings.colors;

          return MaterialApp(
            title: 'LiraPlus',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: colors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: colors.accent,
                brightness: settings.profile ==
                            AccessibilityProfile.lowVision ||
                        settings.profile == AccessibilityProfile.lsqVisual ||
                        settings.profile == AccessibilityProfile.nightReading
                    ? Brightness.dark
                    : Brightness.light,
                surface: colors.surface,
                primary: colors.accent,
              ),
              textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme().apply(
                bodyColor: colors.textPrimary,
                displayColor: colors.textPrimary,
              ),
            ),
            home: const ReaderScreen(),
          );
        },
      ),
    );
  }
}
