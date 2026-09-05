import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:investapas/presentation/pages/dashBoard/trading_journal/widget/journal_list_view.dart';
import 'package:investapas/presentation/pages/dashBoard/trading_journal/widget/journal_month_view.dart';
import 'package:investapas/presentation/pages/dashBoard/trading_journal/widget/journal_year_view.dart';

import '../../../../Widgets/circle_widget.dart';
import '../../../../core/constants/constants.dart';
import '../../../bloc/trading_journal/journal_bloc.dart';
import '../../../bloc/trading_journal/journal_event.dart';
import '../../../bloc/trading_journal/journal_state.dart';

class TradingJournalTab extends StatelessWidget {
  const TradingJournalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(
            top: 50.sp,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        child: Text(
                          "Journal",
                          style: AppTextStyles.semiBold.copyWith(
                            fontSize: SizeConfig.headerTwoFont,
                            color: Colorz.textColor,
                          ),
                        ),
                      ),
                      Divider(color: Colorz.bottomPillBg,thickness: 2),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Weighted Avg",
                              style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                            ),
                            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                            FlutterSwitch(
                              width: 40,
                              height: 23,
                              toggleSize: 18,
                              value: state.isWeightedAvg,
                              borderRadius: 15,
                              padding: 4,
                              toggleColor: Colorz.white,
                              inactiveToggleColor: Colorz.lineColor,
                              activeColor: Colorz.primary,
                              inactiveColor: Colorz.lightPrimary,
                              onToggle: (val) {
                                context.read<JournalBloc>().add(ToggleWeightedAverage(val));
                              },
                            ),
                            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                            Text(
                              "FIFO",
                              style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontWeight: FontWeight.w700,fontSize: SizeConfig.smallFont),
                            ),
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 2,color: Colorz.bottomPillBg)
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Gross Realized PnL",
                                    style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                                  Text(
                                    "\u20b9 ${state.tradeSummary.fold<double>(0.0, (sum, item) => sum + (item.grossPnL)).toStringAsFixed(2)}",
                                    style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontWeight: FontWeight.w700,fontSize: SizeConfig.smallFont),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              child: VerticalDivider(
                                color: Colorz.bottomPillBg,
                                thickness: 2,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Unrealized PnL",
                                    style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                                  Text(
                                    "\u20b9 ${state.positions.fold<double>(0.0, (sum, pos) => sum + pos.unrealizedProfit).toStringAsFixed(2)}",
                                    style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontWeight: FontWeight.w700,fontSize: SizeConfig.smallFont),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                      _buildCalendarView(state),
                    ],
                  ),
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
              _buildViewSelector(context, state),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(JournalState state) {
    switch (state.viewType) {
      case JournalViewType.list:
        return const JournalListView();
      case JournalViewType.month:
        return JournalMonthView(selectedDate: state.selectedDate);
      case JournalViewType.year:
        return JournalYearView(year: state.selectedDate.year);
    }
  }

  Widget _buildViewSelector(BuildContext context, JournalState state) {
    Widget item(String svgIcon, String text, JournalViewType type, double size) {
      final active = state.viewType == type;

      return Expanded(
        child: InkWell(
          onTap: () {
            context.read<JournalBloc>().add(ChangeJournalView(type));
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.spaceBetween * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  svgIcon,
                  height: size,
                  width: size,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      active ? Colorz.primary : Colorz.hintTextColor2,
                      BlendMode.srcIn
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                Text(
                  text,
                  style: AppTextStyles.small.copyWith(color: active ? Colorz.primary : Colorz.hintTextColor2,)
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        item(Assets.calanderListSvg, "List View", JournalViewType.list,14),
        item(Assets.calanderMonthSvg, "Month View", JournalViewType.month,20),
        item(Assets.calanderYearSvg, "Yearly View", JournalViewType.year,20),
      ],
    );
  }


}
