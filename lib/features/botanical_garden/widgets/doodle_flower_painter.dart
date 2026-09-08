import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/botanical_character.dart';

class DoodleFlowerWidget extends StatefulWidget {
  final BotanicalCharacter character;
  final double size;
  final VoidCallback? onTap;

  const DoodleFlowerWidget({
    super.key,
    required this.character,
    this.size = 200,
    this.onTap,
  });

  @override
  State<DoodleFlowerWidget> createState() => _DoodleFlowerWidgetState();
}

class _DoodleFlowerWidgetState extends State<DoodleFlowerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;

  @override
  void initState() {
    super.initState();
    // Frame-by-frame hand-drawn wiggle simulation
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _wiggleController,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size * 1.2,
            child: CustomPaint(
              painter: DoodleFlowerPainter(
                character: widget.character,
                wiggle: _wiggleController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class DoodleFlowerPainter extends CustomPainter {
  final BotanicalCharacter character;
  final double wiggle;

  // Hand-drawn monoline cobalt ink color (from user image)
  static const Color inkColor = Color(0xFF24338A);
  static const Color inkFireColor = Color(0xFFD32F2F);

  DoodleFlowerPainter({
    required this.character,
    required this.wiggle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseCenter = Offset(size.width / 2, size.height * 0.90);
    final j = math.sin(wiggle * math.pi * 2) * 2.0; // Hand jitter

    final inkPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width / 45.0).clamp(1.8, 2.6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = inkColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    switch (character.species) {
      case BotanicalSpecies.daisy:
        _drawDoodleDaisy(canvas, baseCenter, size, inkPaint, fillPaint, j);
        break;
      case BotanicalSpecies.rose:
        _drawDoodleRose(canvas, baseCenter, size, inkPaint, fillPaint, j);
        break;
      case BotanicalSpecies.mushroom:
        _drawDoodleMushroom(canvas, baseCenter, size, inkPaint, fillPaint, j);
        break;
      case BotanicalSpecies.tree:
      case BotanicalSpecies.bonsai:
      case BotanicalSpecies.lotus:
        _drawDoodleTree(canvas, baseCenter, size, inkPaint, fillPaint, j);
        break;
    }

    // Draw Playful Doodle Flame if penalty active
    if (character.hasFire) {
      _drawDoodleFire(canvas, Offset(size.width / 2 + j, size.height * 0.22), size);
    }
  }

  void _drawDoodleDaisy(Canvas canvas, Offset baseCenter, Size size, Paint inkPaint, Paint fillPaint, double j) {
    final stemEnd = Offset(baseCenter.dx + j, size.height * 0.48);
    final control1 = Offset(baseCenter.dx - 6 + j * 0.5, size.height * 0.70);

    // Stem
    final stemPath = Path()
      ..moveTo(baseCenter.dx, baseCenter.dy)
      ..quadraticBezierTo(control1.dx, control1.dy, stemEnd.dx, stemEnd.dy);
    canvas.drawPath(stemPath, inkPaint);

    // Leaves
    final leftLeaf = Path()
      ..moveTo(baseCenter.dx - 2, baseCenter.dy - size.height * 0.15)
      ..quadraticBezierTo(
        baseCenter.dx - size.width * 0.22 + j, baseCenter.dy - size.height * 0.22,
        baseCenter.dx - size.width * 0.28 + j, baseCenter.dy - size.height * 0.14,
      )
      ..quadraticBezierTo(
        baseCenter.dx - size.width * 0.15, baseCenter.dy - size.height * 0.10,
        baseCenter.dx - 2, baseCenter.dy - size.height * 0.15,
      );
    canvas.drawPath(leftLeaf, inkPaint);
    canvas.drawPath(leftLeaf, fillPaint);

    final rightLeaf = Path()
      ..moveTo(baseCenter.dx + 2, baseCenter.dy - size.height * 0.26)
      ..quadraticBezierTo(
        baseCenter.dx + size.width * 0.20 + j, baseCenter.dy - size.height * 0.32,
        baseCenter.dx + size.width * 0.26 + j, baseCenter.dy - size.height * 0.22,
      )
      ..quadraticBezierTo(
        baseCenter.dx + size.width * 0.12, baseCenter.dy - size.height * 0.20,
        baseCenter.dx + 2, baseCenter.dy - size.height * 0.26,
      );
    canvas.drawPath(rightLeaf, inkPaint);
    canvas.drawPath(rightLeaf, fillPaint);

    // Center Core Ring
    final coreRadius = size.width * 0.12 * (0.8 + 0.4 * character.bloomProgress);
    final coreCenter = Offset(stemEnd.dx, stemEnd.dy - coreRadius);
    canvas.drawCircle(coreCenter, coreRadius, inkPaint);
    canvas.drawCircle(coreCenter, coreRadius, fillPaint);

    // Doodle Petals loop around core
    final numPetals = 8;
    final petalLength = size.width * 0.18 * (0.4 + 0.6 * character.bloomProgress);
    for (int i = 0; i < numPetals; i++) {
      final angle = (i * (2 * math.pi / numPetals)) + (j * 0.05);
      final p1 = Offset(
        coreCenter.dx + math.cos(angle) * coreRadius,
        coreCenter.dy + math.sin(angle) * coreRadius,
      );
      final pTip = Offset(
        coreCenter.dx + math.cos(angle) * (coreRadius + petalLength),
        coreCenter.dy + math.sin(angle) * (coreRadius + petalLength),
      );

      final petalPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          pTip.dx + math.sin(angle) * 6, pTip.dy - math.cos(angle) * 6,
          pTip.dx, pTip.dy,
        )
        ..quadraticBezierTo(
          pTip.dx - math.sin(angle) * 6, pTip.dy + math.cos(angle) * 6,
          p1.dx, p1.dy,
        );

      canvas.drawPath(petalPath, inkPaint);
    }

    // Floating Doodle Bumblebee when awake!
    if (character.bloomProgress > 0.6) {
      _drawDoodleBee(canvas, Offset(coreCenter.dx + size.width * 0.32 + j, coreCenter.dy - size.height * 0.12 + j), inkPaint);
    }
  }

  void _drawDoodleRose(Canvas canvas, Offset baseCenter, Size size, Paint inkPaint, Paint fillPaint, double j) {
    final headCenter = Offset(baseCenter.dx + j, size.height * 0.48);

    // Stem
    final stemPath = Path()
      ..moveTo(baseCenter.dx, baseCenter.dy)
      ..lineTo(headCenter.dx, headCenter.dy);
    canvas.drawPath(stemPath, inkPaint);

    // Swirl Rose Head
    final swirlPath = Path();
    double r = 3.0;
    swirlPath.moveTo(headCenter.dx, headCenter.dy);
    final maxSpiral = 4.5 * math.pi * (0.3 + 0.7 * character.bloomProgress);
    for (double theta = 0; theta < maxSpiral; theta += 0.2) {
      r = 2.5 + (theta * 1.8);
      final x = headCenter.dx + r * math.cos(theta);
      final y = headCenter.dy + r * math.sin(theta);
      swirlPath.lineTo(x, y);
    }
    canvas.drawPath(swirlPath, inkPaint);
  }

  void _drawDoodleMushroom(Canvas canvas, Offset baseCenter, Size size, Paint inkPaint, Paint fillPaint, double j) {
    final capCenter = Offset(baseCenter.dx + j, size.height * 0.52);
    final capWidth = size.width * 0.50 + (character.bloomProgress * 8.0);
    final capHeight = size.height * 0.28;

    // Stem
    final stemPath = Path()
      ..moveTo(baseCenter.dx - 8, baseCenter.dy)
      ..lineTo(baseCenter.dx - 6 + j, capCenter.dy)
      ..lineTo(baseCenter.dx + 6 + j, capCenter.dy)
      ..lineTo(baseCenter.dx + 8, baseCenter.dy)
      ..close();
    canvas.drawPath(stemPath, inkPaint);

    // Mushroom Cap (Dome)
    final capPath = Path()
      ..moveTo(capCenter.dx - capWidth / 2, capCenter.dy)
      ..cubicTo(
        capCenter.dx - capWidth / 2, capCenter.dy - capHeight * 1.2,
        capCenter.dx + capWidth / 2, capCenter.dy - capHeight * 1.2,
        capCenter.dx + capWidth / 2, capCenter.dy,
      )
      ..close();

    canvas.drawPath(capPath, inkPaint);
    canvas.drawPath(capPath, fillPaint);

    // Spots on cap
    canvas.drawCircle(Offset(capCenter.dx - 10, capCenter.dy - 14), 3, inkPaint);
    canvas.drawCircle(Offset(capCenter.dx + 8, capCenter.dy - 16), 4, inkPaint);
    canvas.drawCircle(Offset(capCenter.dx, capCenter.dy - 8), 2.5, inkPaint);
  }

  void _drawDoodleTree(Canvas canvas, Offset baseCenter, Size size, Paint inkPaint, Paint fillPaint, double j) {
    final topCenter = Offset(baseCenter.dx + j, size.height * 0.50);

    // Trunk
    final trunkPath = Path()
      ..moveTo(baseCenter.dx - 9, baseCenter.dy)
      ..lineTo(baseCenter.dx - 6 + j, topCenter.dy)
      ..lineTo(baseCenter.dx + 6 + j, topCenter.dy)
      ..lineTo(baseCenter.dx + 9, baseCenter.dy);
    canvas.drawPath(trunkPath, inkPaint);

    // Cloud-like Canopy Loops
    final canopyPath = Path();
    final r = size.width * 0.25 * (0.5 + 0.5 * character.bloomProgress);
    canopyPath.addOval(Rect.fromCircle(center: Offset(topCenter.dx - 14, topCenter.dy - 12), radius: r));
    canopyPath.addOval(Rect.fromCircle(center: Offset(topCenter.dx + 14, topCenter.dy - 12), radius: r));
    canopyPath.addOval(Rect.fromCircle(center: Offset(topCenter.dx, topCenter.dy - 26), radius: r * 1.1));

    canvas.drawPath(canopyPath, inkPaint);
    canvas.drawPath(canopyPath, fillPaint);
  }

  void _drawDoodleBee(Canvas canvas, Offset pos, Paint inkPaint) {
    final beeBody = Path()
      ..addOval(Rect.fromCenter(center: pos, width: 12, height: 8));
    canvas.drawPath(beeBody, inkPaint);

    final wing1 = Path()
      ..addOval(Rect.fromCenter(center: Offset(pos.dx - 2, pos.dy - 6), width: 6, height: 8));
    final wing2 = Path()
      ..addOval(Rect.fromCenter(center: Offset(pos.dx + 3, pos.dy - 6), width: 6, height: 8));

    canvas.drawPath(wing1, inkPaint);
    canvas.drawPath(wing2, inkPaint);
  }

  void _drawDoodleFire(Canvas canvas, Offset pos, Size size) {
    final firePaint = Paint()
      ..color = inkFireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final firePath = Path()
      ..moveTo(pos.dx - 10, pos.dy + 8)
      ..quadraticBezierTo(pos.dx - 14, pos.dy - 8, pos.dx, pos.dy - 18)
      ..quadraticBezierTo(pos.dx + 14, pos.dy - 8, pos.dx + 10, pos.dy + 8)
      ..close();

    canvas.drawPath(firePath, firePaint);
  }

  @override
  bool shouldRepaint(covariant DoodleFlowerPainter oldDelegate) {
    return oldDelegate.wiggle != wiggle ||
        oldDelegate.character.bloomProgress != character.bloomProgress ||
        oldDelegate.character.species != character.species ||
        oldDelegate.character.hasFire != character.hasFire;
  }
}
