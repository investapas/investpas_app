import 'package:investapas/core/network/api_endpoints.dart';
import 'package:investapas/core/network/api_service.dart';
import 'package:investapas/core/services/demo_mode_service.dart';

/// Unified Trading Service
/// Routes all trading operations (buy, sell, modify, cancel) to either Dhan API or Demo API
/// based on the active trading mode.
/// 
/// Single point of control for:
/// - Buy orders (with optional target/stop loss)
/// - Sell orders
/// - Modify orders
/// - Cancel orders
/// - Get portfolio/positions
/// - Get orders
/// - Get order details

class OrderResponse {
  final bool status;
  final String message;
  final dynamic data;
  final bool challengeBlocked;
  final String blockReason;

  OrderResponse({
    required this.status,
    required this.message,
    this.data,
    this.challengeBlocked = false,
    this.blockReason = '',
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      status:           json['status']           ?? false,
      message:          json['message']          ?? '',
      data:             json['data'],
      challengeBlocked: json['challengeBlocked'] ?? false,
      blockReason:      json['reason']           ?? '',
    );
  }
}

class Position {
  final String symbol;
  final String tradingSymbol;
  final String securityId;
  final String exchangeSegment;
  final int quantity;
  final double averagePrice;
  final double currentPrice;
  final double pnl;
  final double pnlPercentage;

