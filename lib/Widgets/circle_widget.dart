import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';

class CircleWidget extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Widget? child;
  const CircleWidget({super.key, this.size = 40, this.backgroundColor = Colorz.white,this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor
      ),
      child: Center(
        child: child
      ),
    );
  }
}
