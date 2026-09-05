import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Widgets/Widgets.dart';
import '../../../../Widgets/app_background.dart';
import '../../../../Widgets/circle_widget.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/demo_mode_service.dart';
import '../../../../core/utils/navigationService.dart';
import '../../../../data/models/portfolio_position.dart';
import '../../../../data/services/live_price_service.dart';
import '../../../../domain/repositories/portfolio.dart';
import '../../../../routes/appRoutes.dart';

class PositionPage extends StatefulWidget {
  final VoidCallback? onBack;
  const PositionPage({super.key, this.onBack});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  bool _isLoading = true;
  String _error = '';
  List<PortfolioPosition> _positions = [];
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _loadPositions();
    // Recompute P&L from live prices every second — no extra API calls.
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _positions.isNotEmpty) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final positions = await PortfolioRepository.instance.getPortfolio();
      setState(() { _positions = positions; _isLoading = false; });
      _subscribeLivePrices(positions);
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // Subscribe held positions to the live price feed so LivePriceService
  // starts streaming ticks for them (otherwise only browsed/watchlisted
  // instruments get live prices).
  void _subscribeLivePrices(List<PortfolioPosition> positions) {
    final instruments = positions
        .where((p) => p.securityId.isNotEmpty)
        .map((p) => {
              'ExchangeSegment': p.exchangeSegment,
              'SecurityId': p.securityId,
            })
        .toList();
    LivePriceService.instance.subscribe(instruments);
  }

  // Recompute unrealized P&L from the live LTP, keeping realizedProfit fixed.
  PortfolioPosition _withLivePrice(PortfolioPosition p) {
    final live = LivePriceService.instance.priceOf(p.securityId);
    if (live <= 0) return p;
    final avgPrice = p.netQty >= 0 ? p.buyAvg : p.sellAvg;
    final unrealized = (live - avgPrice) * p.netQty;
    return p.copyWith(
      ltp: live,
      unrealizedProfit: unrealized,
      pnl: p.realizedProfit + unrealized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final livePositions = _positions.map(_withLivePrice).toList();
    final totalPnL = livePositions.fold(0.0, (sum, p) => sum + p.pnl);
    final totalUnrealized = livePositions.fold(0.0, (sum, p) => sum + p.unrealizedProfit);
    final isDemoActive = DemoModeService.instance.isActive;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            color: Colorz.primary,
            onRefresh: _loadPositions,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 50.sp,
                      left: 16.sp,
                      right: 16.sp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button + title row
                        Row(
                          children: [
                            InkWell(
                              onTap: () => widget.onBack != null
                                  ? widget.onBack!()
                                  : NavigatorService.goBack(),
                              child: CircleWidget(
                                backgroundColor: Colorz.white,
                                child: Icon(Icons.arrow_back_rounded,
                                    color: Colorz.hintTextColor2, size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Positions',
                              style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.headerTwoFont,
                                color: Colorz.textColor,
                              ),
                            ),
                            const Spacer(),
                            if (_isLoading && _positions.isNotEmpty)
                              const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    color: Colorz.primary, strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Demo banner
                        if (isDemoActive) ...[
                          GestureDetector(
                            onTap: () => NavigatorService.pushNamed(AppRoutes.demoPage),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A73E8).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color: const Color(0xFF1A73E8)
                                        .withValues(alpha: 0.25)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 14, color: Color(0xFF1A73E8)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Demo mode ON — showing Dhan live positions.',
                                    style: AppTextStyles.medium.copyWith(
                                      color: const Color(0xFF1A73E8),
                                      fontSize: SizeConfig.smallerFont,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 10, color: Color(0xFF1A73E8)),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Summary card
                        _SummaryCard(totalPnL: totalPnL, unrealized: totalUnrealized,
                            count: livePositions.length),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Body
                if (_isLoading && _positions.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Colorz.primary)),
                  )
                else if (_error.isNotEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.wifi_off_rounded, size: 40,
                              color: Colorz.hintTextColor),
                          const SizedBox(height: 12),
                          Text(_error,
                              style: AppTextStyles.medium.copyWith(
                                  color: Colorz.redColor),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Button(text: 'Retry', buttonColor: Colorz.primary,
                              textColor: Colors.white, onPressed: _loadPositions),
                        ]),
                      ),
                    ),
                  )
                else if (livePositions.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.pie_chart_outline, size: 48,
                            color: Colorz.hintTextColor),
                        const SizedBox(height: 12),
                        Text('No open positions',
                            style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.largeFont,
                                color: Colorz.textColor)),
                        const SizedBox(height: 6),
                        Text('Open a trade to see your positions here.',
                            style: AppTextStyles.medium.copyWith(
                                color: Colorz.hintTextColor,
                                fontSize: SizeConfig.smallFont),
                            textAlign: TextAlign.center),
                      ]),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 24.sp),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _PositionCard(position: livePositions[i]),
                        childCount: livePositions.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final double totalPnL;
  final double unrealized;
  final int count;
  const _SummaryCard(
      {required this.totalPnL, required this.unrealized, required this.count});

  @override
  Widget build(BuildContext context) {
    final isProfit = totalPnL >= 0;
    final color = isProfit ? Colorz.greenColor : Colorz.redColor;
    final bgColor = isProfit
        ? Colorz.greenColor.withValues(alpha: 0.06)
        : Colorz.redColor.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colorz.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colorz.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Total P&L
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Total P&L',
                      style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallFont)),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colorz.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('LIVE',
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.primary,
                            fontSize: SizeConfig.smallerFont)),
                  ),
                ]),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${isProfit ? '+' : ''}₹${totalPnL.toStringAsFixed(2)}',
                    style: AppTextStyles.semiBold.copyWith(
                      color: color,
                      fontSize: SizeConfig.largeFont,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
              width: 1, height: 40, color: Colorz.dividerColor,
              margin: const EdgeInsets.symmetric(horizontal: 14)),

          // Right: Unrealized + count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Unrealized',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont)),
              const SizedBox(height: 3),
              Text(
                '${unrealized >= 0 ? '+' : ''}₹${unrealized.toStringAsFixed(2)}',
                style: AppTextStyles.semiBold.copyWith(
                  color: unrealized >= 0 ? Colorz.greenColor : Colorz.redColor,
                  fontSize: SizeConfig.smallFont,
                ),
              ),
              const SizedBox(height: 6),
              Text('$count position${count == 1 ? '' : 's'}',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Position card ──────────────────────────────────────────────────────────────
class _PositionCard extends StatelessWidget {
  final PortfolioPosition position;
  const _PositionCard({required this.position});

  @override
  Widget build(BuildContext context) {
    final totalPnl = position.pnl;
    final isProfit = totalPnl >= 0;
    final pnlColor = isProfit ? Colorz.greenColor : Colorz.redColor;
    final invested = position.buyAvg * position.netQty.abs();
    final pnlPct = invested > 0 ? (totalPnl / invested) * 100 : 0.0;
    final unrealized = position.unrealizedProfit;

    return GestureDetector(
      onTap: () => NavigatorService.pushNamed(
        AppRoutes.stockDetailsPage,
        arguments: position,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colorz.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            left: BorderSide(color: pnlColor, width: 3),
            top: BorderSide(color: Colorz.dividerColor, width: 0.8),
            right: BorderSide(color: Colorz.dividerColor, width: 0.8),
            bottom: BorderSide(color: Colorz.dividerColor, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              // Row 1: Symbol + qty + P&L%
              Row(
                children: [
                  // Symbol
                  Expanded(
                    child: Text(
                      position.tradingSymbol,
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Exchange chip
                  _Chip(
                    label: _shortSegment(position.exchangeSegment),
                    color: Colorz.purpleColor,
                  ),
                  const SizedBox(width: 6),
                  // P&L % badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                      style: AppTextStyles.semiBold.copyWith(
                          color: pnlColor,
                          fontSize: SizeConfig.smallerFont),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Row 2: product • type | Qty
              Row(children: [
                Text(
                  '${position.productType}  ·  ${position.positionType}',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont),
                ),
                const Spacer(),
                Text(
                  'Qty ${position.netQty}',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.hintTextColor2,
                      fontSize: SizeConfig.smallerFont),
                ),
              ]),
              const SizedBox(height: 8),

              // Divider
              Divider(color: Colorz.dividerColor, thickness: 0.8, height: 1),
              const SizedBox(height: 8),

              // Row 3: Avg | Unrealized | Total P&L
              Row(
                children: [
                  _DataCell(
                    label: 'Avg. Price',
                    value: '₹${position.buyAvg.toStringAsFixed(2)}',
                    valueColor: Colorz.textColor,
                    align: CrossAxisAlignment.start,
                  ),
                  _DataCell(
                    label: 'Unrealized',
                    value:
                        '${unrealized >= 0 ? '+' : ''}₹${unrealized.toStringAsFixed(2)}',
                    valueColor:
                        unrealized >= 0 ? Colorz.greenColor : Colorz.redColor,
                    align: CrossAxisAlignment.center,
                  ),
                  _DataCell(
                    label: 'Total P&L',
                    value:
                        '${isProfit ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}',
                    valueColor: pnlColor,
                    align: CrossAxisAlignment.end,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortSegment(String seg) {
    // NSE_EQ → NSE, BSE_EQ → BSE, NSE_FNO → F&O
    if (seg.contains('FNO') || seg.contains('F&O')) return 'F&O';
    if (seg.startsWith('NSE')) return 'NSE';
    if (seg.startsWith('BSE')) return 'BSE';
    return seg.length > 6 ? seg.substring(0, 6) : seg;
  }
}

class _DataCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment align;
  const _DataCell(
      {required this.label,
      required this.value,
      required this.valueColor,
      required this.align});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(label,
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallerFont)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.semiBold.copyWith(
                  color: valueColor, fontSize: SizeConfig.smallFont)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(label,
          style: AppTextStyles.semiBold.copyWith(
              color: color, fontSize: SizeConfig.smallerFont)),
    );
  }
}
