import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Types de configurations manuelles anatomiques de l'alphabet LSQ
enum LsqHandshapeType {
  fistWithSideThumb, // A : Poing fermé, pouce dressé contre l'index
  flatVerticalPalm, // B : 4 doigts dressés serrés, pouce replié sur la paume
  curvedArcC, // C : Main en arc de cercle ouvert (aucun logo copyright !)
  indexUpWithLoopD, // D : Index vertical, boucle ronde avec les autres doigts
  curvedClawE, // E : Doigts repliés en griffe sur le pouce
  okCircleF, // F : Pouce et index en anneau, 3 doigts dressés
  horizontalPincerG, // G : Index et pouce parallèles horizontaux
  twoFingersH, // H : Index et majeur horizontaux côte à côte
  littleFingerUpI, // I : Auriculaire dressé verticalement
  littleFingerHookJ, // J : Auriculaire avec trajectoire courbée (mouvement actif !)
  kShapeWithMiddleThumb, // K : Index levé, majeur oblique, pouce entre les deux
  lShapeRightAngle, // L : Index et pouce formant un angle droit à 90°
  threeFingersDownM, // M : 3 doigts retombant par-dessus le pouce
  twoFingersDownN, // N : 2 doigts retombant par-dessus le pouce
  circleFingersO, // O : Doigts arrondis touchant le pouce en O
  kShapePointingDownP, // P : Configuration K orientée vers le sol
  pincerPointingDownQ, // Q : Pince G inclinée vers le bas
  crossedFingersR, // R : Index et majeur croisés (porte-bonheur)
  fistFrontThumbS, // S : Poing fermé, pouce barrant le devant des doigts
  thumbBetweenT, // T : Pouce glissé entre l'index et le majeur
  twoFingersTogetherU, // U : Deux doigts droits collés
  vVictorySpread, // V : V de la victoire largement ouvert
  threeFingersSpreadW, // W : 3 doigts écartés vers le haut
  hookedIndexX, // X : Index replié en crochet
  hornsThumbLittleY, // Y : Pouce et auriculaire écartés vers l'extérieur
  indexZigzagZ, // Z : Index traçant un Z dans l'air (mouvement actif !)
}

/// Widget affichant la véritable forme de main vectorielle de la LSQ avec mouvement
class LsqHandshapeWidget extends StatefulWidget {
  final LsqHandshapeType handshape;
  final Color color;
  final double size;
  final bool animateMotion;
  final bool isMirrorView;

  const LsqHandshapeWidget({
    super.key,
    required this.handshape,
    required this.color,
    this.size = 32.0,
    this.animateMotion = true,
    this.isMirrorView = false,
  });

  @override
  State<LsqHandshapeWidget> createState() => _LsqHandshapeWidgetState();
}

class _LsqHandshapeWidgetState extends State<LsqHandshapeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  bool get _hasActiveMotion =>
      widget.handshape == LsqHandshapeType.littleFingerHookJ ||
      widget.handshape == LsqHandshapeType.indexZigzagZ;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (_hasActiveMotion && widget.animateMotion) {
      _motionController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LsqHandshapeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasActiveMotion && widget.animateMotion) {
      if (!_motionController.isAnimating) {
        _motionController.repeat(reverse: true);
      }
    } else {
      _motionController.stop();
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motionController,
      builder: (context, child) {
        Widget content = CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LsqHandshapePainter(
            handshape: widget.handshape,
            color: widget.color,
            motionProgress: _hasActiveMotion ? _motionController.value : 0.0,
          ),
        );
        if (widget.isMirrorView) {
          content = Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
            child: content,
          );
        }
        return content;
      },
    );
  }
}

class _LsqHandshapePainter extends CustomPainter {
  final LsqHandshapeType handshape;
  final Color color;
  final double motionProgress;

