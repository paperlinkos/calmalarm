import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/botanical_character.dart';

class WatercolorFlowerWidget extends StatefulWidget {
  final BotanicalCharacter character;
  final double size;
  final VoidCallback? onTap;

  const WatercolorFlowerWidget({
    super.key,
    required this.character,
    this.size = 220,
    this.onTap,
  });

  @override
  State<WatercolorFlowerWidget> createState() => _WatercolorFlowerWidgetState();
}

class _WatercolorFlowerWidgetState extends State<WatercolorFlowerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breezeController;

  @override
  void initState() {
    super.initState();
    _breezeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breezeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _breezeController,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size * 1.2,
            child: CustomPaint(
              painter: WatercolorFlowerPainter(
                character: widget.character,
                breezeValue: _breezeController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class WatercolorFlowerPainter extends CustomPainter {
  final BotanicalCharacter character;
  final double breezeValue;

  WatercolorFlowerPainter({
    required this.character,
    required this.breezeValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final sway = math.sin(breezeValue * math.pi * 2) * 6.0;

    // 1. Draw Ceramic Vase (Inspired by User Artwork Image #3)
    _drawCeramicVase(canvas, center, size);

    // 2. Draw Stem with Bezier Curve
    final stemEnd = Offset(center.dx + sway, size.height * 0.28);
    final control1 = Offset(center.dx - 12 + sway * 0.5, size.height * 0.55);
    final control2 = Offset(center.dx + 15 + sway * 0.8, size.height * 0.4);

    final stemPath = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, stemEnd.dx, stemEnd.dy);

    final stemPaint = Paint()
      ..color = const Color(0xFF4A5D4E).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(stemPath, stemPaint);

    // 3. Draw Watercolor Leaves
    _drawWatercolorLeaf(canvas, control1, true, 0.9);
    _drawWatercolorLeaf(canvas, control2, false, 1.1);

    // 4. Draw Flower Bud / Blooming Petals based on bloomProgress
    _drawWatercolorPetals(canvas, stemEnd, character.bloomProgress, sway);

    // 5. Draw Playful Fire Overlay if snooze/cheat penalty is active
    if (character.hasFire) {
      _drawPlayfulFire(canvas, stemEnd, size);
    }
  }

  void _drawCeramicVase(Canvas canvas, Offset baseCenter, Size size) {
    final vasePath = Path();
    final topWidth = 28.0;
    final bodyWidth = 48.0;
    final vaseHeight = 70.0;

    vasePath.moveTo(baseCenter.dx - topWidth / 2, baseCenter.dy - vaseHeight);
    vasePath.lineTo(baseCenter.dx + topWidth / 2, baseCenter.dy - vaseHeight);
    
    // Neck curve to body
    vasePath.cubicTo(
      baseCenter.dx + bodyWidth, baseCenter.dy - vaseHeight * 0.5,
      baseCenter.dx + bodyWidth, baseCenter.dy,
      baseCenter.dx + topWidth * 0.6, baseCenter.dy,
    );
    vasePath.lineTo(baseCenter.dx - topWidth * 0.6, baseCenter.dy);
    vasePath.cubicTo(
      baseCenter.dx - bodyWidth, baseCenter.dy,
      baseCenter.dx - bodyWidth, baseCenter.dy - vaseHeight * 0.5,
      baseCenter.dx - topWidth / 2, baseCenter.dy - vaseHeight,
    );
    vasePath.close();

    // Watercolor Ceramic Fill Gradient
    final vaseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFD3C3B1).withOpacity(0.9),
        const Color(0xFFBCAAA4).withOpacity(0.85),
        const Color(0xFF8D6E63).withOpacity(0.9),
      ],
    );

    final vasePaint = Paint()
      ..shader = vaseGradient.createShader(Rect.fromLTWH(
        baseCenter.dx - bodyWidth, baseCenter.dy - vaseHeight, bodyWidth * 2, vaseHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(vasePath, vasePaint);

    // Fine Ink Outline (Oriental Watercolor Detail)
    final inkPaint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(vasePath, inkPaint);
  }

  void _drawWatercolorLeaf(Canvas canvas, Offset position, bool isLeft, double scale) {
    final leafPath = Path();
    final direction = isLeft ? -1.0 : 1.0;
    
    leafPath.moveTo(position.dx, position.dy);
    leafPath.quadraticBezierTo(
      position.dx + (25 * direction * scale), position.dy - (15 * scale),
      position.dx + (40 * direction * scale), position.dy - (5 * scale),
    );
    leafPath.quadraticBezierTo(
      position.dx + (20 * direction * scale), position.dy + (15 * scale),
      position.dx, position.dy,
    );

    final leafPaint = Paint()
      ..color = const Color(0xFF73937E).withOpacity(0.75)
      ..style = PaintingStyle.fill;

    canvas.drawPath(leafPath, leafPaint);

    final leafOutline = Paint()
      ..color = const Color(0xFF2E4032).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(leafPath, leafOutline);
  }

  void _drawWatercolorPetals(Canvas canvas, Offset center, double bloomProgress, double sway) {
    final numPetals = 6;
    final maxRadius = 32.0 * (0.3 + 0.7 * bloomProgress);
    final innerBudRadius = 14.0 + (6.0 * bloomProgress);

    for (int i = 0; i < numPetals; i++) {
      final angle = (i * (2 * math.pi / numPetals)) + (breezeValue * 0.1);
      final petalCenter = Offset(
        center.dx + math.cos(angle) * maxRadius * 0.6,
        center.dy + math.sin(angle) * maxRadius * 0.6,
      );

      final petalPath = Path();
      petalPath.addOval(Rect.fromCircle(center: petalCenter, radius: maxRadius * 0.65));

      // Layered Watercolor Petal Colors (Terracotta to Warm Ochre)
      final petalGradient = RadialGradient(
        colors: [
          const Color(0xFFE05A36).withOpacity(0.85), // Terracotta
          const Color(0xFFD99B6A).withOpacity(0.6),  // Ochre Edge
        ],
      );

      final petalPaint = Paint()
        ..shader = petalGradient.createShader(Rect.fromCircle(center: petalCenter, radius: maxRadius * 0.65))
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, petalPaint);

      // Fine ink outline
      final petalOutline = Paint()
        ..color = const Color(0xFF8C3820).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawPath(petalPath, petalOutline);
    }

    // Center Floral Core
    final corePaint = Paint()
      ..color = const Color(0xFFFFB74D).withOpacity(0.95)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerBudRadius, corePaint);
  }

  void _drawPlayfulFire(Canvas canvas, Offset flowerCenter, Size size) {
    final firePath = Path();
    final fireWidth = 24.0;
    final fireHeight = 35.0 + math.sin(breezeValue * math.pi * 4) * 5.0;

    final top = Offset(flowerCenter.dx, flowerCenter.dy - fireHeight);
    firePath.moveTo(flowerCenter.dx - fireWidth / 2, flowerCenter.dy);
    firePath.quadraticBezierTo(
      flowerCenter.dx - fireWidth * 0.8, flowerCenter.dy - fireHeight * 0.6,
      top.dx, top.dy,
    );
    firePath.quadraticBezierTo(
      flowerCenter.dx + fireWidth * 0.8, flowerCenter.dy - fireHeight * 0.6,
      flowerCenter.dx + fireWidth / 2, flowerCenter.dy,
    );
    firePath.close();

    final firePaint = Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    canvas.drawPath(firePath, firePaint);
  }

  @override
  bool shouldRepaint(covariant WatercolorFlowerPainter oldDelegate) {
    return oldDelegate.breezeValue != breezeValue ||
        oldDelegate.character.bloomProgress != character.bloomProgress ||
        oldDelegate.character.hasFire != character.hasFire;
  }
}
