import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class GaugePainter extends CustomPainter {

  final segments = const [
    ("Strong sell", Colorz.strongSellColor),
    ("Sell", Colorz.sellColor),
    ("Neutral", Colorz.neutralColor),
    ("Buy", Colorz.buyColor),
    ("Strong buy", Colorz.strongBuyColor),
  ];

  @override
  void paint(Canvas canvas, Size size) {

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;

    final rect = Rect.fromCircle(center: center, radius: radius);

    const gap = 0.06;
    final totalGaps = gap * (segments.length - 1);
    final sweepPerSegment = (pi - totalGaps) / segments.length;

    double start = pi;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    for (final segment in segments) {

      final label = segment.$1;
      final color = segment.$2;

      paint.color = color;
      canvas.drawArc(rect, start, sweepPerSegment, false, paint);
      final midAngle = start + sweepPerSegment / 2;
      double textRadius;
      if (label == "Strong sell" || label == "Strong buy") {
        textRadius = radius + 34;
      }
      else if (label == "Neutral") {
        textRadius = radius + 15;
      }
      else {
        textRadius = radius + 18;
      }

      final textOffset = Offset(
        center.dx + textRadius * cos(midAngle),
        center.dy + textRadius * sin(midAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: AppTextStyles.medium.copyWith(
            fontSize: SizeConfig.smallerFont,
            color: Colorz.hintTextColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      start += sweepPerSegment + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}