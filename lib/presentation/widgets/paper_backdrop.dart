import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/nesti_theme.dart';

class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF2), NestiColors.paper, Color(0xFFEAF0E5)],
          stops: [0, 0.56, 1],
        ),
      ),
      child: CustomPaint(painter: _PaperGrainPainter(), child: child),
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = NestiColors.ink.withValues(alpha: 0.028);
    for (var i = 0; i < 240; i++) {
      final offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawCircle(offset, random.nextDouble() * 0.8 + 0.2, paint);
    }
    final glow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x55F2CB7B), Color(0x00F2CB7B)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.76, size.height * 0.2),
              radius: size.shortestSide * 0.42,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
