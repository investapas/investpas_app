import 'package:equatable/equatable.dart';

enum OrderType { limit, market }
enum ProductType { intraday, cnc }
enum PriceType { market, limit }

class BuyState extends Equatable {
  final OrderType orderType;
  final ProductType productType;
  final PriceType priceType;
  final bool isAdvancedOpen;
  final int quantity;
  final double price;
  final double targetPrice;
  final double stopLossPrice;
  final double trailingJump;

  final bool stoplossEnabled;
  final bool marketProtection;

  final double margin;
  final double charges;
  final double availableBalance;
  final bool isLoading;
  final String message;
  final bool isSuccess;
  final String orderId;
  final String quantityValidationError;
  final int lotSize;
  final int lots;
  final bool isMarginLoading;
  final bool isBlocked;
  final String blockRule;
  final String blockMessage;
  final bool isUnlocking;

  const BuyState({
    this.orderType = OrderType.market,
    this.productType = ProductType.intraday,
    this.priceType = PriceType.market,
    this.isAdvancedOpen = false,
    this.quantity = 0,
    this.price = 0,
    this.targetPrice = 0,
    this.stopLossPrice = 0,
    this.trailingJump = 0,
    this.stoplossEnabled = true,
    this.marketProtection = true,
    this.margin = 0,
    this.charges = 0,
    this.availableBalance = 0,
    this.isLoading = false,
    this.message = '',
    this.isSuccess = false,
    this.orderId = '',
    this.quantityValidationError = '',
    this.lotSize = 1,
    this.lots = 0,
    this.isMarginLoading = false,
    this.isBlocked = false,
    this.blockRule = '',
    this.blockMessage = '',
    this.isUnlocking = false,
  });

  BuyState copyWith({
    OrderType? orderType,
    ProductType? productType,
    PriceType? priceType,
    bool? isAdvancedOpen,
    int? quantity,
    double? price,
    double? targetPrice,
    double? stopLossPrice,
    double? trailingJump,
    bool? stoplossEnabled,
    bool? marketProtection,
    double? margin,
    double? charges,
    double? availableBalance,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    String? orderId,
    String? quantityValidationError,
    int? lotSize,
    int? lots,
    bool? isMarginLoading,
    bool? isBlocked,
    String? blockRule,
    String? blockMessage,
    bool? isUnlocking,
  }) {
    return BuyState(
      orderType: orderType ?? this.orderType,
      productType: productType ?? this.productType,
      priceType: priceType ?? this.priceType,
      isAdvancedOpen: isAdvancedOpen ?? this.isAdvancedOpen,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      targetPrice: targetPrice ?? this.targetPrice,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      trailingJump: trailingJump ?? this.trailingJump,
      stoplossEnabled: stoplossEnabled ?? this.stoplossEnabled,
      marketProtection: marketProtection ?? this.marketProtection,
      margin: margin ?? this.margin,
      charges: charges ?? this.charges,
      availableBalance: availableBalance ?? this.availableBalance,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      isSuccess: isSuccess ?? this.isSuccess,
      orderId: orderId ?? this.orderId,
      quantityValidationError: quantityValidationError ?? this.quantityValidationError,
      lotSize: lotSize ?? this.lotSize,
      lots: lots ?? this.lots,
      isMarginLoading: isMarginLoading ?? this.isMarginLoading,
      isBlocked: isBlocked ?? this.isBlocked,
      blockRule: blockRule ?? this.blockRule,
      blockMessage: blockMessage ?? this.blockMessage,
      isUnlocking: isUnlocking ?? this.isUnlocking,
    );
  }

  @override
  List<Object> get props =>
      [orderType, productType, priceType, isAdvancedOpen, quantity, price, targetPrice, stopLossPrice, trailingJump, stoplossEnabled, marketProtection, margin, charges, availableBalance, isLoading, message, isSuccess, orderId, quantityValidationError, lotSize, lots, isMarginLoading, isBlocked, blockRule, blockMessage, isUnlocking];
}