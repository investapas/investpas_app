import '../../core/constants/constants.dart';
import 'Model.dart';

/// Portfolio Position model
class PortfolioPosition extends Model {
  /// Trading Symbol
  final String tradingSymbol;
  /// Security ID
  final String securityId;
  /// Position Type
  final String positionType;
  /// Exchange Segment
  final String exchangeSegment;
  /// Product Type
  final String productType;
  /// Buy Average
  final double buyAvg;
  /// Cost Price
  final double costPrice;
  /// Buy Quantity
  final int buyQty;
  /// Sell Average
  final double sellAvg;
  /// Sell Quantity
  final int sellQty;
  /// Net Quantity
  final int netQty;
  /// Realized Profit
  final double realizedProfit;
  /// Unrealized Profit
  final double unrealizedProfit;
  /// LTP (Last Traded Price) - we'll use costPrice as LTP for now
  final double ltp;
  /// P&L (Total P&L)
  final double pnl;

  /// Constructor
  PortfolioPosition({
    required this.tradingSymbol,
    required this.securityId,
    required this.positionType,
    required this.exchangeSegment,
    required this.productType,
    required this.buyAvg,
    required this.costPrice,
    required this.buyQty,
    required this.sellAvg,
    required this.sellQty,
    required this.netQty,
    required this.realizedProfit,
    required this.unrealizedProfit,
    required this.ltp,
    required this.pnl,
  });

  @override
  PortfolioPosition copyWith({
    String? tradingSymbol,
    String? securityId,
    String? positionType,
    String? exchangeSegment,
    String? productType,
    double? buyAvg,
    double? costPrice,
    int? buyQty,
    double? sellAvg,
    int? sellQty,
    int? netQty,
    double? realizedProfit,
    double? unrealizedProfit,
    double? ltp,
    double? pnl,
  }) {
    return PortfolioPosition(
      tradingSymbol: tradingSymbol ?? this.tradingSymbol,
      securityId: securityId ?? this.securityId,
      positionType: positionType ?? this.positionType,
      exchangeSegment: exchangeSegment ?? this.exchangeSegment,
      productType: productType ?? this.productType,
      buyAvg: buyAvg ?? this.buyAvg,
      costPrice: costPrice ?? this.costPrice,
      buyQty: buyQty ?? this.buyQty,
      sellAvg: sellAvg ?? this.sellAvg,
      sellQty: sellQty ?? this.sellQty,
      netQty: netQty ?? this.netQty,
      realizedProfit: realizedProfit ?? this.realizedProfit,
      unrealizedProfit: unrealizedProfit ?? this.unrealizedProfit,
      ltp: ltp ?? this.ltp,
      pnl: pnl ?? this.pnl,
    );
  }

  @override
  Json get toJson => {
        'tradingSymbol': tradingSymbol,
        'securityId': securityId,
        'positionType': positionType,
        'exchangeSegment': exchangeSegment,
        'productType': productType,
        'buyAvg': buyAvg,
        'costPrice': costPrice,
        'buyQty': buyQty,
        'sellAvg': sellAvg,
        'sellQty': sellQty,
        'netQty': netQty,
        'realizedProfit': realizedProfit,
        'unrealizedProfit': unrealizedProfit,
        'ltp': ltp,
        'pnl': pnl,
      };

  /// Factory method to create from JSON
  factory PortfolioPosition.fromJson(Json json) {
    return PortfolioPosition(
      tradingSymbol: json['tradingSymbol'] ?? '',
      securityId: json['securityId'] ?? '',
      positionType: json['positionType'] ?? '',
      exchangeSegment: json['exchangeSegment'] ?? '',
      productType: json['productType'] ?? '',
      buyAvg: (json['buyAvg'] ?? 0.0).toDouble(),
      costPrice: (json['costPrice'] ?? 0.0).toDouble(),
      buyQty: json['buyQty'] ?? 0,
      sellAvg: (json['sellAvg'] ?? 0.0).toDouble(),
      sellQty: json['sellQty'] ?? 0,
      netQty: json['netQty'] ?? 0,
      realizedProfit: (json['realizedProfit'] ?? 0.0).toDouble(),
      unrealizedProfit: (json['unrealizedProfit'] ?? 0.0).toDouble(),
      ltp: (json['costPrice'] ?? 0.0).toDouble(), // Using costPrice as LTP
      pnl: ((json['realizedProfit'] ?? 0.0) + (json['unrealizedProfit'] ?? 0.0)).toDouble(),
    );
  }
}