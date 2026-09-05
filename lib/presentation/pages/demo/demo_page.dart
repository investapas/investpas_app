import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/app_dialog.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/services/unified_trading_service.dart';
import '../../../data/models/demo_order_model.dart';
import '../../../data/models/market_item.dart';
import '../../../data/services/live_price_service.dart';
import '../trade_sheet/trade_sheet.dart';
import '../../bloc/demo/demo_bloc.dart';
import '../../bloc/demo/demo_event.dart';
import '../../bloc/demo/demo_state.dart';

// Maps raw exchange segment codes to Dhan WebSocket format
String _mapSeg(String seg) {
  const m = {
    'D': 'NSE_FNO', 'E': 'NSE_EQ',
    'NSE_FNO': 'NSE_FNO', 'BSE_FNO': 'BSE_FNO',
    'NSE_EQ': 'NSE_EQ',   'BSE_EQ': 'BSE_EQ',
    'NSE_CURR': 'NSE_CURR', 'MCX_COMM': 'MCX_COMM',
  };
  return m[seg] ?? seg;
}

// ── Main page ────────────────────────────────────────────────────────────────
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadAll();
  }

  void _loadAll() {
    final bloc = context.read<DemoBloc>();
    bloc.add(const LoadDemoWallet());
    bloc.add(const LoadDemoOrders());
    bloc.add(const LoadDemoPortfolio());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocConsumer<DemoBloc, DemoState>(
            listenWhen: (p, c) =>
                p.actionMessage != c.actionMessage && c.actionMessage.isNotEmpty,
            listener: (ctx, state) {
              context.read<DemoBloc>().add(const ClearDemoMessage());
              if (state.actionSuccess) {
                AppSnackBar.showSuccess(ctx, state.actionMessage);
              } else {
                AppSnackBar.showError(ctx, state.actionMessage);
              }
            },
            builder: (ctx, state) {
              return Column(
                children: [
                  SizedBox(height: 50.sp),
                  // ── Header ─────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.spaceBetween * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: NavigatorService.goBack,
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.black),
                            ),
                            SizeConfig.horizontalSpace(
                                width: SizeConfig.spaceBetween),
                            Text(
                              'Demo Trading',
                              style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.headerTwoFont,
                                color: Colorz.textColor,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => _confirmReset(ctx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      Colorz.redColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'Reset',
                                  style: AppTextStyles.semiBold.copyWith(
                                    color: Colorz.redColor,
                                    fontSize: SizeConfig.smallFont,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizeConfig.verticalSpace(
                            height: SizeConfig.spaceBetween * 1.5),

                        // Coin balance card
                        _CoinCard(
                          state: state,
                          onBuyMore: () => _showBuyCoinsSheet(ctx, state),
                        ),
                        SizeConfig.verticalSpace(
                            height: SizeConfig.spaceBetween * 1.5),

                        // Tab bar
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colorz.bottomPillBg,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: TabBar(
                            controller: _tab,
                            indicator: BoxDecoration(
                              color: Colorz.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelStyle: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.mediumFont),
                            unselectedLabelStyle: AppTextStyles.semiBold
                                .copyWith(fontSize: SizeConfig.mediumFont),
                            labelColor: Colorz.textColor,
                            unselectedLabelColor: Colorz.hintTextColor,
                            tabs: const [
                              Tab(text: 'Portfolio'),
                              Tab(text: 'Orders'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                  // ── Tab views ──────────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        // Portfolio tab — pass buy/sell callbacks
                        _PortfolioTab(
                          positions: state.portfolio,
                          closedToday: state.closedToday,
                          closedAllTime: state.closedAllTime,
                          realizedPnl: state.realizedPnl,
                          isLoading: state.isLoading,
                          onBuy: (pos) {
                            final item = MarketItem(
                              securityId: pos.securityId,
                              name: pos.tradingSymbol,
                              symbol: pos.tradingSymbol,
                              exchangeSegment: pos.exchangeSegment,
                              exchange: pos.exchangeSegment.startsWith('BSE') ? 'BSE' : 'NSE',
                              lotSize: '1',
                              isUp: false,
                            );
                            TradeSheet.show(
                              context,
                              item: item,
                              isBuy: true,
                              existingQty: pos.netQuantity,
                            ).then((_) {
                              if (mounted) _loadAll();
                            });
                          },
                          onSell: (pos) {
                            final item = MarketItem(
                              securityId: pos.securityId,
                              name: pos.tradingSymbol,
                              symbol: pos.tradingSymbol,
                              exchangeSegment: pos.exchangeSegment,
                              exchange: pos.exchangeSegment.startsWith('BSE') ? 'BSE' : 'NSE',
                              lotSize: '1',
                              isUp: false,
                            );
                            TradeSheet.show(
                              context,
                              item: item,
                              isBuy: false,
                              existingQty: pos.netQuantity,
                            ).then((_) {
                              if (mounted) _loadAll();
                            });
                          },
                        ),
                        // Orders tab
                        _OrdersTab(
                          orders: state.orders,
                          isLoading: state.isLoading,
                          onOrderTap: (order) {
                            // A PENDING limit order isn't a finished trade to
                            // re-open a new order for — offer Cancel/Modify
                            // instead of the normal "place a fresh order" flow.
                            if (order.isPending) {
                              _showPendingOrderActions(order);
                              return;
                            }
                            final item = MarketItem(
                              securityId: order.securityId,
                              name: order.tradingSymbol,
                              symbol: order.tradingSymbol,
                              exchangeSegment: order.exchangeSegment,
                              exchange: order.exchangeSegment.startsWith('BSE') ? 'BSE' : 'NSE',
                              lotSize: '1',
                              isUp: false,
                            );
                            TradeSheet.show(
                              context,
                              item: item,
                              isBuy: order.isBuy,
                            ).then((_) {
                              if (mounted) _loadAll();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext ctx) {
    final bloc = ctx.read<DemoBloc>();
    AppDialog.showConfirm(
      ctx,
      title: 'Reset Demo Account',
      message:
          'This will delete all your demo orders and restore your coin balance. Continue?',
      confirmText: 'Yes, Reset',
      cancelText: 'Cancel',
    ).then((ok) {
      if (ok) bloc.add(const ResetDemoAccount());
    });
  }

  // Actions for a PENDING limit order — Cancel or Modify (price/qty), both
  // via the existing backend endpoints (DemoController.cancelOrder/modifyOrder,
  // now gated to PENDING-only).
  void _showPendingOrderActions(DemoOrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colorz.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${order.tradingSymbol} — Pending ${order.transactionType} LIMIT',
                style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont)),
            const SizedBox(height: 4),
            Text('Qty: ${order.quantity}  •  Limit ₹${order.price.toStringAsFixed(2)}',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showModifyPendingOrder(order);
                },
                child: const Text('Modify'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context.read<DemoBloc>().add(CancelDemoOrder(orderId: order.id));
                },
                child: const Text('Cancel Order'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showModifyPendingOrder(DemoOrderModel order) {
    final priceCtrl = TextEditingController(text: order.price.toStringAsFixed(2));
    final qtyCtrl = TextEditingController(text: order.quantity.toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colorz.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: 20 + MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Modify ${order.tradingSymbol}',
              style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont)),
          const SizedBox(height: 16),
          TextField(
            controller: priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Limit Price'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text) ?? 0;
                final newQty = int.tryParse(qtyCtrl.text) ?? 0;
                if (newPrice <= 0 || newQty <= 0) {
                  AppSnackBar.showError(sheetCtx, 'Enter a valid price and quantity');
                  return;
                }
                Navigator.pop(sheetCtx);
                UnifiedTradingService.modifyOrder(
                  orderId: order.id.toString(),
                  newPrice: newPrice,
                  newQuantity: newQty,
                ).then((result) {
                  if (!mounted) return;
                  if (result.status) {
                    AppSnackBar.showSuccess(context,
                        result.message.isNotEmpty ? result.message : 'Order updated');
                    _loadAll();
                  } else {
                    AppSnackBar.showError(context, result.message);
                  }
                });
              },
              child: const Text('Update'),
            ),
          ),
        ]),
      ),
    );
  }

  void _showBuyCoinsSheet(BuildContext ctx, DemoState state) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colorz.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<DemoBloc>(),
        child: _BuyCoinsSheet(state: state),
      ),
    );
  }
}

// ── Coin balance card ─────────────────────────────────────────────────────────
class _CoinCard extends StatelessWidget {
  final DemoState state;
  final VoidCallback onBuyMore;
  const _CoinCard({required this.state, required this.onBuyMore});

  @override
  Widget build(BuildContext context) {
    final coins = state.availableCoins;
    final total = state.totalGrantedCoins > 0 ? state.totalGrantedCoins : 1;
    final pct   = (coins / total).clamp(0.0, 1.0);
    final isLow = coins < (state.coinPackCoins * 0.1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.toll_rounded,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'DEMO COINS',
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.smallerFont,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '1 Coin = ₹1',
                style: AppTextStyles.medium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: SizeConfig.smallerFont,
                ),
              ),
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.toll_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                _fmt(coins),
                style: AppTextStyles.semiBold.copyWith(
                  color: Colors.white,
                  fontSize: 26.sp,
                ),
              ),
            ],
          ),
          SizeConfig.verticalSpace(height: 4),
          Row(
            children: [
              Text(
                'Available Demo Coins',
                style: AppTextStyles.medium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: SizeConfig.smallFont,
                ),
              ),
              const Spacer(),
              // Trading P&L indicator: coins gained or lost from trading
              Builder(builder: (context) {
                final tradingPnl = state.availableCoins - state.totalGrantedCoins;
                if (tradingPnl == 0) return const SizedBox.shrink();
                final isGain = tradingPnl >= 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${isGain ? '+' : ''}${tradingPnl.toStringAsFixed(0)} coins',
                    style: AppTextStyles.semiBold.copyWith(
                      color: isGain ? const Color(0xFF80FFD4) : const Color(0xFFFF8A80),
                      fontSize: SizeConfig.smallerFont,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(
                  isLow ? Colors.orangeAccent : Colors.white),
              minHeight: 6,
            ),
          ),
          SizeConfig.verticalSpace(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total granted: ${_fmt(state.totalGrantedCoins)} coins',
                style: AppTextStyles.medium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: SizeConfig.smallerFont,
                ),
              ),
              GestureDetector(
                onTap: onBuyMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '+ Buy Coins',
                    style: AppTextStyles.semiBold.copyWith(
                      color: const Color(0xFF1A73E8),
                      fontSize: SizeConfig.smallerFont,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double c) {
    if (c >= 100000) return '${(c / 100000).toStringAsFixed(c % 100000 == 0 ? 0 : 1)} L';
    if (c >= 1000)   return '${(c / 1000).toStringAsFixed(c % 1000 == 0 ? 0 : 1)} K';
    return c.toStringAsFixed(0);
  }
}

// ── Buy more coins bottom sheet ───────────────────────────────────────────────
class _BuyCoinsSheet extends StatelessWidget {
  final DemoState state;
  const _BuyCoinsSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
      child: BlocConsumer<DemoBloc, DemoState>(
        listenWhen: (p, c) =>
            p.actionMessage != c.actionMessage && c.actionMessage.isNotEmpty,
        listener: (ctx, s) {
          context.read<DemoBloc>().add(const ClearDemoMessage());
          if (s.actionSuccess) {
            AppSnackBar.showSuccess(ctx, s.actionMessage);
            Navigator.of(ctx).pop();
          } else {
            AppSnackBar.showError(ctx, s.actionMessage);
          }
        },
        builder: (ctx, s) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colorz.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
            Container(
              width: 64.sp,
              height: 64.sp,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.toll_rounded,
                  color: Colors.white, size: 32),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Text(
              'Get More Demo Coins',
              style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.headerThreeFont,
                color: Colorz.textColor,
              ),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
            Container(
              padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
              decoration: BoxDecoration(
                color: Colorz.bottomPillBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.toll_rounded,
                      color: Color(0xFF1A73E8), size: 28),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_fmtPack(s.coinPackCoins.toDouble())} Demo Coins',
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.mediumFont),
                        ),
                        Text(
                          'Practice trading worth ₹${s.coinPackCoins}',
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.hintTextColor,
                              fontSize: SizeConfig.smallFont),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${s.coinPackPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.semiBold.copyWith(
                      color: const Color(0xFF1A73E8),
                      fontSize: SizeConfig.headerThreeFont,
                    ),
                  ),
                ],
              ),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.75),
            Text(
              '1 Demo Coin = ₹1 trading power',
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
            Button(
              text: s.isActionLoading
                  ? 'Processing...'
                  : 'Buy for ₹${s.coinPackPrice.toStringAsFixed(0)}',
              onPressed: s.isActionLoading
                  ? () {}
                  : () => ctx.read<DemoBloc>().add(const PurchaseCoinPack()),
              buttonColor: const Color(0xFF1A73E8),
              textColor: Colors.white,
              radius: 12,
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          ],
        ),
      ),
    );
  }

  String _fmtPack(double c) {
    if (c >= 100000) return '${(c / 100000).toStringAsFixed(0)} Lakh';
    if (c >= 1000)   return '${(c / 1000).toStringAsFixed(0)}K';
    return c.toStringAsFixed(0);
  }
}

