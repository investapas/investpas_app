import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:investapas/presentation/bloc/buy/buy_bloc.dart';
import 'package:investapas/presentation/bloc/buy/buy_state.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../Widgets/live_price_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/utils/app_dialog.dart';
import '../../../data/models/market_item.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../quick_unlock/quick_unlock_sheet.dart';
import '../../../core/services/demo_mode_service.dart';
import '../../../data/services/live_price_service.dart';
import '../../../core/services/unified_trading_service.dart';
import '../../../routes/appRoutes.dart';
import '../../bloc/buy/buy_event.dart';
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/trading_terminal/terminal_state.dart';

class BuyPage extends StatefulWidget {
  final MarketItem? marketItem;
  const BuyPage({super.key,this.marketItem});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {

  final SharedPrefsHelper prefs = SharedPrefsHelper();
  String? accessToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyBloc>().add(ResetBuyState());
    });
    getPrefsData();
  }

  getPrefsData() async {
    final aToken = await prefs.getAccessToken() ?? '';
    setState(() {
      accessToken = aToken;
    });

    // Subscribe this stock for live price
    if (widget.marketItem != null && mounted) {
      context.read<TerminalBloc>().add(
        SubscribeAdditionalItemsEvent([widget.marketItem!]),
      );
    }

    print("token $accessToken");

    print(widget.marketItem!.name);
    print(widget.marketItem!.exchangeSegment);
    print(widget.marketItem!.exchange);
    print(widget.marketItem!.symbol);
    print(widget.marketItem!.securityId);


    print("Market ITem ${widget.marketItem} ${widget.marketItem!.name} ${widget
        .marketItem!.symbol} ${widget.marketItem!.exchangeSegment} ${widget
        .marketItem!.exchange}");
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        // body: SafeArea(
        //   top: false,
        //   bottom: false,
        //   child: BlocBuilder<BuyBloc, BuyState>(
        //       builder: (context, state) {
        //         // Initialize lot size on first build
        //         if (state.lotSize == 1 && widget.marketItem?.lotSize != null) {
        //           final initialLotSize = int.tryParse(
        //               widget.marketItem!.lotSize) ?? 1;
        //           if (initialLotSize != state.lotSize) {
        //             context.read<BuyBloc>().add(SetLotSize(initialLotSize));
        //           }
        //         }
        //
        //         if (!state.isLoading && state.message.isNotEmpty) {
        //           ToastHelper.showToast(state.message, isSuccess: false);
        //
        //           if (state.isSuccess) {
        //             print("ORDER ID: ${state.orderId}");
        //           }
        //         }
        //
        //         return Container(
        //           margin: EdgeInsets.only(
        //               top: 50.sp,
        //               left: SizeConfig.spaceBetween * 2,
        //               right: SizeConfig.spaceBetween * 2
        //           ),
        //           child: SingleChildScrollView(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 InkWell(
        //                   onTap: () {
        //                     NavigatorService.goBack();
        //                   },
        //                   child: CircleWidget(
        //                     backgroundColor: Colorz.white,
        //                     child: Icon(Icons.arrow_back_rounded,
        //                       color: Colorz.hintTextColor2,),
        //                   ),
        //                 ),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween),
        //                 Text(
        //                   widget.marketItem!.name,
        //                   style: AppTextStyles.semiBold.copyWith(color: Colorz
        //                       .textColor, fontSize: SizeConfig.headerTwoFont),
        //                 ),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 0.5),
        //                 Row(
        //                   children: [
        //                     Text(widget.marketItem!.exchange + " ",
        //                         style: AppTextStyles.small),
        //                     Text(widget.marketItem!.lotSize + " ",
        //                         style: AppTextStyles.small.copyWith(
        //                             color: Colorz.redColor)),
        //                     Text(
        //                         "-99.70 (-45.16%)", style: AppTextStyles.small),
        //                   ],
        //                 ),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 2),
        //                 orderTypeSwitch(context, state),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 2),
        //                 Container(
        //                   padding: EdgeInsets.symmetric(horizontal: SizeConfig
        //                       .spaceBetween, vertical: SizeConfig.spaceBetween *
        //                       1.5),
        //                   decoration: BoxDecoration(
        //                       color: Colorz.buyBgColor,
        //                       borderRadius: BorderRadius.circular(
        //                           SizeConfig.borderRadius)
        //                   ),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       quantityField(context, state),
        //                       SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5),
        //                       priceTypeSelector(context, state),
        //                       SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5),
        //                       state.priceType == PriceType.limit ? priceField(
        //                           context, state) : Container(),
        //                       state.priceType == PriceType.limit
        //                           ? SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5)
        //                           : Container(),
        //
        //                       // Limit Order - Additional fields
        //                       state.orderType == OrderType.limit
        //                           ? stopLossToggleField(context, state)
        //                           : Container(),
        //                       state.orderType == OrderType.limit
        //                           ? SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5)
        //                           : Container(),
        //                       state.orderType == OrderType.limit
        //                           ? targetPriceField(context, state)
        //                           : Container(),
        //                       state.orderType == OrderType.limit
        //                           ? SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5)
        //                           : Container(),
        //                       state.orderType == OrderType.limit &&
        //                           state.stoplossEnabled ? stopLossPriceField(
        //                           context, state) : Container(),
        //                       state.orderType == OrderType.limit &&
        //                           state.stoplossEnabled
        //                           ? SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 1.5)
        //                           : Container(),
        //                       state.orderType == OrderType.limit
        //                           ? trailingJumpField(context, state)
        //                           : Container(),
        //                       state.orderType == OrderType.limit
        //                           ? SizeConfig.verticalSpace(
        //                           height: SizeConfig.spaceBetween * 2)
        //                           : Container(),
        //                       productType(context, state),
        //                     ],
        //                   ),
        //                 ),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 2),
        //                 toggles(context, state),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 1.2),
        //                 Divider(color: Colorz.dividerColor,),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 1.5),
        //                 marginBox(context, state),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 2),
        //                 Button(
        //                   text: 'Buy',
        //                   isOutlined: false,
        //                   isBig: true,
        //                   radius: 100,
        //                   gradient: Colorz.primaryButtonGradient,
        //                   onPressed: () {
        //                     // final args = ModalRoute.of(context)?.settings.arguments;
        //                     // MarketItem? item;
        //                     // if (args != null && args is Map && args["stockData"] != null) {
        //                     //   item = args["stockData"] as MarketItem;
        //                     // }
        //                     //
        //                     // if (item == null) {
        //                     //   ToastHelper.showToast("Invalid stock data",isSuccess: false);
        //                     //   return;
        //                     // }
        //
        //                     if (accessToken == null || accessToken!.isEmpty) {
        //                       ToastHelper.showToast(
        //                           "Access token missing", isSuccess: false);
        //                       return;
        //                     }
        //
        //                     // Check for quantity validation errors
        //                     if (state.quantityValidationError.isNotEmpty) {
        //                       ToastHelper.showToast(
        //                           state.quantityValidationError,
        //                           isSuccess: false);
        //                       return;
        //                     }
        //
        //                     if (state.quantity == 0) {
        //                       ToastHelper.showToast(
        //                           "Please enter quantity", isSuccess: false);
        //                       return;
        //                     }
        //
        //                     context.read<BuyBloc>().add(
        //                       PlaceBuyOrderEvent(
        //                         securityId: widget.marketItem!.securityId ?? '',
        //                         exchangeSegment: mapExchangeSegment(
        //                             widget.marketItem!),
        //                         dhanAccessToken: accessToken!,
        //                         index: getIndexFromName(
        //                             widget.marketItem!.name),
        //                       ),
        //                     );
        //                   },
        //                 ),
        //                 SizeConfig.verticalSpace(
        //                     height: SizeConfig.spaceBetween * 2),
        //               ],
        //             ),
        //           ),
        //         );
        //       }
        //   ),
        // ),


        body: SafeArea(
          top: false,
          bottom: false,
          child: MultiBlocListener(
            listeners: [
              // ── Live order result ──────────────────────────────────────
              BlocListener<BuyBloc, BuyState>(
                listenWhen: (previous, current) =>
                    previous.isLoading != current.isLoading ||
                    previous.isBlocked != current.isBlocked ||
                    previous.isUnlocking != current.isUnlocking,
                listener: (context, state) {
                  // ✅ SUCCESS CASE
                  if (state.isSuccess) {
                    AppSnackBar.showSuccess(context, "Order placed successfully");
                    context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
                    context.read<TerminalBloc>().add(const ChangeTerminalSubViewEvent(TerminalSubView.positions));
                    context.read<TerminalBloc>().add(const LoadPortfolioEvent());
                    Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.homePage, (route) => false,
                    );
                  }
                  // 🔒 CHALLENGE BLOCKED
                  if (state.isBlocked) {
                    final canUnlock = state.blockRule != 'QUANTITY_RULE';
                    final dashState = context.read<DashBoardBloc>().state;
                    final challengeCompleted = dashState.hasChallenge &&
                        dashState.totalDays > 0 &&
                        dashState.completedDays >= dashState.totalDays;
                    if (canUnlock) {
                      if (challengeCompleted) {
                        AppDialog.showChallengeCompleted(context);
                      } else {
                        QuickUnlockSheet.show(
                          context,
                          onUnlocked: () => context.read<WalletBloc>().add(const LoadWalletBalance()),
                        );
                      }
                    } else {
                      AppDialog.showAlert(
                        context,
                        title: 'Quantity Limit Exceeded',
                        message: state.blockMessage,
                        buttonText: 'OK',
                        isError: false,
                      );
                    }
                  }
                  // ✅ UNLOCK SUCCESS
                  if (!state.isBlocked && !state.isUnlocking &&
                      state.message == 'Trading resumed! New session started.') {
                    AppSnackBar.showSuccess(context, "Trading resumed! New session started.");
                  }
                  // ❌ ERROR CASE
                  if (!state.isLoading && !state.isSuccess && !state.isBlocked &&
                      state.message.isNotEmpty &&
                      state.message != 'Trading resumed! New session started.') {
                    AppSnackBar.showError(context, state.message);
                  }
                },
              ),   // closes BlocListener<BuyBloc>
            ],
            child: BlocBuilder<BuyBloc, BuyState>(
              builder: (context, state) {
                return BlocBuilder<BuyBloc, BuyState>(
                    builder: (context, state) {
                      // Initialize lot size on first build
                      if (state.lotSize == 1 && widget.marketItem?.lotSize != null) {
                        final initialLotSize = int.tryParse(
                            widget.marketItem!.lotSize) ?? 1;
                        if (initialLotSize != state.lotSize) {
                          context.read<BuyBloc>().add(SetLotSize(initialLotSize));
                        }
                      }

                      return Container(
                        margin: EdgeInsets.only(
                            top: 50.sp,
                            left: SizeConfig.spaceBetween * 2,
                            right: SizeConfig.spaceBetween * 2
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  NavigatorService.goBack();
                                },
                                child: CircleWidget(
                                  backgroundColor: Colorz.white,
                                  child: Icon(Icons.arrow_back_rounded,
                                    color: Colorz.hintTextColor2,),
                                ),
                              ),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween),
                              Text(
                                widget.marketItem!.name,
                                style: AppTextStyles.semiBold.copyWith(color: Colorz
                                    .textColor, fontSize: SizeConfig.headerTwoFont),
                              ),
                              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                              Row(
                                children: [
                                  Text("${widget.marketItem!.exchange} ",
                                      style: AppTextStyles.small),
                                  Text("Lot: ${widget.marketItem!.lotSize}",
                                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor)),
                                  const Spacer(),
                                  // Live price
                                  Text("LTP  ", style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor)),
                                  LivePriceWidget(
                                    securityId: widget.marketItem!.securityId,
                                    style: AppTextStyles.semiBold.copyWith(
                                      color: Colorz.primary,
                                      fontSize: SizeConfig.headerThreeFont,
                                    ),
                                  ),
                                ],
                              ),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 2),
                              orderTypeSwitch(context, state),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 2),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig
                                    .spaceBetween, vertical: SizeConfig.spaceBetween *
                                    1.5),
                                decoration: BoxDecoration(
                                    color: Colorz.buyBgColor,
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.borderRadius)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    quantityField(context, state),
                                    SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5),
                                    priceTypeSelector(context, state),
                                    SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5),
                                    state.priceType == PriceType.limit ? priceField(
                                        context, state) : Container(),
                                    state.priceType == PriceType.limit
                                        ? SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5)
                                        : Container(),

                                    // Limit Order - Additional fields
                                    state.orderType == OrderType.limit
                                        ? stopLossToggleField(context, state)
                                        : Container(),
                                    state.orderType == OrderType.limit
                                        ? SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5)
                                        : Container(),
                                    state.orderType == OrderType.limit
                                        ? targetPriceField(context, state)
                                        : Container(),
                                    state.orderType == OrderType.limit
                                        ? SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5)
                                        : Container(),
                                    state.orderType == OrderType.limit &&
                                        state.stoplossEnabled ? stopLossPriceField(
                                        context, state) : Container(),
                                    state.orderType == OrderType.limit &&
                                        state.stoplossEnabled
                                        ? SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 1.5)
                                        : Container(),
                                    state.orderType == OrderType.limit
                                        ? trailingJumpField(context, state)
                                        : Container(),
                                    state.orderType == OrderType.limit
                                        ? SizeConfig.verticalSpace(
                                        height: SizeConfig.spaceBetween * 2)
                                        : Container(),
                                    productType(context, state),
                                  ],
                                ),
                              ),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 2),
                              toggles(context, state),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 1.2),
                              Divider(color: Colorz.dividerColor,),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 1.5),
                              marginBox(context, state),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 2),
                              Button(
                                text: 'Buy',
                                isOutlined: false,
                                isBig: true,
                                radius: 100,
                                gradient: Colorz.primaryButtonGradient,
                                onPressed: () {
                                  // final args = ModalRoute.of(context)?.settings.arguments;
                                  // MarketItem? item;
                                  // if (args != null && args is Map && args["stockData"] != null) {
                                  //   item = args["stockData"] as MarketItem;
                                  // }
                                  //
                                  // if (item == null) {
                                  //   ToastHelper.showToast("Invalid stock data",isSuccess: false);
                                  //   return;
                                  // }

                                  if (state.lots == 0) {
                                    AppSnackBar.showError(context, "Please enter lots");
                                    return;
                                  }

                                  // ── Demo mode: call demo API, skip Dhan ──
                                  if (DemoModeService.instance.isActive) {
                                    final secId = widget.marketItem!.securityId;
                                    double ltp = LivePriceService.instance.priceOf(secId);
                                    if (ltp <= 0) {
                                      ltp = context.read<TerminalBloc>().state.livePrices[secId] ?? 0;
                                    }

                                    final bool isSuperOrder = state.orderType == OrderType.limit &&
                                        (state.targetPrice > 0 || state.stopLossPrice > 0);
                                    final bool isLimitOrder = state.priceType == PriceType.limit && !isSuperOrder;

                                    String demoOrderType = 'MARKET';
                                    double execPrice = ltp;

                                    if (isSuperOrder) {
                                      demoOrderType = 'SUPER';
                                      execPrice = state.price > 0 ? state.price : ltp;
                                    } else if (isLimitOrder) {
                                      demoOrderType = 'LIMIT';
                                      execPrice = state.price > 0 ? state.price : ltp;
                                    }

                                    if (execPrice <= 0) {
                                      AppSnackBar.showError(context, "Live price not available yet — please wait");
                                      return;
                                    }

                                    UnifiedTradingService.buyOrder(
                                      securityId: widget.marketItem!.securityId,
                                      exchangeSegment: mapExchangeSegment(widget.marketItem!),
                                      quantity: state.quantity > 0 ? state.quantity : state.lots,
                                      price: execPrice,
                                      orderType: demoOrderType,
                                      targetPrice: isSuperOrder ? state.targetPrice : null,
                                      stopLossPrice: isSuperOrder ? state.stopLossPrice : null,
                                    ).then((result) {
                                      if (!mounted) return;
                                      if (result.status) {
                                        AppSnackBar.showSuccess(context, result.message.isNotEmpty ? result.message : 'Demo order placed');
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          AppRoutes.demoPage,
                                          ModalRoute.withName(AppRoutes.homePage),
                                        );
                                      } else {
                                        AppSnackBar.showError(context, result.message);
                                      }
                                    }).catchError((error) {
                                      AppSnackBar.showError(context, error.toString());
                                    });
                                    return;
                                  }

                                  // ── Live mode ────────────────────────────
                                  if (accessToken == null || accessToken!.isEmpty) {
                                    AppSnackBar.showError(context, "Access token missing");
                                    return;
                                  }

                                  context.read<BuyBloc>().add(
                                    PlaceBuyOrderEvent(
                                      securityId: widget.marketItem!.securityId,
                                      exchangeSegment: mapExchangeSegment(
                                          widget.marketItem!),
                                      dhanAccessToken: accessToken!,
                                      index: getIndexFromName(
                                          widget.marketItem!.name),
                                    ),
                                  );
                                },
                              ),
                              SizeConfig.verticalSpace(
                                  height: SizeConfig.spaceBetween * 2),
                            ],
                          ),
                        ),
                      );
                    }
                );
              },
            ),
          ),
        ),



      ),
    );
  }

  String mapExchangeSegment(MarketItem item) {
    if (item.exchangeSegment == "D") {
      return "NSE_FNO";
    }
    if (item.exchangeSegment == "E") {
      return "NSE_EQ";
    }
    return "NSE_FNO";
  }

  String getIndexFromName(String name) {
    final upper = name.toUpperCase();
    // Order matters — check longer names first
    if (upper.contains("MIDCAPNIFTY")) return "MIDCAPNIFTY";
    if (upper.contains("BANKNIFTY"))   return "BANKNIFTY";
    if (upper.contains("FINNIFTY"))    return "FINNIFTY";
    if (upper.contains("SENSEX"))      return "SENSEX";
    if (upper.contains("BANKEX"))      return "SENSEX"; // BANKEX → use SENSEX limit
    if (upper.contains("NIFTY"))       return "NIFTY";
    return "NIFTY";
  }

  Widget orderTypeSwitch(BuildContext context, BuyState state) {
    final isRegular = state.orderType == OrderType.limit;

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
            left: isRegular ? 0 : null,
            right: isRegular ? null : 0,
            top: 0,
            bottom: 0,
            width: MediaQuery
                .of(context)
                .size
                .width / 2
                - (SizeConfig.spaceBetween * 2.6),
            // adjusted width
            child: Container(
              decoration: BoxDecoration(
                color: Colorz.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
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
                  onTap: () =>
                      context.read<BuyBloc>().add(ChangeOrderType(type)),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: AppTextStyles.semiBold.copyWith(
                        color: selected
                            ? Colorz.textColor
                            : Colorz.hintTextColor,
                        fontSize: SizeConfig.largeFont,
                      ),
                      child: Text(
                          type == OrderType.limit ? "Limit" : "Market"),
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

  Widget quantityField(BuildContext context, BuyState state) {
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
              fontSize: SizeConfig.headerTwoFont, color: Colorz.primary),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
        // Input: user enters lot count
        Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius * 1.2),
            border: Border.all(color: Colorz.newBorderColor, width: 1),
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
                  onChanged: (v) {
                    final lots = int.tryParse(v) ?? 0;
                    context.read<BuyBloc>().add(ChangeLots(lots));
                    if (lots > 0 &&
                        accessToken != null &&
                        accessToken!.isNotEmpty) {
                      context.read<BuyBloc>().add(FetchMarginEvent(
                        dhanAccessToken: accessToken!,
                        securityId: widget.marketItem!.securityId,
                        exchangeSegment: mapExchangeSegment(widget.marketItem!),
                      ));
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.borderRadius * 1.2),
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

  Widget priceField(BuildContext context, BuyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price", style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.smallFont, color: Colorz.textColor),),
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
                      context.read<BuyBloc>().add(
                          ChangePrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius: BorderRadius.circular(
                      SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.2,
                    vertical: SizeConfig.spaceBetween * 1.5),
                child: SvgPicture.asset(
                    Assets.swapHorizontalSvg
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget targetPriceField(BuildContext context, BuyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Target Price", style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.smallFont, color: Colorz.textColor),),
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
                      context.read<BuyBloc>().add(
                          ChangeTargetPrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius: BorderRadius.circular(
                      SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.2,
                    vertical: SizeConfig.spaceBetween * 1.5),
                child: SvgPicture.asset(
                    Assets.swapHorizontalSvg
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget stopLossPriceField(BuildContext context, BuyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Stop Loss Price", style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.smallFont, color: Colorz.textColor),),
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
                      context.read<BuyBloc>().add(
                          ChangeStopLossPrice(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius: BorderRadius.circular(
                      SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.2,
                    vertical: SizeConfig.spaceBetween * 1.5),
                child: SvgPicture.asset(
                    Assets.swapHorizontalSvg
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget trailingJumpField(BuildContext context, BuyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Trailing Jump", style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.smallFont, color: Colorz.textColor),),
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
                      context.read<BuyBloc>().add(
                          ChangeTrailingJump(double.tryParse(v) ?? 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig.spaceBetween * 0.3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius: BorderRadius.circular(
                      SizeConfig.borderRadius * 1.2),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.2,
                    vertical: SizeConfig.spaceBetween * 1.5),
                child: SvgPicture.asset(
                    Assets.swapHorizontalSvg
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget stopLossToggleField(BuildContext context, BuyState state) {
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
              Icon(Icons.info_outline_rounded, color: Colorz.primary, size: 18)
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
          activeColor: Colorz.primary,
          inactiveColor: Colorz.borderColor,
          onToggle: (val) => context.read<BuyBloc>().add(ToggleStoploss()),
        ),
      ],
    );
  }

  Widget priceTypeSelector(BuildContext context, BuyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price Type", style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.smallFont, color: Colorz.textColor),),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  context.read<BuyBloc>().add(
                      ChangePriceType(PriceType.market));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.spaceBetween * 1.2),
                  decoration: BoxDecoration(
                    color: state.priceType == PriceType.market
                        ? Colorz.primary
                        : Colorz.white,
                    borderRadius: BorderRadius.circular(
                        SizeConfig.borderRadius * 1.2),
                    border: Border.all(
                        color: state.priceType == PriceType.market ? Colorz
                            .primary : Colorz.newBorderColor,
                        width: 1.5
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Market",
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.largeFont,
                        color: state.priceType == PriceType.market ? Colorz
                            .white : Colorz.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.read<BuyBloc>().add(ChangePriceType(PriceType.limit));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.spaceBetween * 1.2),
                  decoration: BoxDecoration(
                    color: state.priceType == PriceType.limit
                        ? Colorz.primary
                        : Colorz.white,
                    borderRadius: BorderRadius.circular(
                        SizeConfig.borderRadius * 1.2),
                    border: Border.all(
                        color: state.priceType == PriceType.limit ? Colorz
                            .primary : Colorz.newBorderColor,
                        width: 1.5
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

  int productTypeToIndex(ProductType type) {
    // Only Intraday is available now
    return 0;
  }

  ProductType indexToProductType(int index) {
    // Only Intraday is available now
    return ProductType.intraday;
  }

  Widget productType(BuildContext context, BuyState state) {
    // Display only Intraday - no selection needed
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colorz.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
              border: Border.all(color: Colorz.primary, width: 1)
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colorz.primary,
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
              SizedBox(width: 8),
              Text(
                "Intraday",
                style: AppTextStyles.medium.copyWith(
                  color: Colorz.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget toggles(BuildContext context, BuyState state) {
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
                        color: Colorz.textColor,
                        fontSize: SizeConfig.largeFont),
                  ),
                  SizeConfig.horizontalSpace(
                      width: SizeConfig.spaceBetween * 0.5),
                  Icon(Icons.info_outline_rounded, color: Colorz.primary,)
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
              activeColor: Colorz.primary,
              inactiveColor: Colorz.borderColor,
              onToggle: (val) =>
                  context.read<BuyBloc>().add(ToggleMarketProtection()),
            ),
          ],
        )
      ],
    );
  }

  Widget marginBox(BuildContext context, BuyState state) {
    final isDemo = DemoModeService.instance.isActive;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Help",
              style: AppTextStyles.small.copyWith(
                color: Colorz.primary,
                fontSize: SizeConfig.mediumFont,
              ),
            ),
            InkWell(
              onTap: () => context.read<BuyBloc>().add(ToggleAdvanced()),
              child: Row(
                children: [
                  Text(
                    "Advanced",
                    style: AppTextStyles.small.copyWith(
                      color: Colorz.primary,
                      fontSize: SizeConfig.mediumFont,
                    ),
                  ),
                  SizeConfig.horizontalSpace(
                      width: SizeConfig.spaceBetween * 0.5),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: state.isAdvancedOpen ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colorz.primary,
                    ),
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
                onTap: () => context.read<BuyBloc>().add(ToggleAdvanced()),
                child: Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up_rounded,
                        color: Colorz.textColor),
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
                  color: isDemo
                      ? const Color(0xFF1A73E8).withValues(alpha: 0.06)
                      : Colorz.buyNewBgColor,
                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                ),
                child: state.isMarginLoading
                    ? Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: isDemo
                                ? const Color(0xFF1A73E8)
                                : Colorz.primary,
                          ),
                        ),
                      )
                    : isDemo
                        // \u2500\u2500 Demo mode: show coin balance \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.toll_rounded,
                                      size: 14,
                                      color: const Color(0xFF1A73E8)),
                                  SizeConfig.horizontalSpace(width: 4),
                                  Text(
                                    "Order Est.",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.horizontalSpace(
                                      width: SizeConfig.spaceBetween * 0.7),
                                  Text(
                                    state.quantity > 0 && state.price > 0
                                        ? "~${(state.quantity * state.price).toStringAsFixed(0)} coins"
                                        : "\u2014",
                                    style: AppTextStyles.small.copyWith(
                                        color: const Color(0xFF1A73E8)),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.toll_rounded,
                                      size: 14,
                                      color: const Color(0xFF1A73E8)),
                                  SizeConfig.horizontalSpace(width: 4),
                                  Text(
                                    "Avail.",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.horizontalSpace(
                                      width: SizeConfig.spaceBetween * 0.5),
                                  Text(
                                    "${state.availableBalance.toStringAsFixed(0)} coins",
                                    style: AppTextStyles.small.copyWith(
                                        color: const Color(0xFF1A73E8)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        // \u2500\u2500 Real mode: show Dhan margin \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Margin",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.horizontalSpace(
                                      width: SizeConfig.spaceBetween * 0.7),
                                  Text(
                                    "\u20b9 ${state.margin.toStringAsFixed(0)} + \u20b9 ${state.charges.toStringAsFixed(2)}",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.primary),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Avail.",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.textColor),
                                  ),
                                  SizeConfig.horizontalSpace(
                                      width: SizeConfig.spaceBetween * 0.5),
                                  Text(
                                    "\u20b9 ${state.availableBalance.toStringAsFixed(2)}",
                                    style: AppTextStyles.small
                                        .copyWith(color: Colorz.primary),
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
