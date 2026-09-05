import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colorz.backgroundColor1,
              Colorz.backgroundColor2,
              Colorz.white,
            ],
            stops: [
              0.0,
              0.18,
              0.35,
            ],
          ),
        ),
        child: child
    );
  }
}