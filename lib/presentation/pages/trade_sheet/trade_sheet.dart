import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Widgets/live_price_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/demo_mode_service.dart';
import '../../../core/services/unified_trading_service.dart';
import '../../../core/utils/app_dialog.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/market_item.dart';
import '../../../data/services/live_price_service.dart';
import '../../bloc/buy/buy_bloc.dart';
import '../../bloc/buy/buy_event.dart';
import '../../bloc/buy/buy_state.dart' as bs;
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/sell/sell_bloc.dart';
import '../../bloc/sell/sell_event.dart' as se;
import '../../bloc/sell/sell_state.dart' as ss;
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/trading_terminal/terminal_state.dart';
import '../../bloc/demo/demo_bloc.dart';
import '../../bloc/demo/demo_event.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../quick_unlock/quick_unlock_sheet.dart';

// ── Entry point ────────────────────────────────────────────────────────────────
class TradeSheet {
  static Future<void> show(
    BuildContext context, {
    required MarketItem item,
    bool isBuy = true,
    int? existingQty,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BuyBloc()),
          BlocProvider(create: (_) => SellBloc()),
        ],
        child: _TradeSheetContent(
          item: item,
          initialBuy: isBuy,
          existingQty: existingQty ?? 0,
        ),
      ),
    );
  }
}

// ── Sheet content ──────────────────────────────────────────────────────────────
class _TradeSheetContent extends StatefulWidget {
  final MarketItem item;
  final bool initialBuy;
  final int existingQty;

  const _TradeSheetContent({
    required this.item,
    required this.initialBuy,
    required this.existingQty,
  });

  @override
  State<_TradeSheetContent> createState() => _TradeSheetContentState();
}

class _TradeSheetContentState extends State<_TradeSheetContent> {
  late bool _isBuy;
  String _accessToken = '';
  bool _showAdvanced = false;
  bool _isLotSizeLoading = false;
  double _challengeCapital = 0;
  double _suggestedSL = 0;
  double _suggestedTarget = 0;
  String _riskInfo = '';
  // Demo-mode product type: INTRADAY | DELIVERY. Real trading is INTRADAY-only
  // today (see buy_page.dart's disabled productType picker), so this only
  // matters — and is only shown — when DemoModeService is active.
  _ProductType _productType = _ProductType.intraday;

