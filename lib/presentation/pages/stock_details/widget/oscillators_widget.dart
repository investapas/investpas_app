import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/data/models/technical_type_model.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/technical/technical_state.dart';

class OscillatorsWidget extends StatelessWidget {
  final TechnicalState? technicalState;
  final bool? isOscillator;
  const OscillatorsWidget({super.key,this.technicalState,this.isOscillator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
          child: Text(
            isOscillator! ? "Oscillators" : "Moving Average",
            style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerTwoFont),
          ),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2,vertical: SizeConfig.spaceBetween*0.9),
          color: Colorz.bottomPillBg,
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  "Name",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
              Expanded(
                flex: 3,
                child: Text(
                  "Value",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Action",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                  ),
                ),
              )
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: isOscillator! ? technicalState!.oscillatorList.length : technicalState!.movingList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = isOscillator! ? technicalState!.oscillatorList[index] : technicalState!.movingList[index];
            return OscillatorsItems(item: item,);
          },
          separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor,thickness: 1,),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
      ],
    );
  }
}

class OscillatorsItems extends StatelessWidget {
  final TechnicalTypeModel? item;
  const OscillatorsItems({super.key,this.item});

  @override
  Widget build(BuildContext context) {
    final color = item!.action == "Buy"
        ? Colorz.greenColor
        : item!.action == "Sell"
            ? Colorz.redColor
            : Colorz.textColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(item!.name,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.hintTextColor2,
                    fontSize: SizeConfig.smallFont)),
          ),
          Expanded(
            flex: 3,
            child: Text(item!.value,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor,
                    fontSize: SizeConfig.smallFont)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item!.action,
                    style: AppTextStyles.semiBold.copyWith(
                        color: color,
                        fontSize: SizeConfig.smallFont)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}