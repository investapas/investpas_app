import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../bloc/technical/technical_bloc.dart';
import '../../../bloc/technical/technical_state.dart';
import 'guage_painter.dart';
import 'needle_painter.dart';

class TechnicalGauge extends StatelessWidget {
  const TechnicalGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicalBloc, TechnicalState>(
      buildWhen: (p, c) => p.oscillatorScore != c.oscillatorScore,
      builder: (context, state) {
        final score = state.oscillatorScore;
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          tween: Tween(begin: 0, end: score),
          builder: (context, value, _) {
            return SizedBox(
              height: 160, // visible height
              child: OverflowBox(
                maxHeight: 260, // original painter size
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: GaugePainter(),
                    ),
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: NeedlePainter(value),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colorz.textColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}