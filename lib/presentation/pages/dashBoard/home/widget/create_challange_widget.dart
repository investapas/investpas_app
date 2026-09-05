import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../../../core/utils/navigationService.dart';
import '../../../../../routes/appRoutes.dart';

class CreateChallangeWidget extends StatelessWidget {
  const CreateChallangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colorz.bottomPillBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 5,
              bottom: 0,
              child: SvgPicture.asset(
                Assets.cupSvg,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Set Up Challenge",
                    style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerTwoFont, color: Colorz.textColor),
                  ),
                  Text(
                    "Fix your rules before trading starts.",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.mediumFont, color: Colorz.hintTextColor),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                  InkWell(
                    onTap: (){
                      NavigatorService.pushNamed(AppRoutes.setupChallengePage);
                    },
                    child: Container(
                      padding: EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: Colorz.primaryButtonGradient
                      ),
                      child: Text(
                        "Create Challenge",
                        style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont, color: Colorz.white),
                      ),
                    ),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                  Text(
                    "Create or edit trading rules, position size and limits.",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallerFont, color: Colorz.hintTextColor),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