  final _priceController    = TextEditingController();
  final _targetController   = TextEditingController();
  final _slController       = TextEditingController();
  final _trailingController = TextEditingController();
  final _lotsController     = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _isBuy = widget.initialBuy;
    _loadToken();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initBlocs());
  }

  Future<void> _loadToken() async {
    final t = await SharedPrefsHelper().getAccessToken() ?? '';
    if (mounted) setState(() => _accessToken = t);
  }

  void _initBlocs() {
    if (!mounted) return;
    final itemLotSize = int.tryParse(widget.item.lotSize) ?? 1;
    _applyLotSize(itemLotSize);
    _subscribeLivePrice();

    // If lot size wasn't provided (default 1), fetch the real value from backend.
    // Disable the Place Order button while loading to prevent premature submission.
    if (itemLotSize <= 1) {
      setState(() => _isLotSizeLoading = true);
      ApiHelper.get(
        '${ApiEndpoints.lotSizeApi}?securityId=${widget.item.securityId}',
      ).then((resp) {
        if (!mounted) return;
        final fetched = (resp['data']?['lotSize'] as num?)?.toInt() ?? 1;
        if (fetched > 1) _applyLotSize(fetched);
      }).catchError((_) {}).whenComplete(() {
        if (mounted) setState(() => _isLotSizeLoading = false);
      });
    }

    // For demo mode, fetch challenge capital to show in trade sheet
    if (DemoModeService.instance.isActive) {
      ApiHelper.get(ApiEndpoints.demoChallengeInfoApi).then((resp) {
        if (!mounted) return;
        final capital = (resp['data']?['tradingCapital'] as num?)?.toDouble() ?? 0;
        if (capital > 0) setState(() => _challengeCapital = capital);
      }).catchError((_) {});
    }

    // Fetch risk framework (suggested SL/TP) based on live price
    _fetchRiskFramework();
  }

  void _fetchRiskFramework() {
    final ltp = LivePriceService.instance.priceOf(widget.item.securityId);
    if (ltp <= 0) return;
    ApiHelper.get('${ApiEndpoints.challengeRiskFrameworkApi}?price=$ltp').then((resp) {
      if (!mounted || resp?['status'] != true || resp['data'] == null) return;
      final d = resp['data'];
      setState(() {
        _suggestedSL = (d['suggestedSL'] as num?)?.toDouble() ?? 0;
        _suggestedTarget = (d['suggestedTarget'] as num?)?.toDouble() ?? 0;
        _riskInfo = 'Risk ${d['riskPct']}% (₹${d['maxLossAmount']}) → Target ${d['targetPct']}% (₹${d['maxTargetAmount']})';
      });
    }).catchError((_) {});
  }

  void _applyLotSize(int lotSize) {
    context.read<BuyBloc>()
      ..add(ResetBuyState())
      ..add(SetLotSize(lotSize))
      ..add(ChangeLots(1));

    final initialSellLots = (!widget.initialBuy && widget.existingQty > 0 && lotSize > 0)
        ? (widget.existingQty / lotSize).round().clamp(1, 999999)
        : 1;
    context.read<SellBloc>()
      ..add(se.SetLotSize(lotSize))
      ..add(se.ChangeLots(initialSellLots));
  }

  void _subscribeLivePrice() {
    LivePriceService.instance.subscribe([
      {'ExchangeSegment': _mapSeg(widget.item.exchangeSegment),
       'SecurityId': widget.item.securityId},
    ]);
  }

  void _onToggle(bool isBuy) {
    setState(() {
      _isBuy = isBuy;
      _showAdvanced = false;
    });
    // Clear shared price controllers so the newly active form starts clean
    _priceController.clear();
    _targetController.clear();
    _slController.clear();
    _trailingController.clear();
    // Reset price fields in the bloc that is now active
    if (isBuy) {
      context.read<BuyBloc>().add(ChangePrice(0));
      context.read<BuyBloc>().add(ChangeTargetPrice(0));
      context.read<BuyBloc>().add(ChangeStopLossPrice(0));
      context.read<BuyBloc>().add(ChangeTrailingJump(0));
    } else {
      context.read<SellBloc>().add(se.ChangePrice(0));
      context.read<SellBloc>().add(se.ChangeTargetPrice(0));
      context.read<SellBloc>().add(se.ChangeStopLossPrice(0));
      context.read<SellBloc>().add(se.ChangeTrailingJump(0));
    }
  }

  String _mapSeg(String s) {
    const map = {
      'D': 'NSE_FNO', 'E': 'NSE_EQ',
      'NSE_FNO': 'NSE_FNO', 'BSE_FNO': 'BSE_FNO',
      'NSE_EQ': 'NSE_EQ',   'BSE_EQ': 'BSE_EQ',
      'IDX_I': 'IDX_I',
    };
    return map[s] ?? s;
  }

  String _getExSeg() => _mapSeg(widget.item.exchangeSegment);

  String _getIndex() {
    final n = widget.item.name.toUpperCase();
    if (n.contains('MIDCAPNIFTY')) return 'MIDCAPNIFTY';
    if (n.contains('BANKNIFTY'))   return 'BANKNIFTY';
    if (n.contains('FINNIFTY'))    return 'FINNIFTY';
    if (n.contains('SENSEX'))      return 'SENSEX';
    if (n.contains('BANKEX'))      return 'SENSEX';
    if (n.contains('NIFTY'))       return 'NIFTY';
    return 'NIFTY';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _targetController.dispose();
    _slController.dispose();
    _trailingController.dispose();
    _lotsController.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  void _submitBuy(BuildContext ctx) {
    final state = ctx.read<BuyBloc>().state;
    if (state.lots == 0) { AppSnackBar.showError(ctx, 'Please enter lots'); return; }

    if (DemoModeService.instance.isActive) {
      _demoBuy(ctx, state); return;
    }
    if (_accessToken.isEmpty) { AppSnackBar.showError(ctx, 'Access token missing'); return; }

    ctx.read<BuyBloc>().add(PlaceBuyOrderEvent(
      securityId:      widget.item.securityId,
      exchangeSegment: _getExSeg(),
      dhanAccessToken: _accessToken,
      index:           _getIndex(),
    ));
  }

  void _demoBuy(BuildContext ctx, bs.BuyState state) {
    final secId = widget.item.securityId;
    double ltp = LivePriceService.instance.priceOf(secId);
    if (ltp <= 0) ltp = ctx.read<TerminalBloc>().state.livePrices[secId] ?? 0;

    // Limit chip + Advanced target/SL filled → SUPER (unchanged definition).
    // Limit chip alone → LIMIT (previously dead code — this used to read
    // state.priceType, which nothing in this UI ever sets, so demo BUY could
    // never actually become LIMIT before this fix).
    final isSuper = state.orderType == bs.OrderType.limit &&
        (state.targetPrice > 0 || state.stopLossPrice > 0);
    final isLimit = state.orderType == bs.OrderType.limit && !isSuper;
    String type = 'MARKET';
    double execPrice = ltp;
    if (isSuper) {
      type = 'SUPER';
      execPrice = state.price > 0 ? state.price : ltp;
    } else if (isLimit) {
      if (state.price <= 0) {
        AppSnackBar.showError(ctx, 'Enter a valid limit price'); return;
      }
      type = 'LIMIT';
      execPrice = state.price; // the limit price — does not execute immediately
    }

    if (execPrice <= 0) { AppSnackBar.showError(ctx, 'Live price not available yet'); return; }

    final nav          = Navigator.of(ctx);
    final dashBloc     = ctx.read<DashBoardBloc>();
    final terminalBloc = ctx.read<TerminalBloc>();

    UnifiedTradingService.buyOrder(
      securityId:      secId,
      exchangeSegment: _getExSeg(),
      quantity:        state.quantity > 0 ? state.quantity : state.lots,
      price:           execPrice,
      orderType:       type,
      productType:     _productType == _ProductType.delivery ? 'DELIVERY' : 'INTRADAY',
      tradingSymbol:   widget.item.name,
      targetPrice:     isSuper ? state.targetPrice : null,
      stopLossPrice:   isSuper ? state.stopLossPrice : null,
    ).then((result) {
      if (!mounted) return;
      if (result.status) {
        nav.pop();
        dashBloc.add(const ChangeTabDashBoardEvent(1));
        terminalBloc
          ..add(const ChangeTerminalSubViewEvent(TerminalSubView.positions))
          ..add(const LoadPortfolioEvent());
        // Refresh demo orders list so the orders tab shows the new trade
        context.read<DemoBloc>().add(const LoadDemoOrders());
        AppSnackBar.showSuccess(context,
            result.message.isNotEmpty ? result.message : 'Demo order placed');
      } else if (result.challengeBlocked) {
        // Mirrors real trading: show Quick Unlock sheet for challenge blocks
        final dashState = context.read<DashBoardBloc>().state;
        final challengeCompleted = dashState.hasChallenge &&
            dashState.totalDays > 0 &&
            dashState.completedDays >= dashState.totalDays;
        if (challengeCompleted) {
          AppDialog.showChallengeCompleted(context);
        } else {
          QuickUnlockSheet.show(context,
              onUnlocked: () => context.read<WalletBloc>().add(const LoadWalletBalance()));
        }
      } else if (result.blockReason == 'QUANTITY_RULE') {
        AppDialog.showAlert(context,
            title: 'Quantity Limit Exceeded',
            message: result.message,
            buttonText: 'OK',
            isError: false);
      } else {
        AppSnackBar.showError(context, result.message);
      }
    });
  }

  void _submitSell(BuildContext ctx) {
    final state = ctx.read<SellBloc>().state;
    if (state.lots == 0) { AppSnackBar.showError(ctx, 'Please enter lots'); return; }

    if (DemoModeService.instance.isActive) {
      _demoSell(ctx, state); return;
    }
    if (_accessToken.isEmpty) { AppSnackBar.showError(ctx, 'Access token missing'); return; }

    final ltp = LivePriceService.instance.priceOf(widget.item.securityId);
    ctx.read<SellBloc>().add(se.PlaceSellOrderEvent(
      securityId:      widget.item.securityId,
      exchangeSegment: _getExSeg(),
      dhanAccessToken: _accessToken,
      livePrice:       ltp,
    ));
  }

  void _demoSell(BuildContext ctx, ss.SellState state) {
    final secId = widget.item.securityId;
    double ltp = LivePriceService.instance.priceOf(secId);
    if (ltp <= 0) ltp = ctx.read<TerminalBloc>().state.livePrices[secId] ?? 0;
    if (ltp <= 0) { AppSnackBar.showError(ctx, 'Live price not available yet'); return; }

    final isLimit = state.orderType == ss.OrderType.limit;
    if (isLimit && state.price <= 0) {
      AppSnackBar.showError(ctx, 'Enter a valid limit price'); return;
    }
    final execPrice = isLimit ? state.price : ltp;
    final sellOrderType = isLimit ? 'LIMIT' : 'MARKET';

    final nav = Navigator.of(ctx);

    UnifiedTradingService.sellOrder(
      securityId:      secId,
      exchangeSegment: _getExSeg(),
      quantity:        state.quantity > 0 ? state.quantity : state.lots,
      price:           execPrice,
      orderType:       sellOrderType,
      productType:     _productType == _ProductType.delivery ? 'DELIVERY' : 'INTRADAY',
      tradingSymbol:   widget.item.name,
    ).then((result) {
      if (!mounted) return;
      if (result.status) {
        AppSnackBar.showSuccess(context,
            result.message.isNotEmpty ? result.message : 'Demo sell placed');
        context.read<DemoBloc>().add(const LoadDemoOrders());
        nav.pop();
      } else {
        AppSnackBar.showError(context, result.message);
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BuyBloc, bs.BuyState>(
          listenWhen: (p, c) =>
              p.isSuccess != c.isSuccess ||
              p.isBlocked != c.isBlocked ||
              p.message   != c.message,
          listener: (ctx, state) {
            if (state.isSuccess) {
              Navigator.of(ctx).pop();
              AppSnackBar.showSuccess(ctx, 'Buy order placed successfully');
              ctx.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
              ctx.read<TerminalBloc>()
                ..add(const ChangeTerminalSubViewEvent(TerminalSubView.positions))
                ..add(const LoadPortfolioEvent());
              return;
            }
            if (state.isBlocked) {
              if (state.blockRule != 'QUANTITY_RULE') {
                final dashState = ctx.read<DashBoardBloc>().state;
                final challengeCompleted = dashState.hasChallenge &&
                    dashState.totalDays > 0 &&
                    dashState.completedDays >= dashState.totalDays;
                if (challengeCompleted) {
                  AppDialog.showChallengeCompleted(ctx);
                } else {
                  QuickUnlockSheet.show(ctx,
                      onUnlocked: () => ctx.read<WalletBloc>().add(const LoadWalletBalance()));
                }
              } else {
                AppDialog.showAlert(ctx,
                    title: 'Quantity Limit Exceeded',
                    message: state.blockMessage,
                    buttonText: 'OK',
                    isError: false);
              }
              return;
            }
            if (!state.isLoading && !state.isSuccess && !state.isBlocked &&
                state.message.isNotEmpty) {
              AppSnackBar.showError(ctx, state.message);
            }
          },
        ),
        BlocListener<SellBloc, ss.SellState>(
          listenWhen: (p, c) => p.isSuccess != c.isSuccess || p.message != c.message,
          listener: (ctx, state) {
            if (state.isSuccess) {
              Navigator.of(ctx).pop();
              AppSnackBar.showSuccess(ctx, 'Sell order placed successfully');
              ctx.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
              ctx.read<TerminalBloc>()
                ..add(const ChangeTerminalSubViewEvent(TerminalSubView.positions))
                ..add(const LoadPortfolioEvent());
              return;
            }
            if (!state.isLoading && !state.isSuccess && state.message.isNotEmpty) {
              AppSnackBar.showError(ctx, state.message);
            }
          },
        ),
      ],
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Drag handle ────────────────────────────────────────────────────────────
  Widget _buildHandle() => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Center(
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colorz.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        decoration: const BoxDecoration(
          color: Colorz.backgroundColor2,
          border: Border(bottom: BorderSide(color: Colorz.dividerColor, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          children: [
            // Stock info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.mediumFont,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    _exchangeBadge(widget.item.exchange),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colorz.backgroundColor1,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Lot ${widget.item.lotSize}',
                        style: AppTextStyles.medium.copyWith(
                            color: Colorz.primary,
                            fontSize: SizeConfig.smallerFont),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            // LTP column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('LTP',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.smallerFont)),
                const SizedBox(height: 2),
                LivePriceWidget(
                  securityId: widget.item.securityId,
                  style: AppTextStyles.semiBold.copyWith(
                    color: _isBuy ? Colorz.greenColor : Colorz.sellButtonColor,
                    fontSize: SizeConfig.largeFont,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Toggle
            _BuySellToggle(
              isBuy: _isBuy,
              onChanged: _onToggle,
            ),
          ],
        ),
      );

  Widget _exchangeBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: Colorz.primaryButtonGradient,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: AppTextStyles.semiBold.copyWith(
                color: Colors.white, fontSize: SizeConfig.smallerFont)),
      );

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isBuy) {
      return BlocBuilder<BuyBloc, bs.BuyState>(
        builder: (ctx, state) {
          final orderType = state.orderType == bs.OrderType.market
              ? _TradeOrderType.market
              : _TradeOrderType.limit;
          return _TradeForm(
            isBuy:            true,
            orderType:        orderType,
            productType:      _productType,
            onProductType:    (t) => setState(() => _productType = t),
            lots:             state.lots,
            lotSize:          state.lotSize,
            quantity:         state.quantity,
            price:            state.price,
            targetPrice:      state.targetPrice,
            stopLoss:         state.stopLossPrice,
            trailing:         state.trailingJump,
            isLoading:        state.isLoading || _isLotSizeLoading,
            margin:           state.margin,
            available:        state.availableBalance,
            isMarginLoad:     state.isMarginLoading,
            showAdvanced:     _showAdvanced,
            challengeCapital: _challengeCapital,
            riskInfo:         _riskInfo,
            lotsController:     _lotsController,
            priceController:    _priceController,
            targetController:   _targetController,
            slController:       _slController,
            trailingController: _trailingController,
            onOrderType: (t) => ctx.read<BuyBloc>().add(ChangeOrderType(
                t == _TradeOrderType.market ? bs.OrderType.market : bs.OrderType.limit)),
            onLots: (l) {
              ctx.read<BuyBloc>().add(ChangeLots(l));
              if (l > 0 && _accessToken.isNotEmpty) {
                ctx.read<BuyBloc>().add(FetchMarginEvent(
                  dhanAccessToken: _accessToken,
                  securityId:      widget.item.securityId,
                  exchangeSegment: _getExSeg(),
                ));
              }
            },
            onPrice:          (p) => ctx.read<BuyBloc>().add(ChangePrice(p)),
            onTarget:         (p) => ctx.read<BuyBloc>().add(ChangeTargetPrice(p)),
            onStopLoss:       (p) => ctx.read<BuyBloc>().add(ChangeStopLossPrice(p)),
            onTrailing:       (p) => ctx.read<BuyBloc>().add(ChangeTrailingJump(p)),
            onToggleAdvanced: () => setState(() => _showAdvanced = !_showAdvanced),
            onSubmit:         () => _submitBuy(ctx),
          );
        },
      );
    }

    return BlocBuilder<SellBloc, ss.SellState>(
      builder: (ctx, state) {
        final orderType = state.orderType == ss.OrderType.market
            ? _TradeOrderType.market
            : _TradeOrderType.limit;
        return _TradeForm(
          isBuy:            false,
          orderType:        orderType,
          productType:      _productType,
          onProductType:    (t) => setState(() => _productType = t),
          lots:             state.lots,
          lotSize:          state.lotSize,
          quantity:         state.quantity,
          price:            state.price,
          targetPrice:      state.targetPrice,
          stopLoss:         state.stopLossPrice,
          trailing:         state.trailingJump,
          isLoading:        state.isLoading || _isLotSizeLoading,
          margin:           state.margin,
          available:        state.availableBalance,
          isMarginLoad:     false,
          showAdvanced:     _showAdvanced,
          challengeCapital: _challengeCapital,
          riskInfo:         _riskInfo,
          lotsController:     _lotsController,
          priceController:    _priceController,
          targetController:   _targetController,
          slController:       _slController,
          trailingController: _trailingController,
          onOrderType: (t) => ctx.read<SellBloc>().add(se.ChangeOrderType(
              t == _TradeOrderType.market ? ss.OrderType.market : ss.OrderType.limit)),
          onLots:           (l) => ctx.read<SellBloc>().add(se.ChangeLots(l)),
          onPrice:          (p) => ctx.read<SellBloc>().add(se.ChangePrice(p)),
          onTarget:         (p) => ctx.read<SellBloc>().add(se.ChangeTargetPrice(p)),
          onStopLoss:       (p) => ctx.read<SellBloc>().add(se.ChangeStopLossPrice(p)),
          onTrailing:       (p) => ctx.read<SellBloc>().add(se.ChangeTrailingJump(p)),
          onToggleAdvanced: () => setState(() => _showAdvanced = !_showAdvanced),
          onSubmit:         () => _submitSell(ctx),
        );
      },
    );
  }
}

// ── Order type enum (local, avoids buy/sell enum conflict) ─────────────────────
enum _TradeOrderType { market, limit }

// ── Product type (demo mode only — real trading is INTRADAY-only today) ────────
enum _ProductType { intraday, delivery }

// ── Trade form ─────────────────────────────────────────────────────────────────
class _TradeForm extends StatelessWidget {
  final bool isBuy;
  final _TradeOrderType orderType;
  final _ProductType productType;
  final ValueChanged<_ProductType> onProductType;
  final int lots;
  final int lotSize;
  final int quantity;
  final double price;
  final double targetPrice;
  final double stopLoss;
  final double trailing;
  final bool isLoading;
  final double margin;
  final double available;
  final bool isMarginLoad;
  final bool showAdvanced;
  final double challengeCapital;
  final String riskInfo;
  final TextEditingController lotsController;
  final TextEditingController priceController;
  final TextEditingController targetController;
  final TextEditingController slController;
  final TextEditingController trailingController;
  final ValueChanged<_TradeOrderType> onOrderType;
  final ValueChanged<int> onLots;
  final ValueChanged<double> onPrice;
  final ValueChanged<double> onTarget;
  final ValueChanged<double> onStopLoss;
  final ValueChanged<double> onTrailing;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onSubmit;

  const _TradeForm({
    required this.isBuy,
    required this.orderType,
    required this.productType,
    required this.onProductType,
    required this.lots,
    required this.lotSize,
    required this.quantity,
    required this.price,
    required this.targetPrice,
    required this.stopLoss,
    required this.trailing,
    required this.isLoading,
    required this.margin,
    required this.available,
    required this.isMarginLoad,
    required this.showAdvanced,
    this.challengeCapital = 0,
    this.riskInfo = '',
    required this.lotsController,
    required this.priceController,
    required this.targetController,
    required this.slController,
    required this.trailingController,
    required this.onOrderType,
    required this.onLots,
    required this.onPrice,
    required this.onTarget,
    required this.onStopLoss,
    required this.onTrailing,
    required this.onToggleAdvanced,
    required this.onSubmit,
  });

  bool get _isLimit => orderType == _TradeOrderType.limit;

  // Buy uses app primary gradient; sell uses sell gradient
  LinearGradient get _buttonGradient =>
      isBuy ? Colorz.primaryButtonGradient : Colorz.sellButtonGradient;

  Color get _accentColor =>
      isBuy ? Colorz.primary : Colorz.sellButtonColor;

  Color get _lightBg =>
      isBuy ? Colorz.backgroundColor2 : Colorz.sellNewBgColor;

  @override
  Widget build(BuildContext context) {
    final isDemo = DemoModeService.instance.isActive;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Market / Limit ─────────────────────────────────────────────────
          _OrderTypeRow(
            selected: orderType,
            isBuy: isBuy,
            onChanged: onOrderType,
          ),
          const SizedBox(height: 16),

          // ── Delivery / Intraday (demo mode only — real trading is
          // INTRADAY-only today, see buy_page.dart's disabled picker) ────────
          if (isDemo) ...[
            _ProductTypeRow(
              selected: productType,
              isBuy: isBuy,
              onChanged: onProductType,
            ),
            const SizedBox(height: 16),
          ],

          // ── Lots stepper ───────────────────────────────────────────────────
          _LotsStepper(
            lots:       lots,
            lotSize:    lotSize,
            quantity:   quantity,
            isBuy:      isBuy,
            controller: lotsController,
            onChanged:  onLots,
          ),
          const SizedBox(height: 14),

          // ── Price field (Limit only) ───────────────────────────────────────
          if (_isLimit) ...[
            _InputField(
              label:      'Price',
              controller: priceController,
              hint:       price > 0 ? price.toStringAsFixed(2) : '0.00',
              onChanged:  onPrice,
              isBuy:      isBuy,
            ),
            if (isDemo && price > 0) ...[
              const SizedBox(height: 6),
              Text(
                isBuy
                    ? 'Stays pending until price reaches ₹${price.toStringAsFixed(2)} or below'
                    : 'Stays pending until price reaches ₹${price.toStringAsFixed(2)} or above',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont),
              ),
            ],
            const SizedBox(height: 14),
          ],

          // ── Advanced toggle ────────────────────────────────────────────────
          GestureDetector(
            onTap: onToggleAdvanced,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _lightBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _accentColor.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(children: [
                Icon(
                  showAdvanced
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _accentColor, size: 16,
                ),
                const SizedBox(width: 6),
                Text('Target / Stop Loss',
                    style: AppTextStyles.medium.copyWith(
                        color: _accentColor,
                        fontSize: SizeConfig.smallFont)),
                const Spacer(),
                Text(showAdvanced ? 'Hide' : 'Show',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.smallerFont)),
              ]),
            ),
          ),

          // ── Advanced fields ────────────────────────────────────────────────
          if (showAdvanced) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _InputField(
                label: 'Target', controller: targetController,
                hint: targetPrice > 0 ? targetPrice.toStringAsFixed(2) : '0.00',
                onChanged: onTarget, isBuy: isBuy,
              )),
              const SizedBox(width: 10),
              Expanded(child: _InputField(
                label: 'Stop Loss', controller: slController,
                hint: stopLoss > 0 ? stopLoss.toStringAsFixed(2) : '0.00',
                onChanged: onStopLoss, isBuy: isBuy,
              )),
            ]),
            const SizedBox(height: 10),
            _InputField(
              label: 'Trailing Jump', controller: trailingController,
              hint: trailing > 0 ? trailing.toStringAsFixed(2) : '0.00',
              onChanged: onTrailing, isBuy: isBuy,
            ),
          ],

          const SizedBox(height: 16),

          // ── Footer row ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colorz.backgroundColor2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colorz.dividerColor),
            ),
            child: Row(children: [
              // Intraday pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: Colorz.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Intraday',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.smallerFont)),
              ),
              const Spacer(),
              if (isDemo) ...[
                const Icon(Icons.toll_rounded, size: 13,
                    color: Colorz.primary),
                const SizedBox(width: 4),
                Text('${available.toStringAsFixed(0)} coins',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.smallFont)),
              ] else ...[
                if (isMarginLoad)
                  const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colorz.primary))
                else if (margin > 0) ...[
                  Text('Margin ',
                      style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallerFont)),
                  Text('₹${margin.toStringAsFixed(0)}',
                      style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.smallFont)),
                  const SizedBox(width: 10),
                ],
                Text('Avail ',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.smallerFont)),
                Text('₹${available.toStringAsFixed(0)}',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.smallFont)),
              ],
            ]),
          ),
          const SizedBox(height: 10),

          // ── Challenge capital (demo mode only) ─────────────────────────────
          if (isDemo && challengeCapital > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colorz.backgroundColor2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colorz.primary.withValues(alpha: 0.25), width: 1),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 13, color: Colorz.primary),
                const SizedBox(width: 6),
                Text('Challenge Capital',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.smallerFont)),
                const Spacer(),
                Text('₹${challengeCapital.toStringAsFixed(0)}',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.smallFont)),
              ]),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 4),

          // ── Risk framework info ──────────────────────────────────────────
          if (riskInfo.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.shield_outlined, size: 13, color: Colors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(riskInfo,
                      style: AppTextStyles.medium.copyWith(
                          color: const Color(0xFF6D4C00),
                          fontSize: SizeConfig.smallerFont)),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          // ── Submit button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isLoading
                    ? null
                    : _buttonGradient,
                color: isLoading ? Colorz.hintTextColor.withValues(alpha: 0.3) : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading ? [] : [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isBuy
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: Colors.white, size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBuy ? 'Place Buy Order' : 'Place Sell Order',
                            style: AppTextStyles.semiBold.copyWith(
                              color: Colors.white,
                              fontSize: SizeConfig.mediumFont,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BUY / SELL toggle ──────────────────────────────────────────────────────────
class _BuySellToggle extends StatelessWidget {
  final bool isBuy;
  final ValueChanged<bool> onChanged;
  const _BuySellToggle({required this.isBuy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colorz.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('SELL', !isBuy, Colorz.sellButtonGradient, () => onChanged(false)),
          const SizedBox(width: 3),
          _tab('BUY',   isBuy, Colorz.primaryButtonGradient, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? gradient : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active ? [
            BoxShadow(
              color: (label == 'BUY' ? Colorz.primary : Colorz.sellButtonColor)
                  .withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(label,
            style: AppTextStyles.semiBold.copyWith(
              color: active ? Colors.white : Colorz.hintTextColor,
              fontSize: SizeConfig.smallFont,
            )),
      ),
    );
  }
}

// ── Market / Limit chips ───────────────────────────────────────────────────────
class _OrderTypeRow extends StatelessWidget {
  final _TradeOrderType selected;
  final bool isBuy;
  final ValueChanged<_TradeOrderType> onChanged;
  const _OrderTypeRow({
    required this.selected, required this.isBuy, required this.onChanged});

  Color get _active => isBuy ? Colorz.primary : Colorz.sellButtonColor;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _chip(_TradeOrderType.market, 'Market'),
      const SizedBox(width: 8),
      _chip(_TradeOrderType.limit, 'Limit'),
    ]);
  }

  Widget _chip(_TradeOrderType type, String label) {
    final active = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _active : Colorz.backgroundColor2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? _active : Colorz.textFieldBorderColor,
              width: 1.5),
          boxShadow: active ? [
            BoxShadow(
              color: _active.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(label,
            style: AppTextStyles.semiBold.copyWith(
              color: active ? Colors.white : Colorz.hintTextColor,
              fontSize: SizeConfig.smallFont,
            )),
      ),
    );
  }
}

// ── Delivery / Intraday chips (demo mode) — same pattern as _OrderTypeRow ──────
class _ProductTypeRow extends StatelessWidget {
  final _ProductType selected;
  final bool isBuy;
  final ValueChanged<_ProductType> onChanged;
  const _ProductTypeRow({
    required this.selected, required this.isBuy, required this.onChanged});

  Color get _active => isBuy ? Colorz.primary : Colorz.sellButtonColor;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _chip(_ProductType.intraday, 'Intraday'),
      const SizedBox(width: 8),
      _chip(_ProductType.delivery, 'Delivery'),
    ]);
  }

  Widget _chip(_ProductType type, String label) {
    final active = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _active : Colorz.backgroundColor2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? _active : Colorz.textFieldBorderColor,
              width: 1.5),
          boxShadow: active ? [
            BoxShadow(
              color: _active.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(label,
            style: AppTextStyles.semiBold.copyWith(
              color: active ? Colors.white : Colorz.hintTextColor,
              fontSize: SizeConfig.smallFont,
            )),
      ),
    );
  }
}

