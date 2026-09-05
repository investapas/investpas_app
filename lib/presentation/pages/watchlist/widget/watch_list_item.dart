import 'package:flutter/material.dart';
import 'package:investapas/data/models/watch_item.dart';
import 'package:investapas/presentation/pages/watchlist/widget/spark_link_chart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/navigationService.dart';
import '../../../../routes/appRoutes.dart';

class WatchListItem extends StatelessWidget {
  final WatchItem? item;
  const WatchListItem({super.key,this.item});

  @override
  Widget build(BuildContext context) {

    final color = item!.isUp ? Colorz.greenColor : Colorz.redColor;

    return InkWell(
      onTap: (){
        NavigatorService.pushNamed(AppRoutes.stockDetailsPage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 5,
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
            Center(
              child: SparklineChart(
                data: item!.chart,
                color: color,
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item!.price,
                      style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.largeFont)),
                  SizeConfig.verticalSpace(height: 4),
                  Text(item!.changePercent,
                      style: AppTextStyles.headerThree.copyWith(
                          color: color,
                          fontSize: SizeConfig.smallFont)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
