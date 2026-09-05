import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/technical/technical_state.dart';

class TypeDurationSelector extends StatelessWidget {
  final TechnicalDuration selected;
  final Function(TechnicalDuration) onSelect;

  const TypeDurationSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const durations = [
    (TechnicalDuration.min1, "1 minute"),
    (TechnicalDuration.min5, "5 minute"),
    (TechnicalDuration.min15, "15 minute"),
    (TechnicalDuration.min30, "30 minute"),
    (TechnicalDuration.hour1, "1 hour"),
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
