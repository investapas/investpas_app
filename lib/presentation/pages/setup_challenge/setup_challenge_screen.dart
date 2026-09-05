import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/utils/toast_helper.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_five_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_four_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_one_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_summary_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_three_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/rule_two_widget.dart';
import 'package:investapas/presentation/pages/setup_challenge/widget/use_range_widget.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../../routes/appRoutes.dart';
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/setup_challenge/challenge_bloc.dart';
import '../../bloc/setup_challenge/challenge_event.dart';
import '../../bloc/setup_challenge/challenge_state.dart';

class SetupChallengeScreen extends StatefulWidget {
  const SetupChallengeScreen({super.key});

  @override
  State<SetupChallengeScreen> createState() => _SetupChallengeScreenState();
}

class _SetupChallengeScreenState extends State<SetupChallengeScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ChallengeBloc>().add(LoadCapitalListEvent());
    context.read<ChallengeBloc>().add(LoadTradeListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocListener<ChallengeBloc, ChallengeState>(
            listenWhen: (previous, current) =>
                previous.isLoading && !current.isLoading,
            listener: (context, state) {
              if (state.message.isNotEmpty) {
                ToastHelper.showToast(state.message, isSuccess: state.isSuccess);
              }
              if (state.isSuccess) {
                context.read<DashBoardBloc>().add(LoadChallengeEvent());
                context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(0));
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homePage,
                  (route) => false,
                );
              }
            },
            child: BlocBuilder<ChallengeBloc, ChallengeState>(
              builder: (context, state) {

                if (state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Colorz.primary),
                  );
                }

                return Container(
                  margin: EdgeInsets.only(
                    top: 50.sp,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: (){
                            NavigatorService.goBack();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: CircleWidget(
                              backgroundColor: Colorz.white,
                              child: Icon(Icons.arrow_back_rounded,color: Colorz.hintTextColor2,),
                            ),
                          ),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween * 2,
                          ),
                          child: Text(
                            "Set Up Challenge",
                            style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerTwoFont),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween * 2,
                          ),
                          child: Text(
                            "Lock your rules before you start trading.",
                            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
                          ),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        // ── Trading Style Selector (temporarily hidden) ──
                        // Container(
                        //   margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                        //   child: _TradingStyleSelector(selected: state.tradingStyle ?? 'SCALPER'),
                        // ),
                        // SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: RuleOneWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: RuleTwoWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: RuleThreeWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: RuleFourWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: RuleFiveWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            child: UseRangeWidget()),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                        RuleSummaryWidget(),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}

// class _TradingStyleSelector extends StatelessWidget {
//   final String selected;
//   const _TradingStyleSelector({required this.selected});
//
//   static const _styles = [
//     ('SCALPER',        'Scalper',         Icons.flash_on_rounded),
//     ('INTRADAY',       'Intraday',        Icons.today_rounded),
//     ('SWING',          'Swing',           Icons.swap_horiz_rounded),
//     ('EQUITY',         'Equity',          Icons.trending_up_rounded),
//     ('OPTIONS_BUYER',  'Options Buyer',   Icons.call_made_rounded),
//     ('OPTIONS_SELLER', 'Options Seller',  Icons.call_received_rounded),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Trading Style', style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont, color: Colorz.textColor)),
//         SizeConfig.verticalSpace(height: 4),
//         Text('Select your trading style for personalized rules', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont)),
//         SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: _styles.map((s) {
//             final isActive = s.$1 == selected;
//             return GestureDetector(
//               onTap: () => context.read<ChallengeBloc>().add(SelectTradingStyleEvent(s.$1)),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
//                 decoration: BoxDecoration(
//                   color: isActive ? Colorz.primary : Colorz.bottomPillBg,
//                   borderRadius: BorderRadius.circular(10.sp),
//                   border: Border.all(color: isActive ? Colorz.primary : Colorz.borderColor),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(s.$3, size: 16.sp, color: isActive ? Colors.white : Colorz.hintTextColor),
//                     SizedBox(width: 6.sp),
//                     Text(s.$2, style: AppTextStyles.semiBold.copyWith(
//                       fontSize: SizeConfig.smallFont,
//                       color: isActive ? Colors.white : Colorz.textColor,
//                     )),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }
