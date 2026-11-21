import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/accessibility_themes.dart';

/// Types de mouvements gestuels en Langue des Signes Québécoise (LSQ)
enum LsqMovementKind {
  wingsFlapping, // Battements répétés (oiseau, papillon)
  whiskersCaress, // Caresse symétrique vers l'extérieur (chat)
  pattingThigh, // Tapotement vertical vers le bas (chien)
  treeSwaying, // Tronc fixe et oscillation douce des branches (arbre, forêt)
  handPinch, // Pincement répété (bec, petit)
  turningPages, // Deux mains qui miment l'ouverture d'un livre (livre, lire)
  heartPulse, // Battement doux sur la poitrine (aimer, cœur)
  sunRaysExpansion, // Mains partant du centre et s'ouvrant vers l'extérieur (soleil, lumière)
  houseRoofTriangle, // Mains formant un chevron descendant (maison, école)
  waterWaveFlow, // Vague ondulante horizontale (eau, rivière, mer)
  starTwinkle, // Doigts qui s'ouvrent et se ferment en étincelles (étoile, briller)
  directionalArc, // Trajectoire en arc dynamique (mouvement par défaut)
}

/// Modèle descriptif complet du mouvement en LSQ
class LsqMotionSpec {
  final String title;
  final LsqMovementKind kind;
  final String startPosition;
  final String trajectoryDescription;
  final String repetition;
  final int defaultCycles;

  const LsqMotionSpec({
    required this.title,
    required this.kind,
    required this.startPosition,
    required this.trajectoryDescription,
    required this.repetition,
    this.defaultCycles = 2,
  });

