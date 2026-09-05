import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CircleBorderIcon extends StatelessWidget {
  final String svg;
  final double size;
  final double borderWidth;
  final Color borderColor;

  const CircleBorderIcon({
    super.key,
    required this.svg,
    this.size = 40,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          svg,
          height: size * 0.45,
          width: size * 0.45,
        ),
      ),
    );
  }
}
