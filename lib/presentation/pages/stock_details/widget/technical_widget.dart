import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/presentation/bloc/technical/technical_bloc.dart';
import 'package:investapas/presentation/bloc/technical/technical_event.dart';
import 'package:investapas/presentation/bloc/technical/technical_state.dart';
import 'package:investapas/presentation/pages/stock_details/widget/oscillators_widget.dart';
import 'package:investapas/presentation/pages/stock_details/widget/pivot_widget.dart';
import 'package:investapas/presentation/pages/stock_details/widget/technical_guage.dart';
import 'package:investapas/presentation/pages/stock_details/widget/type_duration_selector.dart';

import '../../../../Widgets/common_dropdown.dart';
import '../../../../core/constants/constants.dart';

class TechnicalWidget extends StatelessWidget {
  const TechnicalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicalBloc, TechnicalState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error.isNotEmpty && state.oscillatorList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart_outlined,
                    color: Colorz.hintTextColor2, size: 40.sp),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                Text(
                  'Could not load technical data',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.mediumFont),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                GestureDetector(
                  onTap: () {
                    if (state.securityId.isNotEmpty) {
                      context.read<TechnicalBloc>().add(LoadTechnicalDataEvent(
                        securityId: state.securityId,
                        exchangeSegment: state.exchangeSegment,
                        instrument: state.instrument,
                      ));
                    }
                  },
                  child: Text(
                    'Retry',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.mediumFont),
                  ),
                ),
              ],
            ),
          );
        }

        final totalOscillators = state.oscillatorList.length;
        final buyCount  = state.oscillatorList.where((o) => o.action == 'Buy').length;
        final sellCount = state.oscillatorList.where((o) => o.action == 'Sell').length;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2),
                child: CustomDropdown(
                  selectedValue: state.selectedDropdown,
                  hintText: "Select Type",
                  borderColor: Colorz.dividerColor,
                  items: state.typeDropdown.map((e) {
                    return DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<TechnicalBloc>()
                          .add(ChangeTypeDuration(value));
                    }
                  },
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 3),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2),
                child: TechnicalGauge(),
              ),
              if (state.oscillatorList.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween * 2),
                  child: Text(
                    "Bullish signals: $buyCount, Bearish signals: $sellCount out of $totalOscillators oscillators",
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.smallFont),
                  ),
                ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2),
                child: TypeDurationSelector(
                  selected: state.duration,
                  onSelect: (d) =>
                      context.read<TechnicalBloc>().add(ChangeDuration(d)),
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
              OscillatorsWidget(technicalState: state, isOscillator: true),
              OscillatorsWidget(technicalState: state, isOscillator: false),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
              PivotWidget(technicalState: state),
            ],
          ),
        );
      },
    );
  }
}
