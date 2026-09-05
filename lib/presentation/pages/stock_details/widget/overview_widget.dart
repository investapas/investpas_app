import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_bloc.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';
import 'package:investapas/presentation/pages/stock_details/widget/price_state_widget.dart';

import '../../../../Widgets/Widgets.dart';
import '../../../../Widgets/live_price_widget.dart';
import '../../../../core/utils/navigationService.dart';
import '../../../../data/models/market_item.dart';
import '../../../../routes/appRoutes.dart';
import '../../trade_sheet/trade_sheet.dart';
import '../../../bloc/stock_details/stock_details_event.dart';
import '../fullscreen_chart_page.dart';
import 'overview_chart.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockDetailsBloc, StockDetailsState>(
      builder: (context, state) {
        final position = state.position;
        
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (position != null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colorz.bottomPillBg, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      position.tradingSymbol,
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: SizeConfig.largeFont,
                                        color: Colorz.textColor,
                                      ),
                                    ),
                                    SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                                    Text(
                                      "${position.exchangeSegment} - ${position.productType}",
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: SizeConfig.smallFont,
                                        color: Colorz.hintTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                // Container(
                                //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                //   decoration: BoxDecoration(
                                //     color: position.pnl >= 0 ? Colorz.greenColor.withValues(alpha: 0.15) : Colorz.lightRedColor,
                                //     borderRadius: BorderRadius.circular(4),
                                //   ),
                                //   child: Text(
                                //     "${position.pnl >= 0 ? '+' : ''}${position.pnl.toStringAsFixed(2)}",
                                //     style: AppTextStyles.semiBold.copyWith(
                                //       color: position.pnl >= 0 ? Colorz.greenColor : Colorz.redColor,
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "LTP",
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: SizeConfig.smallFont,
                                        color: Colorz.hintTextColor,
                                      ),
                                    ),
                                    Text(
                                      position.ltp.toStringAsFixed(2),
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: SizeConfig.mediumFont,
                                        color: Colorz.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Avg. Price",
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: SizeConfig.smallFont,
                                        color: Colorz.hintTextColor,
                                      ),
                                    ),
                                    Text(
                                      position.buyAvg.toStringAsFixed(2),
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: SizeConfig.mediumFont,
                                        color: Colorz.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Quantity",
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: SizeConfig.smallFont,
                                        color: Colorz.hintTextColor,
                                      ),
                                    ),
                                    Text(
                                      position.buyQty.toString(),
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: SizeConfig.mediumFont,
                                        color: Colorz.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    // Live price header
                    if (state.securityId.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                        child: Row(
                          children: [
                            Text('LTP  ', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.mediumFont)),
                            LivePriceWidget(
                              securityId: state.securityId,
                              style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerTwoFont),
                            ),
                          ],
                        ),
                      ),
                    SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                    // ── Chart header: 3D icon + fullscreen button ─────
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                      child: Row(
                        children: [
                          SvgPicture.asset(Assets.view3dSvg),
                          const Spacer(),
                          // Fullscreen button
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<StockDetailsBloc>(),
                                  child: const FullscreenChartPage(),
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colorz.bottomPillBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fullscreen_rounded,
                                  color: Colorz.hintTextColor2, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ── Chart ─────────────────────────────────────────
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                      child: state.isChartLoading
                          ? OverviewChart(candles: const [], isLoading: true)
                          : OverviewChart(
                              candles: state.candles,
                              isLoading: false,
                              securityId: state.securityId,
                              onNeedOlderData: () => context.read<StockDetailsBloc>()
                                  .add(const LoadOlderCandlesEvent()),
                            ),
                    ),
                    SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                    // ── Interval selector (always visible) ───────────
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                      child: _IntervalSelector(
                        selected: state.chartInterval,
                        onSelect: (i) => context.read<StockDetailsBloc>()
                            .add(ChangeInterval(i)),
                      ),
                    ),
                    SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                    // OHLC stats — from real candle data
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                      child: PriceStateWidget(candles: state.candles, dailyOpen: state.dailyOpen),
                    ),
                    // Related F&O instruments with live prices
                    if (state.relatedFNO.isNotEmpty) ...[
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                        child: Text(
                          "Related F&O",
                          style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.textColor,
                            fontSize: SizeConfig.headerThreeFont,
                          ),
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      ...state.relatedFNO.map((item) => Container(
                        margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2, vertical: 4),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colorz.bottomPillBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Option type badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (item.optionType ?? '').contains('CE')
                                    ? Colorz.greenColor.withValues(alpha: 0.15)
                                    : Colorz.redColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.optionType ?? '',
                                style: AppTextStyles.semiBold.copyWith(
                                  color: (item.optionType ?? '').contains('CE')
                                      ? Colorz.greenColor
                                      : Colorz.redColor,
                                  fontSize: SizeConfig.smallerFont,
                                ),
                              ),
                            ),
                            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTextStyles.medium.copyWith(
                                      color: Colorz.textColor,
                                      fontSize: SizeConfig.smallFont,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    () {
                                      final isFut = item.name.toUpperCase().contains('FUT');
                                      final sp = double.tryParse(item.strikePrice ?? '') ?? 0;
                                      final strikeStr = (!isFut && sp > 0)
                                          ? 'Strike ${item.strikePrice}  •  ' : '';
                                      return '${strikeStr}Lot ${item.lotSize}';
                                    }(),
                                    style: AppTextStyles.medium.copyWith(
                                      color: Colorz.hintTextColor,
                                      fontSize: SizeConfig.smallerFont,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LivePriceWidget(
                              securityId: item.securityId,
                              style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            Column(
              children: [
                _buildBottomTabs(),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                // Indices (IDX_I) cannot be directly traded — hide Buy/Sell
                if (state.exchangeSegment != 'IDX_I')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Button(
                            text: 'Sell',
                            isOutlined: true,
                            isBig: true,
                            radius: 100,
                            valueColor: Colorz.primary,
                            textColor: Colorz.primary,
                            buttonColor: Colors.transparent,
                            onPressed: () {
                              final pos  = state.position;
                              final item = state.marketItem;
                              if (pos == null && item == null) return;
                              final mi = item ?? MarketItem(
                                securityId:      pos!.securityId,
                                name:            pos.tradingSymbol,
                                symbol:          pos.tradingSymbol,
                                exchange:        pos.exchangeSegment.contains('NSE') ? 'NSE' : 'BSE',
                                exchangeSegment: pos.exchangeSegment,
                                lotSize:         '1',
                                isUp:            pos.pnl >= 0,
                              );
                              TradeSheet.show(context, item: mi, isBuy: false,
                                  existingQty: pos?.netQty);
                            },
                          ),
                        ),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                        Expanded(
                          flex: 1,
                          child: Button(
                            text: 'Buy',
                            isOutlined: false,
                            isBig: true,
                            radius: 100,
                            gradient: Colorz.primaryButtonGradient,
                            onPressed: () {
                              MarketItem? mi = state.marketItem;
                              if (mi == null && state.position != null) {
                                final pos = state.position!;
                                mi = MarketItem(
                                  securityId:      pos.securityId,
                                  name:            pos.tradingSymbol,
                                  symbol:          pos.tradingSymbol,
                                  exchange:        pos.exchangeSegment.contains('NSE') ? 'NSE' : 'BSE',
                                  exchangeSegment: pos.exchangeSegment,
                                  lotSize:         '1',
                                  isUp:            pos.pnl >= 0,
                                );
                              }
                              if (mi == null) return;
                              TradeSheet.show(context, item: mi, isBuy: true);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
              ],
            )
          ],
        );
      },
    );
  }

  _buildBottomTabs(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.sp),
      child: Row(
        children: [
          item(Assets.ordersSvg, "Charts",15),
          item(Assets.linkSvg, "Option Chain",15),
          item(Assets.watchlistSvg, "Watchlist",15),
        ],
      ),
    );
  }

  Widget item(String svgIcon, String text, double size) {

    return Expanded(
      child: InkWell(
        onTap: () {
          if(text == "Charts"){
            // NavigatorService.pushNamed(AppRoutes.positionPage);
          }

          if(text == "Option Chain"){
            NavigatorService.pushNamed(AppRoutes.optionChangePage);
          }

          if(text == "Watchlist"){
            NavigatorService.pushNamed(AppRoutes.watchListPage);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Colorz.textColor,
                  width: 1
              )
          ),
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*0.3),
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIcon,
                height: size,
                width: size,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    Colorz.hintTextColor2,
                    BlendMode.srcIn
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
              Text(
                  text,
                  style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.smallFont,color: Colorz.hintTextColor2,)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Interval chip row (1m, 3m, 5m, 10m, 15m) ─────────────────────────────────
class _IntervalSelector extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;

  const _IntervalSelector({required this.selected, required this.onSelect});

  static const _options = [
    (1,  '1m'),
    (5,  '5m'),
    (15, '15m'),
    (25, '25m'),
    (60, '1H'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final item = _options[i];
          final isActive = item.$1 == selected && selected > 0;
          return GestureDetector(
            onTap: () => onSelect(isActive ? 0 : item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colorz.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colorz.primary : Colorz.dividerColor,
                ),
              ),
              child: Text(
                item.$2,
                style: AppTextStyles.semiBold.copyWith(
                  color: isActive ? Colors.white : Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
