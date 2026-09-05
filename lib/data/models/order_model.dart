class OrderLeg {
  final String legName;
  final String legStatus;
  final String legOrderId;
  final double price;
  final int quantity;

  const OrderLeg({
    required this.legName,
    required this.legStatus,
    required this.legOrderId,
    required this.price,
    required this.quantity,
  });

  bool get isPending =>
      legStatus == 'PENDING' || legStatus == 'TRANSIT';

  String get displayName {
    switch (legName) {
      case 'ENTRY_LEG':   return 'Entry';
      case 'TARGET_LEG':  return 'Target';
      case 'STOPLOSS_LEG': return 'Stop Loss';
      default: return legName;
    }
  }

  factory OrderLeg.fromJson(Map<String, dynamic> json) {
    return OrderLeg(
      legName: (json['legName'] ?? json['leg_name'] ?? '').toString(),
      legStatus: (json['orderStatus'] ?? json['legStatus'] ?? json['leg_status'] ?? '').toString(),
      legOrderId: (json['legOrderId'] ?? json['leg_order_id'] ?? json['orderId'] ?? '').toString(),
      price: double.tryParse((json['price'] ?? json['orderPrice'] ?? json['legPrice'] ?? '0').toString()) ?? 0,
      quantity: int.tryParse((json['quantity'] ?? json['orderQuantity'] ?? json['legQuantity'] ?? '0').toString()) ?? 0,
    );
  }
}

class OrderModel {
  final String orderId;
  final String orderStatus;
  final String transactionType;
  final String tradingSymbol;
  final String exchangeSegment;
  final String orderType;
  final String productType;
  final int quantity;
  final double price;
  final double triggerPrice;
  final String createTime;
  final String updateTime;
  // super-order specific
  final double targetPrice;
  final double stopLossPrice;
  final double trailingJump;
  final bool isSuperOrder;
  final List<OrderLeg> legs;
  final String securityId;

  OrderModel({
    required this.orderId,
    required this.orderStatus,
    required this.transactionType,
    required this.tradingSymbol,
    required this.exchangeSegment,
    required this.orderType,
    required this.productType,
    required this.quantity,
    required this.price,
    required this.triggerPrice,
    required this.createTime,
    required this.updateTime,
    this.targetPrice = 0,
    this.stopLossPrice = 0,
    this.trailingJump = 0,
    this.isSuperOrder = false,
    this.legs = const [],
    this.securityId = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json,
      {bool isSuperOrder = false}) {
    // Dhan API may use 'legs', 'legDetails', or 'orderLegs'
    final rawLegs = json['legs'] ?? json['legDetails'] ?? json['orderLegs'];
    final List<OrderLeg> legs = (rawLegs is List && rawLegs.isNotEmpty)
        ? rawLegs
            .map((l) => OrderLeg.fromJson(l as Map<String, dynamic>))
            .toList()
        : [];

    return OrderModel(
      orderId: json['orderId']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      tradingSymbol: json['tradingSymbol']?.toString() ?? '',
      exchangeSegment: json['exchangeSegment']?.toString() ?? '',
      orderType: json['orderType']?.toString() ?? '',
      productType: json['productType']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      triggerPrice: double.tryParse(json['triggerPrice']?.toString() ?? '0') ?? 0,
      createTime: json['createTime']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
      targetPrice: double.tryParse(json['targetPrice']?.toString() ?? '0') ?? 0,
      stopLossPrice: double.tryParse(json['stopLossPrice']?.toString() ?? '0') ?? 0,
      trailingJump: double.tryParse(json['trailingJump']?.toString() ?? '0') ?? 0,
      // auto-detect super order if legs exist even when flag not passed
      isSuperOrder: isSuperOrder || legs.isNotEmpty,
      legs: legs,
      securityId: json['securityId']?.toString() ?? '',
    );
  }

  bool get isExecuted {
    final status = orderStatus.toUpperCase();
    return status == 'TRADED' ||
        status == 'EXECUTED' ||
        status == 'CANCELLED' ||
        status == 'REJECTED';
  }

  bool get isOpen => !isExecuted;

  bool get isBuy => transactionType == 'BUY';

  bool get canModify => isOpen;

  bool get canCancel => isOpen;
}