// ── Portfolio tab ─────────────────────────────────────────────────────────────
class _PortfolioTab extends StatefulWidget {
  final List<DemoPositionModel> positions;
  final List<DemoClosedPositionModel> closedToday;
  final List<DemoClosedPositionModel> closedAllTime;
  final double realizedPnl;
  final bool isLoading;
  final void Function(DemoPositionModel) onBuy;
  final void Function(DemoPositionModel) onSell;
  const _PortfolioTab({
    required this.positions,
    required this.closedToday,
    required this.closedAllTime,
    required this.realizedPnl,
    required this.isLoading,
    required this.onBuy,
    required this.onSell,
  });

  @override
  State<_PortfolioTab> createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<_PortfolioTab> {
  StreamSubscription? _sub;
  bool _showTodayOnly = true;

  List<DemoClosedPositionModel> get _visibleClosed =>
      _showTodayOnly ? widget.closedToday : widget.closedAllTime;

  double get _visibleRealizedPnl =>
      _visibleClosed.fold(0.0, (s, c) => s + c.pnl);

  @override
  void initState() {
    super.initState();
    _subscribeAll();
    // Rebuild total P&L whenever any live price changes
    _sub = LivePriceService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(_PortfolioTab old) {
    super.didUpdateWidget(old);
    // Re-subscribe if positions list changed (e.g. after sell)
    if (old.positions != widget.positions) _subscribeAll();
  }

  void _subscribeAll() {
    if (widget.positions.isEmpty) return;
    LivePriceService.instance.subscribe(
      widget.positions
          .map((p) => {
                'ExchangeSegment': _mapSeg(p.exchangeSegment),
                'SecurityId': p.securityId,
              })
          .toList(),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  double get _totalPnl => widget.positions.fold(0.0, (sum, p) {
        double ltp = LivePriceService.instance.priceOf(p.securityId);
        if (ltp <= 0) ltp = LivePriceService.instance.lastSeenPriceOf(p.securityId);
        if (ltp <= 0) ltp = p.avgBuyPrice;
        return sum + (ltp - p.avgBuyPrice) * p.netQuantity;
      });

  Widget _dateToggleChip(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showTodayOnly = label == 'Today'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.semiBold.copyWith(
            color: active ? Colorz.textColor : Colorz.hintTextColor,
            fontSize: SizeConfig.smallerFont,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasOpen   = widget.positions.isNotEmpty;
    final visibleClosed = _visibleClosed;
    final hasClosed = widget.closedToday.isNotEmpty;

    if (widget.isLoading && !hasOpen && !hasClosed) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A73E8)));
    }

    final unrealizedPnl      = _totalPnl;
    final isUnrealizedProfit = unrealizedPnl >= 0;
    final realizedPnl        = _visibleRealizedPnl;
    final isRealizedProfit   = realizedPnl >= 0;

    return ListView(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween * 2, vertical: 4),
      children: [
        // ── Closed positions section ───────────────────────────────────────
        if (hasClosed) ...[
          // Today / All-time toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Closed Positions',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.smallFont)),
              Container(
                decoration: BoxDecoration(
                  color: Colorz.bottomPillBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dateToggleChip('Today', _showTodayOnly),
                    _dateToggleChip('All Time', !_showTodayOnly),
                  ],
                ),
              ),
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          // Realized P&L summary card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (isRealizedProfit ? const Color(0xFF00C896) : Colorz.redColor)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isRealizedProfit ? const Color(0xFF00C896) : Colorz.redColor)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_showTodayOnly ? "Today's" : "All-time"} Realized P&L',
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.textColor,
                            fontSize: SizeConfig.smallFont)),
                    Text('${visibleClosed.length} position${visibleClosed.length != 1 ? 's' : ''} closed',
                        style: AppTextStyles.medium.copyWith(
                            color: Colorz.hintTextColor,
                            fontSize: SizeConfig.smallerFont)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.toll_rounded,
                        size: 14,
                        color: isRealizedProfit
                            ? const Color(0xFF00C896)
                            : Colorz.redColor),
                    const SizedBox(width: 4),
                    Text(
                      '${isRealizedProfit ? '+' : ''}${realizedPnl.toStringAsFixed(0)} coins',
                      style: AppTextStyles.semiBold.copyWith(
                        color: isRealizedProfit
                            ? const Color(0xFF00C896)
                            : Colorz.redColor,
                        fontSize: SizeConfig.mediumFont,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          if (visibleClosed.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween),
              child: Text('No closed positions today',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallFont)),
            )
          else ...[
            ...visibleClosed.map((cp) => _ClosedPositionRow(closed: cp)),
          ],
          Divider(color: Colorz.dividerColor, thickness: 1.5),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
        ],

