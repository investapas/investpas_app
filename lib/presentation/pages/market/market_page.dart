import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/data/services/live_price_service.dart';
import 'package:investapas/presentation/bloc/market/market_bloc.dart';
import 'package:investapas/presentation/bloc/market/market_event.dart';
import 'package:investapas/presentation/bloc/market/market_state.dart';
import '../../../Widgets/app_background.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketBloc()..add(LoadMarketDataEvent()),
      child: const _MarketView(),
    );
  }
}

class _MarketView extends StatelessWidget {
  const _MarketView();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colorz.textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Market',
              style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.textColor, fontSize: SizeConfig.headerTwoFont)),
          centerTitle: false,
        ),
        body: BlocBuilder<MarketBloc, MarketState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colorz.primary));
            }
            if (state.error.isNotEmpty && state.topGainers.isEmpty) {
              return _ErrorView(error: state.error,
                  onRetry: () => context.read<MarketBloc>().add(LoadMarketDataEvent()));
            }
            return RefreshIndicator(
              color: Colorz.primary,
              onRefresh: () async =>
                  context.read<MarketBloc>().add(LoadMarketDataEvent()),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2)
                    .copyWith(bottom: 32),
                children: [
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                  // ── Index cards row ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _IndexCard(data: state.nifty50,   secId: '13')),
                      SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                      Expanded(child: _IndexCard(data: state.bankNifty, secId: '25')),
                    ],
                  ),

                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),

                  // ── Gainers / Losers toggle ──────────────────────────────
                  _SectionToggle(active: state.activeSection),

                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                  // ── Header row ──────────────────────────────────────────
                  _MoverHeader(),

                  Divider(color: Colorz.dividerColor, thickness: 1),

                  // ── Mover list ──────────────────────────────────────────
                  ...( state.activeSection == MarketSection.gainers
                          ? state.topGainers
                          : state.topLosers
                      ).map((m) => _MoverRow(mover: m)),

                  if ((state.activeSection == MarketSection.gainers
                          ? state.topGainers
                          : state.topLosers)
                      .isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.sp),
                      child: Center(
                        child: Text('No data available',
                            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Index card (NIFTY 50 / BANKNIFTY) ────────────────────────────────────────
class _IndexCard extends StatelessWidget {
  final MarketIndexData? data;
  final String secId;

  const _IndexCard({required this.data, required this.secId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (_, snap) {
        final prices   = snap.data ?? {};
        final liveLtp  = prices[secId] ?? 0;
        final pc       = LivePriceService.instance.prevCloseOf(secId);

        // Prefer live price; fall back to backend snapshot
        final ltp      = liveLtp > 0 ? liveLtp : (data?.ltp ?? 0);
        final prevClose = pc > 0 ? pc : (data?.prevClose ?? 0);
        final change    = prevClose > 0 ? ltp - prevClose : (data?.change ?? 0);
        final changePct = prevClose > 0
            ? (change / prevClose) * 100
            : (data?.changePct ?? 0);
        final isUp      = change >= 0;
        final color     = isUp ? Colorz.greenColor : Colorz.redColor;

        final open      = data?.open      ?? 0;
        final high      = data?.high      ?? 0;
        final low       = data?.low       ?? 0;
        final symbol    = data?.symbol    ?? (secId == '13' ? 'NIFTY 50' : 'BANKNIFTY');

        return Container(
          padding: EdgeInsets.all(14.sp),
          decoration: BoxDecoration(
            color: Colorz.bottomPillBg,
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.smallFont)),
              SizeConfig.verticalSpace(height: 6),
              Text(
                ltp > 0 ? ltp.toStringAsFixed(2) : '—',
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.largeFont),
              ),
              SizeConfig.verticalSpace(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isUp ? '+' : ''}${change.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%)',
                  style: AppTextStyles.medium.copyWith(
                      color: color, fontSize: SizeConfig.smallerFont),
                ),
              ),
              if (open > 0) ...[
                SizeConfig.verticalSpace(height: 10),
                Divider(color: Colorz.dividerColor, thickness: 0.5, height: 1),
                SizeConfig.verticalSpace(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ohlcItem('O', open),
                    _ohlcItem('H', high, Colorz.greenColor),
                  ],
                ),
                SizeConfig.verticalSpace(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ohlcItem('L', low, Colorz.redColor),
                    _ohlcItem('PC', prevClose),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _ohlcItem(String label, double value, [Color? color]) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: AppTextStyles.medium.copyWith(
              color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont)),
      Text(value > 0 ? value.toStringAsFixed(2) : '—',
          style: AppTextStyles.semiBold.copyWith(
              color: color ?? Colorz.textColor, fontSize: SizeConfig.smallerFont)),
    ],
  );
}

