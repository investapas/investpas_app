import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/buy/buy_event.dart';
import 'package:investapas/presentation/bloc/buy/buy_state.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/demo_mode_service.dart';

class BuyBloc extends Bloc<BuyEvent, BuyState> {
  Timer? _marginTimer;
  String _securityId = '';
  String _exchangeSegment = '';
  String _dhanAccessToken = '';
  bool _marginFetchedOnce = false;

  BuyBloc() : super(const BuyState()) {

    on<ChangeOrderType>((event, emit) {
      emit(state.copyWith(orderType: event.type));
    });

    on<ChangeProductType>((event, emit) {
      emit(state.copyWith(productType: event.type));
    });

    on<ChangePriceType>((event, emit) {
      emit(state.copyWith(priceType: event.type));
    });

    on<ChangeQuantity>((event, emit) {
      String validationError = '';

      if (event.qty > 0 && state.lotSize > 0) {
        if (event.qty % state.lotSize != 0) {
          validationError = 'Please Enter Valid Quantity. ${state.lotSize}';
        }
      }

      emit(state.copyWith(
        quantity: event.qty,
        quantityValidationError: validationError,
      ));
    });

    on<ChangeLots>((event, emit) {
      final quantity = event.lots * state.lotSize;
      emit(state.copyWith(
        lots: event.lots,
        quantity: quantity,
        quantityValidationError: '',
      ));
    });

    on<SetLotSize>((event, emit) {
      final quantity = state.lots > 0 ? state.lots * event.lotSize : state.quantity;
      emit(state.copyWith(lotSize: event.lotSize, quantity: quantity));
    });

    on<ChangePrice>((event, emit) {
      emit(state.copyWith(price: event.price));
    });

    on<ChangeTargetPrice>((event, emit) {
      emit(state.copyWith(targetPrice: event.price));
    });

    on<ChangeStopLossPrice>((event, emit) {
      emit(state.copyWith(stopLossPrice: event.price));
    });

    on<ChangeTrailingJump>((event, emit) {
      emit(state.copyWith(trailingJump: event.price));
    });

    on<FetchMarginEvent>((event, emit) async {
      // Store params so the timer can reuse them
      _securityId = event.securityId;
      _exchangeSegment = event.exchangeSegment;
      _dhanAccessToken = event.dhanAccessToken;

      // Show loader only on the very first fetch
      if (!_marginFetchedOnce) {
        emit(state.copyWith(isMarginLoading: true));
      }

      await _doFetchMargin(emit);

      // Start background timer after first fetch
      if (!_marginFetchedOnce) {
        _marginFetchedOnce = true;
        // Only poll in real mode — demo wallet doesn't need per-second refresh
        if (!DemoModeService.instance.isActive) {
          _marginTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (!isClosed && _securityId.isNotEmpty) {
              add(RefreshMarginSilentEvent());
            }
          });
        }
      }
    });

    on<RefreshMarginSilentEvent>((event, emit) async {
      if (_securityId.isEmpty || _dhanAccessToken.isEmpty || state.quantity <= 0) return;
      await _doFetchMargin(emit);
    });

    on<ToggleStoploss>((event, emit) {
      emit(state.copyWith(stoplossEnabled: !state.stoplossEnabled));
    });

    on<ToggleMarketProtection>((event, emit) {
      emit(state.copyWith(marketProtection: !state.marketProtection));
    });

    on<ToggleAdvanced>((event, emit) {
      emit(state.copyWith(isAdvancedOpen: !state.isAdvancedOpen));
    });

    /// margin calculation
    on<RecalculateMargin>((event, emit) {
      final margin = state.quantity * state.price * 2.0;
      final charges = margin * 0.0016;

      emit(state.copyWith(
        margin: margin,
        charges: charges,
      ));
    });

    on<ResetBuyState>((event, emit) {
      _marginTimer?.cancel();
      _marginTimer = null;
      _marginFetchedOnce = false;
      _securityId = '';
      _exchangeSegment = '';
      _dhanAccessToken = '';
      emit(const BuyState());
    });

    on<PlaceBuyOrderEvent>((event, emit) async {

      emit(state.copyWith(
        isLoading: true,
        message: '',
        isSuccess: false,
        isBlocked: false,
        blockRule: '',
        blockMessage: '',
      ));

      try {

        // ── Step 1: Check challenge rules before placing order ─────────────
        // Compute lots: use state.lots if set, else derive from quantity / lotSize
        final lotsToCheck = state.lots > 0
            ? state.lots
            : (state.lotSize > 0 ? (state.quantity ~/ state.lotSize) : 1);

        final checkResponse = await ApiHelper.post(
          ApiEndpoints.challengeCheckOrderApi,
          {
            "index": event.index,
            "quantity": state.quantity,
            "lots": lotsToCheck,
            "mode": DemoModeService.instance.isActive ? "DEMO" : "REAL",
          },
        );

        print(checkResponse);
        print("dkasjdhjahsgdhasbdas");

        if (checkResponse != null && checkResponse["allowed"] == false) {
          final rule = checkResponse["rule"] ?? '';
          String blockMsg;
          switch (rule) {
            case "DAILY_PROFIT_TARGET":
              blockMsg = "🎯 Profit target reached! Use Quick Unlock to continue.";
              break;
            case "DAILY_LOSS_LIMIT":
              blockMsg = "⛔ Loss limit reached! Use Quick Unlock to continue.";
              break;
            case "MAX_TRADES_LIMIT":
              blockMsg = "📊 Max trades reached! Use Quick Unlock to continue.";
              break;
            case "QUANTITY_RULE":
              blockMsg = checkResponse["message"] ?? "❌ Lot limit exceeded for this index.";
              break;
            default:
              blockMsg = checkResponse["message"] ?? "Trading blocked.";
          }
          emit(state.copyWith(
            isLoading: false,
            isBlocked: true,
            blockRule: rule,
            blockMessage: blockMsg,
          ));
          return;
        }

        // ── Step 2: Place the order ────────────────────────────────────────
        final bool isDemoMode = DemoModeService.instance.isActive;
        final payload = {
          "mode": isDemoMode ? "DEMO" : "REAL",
          "dhanAccessToken": event.dhanAccessToken,
          "transactionType": "BUY",
          "exchangeSegment": event.exchangeSegment,
          "securityId": event.securityId,
          "quantity": state.quantity,
        };

        if (state.orderType == OrderType.limit) {
          payload["orderType"] = "SUPER";
          payload["price"] = state.price > 0 ? state.price : 0;
          if (state.stoplossEnabled) {
            payload["targetPrice"] = state.targetPrice;
            payload["stopLossPrice"] = state.stopLossPrice;
          }
        } else {
          String orderTypeToSend = state.priceType == PriceType.limit ? "LIMIT" : "MARKET";
          payload["orderType"] = orderTypeToSend;
          payload["productType"] = state.productType == ProductType.cnc ? "CNC" : "INTRADAY";
          if (orderTypeToSend == "LIMIT" && state.price > 0) {
            payload["price"] = state.price;
          }
        }

        final rawResponse = await ApiHelper.post(ApiEndpoints.buyOrderApi, payload);

        Map<String, dynamic> response;
        if (rawResponse is String) {
          response = jsonDecode(rawResponse);
        } else {
          response = rawResponse;
        }

        if (response["status"] == true) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            orderId: response["data"]?["orderId"]?.toString() ?? "",
            message: "Order placed successfully",
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: false,
            message: response["message"] ?? "Order failed",
          ));
        }

      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: e.toString(),
        ));
      }
    });

    // ── Quick Unlock ───────────────────────────────────────────────────────
    on<QuickUnlockEvent>((event, emit) async {
      emit(state.copyWith(isUnlocking: true));
      try {
        final response = await ApiHelper.post(
          ApiEndpoints.challengeQuickUnlockApi,
          {},
        );
        if (response != null && response["status"] == true) {
          emit(state.copyWith(
            isUnlocking: false,
            isBlocked: false,
            blockRule: '',
            blockMessage: '',
            message: 'Trading resumed! New session started.',
          ));
        } else {
          emit(state.copyWith(
            isUnlocking: false,
            message: response?["message"] ?? "Unlock failed",
          ));
        }
      } catch (e) {
        emit(state.copyWith(isUnlocking: false, message: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _marginTimer?.cancel();
    return super.close();
  }

  Future<void> _doFetchMargin(Emitter<BuyState> emit) async {
    // Demo mode: fetch demo coin balance — skip Dhan margin calculator
    if (DemoModeService.instance.isActive) {
      try {
        final response = await ApiHelper.get(ApiEndpoints.demoWalletApi);
        if (response != null && response['status'] == true) {
          final data = response['data'] as Map<String, dynamic>? ?? {};
          final coins = ((data['availableCoins'] ?? 0) as num).toDouble();
          emit(state.copyWith(isMarginLoading: false, availableBalance: coins));
        } else {
          emit(state.copyWith(isMarginLoading: false));
        }
      } catch (_) {
        emit(state.copyWith(isMarginLoading: false));
      }
      return;
    }

    // Real mode: Dhan margin calculator
    try {
      final response = await ApiHelper.post(
        ApiEndpoints.marginCalculatorApi,
        {
          "dhanAccessToken": _dhanAccessToken,
          "transactionType": "BUY",
          "exchangeSegment": _exchangeSegment,
          "productType": "INTRADAY",
          "securityId": _securityId,
          "quantity": state.quantity,
          "price": state.price,
        },
      );

      if (response != null && response["status"] == true) {
        final data = response["data"] as Map<String, dynamic>? ?? {};
        final margin = ((data["totalMargin"] ?? data["requiredMargin"] ?? 0) as num).toDouble();
        final charges = ((data["tradeCharges"] ?? data["brokerage"] ?? 0) as num).toDouble();
        final available = ((data["availableBalance"] ?? 0) as num).toDouble();
        emit(state.copyWith(
          isMarginLoading: false,
          margin: margin,
          charges: charges,
          availableBalance: available,
        ));
      } else {
        emit(state.copyWith(isMarginLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(isMarginLoading: false));
    }
  }
}