        // ── Open positions header + unrealized P&L ────────────────────
        if (hasOpen) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (isUnrealizedProfit ? Colorz.greenColor : Colorz.redColor)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isUnrealizedProfit ? Colorz.greenColor : Colorz.redColor)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Open Positions (Unrealized)',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.smallFont)),
                Row(
                  children: [
                    Icon(Icons.toll_rounded,
                        size: 14,
                        color: isUnrealizedProfit
                            ? Colorz.greenColor
                            : Colorz.redColor),
                    const SizedBox(width: 4),
                    Text(
                      '${isUnrealizedProfit ? '+' : ''}${unrealizedPnl.toStringAsFixed(0)} coins',
                      style: AppTextStyles.semiBold.copyWith(
                        color: isUnrealizedProfit
                            ? Colorz.greenColor
                            : Colorz.redColor,
                        fontSize: SizeConfig.smallFont,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          // ── Open position rows ─────────────────────────────────────
          ...List.generate(widget.positions.length, (i) => Column(
            children: [
              _PositionRow(
                position: widget.positions[i],
                onBuy: () => widget.onBuy(widget.positions[i]),
                onSell: () => widget.onSell(widget.positions[i]),
              ),
              if (i < widget.positions.length - 1)
                Divider(color: Colorz.dividerColor, thickness: 1),
            ],
          )),
        ],

        // ── Empty state (no open, no closed) ─────────────────────────
        if (!hasOpen && !hasClosed)
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 56, color: Colorz.hintTextColor),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                  Text('No positions yet',
                      style: AppTextStyles.semiBold.copyWith(
                          fontSize: SizeConfig.headerThreeFont,
                          color: Colorz.textColor)),
                  SizeConfig.verticalSpace(height: 6),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.spaceBetween * 3),
                    child: Text(
                      'Buy stocks in demo mode to see your portfolio here',
                      style: AppTextStyles.medium
                          .copyWith(color: Colorz.hintTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Single position row with live P&L and Sell button ────────────────────────
class _PositionRow extends StatefulWidget {
  final DemoPositionModel position;
  final VoidCallback onBuy;
  final VoidCallback onSell;
  const _PositionRow({required this.position, required this.onBuy, required this.onSell});

  @override
  State<_PositionRow> createState() => _PositionRowState();
}

class _PositionRowState extends State<_PositionRow> {
  double _ltp = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // Try live price → cached last-seen price → fall back to avg
    _ltp = LivePriceService.instance.priceOf(widget.position.securityId);
    if (_ltp <= 0) {
      _ltp = LivePriceService.instance
          .lastSeenPriceOf(widget.position.securityId);
    }
    _sub = LivePriceService.instance.stream.listen((prices) {
      final p = prices[widget.position.securityId];
      if (p != null && p > 0 && mounted) setState(() => _ltp = p);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ltp      = _ltp > 0 ? _ltp : widget.position.avgBuyPrice;
    final pnl      = (ltp - widget.position.avgBuyPrice) * widget.position.netQuantity;
    final pnlPct   = widget.position.avgBuyPrice > 0
        ? ((ltp - widget.position.avgBuyPrice) / widget.position.avgBuyPrice) * 100
        : 0.0;
    final isProfit = pnl >= 0;

    return GestureDetector(
      onTap: widget.onBuy,
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: symbol + details ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.position.tradingSymbol,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.smallFont),
                ),
                SizeConfig.verticalSpace(height: 3),
                Text(
                  'Qty: ${widget.position.netQuantity}  •  Avg: ₹${widget.position.avgBuyPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont),
                ),
                SizeConfig.verticalSpace(height: 5),
                Row(
                  children: [
                    // LTP
                    Text(
                      'LTP: ${_ltp > 0 ? '₹${_ltp.toStringAsFixed(2)}' : '—'}',
                      style: AppTextStyles.medium.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.smallerFont),
                    ),
                    SizeConfig.horizontalSpace(width: 8),
                    // P&L pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isProfit
                                ? Colorz.greenColor
                                : Colorz.redColor)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${isProfit ? '+' : ''}${pnl.toStringAsFixed(0)}  (${pnlPct.toStringAsFixed(1)}%)',
                        style: AppTextStyles.medium.copyWith(
                          color: isProfit
                              ? Colorz.greenColor
                              : Colorz.redColor,
                          fontSize: SizeConfig.smallerFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),

          // ── Right: Sell button ────────────────────────────────────
          GestureDetector(
            onTap: widget.onSell,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colorz.redColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Sell',
                style: AppTextStyles.semiBold.copyWith(
                  color: Colors.white,
                  fontSize: SizeConfig.smallFont,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// ── Closed position row (sold today, shows realized P&L) ─────────────────────
class _ClosedPositionRow extends StatelessWidget {
  final DemoClosedPositionModel closed;
  const _ClosedPositionRow({required this.closed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 0.8),
      child: Row(
        children: [
          // ── S badge ────────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colorz.redColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('S',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.redColor,
                      fontSize: SizeConfig.mediumFont)),
            ),
          ),
          SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),

          // ── Symbol + qty ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(closed.tradingSymbol,
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.smallFont)),
                    ),
                    if (closed.isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('TODAY',
                            style: AppTextStyles.semiBold.copyWith(
                                color: const Color(0xFF1A73E8),
                                fontSize: 9)),
                      ),
                    ],
                  ],
                ),
                SizeConfig.verticalSpace(height: 3),
                Text(
                  'Qty: ${closed.qty}  •  Buy ₹${closed.avgBuyPrice.toStringAsFixed(2)}  →  Sell ₹${closed.avgSellPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont),
                ),
              ],
            ),
          ),

          // ── P&L pill ────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (closed.isProfit ? const Color(0xFF00C896) : Colorz.redColor)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${closed.isProfit ? '+' : ''}${closed.pnl.toStringAsFixed(0)}',
                  style: AppTextStyles.semiBold.copyWith(
                    color: closed.isProfit
                        ? const Color(0xFF00C896)
                        : Colorz.redColor,
                    fontSize: SizeConfig.smallFont,
                  ),
                ),
              ),
              SizeConfig.verticalSpace(height: 3),
              Text(
                '${closed.isProfit ? '+' : ''}${closed.pnlPercent.toStringAsFixed(1)}%',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallerFont),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Orders tab with Buy / Sell filter ────────────────────────────────────────
