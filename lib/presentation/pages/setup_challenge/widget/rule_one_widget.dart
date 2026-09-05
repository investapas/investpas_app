import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/setup_challenge/challenge_bloc.dart';
import '../../../bloc/setup_challenge/challenge_event.dart';
import '../../../bloc/setup_challenge/challenge_state.dart';

class RuleOneWidget extends StatefulWidget {
  const RuleOneWidget({super.key});

  @override
  State<RuleOneWidget> createState() => _RuleOneWidgetState();
}

class _RuleOneWidgetState extends State<RuleOneWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                "Rule 1 – Trading Capital",
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.headerThreeFont),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.3),
              Text(
                "Fix your rules before trading starts.",
                style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
              Text(
                "Trading Capital (₹)",
                style: AppTextStyles.medium
                    .copyWith(color: Colorz.textColor, fontSize: SizeConfig.smallFont),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
              _buildField(
                controller: _controller,
                hint: "e.g. 50000",
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null) {
                    context.read<ChallengeBloc>().add(SelectCapitalEvent(val));
                  }
                },
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
              Text(
                "Example: 50,000 or 1,00,000",
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont),
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