  /// Déduit le profil de mouvement à partir du mot
  static LsqMotionSpec fromWord(String word) {
    final lower = word.toLowerCase();

    if (lower.contains('oiseau') ||
        lower.contains('vole') ||
        lower.contains('geai') ||
        lower.contains('papillon')) {
      return const LsqMotionSpec(
        title: 'Battement des ailes & Pincement du bec',
        kind: LsqMovementKind.wingsFlapping,
        startPosition: 'Mains devant la poitrine ou près du visage.',
        trajectoryDescription:
            'L\'index et le pouce se pincent 2 fois, puis les deux mains battent de haut en bas.',
        repetition: '2 battements doux consécutifs.',
      );
    }

    if (lower.contains('sapin') ||
        lower.contains('érable') ||
        lower.contains('arbre') ||
        lower.contains('forêt') ||
        lower.contains('bois')) {
      return const LsqMotionSpec(
        title: 'Oscillation du tronc et des branches au vent',
        kind: LsqMovementKind.treeSwaying,
        startPosition:
            'Coude posé sur le dos de l\'autre main, avant-bras vertical.',
        trajectoryDescription:
            'La main ouverte ondule doucement de gauche à droite comme les branches d\'un sapin ou d\'un érable.',
        repetition: 'Mouvement fluide continu.',
      );
    }

    if (lower.contains('mange') ||
        lower.contains('graine') ||
        lower.contains('petit') ||
        lower.contains('bec')) {
      return const LsqMotionSpec(
        title: 'Pincement délicat vers la bouche',
        kind: LsqMovementKind.handPinch,
        startPosition: 'Bout des doigts réunis devant la bouche.',
        trajectoryDescription:
            'Rapprocher et pincer délicatement les doigts pour mimer le bec ou le fait de manger.',
        repetition: '2 petits mouvements doux.',
      );
    }

    if (lower.contains('sourire') ||
        lower.contains('ami') ||
        lower.contains('aimer') ||
        lower.contains('cœur') ||
        lower.contains('souhaite') ||
        lower.contains('merveilleu') ||
        lower.contains('courageu')) {
      return const LsqMotionSpec(
        title: 'Geste chaleureux et bienveillant',
        kind: LsqMovementKind.heartPulse,
        startPosition: 'Main ouverte près du cœur ou des joues.',
        trajectoryDescription:
            'Mouvement circulaire doux sur la poitrine ou vers l\'extérieur avec un beau sourire.',
        repetition: '2 pulsations douces.',
      );
    }

    if (lower.contains('étoile') ||
        lower.contains('brille') ||
        lower.contains('doré') ||
        lower.contains('neige') ||
        lower.contains('illumin') ||
        lower.contains('étincel') ||
        lower.contains('blanc')) {
      return const LsqMotionSpec(
        title: 'Scintillement lumineux des doigts',
        kind: LsqMovementKind.starTwinkle,
        startPosition: 'Mains levées vers le haut, doigts légèrement courbés.',
        trajectoryDescription:
            'Ouvrir et fermer les doigts en alternance comme des étoiles qui brillent ou la neige qui tombe.',
        repetition: 'Scintillement continu.',
      );
    }

    if (lower.contains('chat') || lower.contains('cerf')) {
      return const LsqMotionSpec(
        title: 'Geste animal près du visage',
        kind: LsqMovementKind.whiskersCaress,
        startPosition: 'Mains de chaque côté du visage.',
        trajectoryDescription:
            'Écarter doucement les doigts vers l\'extérieur pour figurer les moustaches ou les bois.',
        repetition: '2 fois de suite.',
      );
    }

    if (lower.contains('chien') ||
        lower.contains('marche') ||
        lower.contains('avance') ||
        lower.contains('sentier') ||
        lower.contains('enfant')) {
      return const LsqMotionSpec(
        title: 'Rythme de pas et de mouvement',
        kind: LsqMovementKind.pattingThigh,
        startPosition: 'Main ouverte devant soi, paume vers le bas.',
        trajectoryDescription:
            'Mouvement rythmé vers le bas ou vers l\'avant pour montrer quelqu\'un qui avance ou un enfant.',
        repetition: '2 tapotements légers rythmés.',
      );
    }

    if (lower.contains('livre') ||
        lower.contains('lire') ||
        lower.contains('histoire') ||
        lower.contains('découvr') ||
        lower.contains('sac') ||
        lower.contains('enseignant') ||
        lower.contains('classe')) {
      return const LsqMotionSpec(
        title: 'Ouverture du livre à deux mains',
        kind: LsqMovementKind.turningPages,
        startPosition: 'Deux mains jointes paumes collées devant soi.',
        trajectoryDescription:
            'Ouvrir les deux paumes vers le haut comme un livre qu\'on découvre à l\'école.',
        repetition: '1 ouverture franche suivie d\'un léger balayage.',
      );
    }

    if (lower.contains('soleil') ||
        lower.contains('ciel') ||
        lower.contains('jour') ||
        lower.contains('matin') ||
        lower.contains('grand') ||
        lower.contains('bleu') ||
        lower.contains('air')) {
      return const LsqMotionSpec(
        title: 'Déploiement ample vers le ciel',
        kind: LsqMovementKind.sunRaysExpansion,
        startPosition: 'Main près du front ou devant le visage.',
        trajectoryDescription:
            'Ouvrir les doigts en déployant la main vers l\'extérieur pour montrer le ciel, le soleil ou la grandeur.',
        repetition: '1 déploiement ample.',
      );
    }

    if (lower.contains('maison') ||
        lower.contains('école') ||
        lower.contains('cabane') ||
        lower.contains('montagne') ||
        lower.contains('sommet') ||
        lower.contains('fenêtre')) {
      return const LsqMotionSpec(
        title: 'Tracé du toit ou du sommet en triangle',
        kind: LsqMovementKind.houseRoofTriangle,
        startPosition:
            'Bouts des doigts joints au sommet pour former un angle.',
        trajectoryDescription:
            'Descendre les deux mains obliquement pour dessiner le toit de la maison, de la cabane ou le sommet.',
        repetition: '1 descente ferme.',
      );
    }

    if (lower.contains('eau') ||
        lower.contains('mer') ||
        lower.contains('lac') ||
        lower.contains('fleuve') ||
        lower.contains('ruisseau') ||
        lower.contains('baleine') ||
        lower.contains('béluga') ||
        lower.contains('nage') ||
        lower.contains('doucement') ||
        lower.contains('vent') ||
        lower.contains('souffle') ||
        lower.contains('calme')) {
      return const LsqMotionSpec(
        title: 'Ondulation douce et fluide',
        kind: LsqMovementKind.waterWaveFlow,
        startPosition: 'Main horizontale paume vers le bas.',
        trajectoryDescription:
            'Faire onduler la main en vagues calmes vers l\'avant pour mimer l\'eau, le vent ou la douceur.',
        repetition: 'Mouvement continu et calme.',
      );
    }

    // Geste par défaut : Arc directionnel avec pulsation
    return const LsqMotionSpec(
      title: 'Mouvement directionnel du signe',
      kind: LsqMovementKind.directionalArc,
      startPosition: 'Main dans l\'espace neutre devant le torse.',
      trajectoryDescription:
          'Mouvement fluide de l\'arrière vers l\'avant avec orientation de la paume.',
      repetition: '1 à 2 répétitions régulières.',
    );
  }
}

