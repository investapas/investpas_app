class DemoOrderModel {
  final int id;
  final String securityId;
  final String tradingSymbol;
  final String exchangeSegment;
  final String transactionType;
  final String orderType;      // MARKET | LIMIT | SUPER
  final String productType;    // INTRADAY | DELIVERY
  final int quantity;
  final double price;          // order/limit price
  final double? executedPrice; // actual fill price — null while PENDING
  final double targetPrice;
  final double stopLossPrice;
  final double trailingJump;
  final String orderStatus;    // PENDING | TRADED | CANCELLED | REJECTED | EXPIRED
  final String? squareOffReason;
  final String createdAt;
  final String? executedAt;

  const DemoOrderModel({
    required this.id,
    required this.securityId,
    required this.tradingSymbol,
    required this.exchangeSegment,
    required this.transactionType,
    required this.orderType,
    this.productType = 'INTRADAY',
    required this.quantity,
    required this.price,
    this.executedPrice,
    this.targetPrice   = 0,
    this.stopLossPrice = 0,
    this.trailingJump  = 0,
    required this.orderStatus,
    this.squareOffReason,
    required this.createdAt,
    this.executedAt,
  });

  bool get isBuy     => transactionType == 'BUY';
  bool get isTraded  => orderStatus == 'TRADED';
  bool get isPending => orderStatus == 'PENDING';
  bool get isSuper   => orderType == 'SUPER';
  bool get isLimit   => orderType == 'LIMIT';
  bool get isDelivery => productType == 'DELIVERY';
  // Fill price if traded, otherwise the order/limit price (still meaningful
  // for a PENDING order — it's what the user is waiting to be filled at).
  double get effectivePrice => executedPrice ?? price;
  double get amount => effectivePrice * quantity;

  factory DemoOrderModel.fromJson(Map<String, dynamic> j) => DemoOrderModel(
    id:              j['id'] as int? ?? 0,
    securityId:      j['security_id']?.toString() ?? '',
    tradingSymbol:   j['trading_symbol']?.toString() ?? '',
    exchangeSegment: j['exchange_segment']?.toString() ?? '',
    transactionType: j['transaction_type']?.toString() ?? '',
    orderType:       j['order_type']?.toString() ?? 'MARKET',
    productType:     j['product_type']?.toString() ?? 'INTRADAY',
    quantity:        int.tryParse(j['quantity']?.toString() ?? '0') ?? 0,
    price:           double.tryParse(j['price']?.toString() ?? '0') ?? 0.0,
    executedPrice:   j['executed_price'] != null
        ? double.tryParse(j['executed_price'].toString())
        : null,
    targetPrice:     double.tryParse(j['target_price']?.toString() ?? '0') ?? 0.0,
    stopLossPrice:   double.tryParse(j['stop_loss_price']?.toString() ?? '0') ?? 0.0,
    trailingJump:    double.tryParse(j['trailing_jump']?.toString() ?? '0') ?? 0.0,
    orderStatus:     j['order_status']?.toString() ?? '',
    squareOffReason: j['square_off_reason']?.toString(),
    createdAt:       j['created_at']?.toString() ?? '',
    executedAt:      j['executed_at']?.toString(),
  );
}

class DemoPositionModel {
  final String securityId;
  final String productType; // INTRADAY | DELIVERY
  final String tradingSymbol;
  final String exchangeSegment;
  final int netQuantity;
  final double avgBuyPrice;

  // Filled by frontend from LivePriceService
  double currentLtp;

  DemoPositionModel({
    required this.securityId,
    this.productType = 'INTRADAY',
    required this.tradingSymbol,
    required this.exchangeSegment,
    required this.netQuantity,
    required this.avgBuyPrice,
    this.currentLtp = 0,
  });

  double get unrealizedPnl  => (currentLtp - avgBuyPrice) * netQuantity;
  double get investedAmount => avgBuyPrice * netQuantity;
  double get currentValue   => currentLtp * netQuantity;
  double get pnlPercent     =>
      avgBuyPrice > 0 ? ((currentLtp - avgBuyPrice) / avgBuyPrice) * 100 : 0;

  factory DemoPositionModel.fromJson(Map<String, dynamic> j) => DemoPositionModel(
    securityId:      j['securityId']?.toString() ?? '',
    productType:     j['productType']?.toString() ?? 'INTRADAY',
    tradingSymbol:   j['tradingSymbol']?.toString() ?? '',
    exchangeSegment: j['exchangeSegment']?.toString() ?? '',
    netQuantity:     int.tryParse(j['netQuantity']?.toString() ?? '0') ?? 0,
    avgBuyPrice:     double.tryParse(j['avgBuyPrice']?.toString() ?? '0') ?? 0.0,
  );
}

// Represents a closed position — used for all-time realized P&L display
class DemoClosedPositionModel {
  final String securityId;
  final String productType; // INTRADAY | DELIVERY
  final String tradingSymbol;
  final String exchangeSegment;
  final int qty;
  final double avgBuyPrice;
  final double avgSellPrice;
  final double pnl;
  final bool isToday;

  const DemoClosedPositionModel({
    required this.securityId,
    this.productType = 'INTRADAY',
    required this.tradingSymbol,
    required this.exchangeSegment,
    required this.qty,
    required this.avgBuyPrice,
    required this.avgSellPrice,
    required this.pnl,
    this.isToday = false,
  });

  bool get isProfit => pnl >= 0;
  double get pnlPercent =>
      avgBuyPrice > 0 ? ((avgSellPrice - avgBuyPrice) / avgBuyPrice) * 100 : 0;

  factory DemoClosedPositionModel.fromJson(Map<String, dynamic> j) =>
      DemoClosedPositionModel(
        securityId:      j['securityId']?.toString() ?? '',
        productType:     j['productType']?.toString() ?? 'INTRADAY',
        tradingSymbol:   j['tradingSymbol']?.toString() ?? '',
        exchangeSegment: j['exchangeSegment']?.toString() ?? '',
        qty:             int.tryParse(j['qty']?.toString() ?? '0') ?? 0,
        avgBuyPrice:     double.tryParse(j['avgBuyPrice']?.toString() ?? '0') ?? 0.0,
        avgSellPrice:    double.tryParse(j['avgSellPrice']?.toString() ?? '0') ?? 0.0,
        pnl:             double.tryParse(j['pnl']?.toString() ?? '0') ?? 0.0,
        isToday:         j['isToday'] == true || j['isToday'] == 1,
      );
}
