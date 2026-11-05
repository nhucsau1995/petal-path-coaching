import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Six-petal progress flower. One petal per programme block; each petal
/// fills from its base outwards. Filled petals alternate cyan / pink.
class PetalFlower extends StatelessWidget {
  const PetalFlower({super.key, required this.petals, this.size = 240, this.centerLabel, this.centerCaption});

  final List<double> petals;
  final double size;
  final String? centerLabel;
  final String? centerCaption;

  @override
  Widget build(BuildContext context) {
    final filled = petals.where((p) => p >= 1).length;
    return Semantics(
      label: 'Progress flower, $filled of 6 petals full',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size.square(size), painter: _FlowerPainter(petals)),
            if (centerLabel != null)
              Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentFill, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(child: Text(centerLabel!, style: AppText.oswald(15, 600))),
                    if (centerCaption != null)
                      FittedBox(child: Text(centerCaption!, style: AppText.caption())),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  _FlowerPainter(this.petals);

  final List<double> petals;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final petalLen = r * 0.92;
    final petalW = r * 0.42;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width / 120)
      ..color = AppColors.borderStrong;

    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle + math.pi / 2);
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-petalW, -petalLen * 0.35, -petalW * 0.7, -petalLen * 0.9, 0, -petalLen)
        ..cubicTo(petalW * 0.7, -petalLen * 0.9, petalW, -petalLen * 0.35, 0, 0)
        ..close();
      final fill = petals[i].clamp(0.0, 1.0);
      if (fill > 0) {
        canvas.save();
        canvas.clipPath(path);
        final color = i.isEven ? AppColors.accent : AppColors.support;
        canvas.drawRect(Rect.fromLTRB(-petalW, -petalLen * fill, petalW, 0), Paint()..color = color);
        canvas.restore();
      }
      canvas.drawPath(path, outline);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FlowerPainter old) => old.petals != petals;
}