class _OrdersTab extends StatefulWidget {
  final List<DemoOrderModel> orders;
  final bool isLoading;
  final void Function(DemoOrderModel) onOrderTap;
  const _OrdersTab({required this.orders, required this.isLoading, required this.onOrderTap});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  // 'ALL' | 'BUY' | 'SELL'
  String _filter = 'ALL';
  // null = today only; non-null = specific past date picked
  DateTime? _selectedDate;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime? _parseDate(String s) {
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  List<DemoOrderModel> get _dateFiltered {
    final target = _selectedDate ?? DateTime.now();
    return widget.orders.where((o) {
      final d = _parseDate(o.createdAt);
      return d != null && _isSameDay(d, target);
    }).toList();
  }

  List<DemoOrderModel> get _filtered {
    final byDate = _dateFiltered;
    if (_filter == 'ALL') return byDate;
    return byDate.where((o) => o.transactionType == _filter).toList();
  }

  String get _dateLabel {
    final d = _selectedDate ?? DateTime.now();
    if (_isToday(d)) return 'Today';
    return '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)}';
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: Colorz.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date selector + BUY/ALL/SELL chips ───────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spaceBetween * 2),
          child: Row(
            children: [
              // Date chip
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colorz.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colorz.primary),
                      const SizedBox(width: 5),
                      Text(_dateLabel,
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.primary,
                              fontSize: SizeConfig.smallFont)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Row(children: _buildChips())),
            ],
          ),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

        // ── List / empty / loader ─────────────────────────────────────
        Expanded(
          child: widget.isLoading && widget.orders.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colorz.primary))
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 56, color: Colorz.hintTextColor),
                          SizeConfig.verticalSpace(
                              height: SizeConfig.spaceBetween),
                          Text(
                            'No orders on $_dateLabel',
                            style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.headerThreeFont,
                                color: Colorz.textColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                          vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colorz.dividerColor, thickness: 1),
                      itemBuilder: (_, i) =>
                          _DemoOrderRow(order: filtered[i], onTap: () => widget.onOrderTap(filtered[i])),
                    ),
        ),
      ],
    );
  }

  List<Widget> _buildChips() {
    return ['ALL', 'BUY', 'SELL'].map((f) {
      final active = _filter == f;
      final color  = f == 'BUY'
          ? Colorz.primary
          : f == 'SELL'
              ? Colorz.redColor
              : Colorz.textColor;
      return GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? color : Colorz.bottomPillBg,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            f,
            style: AppTextStyles.semiBold.copyWith(
              color: active ? Colors.white : Colorz.hintTextColor,
              fontSize: SizeConfig.smallFont,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ── Single order row ──────────────────────────────────────────────────────────
class _DemoOrderRow extends StatelessWidget {
  final DemoOrderModel order;
  final VoidCallback? onTap;
  const _DemoOrderRow({required this.order, this.onTap});

  Color get _statusColor =>
      order.isTraded ? Colorz.greenColor : Colorz.redColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 0.8),
      child: Row(
        children: [
          // ── B / S badge ─────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (order.isBuy ? Colorz.primary : Colorz.redColor)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                order.isBuy ? 'B' : 'S',
                style: AppTextStyles.semiBold.copyWith(
                  color: order.isBuy ? Colorz.primary : Colorz.redColor,
                  fontSize: SizeConfig.mediumFont,
                ),
              ),
            ),
          ),
          SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),

          // ── Symbol + type ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.tradingSymbol,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.smallFont),
                ),
                SizeConfig.verticalSpace(height: 3),
                Text(
                  '${order.orderType}  •  Qty: ${order.quantity}',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallFont),
                ),
              ],
            ),
          ),

          // ── Price + status badge ─────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.toll_rounded,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    order.price.toStringAsFixed(2),
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.smallFont),
                  ),
                ],
              ),
              SizeConfig.verticalSpace(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  order.orderStatus,
                  style: AppTextStyles.medium.copyWith(
                    color: _statusColor,
                    fontSize: SizeConfig.smallerFont,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
