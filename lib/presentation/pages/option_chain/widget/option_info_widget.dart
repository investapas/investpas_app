import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/constants.dart';
import '../../../../data/models/option_chain_model.dart';
import '../../../../data/services/live_price_service.dart';
import '../../../bloc/option_chain/option_chain_state.dart';

class OptionInfoWidget extends StatelessWidget {
  final OptionChainState? optionChainState;
  final ScrollController? scrollController;

  const OptionInfoWidget({super.key, this.optionChainState, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.spaceBetween * 2,
                vertical: SizeConfig.spaceBetween * 0.9),
            color: Colorz.bottomPillBg,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      "CE LTP",
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont,
                          color: Colorz.hintTextColor),
                    ),
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5.sp,
                        width: 5.sp,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colorz.redColor),
                      ),
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween * 0.2),
                      Text(
                        "Call OI",
                        style: AppTextStyles.medium.copyWith(
                            fontSize: SizeConfig.smallerFont,
                            color: Colorz.hintTextColor),
                      ),
                    ],
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Strike",
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont,
                          color: Colorz.hintTextColor),
                    ),
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5.sp,
                        width: 5.sp,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colorz.greenColor),
                      ),
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween * 0.2),
                      Text(
                        "Put OI",
                        style: AppTextStyles.medium.copyWith(
                            fontSize: SizeConfig.smallerFont,
                            color: Colorz.hintTextColor),
                      ),
                    ],
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "OI Chg",
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont,
                          color: Colorz.hintTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: optionChainState!.allItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = optionChainState!.allItems[index];
              return InfoChainItem(item: item);
            },
            separatorBuilder: (_, __) =>
                Divider(color: Colorz.dividerColor, thickness: 1),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
        ],
      ),
    );
  }
}

class InfoChainItem extends StatelessWidget {
  final OptionChainModel? item;
  const InfoChainItem({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final isAtm = item!.isAtm;

    return Container(
      color: isAtm ? Colorz.primary.withValues(alpha: 0.06) : null,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // CE LTP (live, green)
          Expanded(
            flex: 1,
            child: Align(
              alignment: AlignmentGeometry.centerLeft,
              child: _liveText(item!.callSecId, item!.callVolume, Colorz.greenColor),
            ),
          ),
          // Call OI
          Expanded(
            flex: 1,
            child: Align(
              alignment: AlignmentGeometry.center,
              child: Text(item!.callOi,
                  style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
            ),
          ),
          // Strike
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item!.strike,
                  style: AppTextStyles.medium.copyWith(
                      color: isAtm ? Colorz.primary : Colorz.textColor,
                      fontWeight: isAtm ? FontWeight.bold : FontWeight.normal),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 3.sp,
                      width: 7.sp,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          color: Colorz.redColor),
                    ),
                    SizeConfig.horizontalSpace(
                        width: SizeConfig.spaceBetween * 0.2),
                    Container(
                      height: 3.sp,
                      width: 15.sp,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          color: Colorz.greenColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Put OI
          Expanded(
            flex: 1,
            child: Align(
              alignment: AlignmentGeometry.center,
              child: Text(item!.putOi,
                  style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
            ),
          ),
          // OI Chg
          Expanded(
            flex: 1,
            child: Align(
              alignment: AlignmentGeometry.centerRight,
              child: Text(item!.changeOi,
                  style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveText(String secId, String fallback, Color color) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (_, snap) {
        final prices = snap.data ?? {};
        final live = secId.isNotEmpty ? prices[secId] : null;
        final text = (live != null && live > 0) ? live.toStringAsFixed(2) : fallback;
        return Text(text,
            style: AppTextStyles.medium
                .copyWith(color: color, fontSize: SizeConfig.smallFont));
      },
    );
  }
}