// ── Gainers / Losers section toggle ──────────────────────────────────────────
class _SectionToggle extends StatelessWidget {
  final MarketSection active;
  const _SectionToggle({required this.active});

  @override
  Widget build(BuildContext context) {
    Widget btn(String label, MarketSection section) {
      final isActive = active == section;
      final isGainer = section == MarketSection.gainers;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.read<MarketBloc>().add(ChangeMarketSectionEvent(section)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            decoration: BoxDecoration(
              color: isActive
                  ? (isGainer ? Colorz.greenColor : Colorz.redColor).withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: isActive
                    ? (isGainer ? Colorz.greenColor : Colorz.redColor)
                    : Colorz.dividerColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGainer ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14.sp,
                  color: isActive
                      ? (isGainer ? Colorz.greenColor : Colorz.redColor)
                      : Colorz.hintTextColor,
                ),
                SizedBox(width: 4),
                Text(label,
                    style: AppTextStyles.semiBold.copyWith(
                        color: isActive
                            ? (isGainer ? Colorz.greenColor : Colorz.redColor)
                            : Colorz.hintTextColor,
                        fontSize: SizeConfig.mediumFont)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('Top Gainers', MarketSection.gainers),
        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
        btn('Top Losers', MarketSection.losers),
      ],
    );
  }
}

// ── Mover list header ─────────────────────────────────────────────────────────
class _MoverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.sp),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('Symbol',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont))),
          Expanded(
              flex: 2,
              child: Text('LTP',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont))),
          Expanded(
              flex: 2,
              child: Text('Chg%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont))),
          Expanded(
              flex: 2,
              child: Text('Volume',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont))),
        ],
      ),
    );
  }
}

// ── Single mover row ──────────────────────────────────────────────────────────
class _MoverRow extends StatelessWidget {
  final MarketMover mover;
  const _MoverRow({required this.mover});

  @override
  Widget build(BuildContext context) {
    final isUp     = mover.change >= 0;
    final color    = isUp ? Colorz.greenColor : Colorz.redColor;
    final vol      = _fmtVol(mover.volume);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp),
          child: Row(
            children: [
              // Symbol + change
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mover.tradingSymbol,
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.textColor,
                            fontSize: SizeConfig.smallFont),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text(
                      '${isUp ? '+' : ''}${mover.change.toStringAsFixed(2)}',
                      style: AppTextStyles.medium.copyWith(
                          color: color, fontSize: SizeConfig.smallerFont),
                    ),
                  ],
                ),
              ),
              // LTP
              Expanded(
                flex: 2,
                child: Text(
                  mover.ltp > 0 ? mover.ltp.toStringAsFixed(2) : '—',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.smallFont),
                ),
              ),
              // Change %
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 6.sp),
                  padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    '${isUp ? '+' : ''}${mover.changePct.toStringAsFixed(2)}%',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.semiBold.copyWith(
                        color: color, fontSize: SizeConfig.smallerFont),
                  ),
                ),
              ),
              // Volume
              Expanded(
                flex: 2,
                child: Text(
                  vol,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont),
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colorz.dividerColor, thickness: 0.5, height: 0),
      ],
    );
  }

  String _fmtVol(double v) {
    if (v <= 0) return '—';
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colorz.redColor, size: 48.sp),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Colorz.primary),
              child: Text('Retry',
                  style: AppTextStyles.semiBold.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