  Position({
    required this.symbol,
    required this.tradingSymbol,
    required this.securityId,
    required this.exchangeSegment,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.pnl,
    required this.pnlPercentage,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      symbol: json['symbol'] ?? json['tradingSymbol'] ?? '',
      tradingSymbol: json['tradingSymbol'] ?? '',
      securityId: json['securityId'] ?? '',
      exchangeSegment: json['exchangeSegment'] ?? '',
      quantity: json['quantity'] ?? 0,
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      pnl: (json['pnl'] ?? 0).toDouble(),
      pnlPercentage: (json['pnlPercentage'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String orderId;
  final String symbol;
  final String tradingSymbol;
  final String transactionType; // BUY or SELL
  final String orderType; // MARKET, LIMIT
  final int quantity;
  final double price;
  final String status; // PENDING, TRADED, CANCELLED, etc
  final double? targetPrice;
  final double? stopLossPrice;
  final DateTime createdAt;
  final int disclosedQuantity;
  final double triggerPrice;
  final String validity;
  final String? legName;
  final double? trailingJump;

  Order({
    required this.orderId,
    required this.symbol,
    required this.tradingSymbol,
    required this.transactionType,
    required this.orderType,
    required this.quantity,
    required this.price,
    required this.status,
    this.targetPrice,
    this.stopLossPrice,
    required this.createdAt,
    this.disclosedQuantity = 0,
    this.triggerPrice = 0,
    this.validity = 'DAY',
    this.legName,
    this.trailingJump,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      tradingSymbol: json['tradingSymbol'] ?? '',
      transactionType: json['transactionType'] ?? json['transaction_type'] ?? '',
      orderType: json['orderType'] ?? json['order_type'] ?? 'MARKET',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? json['orderStatus'] ?? json['order_status'] ?? 'PENDING',
      targetPrice: json['targetPrice'] != null ? (json['targetPrice'] as num).toDouble() : null,
      stopLossPrice: json['stopLossPrice'] != null ? (json['stopLossPrice'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
      disclosedQuantity: json['disclosedQuantity'] ?? 0,
      triggerPrice: (json['triggerPrice'] ?? 0).toDouble(),
      validity: json['validity'] ?? 'DAY',
      legName: json['legName'],
      trailingJump: json['trailingJump'] != null ? (json['trailingJump'] as num).toDouble() : null,
    );
  }
}

class UnifiedTradingService {
  /// Place a BUY order
  /// Routes to Dhan API if demo is OFF, Demo API if demo is ON
  static Future<OrderResponse> buyOrder({
    required String securityId,
    required String exchangeSegment,
    required int quantity,
    required double price,
    required String orderType,
    String productType = 'INTRADAY', // INTRADAY | DELIVERY (demo mode)
    String dhanAccessToken = '',
    String tradingSymbol = '',
    double? targetPrice,
    double? stopLossPrice,
  }) async {
    try {
      final isDemoMode = DemoModeService.instance.isActive;

      final body = {
        'mode': isDemoMode ? 'DEMO' : 'REAL',
        'securityId': securityId,
        'exchangeSegment': exchangeSegment,
        'quantity': quantity,
        'price': price,
        'orderType': orderType,
        'productType': productType,
        'transactionType': 'BUY',
        if (tradingSymbol.isNotEmpty) 'tradingSymbol': tradingSymbol,
        if (dhanAccessToken.isNotEmpty) 'dhanAccessToken': dhanAccessToken,
        if (targetPrice != null && targetPrice > 0) 'targetPrice': targetPrice,
        if (stopLossPrice != null && stopLossPrice > 0) 'stopLossPrice': stopLossPrice,
      };

      final response = await ApiHelper.post(
        ApiEndpoints.buyOrderApi,
        body,
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      return OrderResponse(
        status: false,
        message: 'Error placing buy order: $e',
      );
    }
  }

  /// Place a SELL order
  /// Routes to Dhan API if demo is OFF, Demo API if demo is ON
  static Future<OrderResponse> sellOrder({
    required String securityId,
    required String exchangeSegment,
    required int quantity,
    required double price,
    required String orderType,
    String productType = 'INTRADAY', // INTRADAY | DELIVERY (demo mode)
    String dhanAccessToken = '',
    String tradingSymbol = '',
  }) async {
    try {
      final isDemoMode = DemoModeService.instance.isActive;

      final body = {
        'mode': isDemoMode ? 'DEMO' : 'REAL',
        'securityId': securityId,
        'exchangeSegment': exchangeSegment,
        'quantity': quantity,
        'price': price,
        'orderType': orderType,
        'productType': productType,
        'transactionType': 'SELL',
        if (tradingSymbol.isNotEmpty) 'tradingSymbol': tradingSymbol,
        if (dhanAccessToken.isNotEmpty) 'dhanAccessToken': dhanAccessToken,
      };

      final response = await ApiHelper.post(
        ApiEndpoints.buyOrderApi,
        body,
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      return OrderResponse(
        status: false,
        message: 'Error placing sell order: $e',
      );
    }
  }

  /// Modify an existing order
  /// Routes to Dhan API if demo is OFF, Demo API if demo is ON
  static Future<OrderResponse> modifyOrder({
    required String orderId,
    required double newPrice,
    required int newQuantity,
    String dhanAccessToken = '',
  }) async {
    try {
      final isDemoMode = DemoModeService.instance.isActive;

      final body = {
        'mode': isDemoMode ? 'DEMO' : 'REAL',
        'orderId': orderId,
        'newPrice': newPrice,
        'newQuantity': newQuantity,
        if (dhanAccessToken.isNotEmpty) 'dhanAccessToken': dhanAccessToken,
      };

      final response = await ApiHelper.post(
        ApiEndpoints.modifyOrderApi,
        body,
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      return OrderResponse(
        status: false,
        message: 'Error modifying order: $e',
      );
    }
  }

  /// Modify a regular Dhan order (PUT /dhan/order/:orderId)
  /// Lets the user change order type (MARKET/LIMIT), quantity, price and
  /// other fields just like at placement time.
  static Future<OrderResponse> modifyDhanOrder({
    required String orderId,
    required String orderType,
    required int quantity,
    required double price,
    int disclosedQuantity = 0,
    double triggerPrice = 0,
    String validity = 'DAY',
    String legName = 'ENTRY_LEG',
  }) async {
    try {
      final body = {
        'orderType': orderType,
        'legName': legName,
        'quantity': quantity,
        'price': price,
        'disclosedQuantity': disclosedQuantity,
        'triggerPrice': triggerPrice,
        'validity': validity,
      };

      final response = await ApiHelper.put(
        '${ApiEndpoints.dhanOrderApi}/$orderId',
        body,
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      return OrderResponse(
        status: false,
        message: 'Error modifying order: $e',
      );
    }
  }

  /// Modify a Dhan super order (PUT /dhan/super-orders/:orderId)
  /// Lets the user change order type, quantity, price, target, stop loss
  /// and trailing jump just like at placement time.
  static Future<OrderResponse> modifyDhanSuperOrder({
    required String orderId,
    required String orderType,
    required int quantity,
    required double price,
    double targetPrice = 0,
    double stopLossPrice = 0,
    double trailingJump = 0,
    String legName = 'ENTRY_LEG',
  }) async {
    try {
      final body = {
        'orderType': orderType,
        'legName': legName,
        'quantity': quantity,
        'price': price,
        'targetPrice': targetPrice,
        'stopLossPrice': stopLossPrice,
        'trailingJump': trailingJump,
      };

      final response = await ApiHelper.put(
        '${ApiEndpoints.superOrdersApi}/$orderId',
        body,
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      return OrderResponse(
        status: false,
        message: 'Error modifying super order: $e',
      );
    }
  }

  /// Cancel an order
  /// Routes to Dhan API if demo is OFF, Demo API if demo is ON
  static Future<bool> cancelOrder({
    required String orderId,
    String dhanAccessToken = '',
  }) async {
    try {
      final isDemoMode = DemoModeService.instance.isActive;

      final body = {
        'mode': isDemoMode ? 'DEMO' : 'REAL',
        'orderId': orderId,
        if (dhanAccessToken.isNotEmpty) 'dhanAccessToken': dhanAccessToken,
      };

      final response = await ApiHelper.post(
        ApiEndpoints.cancelOrderApi,
        body,
      );

      if (response is Map<String, dynamic>) {
        return response['status'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Get portfolio/positions
  /// [forceReal] = true → always fetch Dhan positions, ignoring demo mode
  static Future<List<Position>> getPortfolio({bool forceReal = false}) async {
    try {
      final isDemoMode = forceReal ? false : DemoModeService.instance.isActive;

      final response = await ApiHelper.get(
        ApiEndpoints.portfolioApi,
        body: {'mode': isDemoMode ? 'DEMO' : 'REAL'},
      );

      if (response is Map<String, dynamic> && response['status'] == true) {
        final data = response['data'];
        
        if (data is List) {
          return data
              .map((json) => Position.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic>) {
          // Sometimes it's wrapped in holdings key
          final holdings = data['holdings'] ?? data['positions'] ?? [];
          if (holdings is List) {
            return holdings
                .map((json) => Position.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching portfolio: $e');
      return [];
    }
  }

  /// Get all orders (open, executed, cancelled)
  /// [forceReal] = true → always fetch Dhan orders, ignoring demo mode
  static Future<List<Order>> getOrders({String status = 'ALL', bool forceReal = false}) async {
    try {
      final isDemoMode = forceReal ? false : DemoModeService.instance.isActive;

      final response = await ApiHelper.get(
        ApiEndpoints.ordersApi,
        body: {'mode': isDemoMode ? 'DEMO' : 'REAL', 'status': status},
      );

      if (response is Map<String, dynamic> && response['status'] == true) {
        final data = response['data'];
        
        if (data is List) {
          return data
              .map((json) => Order.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic>) {
          final orders = data['orders'] ?? [];
          if (orders is List) {
            return orders
                .map((json) => Order.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Get single order details
  static Future<Order?> getOrderDetails(String orderId) async {
    try {
      final isDemoMode = DemoModeService.instance.isActive;

      final response = await ApiHelper.get(
        '${ApiEndpoints.orderApi}/$orderId',
        body: {'mode': isDemoMode ? 'DEMO' : 'REAL'},
      );

      if (response is Map<String, dynamic> && response['status'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return Order.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  /// Check if in demo mode
  static bool isDemoMode() {
    return DemoModeService.instance.isActive;
  }

  /// Get current trading mode label
  static String getModeLabel() {
    return DemoModeService.instance.isActive ? 'DEMO' : 'LIVE';
  }
}
