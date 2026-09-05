import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';
import '../../../../data/models/chart_data.dart';

class PriceStateWidget extends StatelessWidget {
  final List<ChartCandle> candles;
  final double dailyOpen;
  const PriceStateWidget({super.key, this.candles = const [], this.dailyOpen = 0});

  @override
  Widget build(BuildContext context) {
    // Compute OHLC from candles
    double open      = 0, high = 0, low = 0, prevClose = 0;
    double weekHigh  = 0, weekLow = double.maxFinite;

    if (candles.isNotEmpty) {
      final now = DateTime.now();

      // Split: today's candles vs historical
      final todayCandles = candles.where((c) =>
          c.time.year == now.year &&
          c.time.month == now.month &&
          c.time.day == now.day).toList();

      final histCandles = candles.where((c) =>
          !(c.time.year == now.year &&
            c.time.month == now.month &&
            c.time.day == now.day)).toList();

      // Today's OHLC — use today's candles if available, else last candle
      final dayCandles = todayCandles.isNotEmpty ? todayCandles : [candles.last];
      // Prefer dailyOpen (pre-open auction price from daily historical candle) over
      // first intraday candle open (first trade price — can differ by ~100 pts)
      open = (dailyOpen > 0) ? dailyOpen : dayCandles.first.open;
      high = dayCandles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
      low  = dayCandles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

      // Prev close = last historical close before today
      prevClose = histCandles.isNotEmpty ? histCandles.last.close : 0;

      // 52W high/low — limit to last 365 days only (DB may contain multi-year history)
      final cutoff = now.subtract(const Duration(days: 365));
      final yearCandles = candles.where((c) => c.time.isAfter(cutoff)).toList();
      final w52 = yearCandles.isNotEmpty ? yearCandles : candles;
      weekHigh = w52.map((c) => c.high).reduce((a, b) => a > b ? a : b);
      weekLow  = w52.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    }

    String fmt(double v) {
      if (v == 0 || v == double.maxFinite || v.isInfinite || v.isNaN) return '—';
      return v.toStringAsFixed(2);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.sp),
        color: Colorz.bottomPillBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Stats",
            style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor, fontSize: SizeConfig.headerThreeFont),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          _row([
            _stat("Open",  fmt(open)),
            _stat("High",  fmt(high),  Colorz.greenColor),
            _stat("Low",   fmt(low),   Colorz.redColor),
          ]),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          Divider(color: Colorz.textFieldBorderColor),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          _row([
            _stat("Prev Close", fmt(prevClose)),
            _stat("52W High",   fmt(weekHigh), Colorz.greenColor),
            _stat("52W Low",    fmt(weekLow),  Colorz.redColor),
          ]),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: children.map((w) => Expanded(child: w)).toList(),
  );

  Widget _stat(String label, String value, [Color? valueColor]) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
      Text(value, style: AppTextStyles.medium.copyWith(color: valueColor ?? Colorz.hintTextColor)),
    ],
  );
}
