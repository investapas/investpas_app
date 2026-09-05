import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';

class UseRangeWidget extends StatelessWidget {
  const UseRangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.sp),
        color: Colorz.primary,
      ),
      child: Column(
        children: [
          Text(
            "Why use a range (₹500–₹600) instead of exact ₹500?",
            style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerThreeFont,color: Colorz.white),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,color: Colorz.white,),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
              Expanded(
                child: Text(
                  "Prices jump in ticks; they rarely stop at exact numbers.",
                  style: AppTextStyles.medium.copyWith(color: Colorz.lightTextColor),
                ),
              )
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,color: Colorz.white,),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
              Expanded(
                child: Text(
                  "A strict ₹500 may be skipped in one fast move.",
                  style: AppTextStyles.medium.copyWith(color: Colorz.lightTextColor),
                ),
              )
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,color: Colorz.white,),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
              Expanded(
                child: Text(
                  "A range lets the system alert early and stop safely.",
                  style: AppTextStyles.medium.copyWith(color: Colorz.lightTextColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
