import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/setup_challenge/challenge_event.dart';

import '../../../../Widgets/common_dropdown.dart';
import '../../../../core/constants/constants.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleFourWidget extends StatelessWidget {
  const RuleFourWidget({super.key});

  // Always 1-10, independent per index
  static final List<DropdownMenuItem<String>> _lotOptions = List.generate(10, (i) {
    final v = i + 1;
    return DropdownMenuItem<String>(
      value: v.toString(),
      child: Text('$v lot${v > 1 ? 's' : ''}'),
    );
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colorz.bottomPillBg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rule 4 – Sizing of Each Index",
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.headerThreeFont),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.3),
              Text(
                "Set max lots per index. User cannot buy more than the set limit for each index.",
                style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // Nifty
              _indexRow(
                context, "Nifty",
                state.selectNifty?.toString(),
                (v) => context.read<ChallengeBloc>().add(SelectNiftyEvent(int.parse(v))),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // BankNifty
              _indexRow(
                context, "BankNifty",
                state.selectBankNifty?.toString(),
                (v) => context.read<ChallengeBloc>().add(SelectBankNiftyEvent(int.parse(v))),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // FinNifty
              _indexRow(
                context, "FinNifty",
                state.selectFinNifty?.toString(),
                (v) => context.read<ChallengeBloc>().add(SelectFinNiftyEvent(int.parse(v))),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // MidcapNifty
              _indexRow(
                context, "MidcapNifty",
                state.selectMidCapNifty?.toString(),
                (v) => context.read<ChallengeBloc>().add(SelectMidCapNiftyEvent(int.parse(v))),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // Sensex
              _indexRow(
                context, "Sensex",
                state.selectSenSex?.toString(),
                (v) => context.read<ChallengeBloc>().add(SelectSenSexEvent(int.parse(v))),
              ),

              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
              Text(
                "Important: Orders exceeding the set lot limit for any index will be instantly rejected.",
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.smallerFont),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _indexRow(
    BuildContext context,
    String label,
    String? selected,
    void Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium.copyWith(
              color: Colorz.textColor, fontSize: SizeConfig.smallFont),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
        CustomDropdown(
          selectedValue: selected,
          hintText: "Select $label lots",
          items: _lotOptions,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}
