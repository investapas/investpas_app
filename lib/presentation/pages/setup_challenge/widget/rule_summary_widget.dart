import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../../Widgets/Widgets.dart';
import '../../../../routes/appRoutes.dart';
import '../../../bloc/dashboard/bloc.dart';
import '../../../bloc/dashboard/event.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_event.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleSummaryWidget extends StatelessWidget {
  const RuleSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeBloc, ChallengeState>(
      listenWhen: (previous, current) =>
          previous.isLoading && !current.isLoading && current.isSuccess,
      listener: (context, state) {
        context.read<DashBoardBloc>().add(LoadChallengeEvent());
        context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(0));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homePage,
          (route) => false,
        );
      },
      child: BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context,state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: Colorz.bottomPillBg
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
              Text(
                "Your Challenge Rules Summary",
                style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerThreeFont),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Trading Capital:",
                      style: AppTextStyles.semiBold.copyWith(color: Colorz.hintTextColor2,fontSize: SizeConfig.largeFont),
                    ),
                  ),
                  Text(
                    "\u20b9 ${state.selectedCapital ?? 0}",
                    style: AppTextStyles.headerTwo.copyWith(color: Colorz.primary,fontSize: SizeConfig.largeFont),
                  )
                ],
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
              Divider(color: Colorz.dividerColor,),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Profit Target:",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.hintTextColor2,fontSize: SizeConfig.largeFont),
                        ),
                        Text(
                          "Alerts start near 90% of min",
                          style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\u20b9 ${state.selectMinProfit ?? 0} - \u20b9 ${state.selectMaxProfit ?? 0}",
                    style: AppTextStyles.headerTwo.copyWith(color: Colorz.primary,fontSize: SizeConfig.largeFont),
                  )
                ],
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
              Divider(color: Colorz.dividerColor,),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Profit Target:",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.hintTextColor2,fontSize: SizeConfig.largeFont),
                        ),
                        Text(
                          "Alerts start near 90% of min",
                          style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\u20b9 ${state.selectMinLoss ?? 0} - \u20b9 ${state.selectMaxLoss ?? 0}",
                    style: AppTextStyles.headerTwo.copyWith(color: Colorz.primary,fontSize: SizeConfig.largeFont),
                  )
                ],
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*4),
              Button(
                text: 'Save & Continue',
                isOutlined: false,
                isBig: true,
                radius: 100,
                gradient: Colorz.primaryButtonGradient,
                onPressed: () {
                  context.read<ChallengeBloc>().add(SubmitChallengeEvent());
                },
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            ],
          ),
        );
      }
    ),
    );
  }
}
