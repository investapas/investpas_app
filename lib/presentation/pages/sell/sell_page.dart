import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:investapas/presentation/bloc/sell/sell_bloc.dart';
import 'package:investapas/presentation/bloc/sell/sell_state.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../Widgets/live_price_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/unified_trading_service.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../data/services/live_price_service.dart';
import '../../../core/services/demo_mode_service.dart';
import '../../../routes/appRoutes.dart';
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/sell/sell_event.dart';
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/trading_terminal/terminal_state.dart';

class SellPage extends StatefulWidget {
  final String? name;
  final int? quantity;
  final String? securityId;
  final String? exchangeSegment;
  final int? lotSize;
  const SellPage({super.key, this.name, this.quantity, this.securityId, this.exchangeSegment, this.lotSize});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final SharedPrefsHelper _prefs = SharedPrefsHelper();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _initLotSize();
    _subscribeLivePrice();
  }

  /// Subscribe this security to the Dhan WebSocket so live price flows in
  /// before the user presses Sell.
  void _subscribeLivePrice() {
    final secId = widget.securityId ?? '';
    final seg   = widget.exchangeSegment ?? '';
    if (secId.isEmpty) return;

    // Segment map mirrors TerminalBloc._mapSegment()
    const segMap = {
      'D': 'NSE_FNO',
      'E': 'NSE_EQ',
      'NSE_FNO': 'NSE_FNO',
      'BSE_FNO': 'BSE_FNO',
      'NSE_EQ':  'NSE_EQ',
      'BSE_EQ':  'BSE_EQ',
      'NSE_CURR': 'NSE_CURR',
      'MCX_COMM': 'MCX_COMM',
    };
    final mappedSeg = segMap[seg] ?? seg;

    LivePriceService.instance.subscribe([
      {'ExchangeSegment': mappedSeg, 'SecurityId': secId},
    ]);
  }

  Future<void> _loadToken() async {
    final token = await _prefs.getAccessToken() ?? '';
    if (mounted) setState(() => _accessToken = token);
  }

  Future<void> _initLotSize() async {
    int ls = widget.lotSize ?? 1;

    // If lotSize wasn't passed (comes from position page), fetch from instruments table
    if (ls <= 1 && (widget.securityId ?? '').isNotEmpty) {
      try {
        final resp = await ApiHelper.get(
            '${ApiEndpoints.lotSizeApi}?securityId=${widget.securityId}');
        if (resp != null && resp['status'] == true) {
          ls = (resp['data']?['lotSize'] as num?)?.toInt() ?? 1;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    // Set instrument lot size (e.g. 65 for NIFTY, 30 for BankNifty)
    if (ls > 1) context.read<SellBloc>().add(SetLotSize(ls));

    // Auto-fill lots from position quantity: qty=130, lotSize=65 → 2 lots
    final qty = widget.quantity ?? 0;
    final lotsHeld = ls > 1 ? (qty / ls).floor() : qty;
    if (lotsHeld > 0) context.read<SellBloc>().add(ChangeLots(lotsHeld > 0 ? lotsHeld : 1));
  }

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
          child: MultiBlocListener(
            listeners: [
              BlocListener<SellBloc, SellState>(
                listenWhen: (previous, current) =>
                    previous.isLoading && !current.isLoading,
                listener: (context, state) {
                  if (state.isSuccess) {
                    ToastHelper.showToast("Order placed successfully", isSuccess: true);
                    context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
                    context.read<TerminalBloc>().add(const ChangeTerminalSubViewEvent(TerminalSubView.positions));
                    context.read<TerminalBloc>().add(const LoadPortfolioEvent());
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
                  }
                  if (!state.isSuccess && state.message.isNotEmpty) {
                    ToastHelper.showToast(state.message, isSuccess: false);
                  }
                },
              ),
            ],
            child: BlocBuilder<SellBloc, SellState>(
            builder: (context, state) {

              return Container(
                margin: EdgeInsets.only(
                  top: 50.sp,
                  left: SizeConfig.spaceBetween * 2,
                  right: SizeConfig.spaceBetween * 2,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => NavigatorService.goBack(),
                        child: CircleWidget(
                          backgroundColor: Colorz.white,
                          child: Icon(Icons.arrow_back_rounded, color: Colorz.hintTextColor2),
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      Text(
                        widget.name ?? '',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.headerTwoFont,
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                      Row(
                        children: [
                          // Show held qty and derived lot count (uses state.lotSize which
                          // gets set after _initLotSize() fetches it from the API)
                          Text(
                            'Held: ${widget.quantity ?? 0} qty',
                            style: AppTextStyles.small.copyWith(
                                color: Colorz.hintTextColor),
                          ),
                          if (state.lotSize > 1) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${((widget.quantity ?? 0) / state.lotSize).floor()} lots × ${state.lotSize})',
                              style: AppTextStyles.small.copyWith(
                                  color: Colorz.hintTextColor),
                            ),
                          ],
                          const Spacer(),
                          Text("LTP  ",
                              style: AppTextStyles.small
                                  .copyWith(color: Colorz.hintTextColor)),
                          LivePriceWidget(
                            securityId: widget.securityId ?? '',
                            style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.redColor,
                              fontSize: SizeConfig.headerThreeFont,
                            ),
                          ),
                        ],
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween,
                          vertical: SizeConfig.spaceBetween * 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colorz.buyBgColor,
                          borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            quantityField(context, state),
                            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                            priceTypeSelector(context, state),
                            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                            state.priceType == PriceType.limit
                                ? priceField(context, state)
                                : Container(),
                            state.priceType == PriceType.limit
                                ? SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5)
                                : Container(),
                            productType(context, state),
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                      toggles(context, state),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.2),
                      Divider(color: Colorz.dividerColor),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
                      marginBox(context, state),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                      Button(
                        text: 'Sell',
                        isOutlined: false,
                        isBig: true,
                        radius: 100,
                        gradient: Colorz.sellButtonGradient,
                        onPressed: () {
                          if (_accessToken == null || _accessToken!.isEmpty) {
                            ToastHelper.showToast("Access token missing", isSuccess: false);
                            return;
                          }
                          if (state.lots == 0) {
                            ToastHelper.showToast("Please enter lots", isSuccess: false);
                            return;
                          }

                          final secId = widget.securityId ?? '';

                          // Validate: can't sell more than held quantity
                          final heldQty  = widget.quantity ?? 0;
                          final maxLots  = state.lotSize > 1
                              ? (heldQty / state.lotSize).floor()
                              : heldQty;
                          if (state.lots > maxLots) {
                            ToastHelper.showToast(
                              'Cannot sell more than held ($maxLots lots / $heldQty qty)',
                              isSuccess: false,
                            );
                            return;
                          }

                          // Read LTP — LivePriceService first, then TerminalBloc
                          double ltp = LivePriceService.instance.priceOf(secId);
                          if (ltp <= 0) {
                            ltp = context
                                    .read<TerminalBloc>()
                                    .state
                                    .livePrices[secId] ??
                                0.0;
                          }

                          if (ltp <= 0) {
                            ToastHelper.showToast(
                              "Live price not available yet — please wait a moment and try again",
                              isSuccess: false,
                            );
                            return;
                          }

                          // ── Demo mode: call demo API, skip Dhan ──────
                          if (DemoModeService.instance.isActive) {
                            // Capture navigator before async gap
                            final nav = Navigator.of(context);
                            UnifiedTradingService.sellOrder(
                              securityId: widget.securityId ?? '',
                              exchangeSegment: widget.exchangeSegment ?? '',
                              // Use state.quantity (actual qty = lots × lotSize)
                              quantity: state.quantity > 0 ? state.quantity : 1,
                              price: ltp,
                              orderType: state.price > 0 ? 'LIMIT' : 'MARKET',
                            ).then((result) {
                              if (!mounted) return;
                              if (result.status) {
                                ToastHelper.showToast(
                                    result.message.isNotEmpty
                                        ? result.message
                                        : 'Demo sell placed',
                                    isSuccess: true);
                                nav.pushNamedAndRemoveUntil(
                                  AppRoutes.demoPage,
                                  ModalRoute.withName(AppRoutes.homePage),
                                );
                              } else {
                                ToastHelper.showToast(result.message,
                                    isSuccess: false);
                              }
                            }).catchError((error) {
                              ToastHelper.showToast(error.toString(),
                                  isSuccess: false);
                            });
                            return;
                          }

                          // ── Live mode ─────────────────────────────────
                          context.read<SellBloc>().add(PlaceSellOrderEvent(
                            securityId: secId,
                            exchangeSegment: widget.exchangeSegment ?? '',
                            dhanAccessToken: _accessToken!,
                            livePrice: ltp,
                          ));
                        },
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                    ],
                  ),
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  Widget orderTypeSwitch(BuildContext context, SellState state) {
    final isLimit = state.orderType == OrderType.limit;

    return Container(
      height: 55,
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 0.5),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: isLimit ? 0 : null,
            right: isLimit ? null : 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width / 2 - (SizeConfig.spaceBetween * 2.6),
            child: Container(
              decoration: BoxDecoration(
                color: Colorz.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: OrderType.values.map((type) {
              final selected = state.orderType == type;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.read<SellBloc>().add(ChangeOrderType(type)),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: AppTextStyles.semiBold.copyWith(
                        color: selected ? Colorz.textColor : Colorz.hintTextColor,
                        fontSize: SizeConfig.largeFont,
                      ),
                      child: Text(type == OrderType.limit ? "Limit" : "Market"),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget quantityField(BuildContext context, SellState state) {
    final lotSize = state.lotSize;
    final totalQty = state.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: "Quantity" label + "1 lot = X qty" info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quantity",
              style: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.smallFont, color: Colorz.textColor),
            ),
            Text(
              "1 lot = $lotSize qty",
              style: AppTextStyles.medium.copyWith(
                  fontSize: SizeConfig.smallFont, color: Colorz.hintTextColor),
            ),
          ],
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.4),
        // Final total quantity shown prominently ABOVE the input field
        Text(
          "$totalQty",
          style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.headerTwoFont,
              color: Colorz.sellButtonColor),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
        // Input: user enters lot count
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.lots == 0 ? '' : state.lots.toString(),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium.copyWith(
                      fontSize: SizeConfig.largeFont, color: Colorz.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter lots',
                    hintStyle: AppTextStyles.medium.copyWith(
                        fontSize: SizeConfig.largeFont,
                        color: Colorz.hintTextColor),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.spaceBetween * 1.2),
                  ),
                  onChanged: (v) => context
                      .read<SellBloc>()
                      .add(ChangeLots(int.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.sellButtonColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.2,
                    vertical: SizeConfig.spaceBetween * 1.5),
                child: SvgPicture.asset(Assets.swapHorizontalSvg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget priceTypeSelector(BuildContext context, SellState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price Type", style: AppTextStyles.semiBold.copyWith(
          fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => context.read<SellBloc>().add(ChangePriceType(PriceType.market)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 1.2),
                  decoration: BoxDecoration(
                    color: state.priceType == PriceType.market ? Colorz.sellButtonColor : Colorz.white,
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                    border: Border.all(
                      color: state.priceType == PriceType.market
                          ? Colorz.sellButtonColor
                          : Colorz.newBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Market",
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.largeFont,
                        color: state.priceType == PriceType.market
                            ? Colorz.white
                            : Colorz.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
            Expanded(
              child: InkWell(
                onTap: () => context.read<SellBloc>().add(ChangePriceType(PriceType.limit)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 1.2),
                  decoration: BoxDecoration(
                    color: state.priceType == PriceType.limit ? Colorz.sellButtonColor : Colorz.white,
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                    border: Border.all(
                      color: state.priceType == PriceType.limit
                          ? Colorz.sellButtonColor
                          : Colorz.newBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Limit",
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.largeFont,
                        color: state.priceType == PriceType.limit
                            ? Colorz.white
                            : Colorz.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget priceField(BuildContext context, SellState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price", style: AppTextStyles.semiBold.copyWith(
          fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.price.toString(),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.largeFont, color: Colorz.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween * 1.2),
                  ),
                  onChanged: (v) =>
                      context.read<SellBloc>().add(ChangePrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.sellButtonColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween * 1.2,
                  vertical: SizeConfig.spaceBetween * 1.5,
                ),
                child: SvgPicture.asset(Assets.swapHorizontalSvg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget targetPriceField(BuildContext context, SellState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Target Price", style: AppTextStyles.semiBold.copyWith(
          fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.targetPrice.toString(),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.largeFont, color: Colorz.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween * 1.2),
                  ),
                  onChanged: (v) =>
                      context.read<SellBloc>().add(ChangeTargetPrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.sellButtonColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween * 1.2,
                  vertical: SizeConfig.spaceBetween * 1.5,
                ),
                child: SvgPicture.asset(Assets.swapHorizontalSvg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget stopLossPriceField(BuildContext context, SellState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Stop Loss Price", style: AppTextStyles.semiBold.copyWith(
          fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.stopLossPrice.toString(),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.largeFont, color: Colorz.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween * 1.2),
                  ),
                  onChanged: (v) =>
                      context.read<SellBloc>().add(ChangeStopLossPrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.sellButtonColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween * 1.2,
                  vertical: SizeConfig.spaceBetween * 1.5,
                ),
                child: SvgPicture.asset(Assets.swapHorizontalSvg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget trailingJumpField(BuildContext context, SellState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Trailing Jump", style: AppTextStyles.semiBold.copyWith(
          fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.trailingJump.toString(),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.largeFont, color: Colorz.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween * 1.2),
                  ),
                  onChanged: (v) =>
                      context.read<SellBloc>().add(ChangeTrailingJump(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.sellButtonColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween * 1.2,
                  vertical: SizeConfig.spaceBetween * 1.5,
                ),
                child: SvgPicture.asset(Assets.swapHorizontalSvg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget stopLossToggleField(BuildContext context, SellState state) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "Enable Stop Loss",
                style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.textColor, fontSize: SizeConfig.largeFont),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
              Icon(Icons.info_outline_rounded, color: Colorz.sellButtonColor, size: 18),
            ],
          ),
        ),
        FlutterSwitch(
          width: 50,
          height: 30,
          toggleSize: 22,
          value: state.stoplossEnabled,
          borderRadius: 15,
          padding: 4,
          toggleColor: Colorz.white,
          inactiveToggleColor: Colorz.lineColor,
          activeColor: Colorz.sellButtonColor,
          inactiveColor: Colorz.borderColor,
          onToggle: (val) => context.read<SellBloc>().add(ToggleStoploss()),
        ),
      ],
    );
  }

  Widget productType(BuildContext context, SellState state) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colorz.sellButtonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
            border: Border.all(color: Colorz.sellButtonColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colorz.sellButtonColor,
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colorz.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Intraday",
                style: AppTextStyles.medium.copyWith(color: Colorz.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget toggles(BuildContext context, SellState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    "Market Protection",
                    style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.largeFont),
                  ),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                  Icon(Icons.info_outline_rounded, color: Colorz.sellButtonColor),
                ],
              ),
            ),
            FlutterSwitch(
              width: 50,
              height: 30,
              toggleSize: 22,
              value: state.marketProtection,
              borderRadius: 15,
              padding: 4,
              toggleColor: Colorz.white,
              inactiveToggleColor: Colorz.lineColor,
              activeColor: Colorz.sellButtonColor,
              inactiveColor: Colorz.borderColor,
              onToggle: (val) => context.read<SellBloc>().add(ToggleMarketProtection()),
            ),
          ],
        ),
      ],
    );
  }

  Widget marginBox(BuildContext context, SellState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Help",
              style: AppTextStyles.small.copyWith(
                color: Colorz.sellButtonColor,
                fontSize: SizeConfig.mediumFont,
              ),
            ),
            InkWell(
              onTap: () => context.read<SellBloc>().add(ToggleAdvanced()),
              child: Row(
                children: [
                  Text(
                    "Advanced",
                    style: AppTextStyles.small.copyWith(
                      color: Colorz.sellButtonColor,
                      fontSize: SizeConfig.mediumFont,
                    ),
                  ),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: state.isAdvancedOpen ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colorz.sellButtonColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 50),
          crossFadeState: state.isAdvancedOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(),
          secondChild: Column(
            children: [
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
              InkWell(
                onTap: () => context.read<SellBloc>().add(ToggleAdvanced()),
                child: Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up_rounded, color: Colorz.textColor),
                    Text(
                      "Less",
                      style: AppTextStyles.small.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont,
                      ),
                    ),
                  ],
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween,
                  vertical: SizeConfig.spaceBetween * 1.5,
                ),
                decoration: BoxDecoration(
                  color: Colorz.sellNewBgColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Margin", style: AppTextStyles.small.copyWith(color: Colorz.textColor)),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.7),
                        Text(
                          "₹ ${state.margin.toStringAsFixed(0)} + ₹ ${state.charges.toStringAsFixed(2)}",
                          style: AppTextStyles.small.copyWith(color: Colorz.sellButtonColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Avail.", style: AppTextStyles.small.copyWith(color: Colorz.textColor)),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                        Text(
                          "₹ ${state.availableBalance.toStringAsFixed(2)}",
                          style: AppTextStyles.small.copyWith(color: Colorz.sellButtonColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
