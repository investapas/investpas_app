import 'dart:math';

import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';

class NeedlePainter extends CustomPainter {
  final double score;
  NeedlePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.6;
    final angle = pi + (score / 100) * pi;

    final needleEnd = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final paint = Paint()
      ..color = Colorz.textColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, paint);
  }

  @override
  bool shouldRepaint(covariant NeedlePainter oldDelegate) =>
      oldDelegate.score != score;
}