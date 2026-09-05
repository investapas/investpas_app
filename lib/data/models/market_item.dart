class MarketItem {
  final String securityId;
  final String name;
  final String symbol;
  final String exchange;
  final String exchangeSegment;
  final String lotSize;
  final bool isUp;
  final String? strikePrice;
  final String? optionType;
  final String? expiry;
  final double ltp;
  final double open;
  final double close;
  final double high;
  final double low;

  MarketItem({
    required this.securityId,
    required this.name,
    required this.symbol,
    required this.exchange,
    required this.exchangeSegment,
    required this.lotSize,
    required this.isUp,
    this.strikePrice,
    this.optionType,
    this.expiry,
    this.ltp = 0.0,
    this.open = 0.0,
    this.close = 0.0,
    this.high = 0.0,
    this.low = 0.0,
  });

  double get change => close > 0 ? ltp - close : 0.0;
  double get changePercent => close > 0 ? ((ltp - close) / close) * 100 : 0.0;
  bool get priceIsUp => change >= 0;

  MarketItem copyWith({
    double? ltp,
    double? open,
    double? close,
    double? high,
    double? low,
    bool? isUp,
  }) {
    return MarketItem(
      securityId: securityId,
      name: name,
      symbol: symbol,
      exchange: exchange,
      exchangeSegment: exchangeSegment,
      lotSize: lotSize,
      isUp: isUp ?? this.isUp,
      strikePrice: strikePrice,
      optionType: optionType,
      expiry: expiry,
      ltp: ltp ?? this.ltp,
      open: open ?? this.open,
      close: close ?? this.close,
      high: high ?? this.high,
      low: low ?? this.low,
    );
  }
}
