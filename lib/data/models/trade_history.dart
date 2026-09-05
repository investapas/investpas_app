import '../../core/constants/constants.dart';
import 'Model.dart';

class TradeOrder {
  final String orderId;
  final int tradedQuantity;
  final double tradedPrice;
  final String exchangeTime;
  final double charges;

  TradeOrder({
    required this.orderId,
    required this.tradedQuantity,
    required this.tradedPrice,
    required this.exchangeTime,
    required this.charges,
  });

  factory TradeOrder.fromJson(Json json) {
    return TradeOrder(
      orderId: json['orderId'] ?? '',
      tradedQuantity: json['tradedQuantity'] ?? 0,
      tradedPrice: (json['tradedPrice'] ?? 0.0).toDouble(),
      exchangeTime: json['exchangeTime'] ?? '',
      charges: (json['charges'] ?? 0.0).toDouble(),
    );
  }

  Json get toJson => {
    'orderId': orderId,
    'tradedQuantity': tradedQuantity,
    'tradedPrice': tradedPrice,
    'exchangeTime': exchangeTime,
    'charges': charges,
  };
}

class TradePosition extends Model {
  final String customSymbol;
  final String securityId;
  final String exchangeSegment;
  final String productType;
  final String instrument;
  final String? drvExpiryDate;
  final String? drvOptionType;
  final double? drvStrikePrice;
  final int totalBuyQty;
  final int totalSellQty;
  final double avgBuyPrice;
  final double avgSellPrice;
  final String status;
  final double? grossPnL;
  final double totalCharges;
  final double? netPnL;
  final List<TradeOrder> buyOrders;
  final List<TradeOrder> sellOrders;

  TradePosition({
    required this.customSymbol,
    required this.securityId,
    required this.exchangeSegment,
    required this.productType,
    required this.instrument,
    this.drvExpiryDate,
    this.drvOptionType,
    this.drvStrikePrice,
    required this.totalBuyQty,
    required this.totalSellQty,
    required this.avgBuyPrice,
    required this.avgSellPrice,
    required this.status,
    this.grossPnL,
    required this.totalCharges,
    this.netPnL,
    required this.buyOrders,
    required this.sellOrders,
  });

  @override
  TradePosition copyWith({
    String? customSymbol,
    String? securityId,
    String? exchangeSegment,
    String? productType,
    String? instrument,
    String? drvExpiryDate,
    String? drvOptionType,
    double? drvStrikePrice,
    int? totalBuyQty,
    int? totalSellQty,
    double? avgBuyPrice,
    double? avgSellPrice,
    String? status,
    double? grossPnL,
    double? totalCharges,
    double? netPnL,
    List<TradeOrder>? buyOrders,
    List<TradeOrder>? sellOrders,
  }) {
    return TradePosition(
      customSymbol: customSymbol ?? this.customSymbol,
      securityId: securityId ?? this.securityId,
      exchangeSegment: exchangeSegment ?? this.exchangeSegment,
      productType: productType ?? this.productType,
      instrument: instrument ?? this.instrument,
      drvExpiryDate: drvExpiryDate ?? this.drvExpiryDate,
      drvOptionType: drvOptionType ?? this.drvOptionType,
      drvStrikePrice: drvStrikePrice ?? this.drvStrikePrice,
      totalBuyQty: totalBuyQty ?? this.totalBuyQty,
      totalSellQty: totalSellQty ?? this.totalSellQty,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
      avgSellPrice: avgSellPrice ?? this.avgSellPrice,
      status: status ?? this.status,
      grossPnL: grossPnL ?? this.grossPnL,
      totalCharges: totalCharges ?? this.totalCharges,
      netPnL: netPnL ?? this.netPnL,
      buyOrders: buyOrders ?? this.buyOrders,
      sellOrders: sellOrders ?? this.sellOrders,
    );
  }

  @override
  Json get toJson => {
    'customSymbol': customSymbol,
    'securityId': securityId,
    'exchangeSegment': exchangeSegment,
    'productType': productType,
    'instrument': instrument,
    'drvExpiryDate': drvExpiryDate,
    'drvOptionType': drvOptionType,
    'drvStrikePrice': drvStrikePrice,
    'totalBuyQty': totalBuyQty,
    'totalSellQty': totalSellQty,
    'avgBuyPrice': avgBuyPrice,
    'avgSellPrice': avgSellPrice,
    'status': status,
    'grossPnL': grossPnL,
    'totalCharges': totalCharges,
    'netPnL': netPnL,
    'buyOrders': buyOrders.map((e) => e.toJson).toList(),
    'sellOrders': sellOrders.map((e) => e.toJson).toList(),
  };

  factory TradePosition.fromJson(Json json) {
    return TradePosition(
      customSymbol: json['customSymbol'] ?? '',
      securityId: json['securityId'] ?? '',
      exchangeSegment: json['exchangeSegment'] ?? '',
      productType: json['productType'] ?? '',
      instrument: json['instrument'] ?? '',
      drvExpiryDate: json['drvExpiryDate'],
      drvOptionType: json['drvOptionType'],
      drvStrikePrice: (json['drvStrikePrice'] ?? 0.0).toDouble(),
      totalBuyQty: json['totalBuyQty'] ?? 0,
      totalSellQty: json['totalSellQty'] ?? 0,
      avgBuyPrice: (json['avgBuyPrice'] ?? 0.0).toDouble(),
      avgSellPrice: (json['avgSellPrice'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      grossPnL: (json['grossPnL'] ?? 0.0).toDouble(),
      totalCharges: (json['totalCharges'] ?? 0.0).toDouble(),
      netPnL: (json['netPnL'] ?? 0.0).toDouble(),
      buyOrders: ((json['buyOrders'] ?? []) as List).map((e) => TradeOrder.fromJson(e)).toList(),
      sellOrders: ((json['sellOrders'] ?? []) as List).map((e) => TradeOrder.fromJson(e)).toList(),
    );
  }
}

class TradeHistorySummary {
  final String date;
  final int totalTrades;
  final double grossPnL;
  final double totalCharges;
  final double netPnL;

  TradeHistorySummary({
    required this.date,
    required this.totalTrades,
    required this.grossPnL,
    required this.totalCharges,
    required this.netPnL,
  });

  factory TradeHistorySummary.fromJson(Json json) {
    return TradeHistorySummary(
      date: json['date'] ?? '',
      totalTrades: json['totalTrades'] ?? 0,
      grossPnL: (json['grossPnL'] ?? 0.0).toDouble(),
      totalCharges: (json['totalCharges'] ?? 0.0).toDouble(),
      netPnL: (json['netPnL'] ?? 0.0).toDouble(),
    );
  }

  Json get toJson => {
    'date': date,
    'totalTrades': totalTrades,
    'grossPnL': grossPnL,
    'totalCharges': totalCharges,
    'netPnL': netPnL,
  };
}
