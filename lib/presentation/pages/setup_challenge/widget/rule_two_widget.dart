import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/setup_challenge/challenge_event.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleTwoWidget extends StatefulWidget {
  const RuleTwoWidget({super.key});

  @override
  State<RuleTwoWidget> createState() => _RuleTwoWidgetState();
}

class _RuleTwoWidgetState extends State<RuleTwoWidget> {
  final TextEditingController _minProfitCtrl = TextEditingController();
  final TextEditingController _maxProfitCtrl = TextEditingController();
  final TextEditingController _minLossCtrl   = TextEditingController();
  final TextEditingController _maxLossCtrl   = TextEditingController();

  void _sync(TextEditingController ctrl, int? value) {
    final text = value != null ? value.toString() : '';
    if (ctrl.text != text) ctrl.text = text;
  }

  @override
  void dispose() {
    _minProfitCtrl.dispose();
    _maxProfitCtrl.dispose();
    _minLossCtrl.dispose();
    _maxLossCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChallengeBloc, ChallengeState>(
      listenWhen: (prev, curr) =>
          prev.selectMinProfit != curr.selectMinProfit ||
          prev.selectMaxProfit != curr.selectMaxProfit ||
          prev.selectMinLoss   != curr.selectMinLoss   ||
          prev.selectMaxLoss   != curr.selectMaxLoss,
      listener: (context, state) {
        _sync(_minProfitCtrl, state.selectMinProfit);
        _sync(_maxProfitCtrl, state.selectMaxProfit);
        _sync(_minLossCtrl,   state.selectMinLoss);
        _sync(_maxLossCtrl,   state.selectMaxLoss);
      },
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
                "Rule 2 – Daily Profit / Loss Limits (Per Day)",
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.headerThreeFont),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.3),
              Text(
                "Daily Profit Target (Range)",
                style: AppTextStyles.semiBold
                    .copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.largeFont),
              ),
              Text(
                "Set a safe profit zone instead of a single number.",
                style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Min Profit (₹)",
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.textColor, fontSize: SizeConfig.smallFont),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
                        _buildField(
                          controller: _minProfitCtrl,
                          hint: "e.g. 500",
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null) {
                              context.read<ChallengeBloc>().add(SelectMinProfitEvent(val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 1.5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Max Profit (₹)",
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.textColor, fontSize: SizeConfig.smallFont),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
                        _buildField(
                          controller: _maxProfitCtrl,
                          hint: "e.g. 1000",
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null) {
                              context.read<ChallengeBloc>().add(SelectMaxProfitEvent(val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
              Text(
                "Daily Loss Limit (Range)",
                style: AppTextStyles.semiBold
                    .copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.largeFont),
              ),
              Text(
                "Protect yourself with a controlled loss range.",
                style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Min Loss (₹)",
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.textColor, fontSize: SizeConfig.smallFont),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
                        _buildField(
                          controller: _minLossCtrl,
                          hint: "e.g. 400",
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null) {
                              context.read<ChallengeBloc>().add(SelectMinLossEvent(val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 1.5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Max Loss (₹)",
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.textColor, fontSize: SizeConfig.smallFont),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
                        _buildField(
                          controller: _maxLossCtrl,
                          hint: "e.g. 700",
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null) {
                              context.read<ChallengeBloc>().add(SelectMaxLossEvent(val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colorz.white,
        borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
        border: Border.all(color: Colorz.newBorderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.medium
            .copyWith(fontSize: SizeConfig.largeFont, color: Colorz.textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spaceBetween * 1.2,
              vertical: SizeConfig.spaceBetween * 1.2),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
