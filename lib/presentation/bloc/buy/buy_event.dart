import 'package:equatable/equatable.dart';

import 'buy_state.dart';

abstract class BuyEvent extends Equatable {
  const BuyEvent();
  @override
  List<Object?> get props => [];
}

class ChangeOrderType extends BuyEvent {
  final OrderType type;
  const ChangeOrderType(this.type);
}

class ChangeProductType extends BuyEvent {
  final ProductType type;
  const ChangeProductType(this.type);
}

class ChangePriceType extends BuyEvent {
  final PriceType type;
  const ChangePriceType(this.type);
}

class ChangeQuantity extends BuyEvent {
  final int qty;
  const ChangeQuantity(this.qty);
}

class ChangeLots extends BuyEvent {
  final int lots;
  const ChangeLots(this.lots);
}

class SetLotSize extends BuyEvent {
  final int lotSize;
  const SetLotSize(this.lotSize);
}

class ChangePrice extends BuyEvent {
  final double price;
  const ChangePrice(this.price);
}

class ChangeTargetPrice extends BuyEvent {
  final double price;
  const ChangeTargetPrice(this.price);
}

class ChangeStopLossPrice extends BuyEvent {
  final double price;
  const ChangeStopLossPrice(this.price);
}

class ChangeTrailingJump extends BuyEvent {
  final double price;
  const ChangeTrailingJump(this.price);
}

class FetchMarginEvent extends BuyEvent {
  final String dhanAccessToken;
  final String securityId;
  final String exchangeSegment;

  const FetchMarginEvent({
    required this.dhanAccessToken,
    required this.securityId,
    required this.exchangeSegment,
  });

  @override
  List<Object?> get props => [dhanAccessToken, securityId, exchangeSegment];
}

class RefreshMarginSilentEvent extends BuyEvent {}

class ToggleStoploss extends BuyEvent {}

class ToggleMarketProtection extends BuyEvent {}

class RecalculateMargin extends BuyEvent {}

class ToggleAdvanced extends BuyEvent {}

class ResetBuyState extends BuyEvent {}

class PlaceBuyOrderEvent extends BuyEvent {
  final String securityId;
  final String exchangeSegment;
  final String dhanAccessToken;
  final String index;

  const PlaceBuyOrderEvent({
    required this.securityId,
    required this.exchangeSegment,
    required this.dhanAccessToken,
    required this.index,
  });

  @override
  List<Object?> get props =>
      [securityId, exchangeSegment, dhanAccessToken, index];
}

class QuickUnlockEvent extends BuyEvent {
  const QuickUnlockEvent();
}