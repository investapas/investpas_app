import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../bloc/stock_details/stock_details_state.dart';

class DurationSelector extends StatelessWidget {
  final ChartDuration selected;
  final Function(ChartDuration) onSelect;

  const DurationSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const durations = [
    (ChartDuration.d1, "1D"),
    (ChartDuration.w1, "1W"),
    (ChartDuration.m1, "1M"),
    (ChartDuration.m3, "3M"),
    (ChartDuration.m6, "6M"),
    (ChartDuration.ytd, "YTD"),
    (ChartDuration.y1, "1Y"),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25.sp,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: durations.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.sp),
        itemBuilder: (_, i) {

          final item = durations[i];
          final isSelected = item.$1 == selected;

          return GestureDetector(
            onTap: () => onSelect(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.sp),
              decoration: BoxDecoration(
                color: isSelected ? Colorz.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(100.sp),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colorz.textFieldBorderColor,
                ),
              ),
              child: Center(
                child: Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semiBold.copyWith(color: isSelected ? Colorz.white : Colorz.hintTextColor,fontSize: SizeConfig.smallFont)
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}