import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/sell/sell_event.dart';
import 'package:investapas/presentation/bloc/sell/sell_state.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/demo_mode_service.dart';

class SellBloc extends Bloc<SellEvent, SellState> {
  SellBloc() : super(const SellState()) {

    on<ChangeOrderType>((event, emit) {
      emit(state.copyWith(orderType: event.type));
    });

    on<ChangePriceType>((event, emit) {
      emit(state.copyWith(priceType: event.type));
    });

    on<SetLotSize>((event, emit) {
      final qty = state.lots > 0 ? state.lots * event.size : state.quantity;
      emit(state.copyWith(lotSize: event.size, quantity: qty));
    });

    on<ChangeLots>((event, emit) {
      emit(state.copyWith(
        lots: event.lots,
        quantity: event.lots * state.lotSize,
      ));
    });

    on<ChangeQuantity>((event, emit) {
      emit(state.copyWith(quantity: event.qty));
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
      emit(state.copyWith(trailingJump: event.value));
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

    on<PlaceSellOrderEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, message: '', isSuccess: false));

      try {
        final bool isLimitOrder = state.price > 0;

        final bool isDemoMode = DemoModeService.instance.isActive;
        final payload = <String, dynamic>{
          "mode": isDemoMode ? "DEMO" : "REAL",
          "dhanAccessToken": event.dhanAccessToken,
          "exchangeSegment": event.exchangeSegment,
          "securityId": event.securityId,
          "quantity": state.quantity,
          "orderType": isLimitOrder ? "LIMIT" : "MARKET",
          "transactionType": "SELL",
        };

        if (isLimitOrder) {
          payload["price"] = state.price;
        } else if (event.livePrice > 0) {
          // For MARKET orders, include the current LTP from WebSocket
          // Dhan uses this as the expected price for slippage protection
          payload["price"] = event.livePrice;
        }

        final response = await ApiHelper.post(ApiEndpoints.buyOrderApi, payload);

        if (response["status"] == true) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            orderId: response["data"]?["orderId"]?.toString() ?? '',
            message: "Order placed successfully",
          ));
        } else {
          String errorMsg = response["message"] ?? "Order failed";
          if (response["rule"] != null) {
            switch (response["rule"]) {
              case "DAILY_LOSS_LIMIT":
                errorMsg = "Daily loss limit reached";
                break;
              case "DAILY_PROFIT_TARGET":
                errorMsg = "Profit target already achieved";
                break;
              case "MAX_TRADES_LIMIT":
                errorMsg = "Max trades limit reached";
                break;
              case "QUANTITY_RULE":
                errorMsg = response["message"];
                break;
            }
          }
          emit(state.copyWith(isLoading: false, isSuccess: false, message: errorMsg));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, isSuccess: false, message: e.toString()));
      }
    });
  }
}