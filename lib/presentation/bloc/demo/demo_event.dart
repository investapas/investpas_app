import 'package:equatable/equatable.dart';

abstract class DemoEvent extends Equatable {
  const DemoEvent();
  @override
  List<Object?> get props => [];
}

class ActivateDemoMode extends DemoEvent {
  const ActivateDemoMode();
}

class LoadDemoWallet extends DemoEvent {
  const LoadDemoWallet();
}

class LoadDemoOrders extends DemoEvent {
  const LoadDemoOrders();
}

class LoadDemoPortfolio extends DemoEvent {
  const LoadDemoPortfolio();
}

class PlaceDemoOrder extends DemoEvent {
  final String securityId;
  final String tradingSymbol;
  final String exchangeSegment;
  final String transactionType; // 'BUY' or 'SELL'
  final String orderType;       // 'MARKET' | 'LIMIT' | 'SUPER'
  final String productType;     // 'INTRADAY' | 'DELIVERY'
  final int quantity;
  final double price;
  final double targetPrice;
  final double stopLossPrice;
  final double trailingJump;

  const PlaceDemoOrder({
    required this.securityId,
    required this.tradingSymbol,
    required this.exchangeSegment,
    required this.transactionType,
    this.orderType    = 'MARKET',
    this.productType  = 'INTRADAY',
    required this.quantity,
    required this.price,
    this.targetPrice   = 0,
    this.stopLossPrice = 0,
    this.trailingJump  = 0,
  });

  @override
  List<Object?> get props =>
      [securityId, transactionType, orderType, productType, quantity, price];
}

class PurchaseCoinPack extends DemoEvent {
  const PurchaseCoinPack();
}

class CancelDemoOrder extends DemoEvent {
  final int orderId;
  const CancelDemoOrder({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class ResetDemoAccount extends DemoEvent {
  const ResetDemoAccount();
}

class ClearDemoMessage extends DemoEvent {
  const ClearDemoMessage();
}
