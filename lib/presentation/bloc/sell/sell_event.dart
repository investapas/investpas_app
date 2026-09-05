import 'package:equatable/equatable.dart';
import 'package:investapas/presentation/bloc/sell/sell_state.dart';

abstract class SellEvent extends Equatable {
  const SellEvent();
  @override
  List<Object?> get props => [];
}

class ChangeOrderType extends SellEvent {
  final OrderType type;
  const ChangeOrderType(this.type);
}

class ChangePriceType extends SellEvent {
  final PriceType type;
  const ChangePriceType(this.type);
}

class ChangeQuantity extends SellEvent {
  final int qty;
  const ChangeQuantity(this.qty);
}

class ChangePrice extends SellEvent {
  final double price;
  const ChangePrice(this.price);
}

class ChangeTargetPrice extends SellEvent {
  final double price;
  const ChangeTargetPrice(this.price);
}

class ChangeStopLossPrice extends SellEvent {
  final double price;
  const ChangeStopLossPrice(this.price);
}

class ChangeTrailingJump extends SellEvent {
  final double value;
  const ChangeTrailingJump(this.value);
}

class SetLotSize extends SellEvent {
  final int size;
  const SetLotSize(this.size);
}

class ChangeLots extends SellEvent {
  final int lots;
  const ChangeLots(this.lots);
}

class ToggleStoploss extends SellEvent {}

class ToggleMarketProtection extends SellEvent {}

class RecalculateMargin extends SellEvent {}

class ToggleAdvanced extends SellEvent {}

class PlaceSellOrderEvent extends SellEvent {
  final String securityId;
  final String exchangeSegment;
  final String dhanAccessToken;
  final double livePrice; // current LTP from WebSocket — sent with market orders

  const PlaceSellOrderEvent({
    required this.securityId,
    required this.exchangeSegment,
    required this.dhanAccessToken,
    this.livePrice = 0,
  });

  @override
  List<Object?> get props => [securityId, exchangeSegment, dhanAccessToken, livePrice];
}