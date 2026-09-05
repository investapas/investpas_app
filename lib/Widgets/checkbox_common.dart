import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';

class CheckBoxCommon extends StatelessWidget {
  final bool? isCheck;
  final GestureTapCallback? onTap;
  const CheckBoxCommon({super.key,this.isCheck = false,this.onTap});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      child: Container(
          height: 20.sp,
          width: 20.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isCheck == true
                  ? Colorz.primary
                  : Colorz.white,
              borderRadius: BorderRadius.circular(4.sp),
              border: Border.all(color: Colorz.primary)),
          child: isCheck == true
              ? Icon(Icons.check,
              size: 15.sp,
              color: Colorz.white)
              : null),
    );
  }
}