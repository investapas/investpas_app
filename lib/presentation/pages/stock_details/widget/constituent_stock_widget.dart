import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../../Widgets/common_dropdown.dart';
import '../../../../data/models/constituent_stock.dart';
import '../../../bloc/stock_details/stock_details_bloc.dart';
import '../../../bloc/stock_details/stock_details_event.dart';
import '../../../bloc/stock_details/stock_details_state.dart';

class ConstituentStockWidget extends StatelessWidget {
  final StockDetailsState? stockDetailsState;
  const ConstituentStockWidget({super.key,this.stockDetailsState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Constituent Stocks",
                  style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerThreeFont,color: Colorz.textColor),
                ),
              ),
              SizedBox(
                width: 100.sp,
                child: CustomDropdown(
                  selectedValue: stockDetailsState!.selectedDropdown,
                  hintText: "Select Duration",
                  borderColor: Colorz.dividerColor,
                  items: stockDetailsState!.durationDropdown.map((e) {
                    return DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<StockDetailsBloc>().add(ChangeConstituentDuration(value));
                    }
                  },
                ),
              )
            ],
          ),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2,vertical: SizeConfig.spaceBetween*0.7),
          color: Colorz.bottomPillBg,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  "Name",
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Text(
                      "Live Price",
                      style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                    ),
                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.2),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 3),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 14.sp,
                            color: Colorz.hintTextColor,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -3),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14.sp,
                            color: Colorz.hintTextColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "1 W Low",
                    style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor),
                  ),
                ),
              )
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: stockDetailsState!.constituents.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = stockDetailsState!.constituents[index];
            return ConstituentItems(item: item,);
          },
          separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor,thickness: 1,),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
      ],
    );
  }
}

class ConstituentItems extends StatelessWidget {
  final ConstituentStock? item;
  const ConstituentItems({super.key,this.item});

  @override
  Widget build(BuildContext context) {
    final color = item!.isUp ? Colorz.greenColor : Colorz.redColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item!.name,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.hintTextColor2,
                        fontSize: SizeConfig.mediumFont)),
                SizeConfig.verticalSpace(height: 4),
                Text(item!.exchange,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.hintTextColor2,
                        fontSize: SizeConfig.smallFont)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item!.price,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont)),
                SizeConfig.verticalSpace(height: 4),
                Text("${item!.changePercent}(${item!.volume})",
                    style: AppTextStyles.headerOne.copyWith(
                        color: color,
                        fontSize: SizeConfig.smallFont)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item!.weekLow,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
