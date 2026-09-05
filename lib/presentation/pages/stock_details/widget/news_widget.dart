import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/core/utils/navigationService.dart';
import 'package:investapas/data/models/news_model.dart';
import 'package:investapas/routes/appRoutes.dart';

import '../../../bloc/stock_details/stock_details_bloc.dart';
import '../../../bloc/stock_details/stock_details_event.dart';
import '../../../bloc/stock_details/stock_details_state.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockDetailsBloc, StockDetailsState>(
      builder: (context, state) {
        if (state.isNewsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.newsError.isNotEmpty && state.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.newspaper_outlined,
                    color: Colorz.hintTextColor2, size: 40.sp),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                Text(
                  'Could not load news',
                  style: AppTextStyles.semiBold
                      .copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.mediumFont),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                GestureDetector(
                  onTap: () =>
                      context.read<StockDetailsBloc>().add(LoadNews()),
                  child: Text(
                    'Retry',
                    style: AppTextStyles.semiBold
                        .copyWith(color: Colorz.primary, fontSize: SizeConfig.mediumFont),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.newspaper_outlined,
                    color: Colorz.hintTextColor2, size: 40.sp),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                Text(
                  'No news available',
                  style: AppTextStyles.semiBold
                      .copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.mediumFont),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            margin:
                EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Related News",
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.headerThreeFont),
                ),
                ListView.builder(
                  itemBuilder: (lContext, index) {
                    return NewsItem(news: state.news[index]);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.news.length,
                ),
                SizeConfig.verticalSpace(
                    height: SizeConfig.spaceBetween),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NewsItem extends StatelessWidget {
  final StockNews? news;
  const NewsItem({super.key, this.news});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigatorService.pushNamed(AppRoutes.newsDetailPage, arguments: news);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.spaceBetween * 1.2),
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 14.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.sp),
          color: Colorz.newsBg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${news!.source} | ${news!.symbol}",
              style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.primary, fontSize: SizeConfig.smallFont),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
            Text(
              news!.title,
              style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
            ),
            Divider(color: Colorz.dividerColor),
            Row(
              children: [
                Icon(Icons.watch_later_outlined,
                    color: Colorz.hintTextColor2, size: 16.sp),
                SizeConfig.horizontalSpace(
                    width: SizeConfig.spaceBetween * 0.5),
                Expanded(
                  child: Text(
                    news!.time,
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor2,
                        fontSize: SizeConfig.smallFont),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
