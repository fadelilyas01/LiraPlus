import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Service utilitaire pour les annonces d'accessibilité (TalkBack / VoiceOver)
class AccessibilityAnnouncer {
  AccessibilityAnnouncer._();

  static String? _lastAnnouncement;
  static DateTime? _lastAnnouncementTime;

  /// Annonce un message vocal au lecteur d'écran (avec anti-rebond)
  static Future<void> announce(
    String message, {
    TextDirection textDirection = TextDirection.ltr,
    bool withHaptic = false,
  }) async {
    if (message.trim().isEmpty) return;

    final now = DateTime.now();
    if (_lastAnnouncement == message &&
        _lastAnnouncementTime != null &&
        now.difference(_lastAnnouncementTime!).inMilliseconds < 1200) {
      return; // Évite les doubles annonces intempestives
    }

    _lastAnnouncement = message;
    _lastAnnouncementTime = now;

    if (withHaptic) {
      unawaited(HapticFeedback.selectionClick());
    }

    try {
      // ignore: deprecated_member_use
      await SemanticsService.announce(message, textDirection);
    } catch (_) {}
  }
}