// ── Lots stepper ───────────────────────────────────────────────────────────────
class _LotsStepper extends StatelessWidget {
  final int lots;
  final int lotSize;
  final int quantity;
  final bool isBuy;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  const _LotsStepper({
    required this.lots,
    required this.lotSize,
    required this.quantity,
    required this.isBuy,
    required this.controller,
    required this.onChanged,
  });

  Color get _accent => isBuy ? Colorz.primary : Colorz.sellButtonColor;

  @override
  Widget build(BuildContext context) {
    final text = lots > 0 ? lots.toString() : '';
    if (controller.text != text) {
      controller.value = controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return Row(
      children: [
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lots',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallFont)),
            const SizedBox(height: 2),
            Text('Qty: $quantity  •  1 lot = $lotSize',
                style: AppTextStyles.semiBold.copyWith(
                    color: _accent,
                    fontSize: SizeConfig.smallFont)),
          ],
        ),
        const Spacer(),
        // Stepper control
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colorz.textFieldBorderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _btn(Icons.remove_rounded,
                  () => onChanged((lots - 1).clamp(0, 9999)),
                  lots <= 0),
              Container(
                width: 1, height: 36,
                color: Colorz.dividerColor,
              ),
              SizedBox(
                width: 56,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.mediumFont),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
                ),
              ),
              Container(
                width: 1, height: 36,
                color: Colorz.dividerColor,
              ),
              _btn(Icons.add_rounded, () => onChanged(lots + 1), false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool disabled) =>
      GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          width: 40, height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: disabled
                ? Colorz.backgroundColor2
                : _accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: disabled ? Colorz.hintTextColor : _accent,
              size: 18),
        ),
      );
}

// ── Price input field ──────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<double> onChanged;
  final bool isBuy;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.isBuy,
  });

  Color get _accent => isBuy ? Colorz.primary : Colorz.sellButtonColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.medium.copyWith(
                color: Colorz.hintTextColor,
                fontSize: SizeConfig.smallFont)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colorz.backgroundColor2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colorz.textFieldBorderColor, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            style: AppTextStyles.semiBold.copyWith(
                color: Colorz.textColor,
                fontSize: SizeConfig.mediumFont),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.mediumFont),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.currency_rupee_rounded,
                    size: 14, color: _accent),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            onChanged: (v) => onChanged(double.tryParse(v) ?? 0.0),
          ),
        ),
      ],
    );
  }
}
