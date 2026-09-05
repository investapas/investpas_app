import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';

class ThinProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const ThinProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor = Colorz.progressBgColor,
    this.progressColor = Colorz.progressBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: height,
        width: double.infinity,
        color: backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}