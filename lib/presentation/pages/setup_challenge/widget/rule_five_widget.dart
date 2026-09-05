import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/Widgets/checkbox_common.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_event.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleFiveWidget extends StatelessWidget {
  const RuleFiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context,state) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colorz.bottomPillBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rule 5 – Challenge Duration",
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerThreeFont),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.3),
                Text(
                  "Choose how long you want to test your discipline",
                  style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                _durationCard(context, state),
              ],
            ),
          );
        }
    );
  }

  Widget _durationCard(BuildContext context, ChallengeState state) {
    Widget item(String totalDays, String price, ChallengeDuration challengeDuration) {
      final active = state.selectedDuration == challengeDuration;

      return InkWell(
        onTap: () {
          context.read<ChallengeBloc>().add(SelectDurationEvent(challengeDuration));
        },
        child: Container(
          height: 56.sp,
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: 15.sp,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.sp,vertical: 16.sp),
          decoration: BoxDecoration(
            color: active ? Colorz.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: Colorz.primary,width: 1.sp)
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      totalDays,
                      style: AppTextStyles.small.copyWith(color: Colorz.textColor,fontSize: SizeConfig.mediumFont),
                    ),
                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                    SizedBox(
                      height: 15.sp,
                      child: VerticalDivider(
                        color: Colorz.hintTextColor,
                        thickness: 1.sp,
                      ),
                    ),
                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                    Text(
                      price,
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor,fontSize: SizeConfig.mediumFont),
                    )
                  ],
                ),
              ),
              price == "Later" ? Text(
                "Coming Soon",
                style: AppTextStyles.medium.copyWith(color: Colorz.primary,fontSize: SizeConfig.smallerFont),
              ) : CheckBoxCommon(
                isCheck: active,
                onTap: (){
                  context.read<ChallengeBloc>().add(SelectDurationEvent(challengeDuration));
                },
              )
            ],
          ),
        )
      );
    }

    return Column(
      children: [
        item("5 Days", "Free", ChallengeDuration.fiveDays),
        item("10 Days", "Free", ChallengeDuration.tenDays),
        item("Paid Duration", "Later", ChallengeDuration.paid),
      ],
    );
  }
}