/// Visualiseur animé 60 FPS du mouvement pour les élèves sourds et malentendants
class LsqMotionViewer extends StatefulWidget {
  final String word;
  final AccessibilityColors colors;
  final bool isLowVision;
  final bool enableHaptics;

  const LsqMotionViewer({
    super.key,
    required this.word,
    required this.colors,
    required this.isLowVision,
    this.enableHaptics = true,
  });

  @override
  State<LsqMotionViewer> createState() => _LsqMotionViewerState();
}

class _LsqMotionViewerState extends State<LsqMotionViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late LsqMotionSpec _spec;
  bool _isSlowMotion = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _spec = LsqMotionSpec.fromWord(widget.word);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.enableHaptics) {
          unawaited(HapticFeedback.lightImpact());
        }
        if (_isPlaying) {
          _animController.forward(from: 0.0);
        }
      }
    });

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant LsqMotionViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) {
      setState(() {
        _spec = LsqMotionSpec.fromWord(widget.word);
      });
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animController.forward();
      } else {
        _animController.stop();
      }
    });
    if (widget.enableHaptics) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void _toggleSlowMotion() {
    setState(() {
      _isSlowMotion = !_isSlowMotion;
      _animController.duration = _isSlowMotion
          ? const Duration(milliseconds: 3200)
          : const Duration(milliseconds: 1800);
    });
    if (_isPlaying) {
      _animController.forward(from: _animController.value);
    }
    if (widget.enableHaptics) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isLowVision = widget.isLowVision;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowVision
              ? colors.border
              : colors.border.withValues(alpha: 0.7),
          width: isLowVision ? 2.5 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête du composant de mouvement LSQ (Anti-Overflow garanti par Wrap)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.motion_photos_on_rounded,
                          size: 18, color: colors.accent),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MOUVEMENT DU SIGNE (LSQ)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
                // Badge interactif "En mouvement"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPlaying ? Colors.green : colors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _isPlaying ? Colors.green : colors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlaying ? 'Mouvement actif' : 'En pause',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color:
                              _isPlaying ? Colors.green : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Zone Canvas animée 60 FPS du mouvement
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _LsqGestureMovementPainter(
                    kind: _spec.kind,
                    colors: colors,
                    progress: _animController.value,
                    isLowVision: isLowVision,
                  ),
                );
              },
            ),
          ),

          // Barre de contrôle du mouvement pour l'élève sourd (Wrap anti-débordement)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(19)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                // Bouton Pause / Relance
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: colors.accent,
                    size: 22,
                  ),
                  label: Text(
                    _isPlaying ? 'Arrêter' : 'Animer',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),

                // Bouton Ralenti pour décomposer le geste
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _isSlowMotion ? colors.background : colors.textPrimary,
                    backgroundColor:
                        _isSlowMotion ? colors.accent : Colors.transparent,
                    side: BorderSide(color: colors.accent, width: 1.2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _toggleSlowMotion,
                  icon: Icon(
                    Icons.slow_motion_video_rounded,
                    size: 16,
                    color: _isSlowMotion ? colors.background : colors.accent,
                  ),
                  label: Text(
                    _isSlowMotion ? 'Ralenti 0.5x' : 'Ralenti',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Décomposition pédagogique des 3 phases du mouvement
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMotionStep(
                  stepNumber: '1',
                  stepTitle: 'Point de départ :',
                  stepDescription: _spec.startPosition,
                  colors: colors,
                ),
                const SizedBox(height: 8),
                _buildMotionStep(
                  stepNumber: '2',
                  stepTitle: 'Mouvement & Trajectoire :',
                  stepDescription: _spec.trajectoryDescription,
                  colors: colors,
                ),
                const SizedBox(height: 8),
                _buildMotionStep(
                  stepNumber: '3',
                  stepTitle: 'Répétition & Rythme :',
                  stepDescription: _spec.repetition,
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionStep({
    required String stepNumber,
    required String stepTitle,
    required String stepDescription,
    required AccessibilityColors colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: colors.background,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  color: colors.textPrimary, fontSize: 13, height: 1.4),
              children: [
                TextSpan(
                  text: '$stepTitle ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: stepDescription,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Peintre vectoriel 60 FPS des trajectoires et battements de mains
class _LsqGestureMovementPainter extends CustomPainter {
  final LsqMovementKind kind;
  final AccessibilityColors colors;
  final double progress; // 0.0 à 1.0
  final bool isLowVision;

  _LsqGestureMovementPainter({
    required this.kind,
    required this.colors,
    required this.progress,
    required this.isLowVision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.5;
    final centerY = h * 0.5;

    // Arrière-plan de scène neutre
    final bgPaint = Paint()
      ..color = colors.surfaceVariant.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), const Radius.circular(16)),
      bgPaint,
    );

    final trackPaint = Paint()
      ..color = colors.border.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final motionArrowPaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLowVision ? 4.0 : 3.0
      ..strokeCap = StrokeCap.round;

    final handMarkerPaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.fill;

    switch (kind) {
      case LsqMovementKind.wingsFlapping: // Battement d'ailes
        // Flèches d'oscillation verticale de chaque côté
        final flapDelta = math.sin(progress * math.pi * 4.0) * 22.0;

        // Aile gauche
        final leftPath = Path()
          ..moveTo(centerX - 90, centerY + 20)
          ..quadraticBezierTo(
              centerX - 60, centerY - 25, centerX - 25, centerY);
        canvas.drawPath(leftPath, trackPaint);
        // Main gauche en battement
        final leftHand = Offset(centerX - 70, centerY + flapDelta);
        canvas.drawCircle(leftHand, 12, handMarkerPaint);
        // Flèche de mouvement
        canvas.drawLine(
            leftHand, Offset(leftHand.dx, leftHand.dy - 16), motionArrowPaint);

        // Aile droite
        final rightPath = Path()
          ..moveTo(centerX + 25, centerY)
          ..quadraticBezierTo(
              centerX + 60, centerY - 25, centerX + 90, centerY + 20);
        canvas.drawPath(rightPath, trackPaint);
        // Main droite en battement
        final rightHand = Offset(centerX + 70, centerY - flapDelta);
        canvas.drawCircle(rightHand, 12, handMarkerPaint);
        canvas.drawLine(rightHand, Offset(rightHand.dx, rightHand.dy - 16),
            motionArrowPaint);
        break;

      case LsqMovementKind
            .whiskersCaress: // Moustaches du chat vers l'extérieur
        final spreadT = (progress * 2.0).clamp(0.0, 1.0);
        final spreadX = spreadT * 65.0;

        // Tracé gauche
        canvas.drawLine(Offset(centerX - 20, centerY),
            Offset(centerX - 90, centerY - 10), trackPaint);
        canvas.drawLine(Offset(centerX - 20, centerY + 15),
            Offset(centerX - 90, centerY + 15), trackPaint);
        // Tracé droite
        canvas.drawLine(Offset(centerX + 20, centerY),
            Offset(centerX + 90, centerY - 10), trackPaint);
        canvas.drawLine(Offset(centerX + 20, centerY + 15),
            Offset(centerX + 90, centerY + 15), trackPaint);

        // Mains animées s'écartant
        canvas.drawCircle(
            Offset(centerX - 20 - spreadX, centerY), 11, handMarkerPaint);
        canvas.drawCircle(
            Offset(centerX + 20 + spreadX, centerY), 11, handMarkerPaint);
        break;

      case LsqMovementKind.pattingThigh: // Tapotement vertical vers le bas
        final patT = math.sin(progress * math.pi * 4.0).abs();
        final patY = centerY - 20 + (patT * 35.0);

        // Tracé vertical
        canvas.drawLine(Offset(centerX, centerY - 30),
            Offset(centerX, centerY + 30), trackPaint);
        // Main qui tape
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(centerX, patY), width: 44, height: 20),
              const Radius.circular(8)),
          handMarkerPaint,
        );
        // Onde d'impact au contact
        if (patT > 0.8) {
          canvas.drawArc(
            Rect.fromCenter(
                center: Offset(centerX, centerY + 32), width: 50, height: 16),
            0,
            math.pi,
            false,
            motionArrowPaint,
          );
        }
        break;

      case LsqMovementKind.treeSwaying: // Tronc et oscillation des branches
        // Tronc vertical fixe
        canvas.drawLine(Offset(centerX, h * 0.85), Offset(centerX, h * 0.35),
            motionArrowPaint);
        // Balancement des feuilles au vent
        final swayAngle = math.sin(progress * math.pi * 2.0) * 0.35;
        final swayX = centerX + math.sin(swayAngle) * 45.0;
        final swayY = (h * 0.35) - math.cos(swayAngle) * 35.0;

        canvas.drawLine(
            Offset(centerX, h * 0.35), Offset(swayX, swayY), motionArrowPaint);
        canvas.drawCircle(Offset(swayX, swayY), 16, handMarkerPaint);
        break;

      case LsqMovementKind.turningPages: // Livre ouvert
        final openAngle = progress * math.pi * 0.45;
        final pageLeftX = centerX - math.cos(openAngle) * 60.0;
        final pageRightX = centerX + math.cos(openAngle) * 60.0;

        canvas.drawLine(Offset(centerX, h * 0.75), Offset(pageLeftX, h * 0.35),
            motionArrowPaint);
        canvas.drawLine(Offset(centerX, h * 0.75), Offset(pageRightX, h * 0.35),
            motionArrowPaint);
        canvas.drawCircle(Offset(pageLeftX, h * 0.35), 10, handMarkerPaint);
        canvas.drawCircle(Offset(pageRightX, h * 0.35), 10, handMarkerPaint);
        break;

      default: // Arc directionnel fluide universel
        final arcAngle = progress * math.pi * 1.5;
        const arcRadius = 45.0;
        final currentX = centerX + math.cos(arcAngle) * arcRadius;
        final currentY = centerY + math.sin(arcAngle) * (arcRadius * 0.6);

        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(centerX, centerY), width: 90, height: 50),
          trackPaint,
        );
        canvas.drawCircle(Offset(currentX, currentY), 12, handMarkerPaint);
        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(currentX + 10, currentY - 8),
          motionArrowPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LsqGestureMovementPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.kind != kind ||
        oldDelegate.colors != colors;
  }
}
