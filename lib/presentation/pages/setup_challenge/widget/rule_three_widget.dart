import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/setup_challenge/challenge_event.dart';

import '../../../../Widgets/common_dropdown.dart';
import '../../../../core/constants/constants.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleThreeWidget extends StatelessWidget {
  const RuleThreeWidget({super.key});

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
                  "Rule 3 – Max Trades Per Day",
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerThreeFont),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.3),
                Text(
                  "Fix your total no. of trades per day",
                  style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                Text(
                  "Max Trades Per Day",
                  style: AppTextStyles.medium.copyWith(color: Colorz.textColor,fontSize: SizeConfig.smallFont),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
                CustomDropdown(
                  selectedValue: state.selectMaxTrade?.toString(),
                  hintText: "Select Trades Per Day",
                  items: state.tradeList.map((amount) {
                    return DropdownMenuItem<String>(
                      value: amount.toString(),
                      child: Text(
                        "$amount",
                        style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ChallengeBloc>().add(SelectMaxTradeEvent(int.parse(value)));
                    }
                  },
                ),
              ],
            ),
          );
        }
    );
  }
}
