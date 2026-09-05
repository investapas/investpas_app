import 'package:flutter/material.dart';
import 'package:investapas/data/models/pivot_model.dart';

import '../../../../core/constants/constants.dart';
import '../../../bloc/technical/technical_state.dart';

class PivotWidget extends StatelessWidget {
  final TechnicalState? technicalState;
  const PivotWidget({super.key,this.technicalState});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
          child: Text(
            "Pivots",
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
                flex: 3,
                child: Text(
                  "Pivot",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "Classic",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "Fibonacci",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
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
          itemCount: technicalState!.pivotList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = technicalState!.pivotList[index];
            return PivotItem(item: item,);
          },
          separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor,thickness: 1,),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
      ],
    );
  }
}

class PivotItem extends StatelessWidget {
  final PivotModel? item;
  const PivotItem({super.key,this.item});

  @override
  Widget build(BuildContext context) {
    final color = item!.action == "Sell" ? Colorz.redColor : Colorz.textColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item!.pivot,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.hintTextColor2,
                    fontSize: SizeConfig.smallFont)),
          ),
          Expanded(
            flex: 4,
            child: Text(item!.classic,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor,
                    fontSize: SizeConfig.smallFont)),
          ),
          Expanded(
            flex: 4,
            child: Text(item!.fibonacci,
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