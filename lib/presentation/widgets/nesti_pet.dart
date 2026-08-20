import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/nesti_theme.dart';

class NestiPet extends StatefulWidget {
  const NestiPet({
    super.key,
    this.size = 250,
    this.reduceMotion = false,
    this.celebrating = false,
  });

  final double size;
  final bool reduceMotion;
  final bool celebrating;

  @override
  State<NestiPet> createState() => _NestiPetState();
}

class _NestiPetState extends State<NestiPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant NestiPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reduceMotion != widget.reduceMotion) _syncMotion();
  }

  void _syncMotion() {
    if (widget.reduceMotion) {
      _controller.stop();
      _controller.value = 0.45;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.celebrating ? '正在开心摇晃的栖伴' : '安静呼吸的栖伴',
      image: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final breath = Curves.easeInOut.transform(_controller.value);
          return Transform.translate(
            offset: Offset(0, -3 * breath),
            child: Transform.scale(
              scaleX: 1 + breath * 0.012,
              scaleY: 1 - breath * 0.008,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _NestiPainter(
                  breath: breath,
                  celebrating: widget.celebrating,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NestiPainter extends CustomPainter {
  const _NestiPainter({required this.breath, required this.celebrating});

  final double breath;
  final bool celebrating;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.54);
    final shadow = Paint()
      ..color = NestiColors.ink.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.88),
        width: w * 0.56,
        height: h * 0.1,
      ),
      shadow,
    );

    final tail = Path()
      ..moveTo(w * 0.68, h * 0.69)
      ..cubicTo(w * 0.98, h * 0.58, w * 0.96, h * 0.84, w * 0.72, h * 0.79);
    canvas.drawPath(
      tail,
      Paint()
        ..color = NestiColors.leaf
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.1
        ..strokeCap = StrokeCap.round,
    );

    final bodyRect = Rect.fromCenter(
      center: center,
      width: w * 0.58,
      height: h * (0.58 + breath * 0.012),
    );
    canvas.drawOval(bodyRect, Paint()..color = const Color(0xFF9DB894));

    final belly = Path()
      ..moveTo(w * 0.34, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.83, w * 0.66, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.34, h * 0.62);
    canvas.drawPath(belly, Paint()..color = const Color(0xFFDDE6C9));

    final leftEar = Path()
      ..moveTo(w * 0.33, h * 0.35)
      ..quadraticBezierTo(w * 0.18, h * 0.08, w * 0.44, h * 0.25)
      ..close();
    final rightEar = Path()
      ..moveTo(w * 0.56, h * 0.25)
      ..quadraticBezierTo(w * 0.82, h * 0.08, w * 0.67, h * 0.35)
      ..close();
    canvas.drawPath(leftEar, Paint()..color = NestiColors.moss);
    canvas.drawPath(rightEar, Paint()..color = NestiColors.moss);
    canvas.drawPath(
      leftEar.shift(Offset(w * 0.025, h * 0.02)),
      Paint()..color = NestiColors.peach.withValues(alpha: 0.7),
    );
    canvas.drawPath(
      rightEar.shift(Offset(-w * 0.025, h * 0.02)),
      Paint()..color = NestiColors.peach.withValues(alpha: 0.7),
    );

    final face = Paint()..color = NestiColors.ink;
    final eyeY = h * 0.47;
    final blink = celebrating ? 0.3 : 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, eyeY),
        width: w * 0.035,
        height: h * 0.055 * blink,
      ),
      face,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.58, eyeY),
        width: w * 0.035,
        height: h * 0.055 * blink,
      ),
      face,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.54), w * 0.018, face);

    final smile = Path()
      ..moveTo(w * 0.5, h * 0.56)
      ..quadraticBezierTo(w * 0.47, h * 0.59, w * 0.44, h * 0.565)
      ..moveTo(w * 0.5, h * 0.56)
      ..quadraticBezierTo(w * 0.53, h * 0.59, w * 0.56, h * 0.565);
    canvas.drawPath(
      smile,
      Paint()
        ..color = NestiColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round,
    );

    if (celebrating) {
      final spark = Paint()
        ..color = NestiColors.honey
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final angle = (math.pi * 2 / 6) * i;
        final start = Offset(
          w * 0.5 + math.cos(angle) * w * 0.37,
          h * 0.46 + math.sin(angle) * h * 0.34,
        );
        final end = Offset(
          w * 0.5 + math.cos(angle) * w * 0.43,
          h * 0.46 + math.sin(angle) * h * 0.4,
        );
        canvas.drawLine(start, end, spark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NestiPainter oldDelegate) {
    return oldDelegate.breath != breath ||
        oldDelegate.celebrating != celebrating;
  }
}
