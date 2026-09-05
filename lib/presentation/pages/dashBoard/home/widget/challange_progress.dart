import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../core/constants/constants.dart';

class ChallengeProgress extends StatelessWidget {
  final int completedDays;
  final int totalDays;
  final String challengeName;
  final bool isActive;
  final String startDate;
  final String endDate;

  const ChallengeProgress({
    super.key,
    required this.completedDays,
    required this.totalDays,
    required this.challengeName,
    this.isActive = true,
    this.startDate = '',
    this.endDate = '',
  });

  double get progress =>
      totalDays > 0 ? (completedDays / totalDays).clamp(0.0, 1.0) : 0.0;


  bool get isCompleted => completedDays >= totalDays && totalDays > 0;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.62,
            child: CircularPercentIndicator(
              radius: 120,
              lineWidth: 10,
              percent: progress,
              startAngle: 180,
              arcType: ArcType.HALF,
              arcBackgroundColor: const Color(0xFFE6ECFA),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
              animateFromLastPercent: true,
              linearGradient: LinearGradient(
                colors: isCompleted
                    ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                    : [Colorz.primary, Colorz.darkPrimary],
              ),
              center: Transform.translate(
                offset: const Offset(0, -35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Day $completedDays/$totalDays',
                      style: AppTextStyles.headerTwo.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7D8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🎉 Challenge Complete',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7D8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active challenge',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      challengeName,
                      style: AppTextStyles.small.copyWith(
                        color: Colorz.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // start / end date row
        if (startDate.isNotEmpty || endDate.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start',
                      style: AppTextStyles.medium.copyWith(
                        fontSize: SizeConfig.smallerFont,
                        color: Colorz.hintTextColor,
                      ),
                    ),
                    Text(
                      startDate,
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.smallFont,
                        color: Colorz.textColor,
                      ),
                    ),
                  ],
                ),
                // progress bar between dates
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFE6ECFA),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? const Color(0xFF4CAF50) : Colorz.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'End',
                      style: AppTextStyles.medium.copyWith(
                        fontSize: SizeConfig.smallerFont,
                        color: Colorz.hintTextColor,
                      ),
                    ),
                    Text(
                      endDate,
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.smallFont,
                        color: Colorz.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