  _LsqHandshapePainter({
    required this.handshape,
    required this.color,
    required this.motionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.08).clamp(2.0, 4.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final accentMotionPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.09).clamp(2.5, 4.5)
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    switch (handshape) {
      case LsqHandshapeType.fistWithSideThumb: // A
        // Paume poing fermé + Pouce dressé le long du bord
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.55, h * 0.55),
          Radius.circular(w * 0.18),
        );
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);
        // Pouce vertical collé à gauche
        canvas.drawLine(
          Offset(w * 0.22, h * 0.70),
          Offset(w * 0.22, h * 0.25),
          strokePaint,
        );
        break;

      case LsqHandshapeType.flatVerticalPalm: // B
        // 4 doigts verticaux dressés
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.30, h * 0.15, w * 0.48, h * 0.72),
          Radius.circular(w * 0.12),
        );
        canvas.drawRRect(rect, fillPaint);
        canvas.drawRRect(rect, strokePaint);
        // Lignes de séparation des 4 doigts
        canvas.drawLine(Offset(w * 0.42, h * 0.15), Offset(w * 0.42, h * 0.55),
            strokePaint);
        canvas.drawLine(Offset(w * 0.54, h * 0.15), Offset(w * 0.54, h * 0.55),
            strokePaint);
        canvas.drawLine(Offset(w * 0.66, h * 0.15), Offset(w * 0.66, h * 0.55),
            strokePaint);
        // Pouce replié devant
        canvas.drawLine(Offset(w * 0.30, h * 0.65), Offset(w * 0.65, h * 0.65),
            strokePaint);
        break;

      case LsqHandshapeType
            .curvedArcC: // C (Vraie main en C, zéro logo copyright !)
        final path = Path();
        path.arcTo(
          Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.64),
          -math.pi * 0.65,
          math.pi * 1.3,
          false,
        );
        canvas.drawPath(path, strokePaint);
        // Bouts des doigts arrondis du C
        canvas.drawCircle(Offset(w * 0.65, h * 0.22), w * 0.07, fillPaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.78), w * 0.07, fillPaint);
        break;

      case LsqHandshapeType.indexUpWithLoopD: // D
        // Index droit vertical
        canvas.drawLine(Offset(w * 0.38, h * 0.12), Offset(w * 0.38, h * 0.85),
            strokePaint);
        // Boucle fermée ronde devant
        final circleRect =
            Rect.fromLTWH(w * 0.38, h * 0.40, w * 0.42, h * 0.45);
        canvas.drawOval(circleRect, fillPaint);
        canvas.drawOval(circleRect, strokePaint);
        break;

      case LsqHandshapeType.curvedClawE: // E
        // Griffe repliée en E
        final path = Path()
          ..moveTo(w * 0.25, h * 0.75)
          ..lineTo(w * 0.25, h * 0.30)
          ..quadraticBezierTo(w * 0.50, h * 0.18, w * 0.75, h * 0.35)
          ..lineTo(w * 0.70, h * 0.50)
          ..lineTo(w * 0.35, h * 0.50)
          ..lineTo(w * 0.70, h * 0.75);
        canvas.drawPath(path, strokePaint);
        break;

      case LsqHandshapeType.okCircleF: // F
        // Anneau index-pouce
        canvas.drawCircle(Offset(w * 0.40, h * 0.55), w * 0.18, fillPaint);
        canvas.drawCircle(Offset(w * 0.40, h * 0.55), w * 0.18, strokePaint);
        // 3 doigts dressés vers le haut
        canvas.drawLine(Offset(w * 0.48, h * 0.40), Offset(w * 0.55, h * 0.15),
            strokePaint);
        canvas.drawLine(Offset(w * 0.60, h * 0.45), Offset(w * 0.72, h * 0.18),
            strokePaint);
        canvas.drawLine(Offset(w * 0.68, h * 0.55), Offset(w * 0.85, h * 0.28),
            strokePaint);
        break;

      case LsqHandshapeType.horizontalPincerG: // G
        // Index et pouce horizontaux
        canvas.drawLine(Offset(w * 0.20, h * 0.40), Offset(w * 0.80, h * 0.40),
            strokePaint);
        canvas.drawLine(Offset(w * 0.20, h * 0.60), Offset(w * 0.70, h * 0.60),
            strokePaint);
        canvas.drawLine(Offset(w * 0.20, h * 0.40), Offset(w * 0.20, h * 0.80),
            strokePaint);
        break;

      case LsqHandshapeType.twoFingersH: // H
        // Index et majeur ensemble horizontaux
        canvas.drawLine(Offset(w * 0.20, h * 0.38), Offset(w * 0.82, h * 0.38),
            strokePaint);
        canvas.drawLine(Offset(w * 0.20, h * 0.52), Offset(w * 0.82, h * 0.52),
            strokePaint);
        final baseRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.30, w * 0.24, h * 0.50),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(baseRRect, fillPaint);
        canvas.drawRRect(baseRRect, strokePaint);
        break;

      case LsqHandshapeType.littleFingerUpI: // I
        // Poing fermé avec petit doigt mince dressé vers le haut
        final fist = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.25, h * 0.45, w * 0.50, h * 0.45),
          Radius.circular(w * 0.12),
        );
        canvas.drawRRect(fist, fillPaint);
        canvas.drawRRect(fist, strokePaint);
        // Auriculaire vertical fin
        canvas.drawLine(Offset(w * 0.70, h * 0.45), Offset(w * 0.70, h * 0.14),
            strokePaint);
        break;

      case LsqHandshapeType
            .littleFingerHookJ: // J (Avec animation de trajectoire !)
        // Poing de base
        final fist = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.25, h * 0.40, w * 0.45, h * 0.45),
          Radius.circular(w * 0.12),
        );
        canvas.drawRRect(fist, fillPaint);
        canvas.drawRRect(fist, strokePaint);

        // Flèche animée de courbure dynamique (mouvement en crochet)
        final hookPath = Path()
          ..moveTo(w * 0.65, h * 0.15)
          ..lineTo(w * 0.65, h * 0.65)
          ..quadraticBezierTo(w * 0.65, h * 0.90,
              w * 0.40 + (motionProgress * w * 0.1), h * 0.85)
          ..quadraticBezierTo(w * 0.25, h * 0.80, w * 0.28, h * 0.65);
        canvas.drawPath(hookPath, strokePaint);

        // Flèche de mouvement dynamique en surbrillance
        final arrowPointX = w * 0.28 + (motionProgress * w * 0.08);
        final arrowPointY = h * 0.65 - (motionProgress * h * 0.05);
        canvas.drawCircle(
            Offset(arrowPointX, arrowPointY), w * 0.06, accentMotionPaint);
        break;

      case LsqHandshapeType.kShapeWithMiddleThumb: // K
        canvas.drawLine(Offset(w * 0.35, h * 0.85), Offset(w * 0.35, h * 0.15),
            strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.50), Offset(w * 0.75, h * 0.22),
            strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.55), Offset(w * 0.60, h * 0.55),
            strokePaint);
        break;

      case LsqHandshapeType
            .lShapeRightAngle: // L (Vrai angle droit à 90°, zéro logo !)
        // Index vertical
        canvas.drawLine(Offset(w * 0.32, h * 0.14), Offset(w * 0.32, h * 0.80),
            strokePaint);
        // Pouce horizontal à 90°
        canvas.drawLine(Offset(w * 0.32, h * 0.80), Offset(w * 0.82, h * 0.80),
            strokePaint);
        break;

      case LsqHandshapeType.threeFingersDownM: // M
        final mPath = Path()
          ..moveTo(w * 0.20, h * 0.75)
          ..lineTo(w * 0.20, h * 0.35)
          ..quadraticBezierTo(w * 0.35, h * 0.20, w * 0.40, h * 0.70)
          ..moveTo(w * 0.40, h * 0.35)
          ..quadraticBezierTo(w * 0.55, h * 0.20, w * 0.60, h * 0.70)
          ..moveTo(w * 0.60, h * 0.35)
          ..quadraticBezierTo(w * 0.75, h * 0.20, w * 0.80, h * 0.70);
        canvas.drawPath(mPath, strokePaint);
        break;

      case LsqHandshapeType.twoFingersDownN: // N
        final nPath = Path()
          ..moveTo(w * 0.25, h * 0.75)
          ..lineTo(w * 0.25, h * 0.35)
          ..quadraticBezierTo(w * 0.45, h * 0.20, w * 0.50, h * 0.70)
          ..moveTo(w * 0.50, h * 0.35)
          ..quadraticBezierTo(w * 0.70, h * 0.20, w * 0.75, h * 0.70);
        canvas.drawPath(nPath, strokePaint);
        break;

      case LsqHandshapeType.circleFingersO: // O (Cercle manuel régulier)
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.32, fillPaint);
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.32, strokePaint);
        break;

      case LsqHandshapeType.kShapePointingDownP: // P
        canvas.drawLine(Offset(w * 0.35, h * 0.15), Offset(w * 0.35, h * 0.85),
            strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.50), Offset(w * 0.75, h * 0.78),
            strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.45), Offset(w * 0.60, h * 0.45),
            strokePaint);
        break;

      case LsqHandshapeType.pincerPointingDownQ: // Q
        canvas.drawLine(Offset(w * 0.35, h * 0.15), Offset(w * 0.35, h * 0.82),
            strokePaint);
        canvas.drawLine(Offset(w * 0.55, h * 0.35), Offset(w * 0.55, h * 0.72),
            strokePaint);
        canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.55, h * 0.35),
            strokePaint);
        break;

      case LsqHandshapeType.crossedFingersR: // R
        canvas.drawLine(Offset(w * 0.38, h * 0.85), Offset(w * 0.62, h * 0.18),
            strokePaint);
        canvas.drawLine(Offset(w * 0.62, h * 0.85), Offset(w * 0.38, h * 0.18),
            strokePaint);
        final base = Rect.fromLTWH(w * 0.30, h * 0.55, w * 0.40, h * 0.35);
        canvas.drawOval(base, fillPaint);
        break;

      case LsqHandshapeType
            .fistFrontThumbS: // S (Zéro cadenas, poing avec pouce devant)
        final fist = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.22, h * 0.30, w * 0.56, h * 0.60),
          Radius.circular(w * 0.16),
        );
        canvas.drawRRect(fist, fillPaint);
        canvas.drawRRect(fist, strokePaint);
        // Pouce barrant le devant horizontalement
        canvas.drawLine(Offset(w * 0.22, h * 0.58), Offset(w * 0.78, h * 0.58),
            strokePaint);
        break;

      case LsqHandshapeType.thumbBetweenT: // T
        final fist = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.22, h * 0.35, w * 0.56, h * 0.55),
          Radius.circular(w * 0.16),
        );
        canvas.drawRRect(fist, fillPaint);
        canvas.drawRRect(fist, strokePaint);
        // Pouce dépassant entre l'index et le majeur
        canvas.drawCircle(Offset(w * 0.44, h * 0.26), w * 0.10, fillPaint);
        canvas.drawCircle(Offset(w * 0.44, h * 0.26), w * 0.10, strokePaint);
        break;

      case LsqHandshapeType.twoFingersTogetherU: // U
        // 2 doigts droits collés
        canvas.drawLine(Offset(w * 0.40, h * 0.15), Offset(w * 0.40, h * 0.75),
            strokePaint);
        canvas.drawLine(Offset(w * 0.58, h * 0.15), Offset(w * 0.58, h * 0.75),
            strokePaint);
        final baseU = Rect.fromLTWH(w * 0.30, h * 0.50, w * 0.38, h * 0.38);
        canvas.drawOval(baseU, fillPaint);
        canvas.drawOval(baseU, strokePaint);
        break;

      case LsqHandshapeType.vVictorySpread: // V
        canvas.drawLine(Offset(w * 0.48, h * 0.85), Offset(w * 0.25, h * 0.15),
            strokePaint);
        canvas.drawLine(Offset(w * 0.48, h * 0.85), Offset(w * 0.75, h * 0.15),
            strokePaint);
        break;

      case LsqHandshapeType.threeFingersSpreadW: // W
        canvas.drawLine(Offset(w * 0.50, h * 0.85), Offset(w * 0.20, h * 0.18),
            strokePaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.85), Offset(w * 0.50, h * 0.15),
            strokePaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.85), Offset(w * 0.80, h * 0.18),
            strokePaint);
        break;

      case LsqHandshapeType.hookedIndexX: // X (Index en crochet)
        final xPath = Path()
          ..moveTo(w * 0.35, h * 0.80)
          ..lineTo(w * 0.35, h * 0.35)
          ..quadraticBezierTo(w * 0.50, h * 0.15, w * 0.72, h * 0.32)
          ..lineTo(w * 0.58, h * 0.50);
        canvas.drawPath(xPath, strokePaint);
        break;

      case LsqHandshapeType
            .hornsThumbLittleY: // Y (Pouce et auriculaire écartés)
        // Paume centrale
        final yFist = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.35, h * 0.35, w * 0.30, h * 0.45),
          Radius.circular(w * 0.10),
        );
        canvas.drawRRect(yFist, fillPaint);
        canvas.drawRRect(yFist, strokePaint);
        // Pouce vers la gauche
        canvas.drawLine(Offset(w * 0.35, h * 0.55), Offset(w * 0.10, h * 0.25),
            strokePaint);
        // Auriculaire vers la droite
        canvas.drawLine(Offset(w * 0.65, h * 0.55), Offset(w * 0.90, h * 0.25),
            strokePaint);
        break;

      case LsqHandshapeType
            .indexZigzagZ: // Z (Avec trajectoire animée 60 FPS !)
        // Doigt index
        canvas.drawLine(Offset(w * 0.25, h * 0.75), Offset(w * 0.25, h * 0.40),
            strokePaint);

        // Tracé du Z dans l'air
        final zPath = Path()
          ..moveTo(w * 0.25, h * 0.25)
          ..lineTo(w * 0.75, h * 0.25)
          ..lineTo(w * 0.25, h * 0.70)
          ..lineTo(w * 0.75, h * 0.70);
        canvas.drawPath(zPath, strokePaint);

        // Curseur de mouvement animé sur le Z
        final double cursorX;
        final double cursorY;
        if (motionProgress < 0.33) {
          final t = motionProgress / 0.33;
          cursorX = w * 0.25 + t * (w * 0.50);
          cursorY = h * 0.25;
        } else if (motionProgress < 0.66) {
          final t = (motionProgress - 0.33) / 0.33;
          cursorX = w * 0.75 - t * (w * 0.50);
          cursorY = h * 0.25 + t * (h * 0.45);
        } else {
          final t = (motionProgress - 0.66) / 0.34;
          cursorX = w * 0.25 + t * (w * 0.50);
          cursorY = h * 0.70;
        }
        canvas.drawCircle(
            Offset(cursorX, cursorY), w * 0.08, accentMotionPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LsqHandshapePainter oldDelegate) {
    return oldDelegate.handshape != handshape ||
        oldDelegate.color != color ||
        oldDelegate.motionProgress != motionProgress;
  }
}
