import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/constants.dart';

class FreeChallangeWidget extends StatelessWidget {
  const FreeChallangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colorz.lightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(
                Assets.targetSvg,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Free Challenge",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.mediumFont, color: Colorz.white),
                  ),
                  Text(
                    "10 Days",
                    style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerOneFont, color: Colorz.white),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                  Container(
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: Colorz.whiteButtonGradient
                    ),
                    child: Text(
                      "Start Free Challenge",
                      style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont, color: Colorz.lightBlue),
                    ),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                  Text(
                    "Practice with simulated capital and real rules.",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallerFont, color: Colorz.lightPrimary),
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
