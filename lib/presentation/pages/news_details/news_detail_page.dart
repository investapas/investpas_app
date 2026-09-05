import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/data/models/news_model.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/utils/navigationService.dart';

class NewsDetailPage extends StatelessWidget {
  final StockNews? news;
  const NewsDetailPage({super.key, this.news});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            margin: EdgeInsets.only(
              top: 50.sp,
              left: SizeConfig.spaceBetween * 2,
              right: SizeConfig.spaceBetween * 2,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => NavigatorService.goBack(),
                          child: CircleWidget(
                            backgroundColor: Colorz.white,
                            child: Icon(Icons.arrow_back_rounded,
                                color: Colorz.hintTextColor2),
                          ),
                        ),
                        SizeConfig.verticalSpace(
                            height: SizeConfig.spaceBetween * 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                news != null
                                    ? "${news!.source} | ${news!.symbol}"
                                    : "Market News",
                                style: AppTextStyles.semiBold.copyWith(
                                    color: Colorz.primary,
                                    fontSize: SizeConfig.smallFont),
                              ),
                            ),
                            if (news != null && news!.time.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.watch_later_outlined,
                                      color: Colorz.hintTextColor2,
                                      size: 16.sp),
                                  SizeConfig.horizontalSpace(
                                      width: SizeConfig.spaceBetween * 0.5),
                                  Text(
                                    news!.time,
                                    style: AppTextStyles.medium.copyWith(
                                        color: Colorz.hintTextColor2,
                                        fontSize: SizeConfig.smallFont),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizeConfig.verticalSpace(
                            height: SizeConfig.spaceBetween * 1.5),
                        Text(
                          news?.title ?? '',
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.headerTwoFont),
                        ),
                        SizeConfig.verticalSpace(
                            height: SizeConfig.spaceBetween * 1.5),
                        if (news != null && news!.description.isNotEmpty)
                          Text(
                            news!.description,
                            style: AppTextStyles.medium
                                .copyWith(color: Colorz.hintTextColor),
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Previous",
                      style: AppTextStyles.semiBold.copyWith(
                          fontSize: SizeConfig.smallFont,
                          color: Colorz.hintTextColor),
                    ),
                    Text(
                      "Next",
                      style: AppTextStyles.semiBold.copyWith(
                          fontSize: SizeConfig.smallFont,
                          color: Colorz.primary),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
