import 'package:equatable/equatable.dart';

enum OrderType { limit, market }
enum ProductType { intraday }
enum PriceType { market, limit, sl }

class SellState extends Equatable {
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
  final String quantityValidationError;
  final int lotSize;
  final int lots;
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final String orderId;

  const SellState({
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
    this.quantityValidationError = '',
    this.lotSize = 1,
    this.lots = 0,
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.orderId = '',
  });

  SellState copyWith({
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
    String? quantityValidationError,
    int? lotSize,
    int? lots,
    bool? isLoading,
    bool? isSuccess,
    String? message,
    String? orderId,
  }) {
    return SellState(
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
      quantityValidationError: quantityValidationError ?? this.quantityValidationError,
      lotSize: lotSize ?? this.lotSize,
      lots: lots ?? this.lots,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object> get props => [
    orderType, productType, priceType, isAdvancedOpen, quantity, price,
    targetPrice, stopLossPrice, trailingJump, stoplossEnabled, marketProtection,
    margin, charges, availableBalance, quantityValidationError, lotSize, lots,
    isLoading, isSuccess, message, orderId,
  ];
}