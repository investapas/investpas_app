import 'package:equatable/equatable.dart';

enum MarketSection { gainers, losers }

class MarketIndexData {
  final String securityId;
  final String symbol;
  final double ltp;
  final double open;
  final double high;
  final double low;
  final double prevClose;
  final double change;
  final double changePct;

  const MarketIndexData({
    required this.securityId,
    required this.symbol,
    required this.ltp,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.change,
    required this.changePct,
  });

  factory MarketIndexData.fromJson(Map<String, dynamic> j) => MarketIndexData(
        securityId: j['securityId']?.toString() ?? '',
        symbol:     j['symbol']?.toString()     ?? '',
        ltp:        (j['ltp']       as num?)?.toDouble() ?? 0,
        open:       (j['open']      as num?)?.toDouble() ?? 0,
        high:       (j['high']      as num?)?.toDouble() ?? 0,
        low:        (j['low']       as num?)?.toDouble() ?? 0,
        prevClose:  (j['prevClose'] as num?)?.toDouble() ?? 0,
        change:     (j['change']    as num?)?.toDouble() ?? 0,
        changePct:  (j['changePct'] as num?)?.toDouble() ?? 0,
      );
}

class MarketMover {
  final String tradingSymbol;
  final double ltp;
  final double change;
  final double changePct;
  final double volume;
  final String securityId;

  const MarketMover({
    required this.tradingSymbol,
    required this.ltp,
    required this.change,
    required this.changePct,
    required this.volume,
    required this.securityId,
  });

  factory MarketMover.fromJson(Map<String, dynamic> j) {
    // Dhan market movers field names (log-verified; null-safe fallbacks)
    return MarketMover(
      tradingSymbol: j['tradingSymbol']?.toString()                        ?? j['symbol']?.toString() ?? '—',
      ltp:           (j['lastTradedPrice'] as num?)?.toDouble()            ?? (j['ltp'] as num?)?.toDouble() ?? 0,
      change:        (j['change']          as num?)?.toDouble()            ?? 0,
      changePct:     (j['percentageChange'] as num?)?.toDouble()           ?? (j['changePct'] as num?)?.toDouble() ?? 0,
      volume:        (j['volume']           as num?)?.toDouble()           ?? 0,
      securityId:    j['securityId']?.toString()                           ?? '',
    );
  }
}

class MarketState extends Equatable {
  final bool isLoading;
  final String error;
  final List<MarketMover> topGainers;
  final List<MarketMover> topLosers;
  final MarketIndexData? nifty50;
  final MarketIndexData? bankNifty;
  final MarketSection activeSection;

  const MarketState({
    this.isLoading   = false,
    this.error       = '',
    this.topGainers  = const [],
    this.topLosers   = const [],
    this.nifty50,
    this.bankNifty,
    this.activeSection = MarketSection.gainers,
  });

  MarketState copyWith({
    bool? isLoading,
    String? error,
    List<MarketMover>? topGainers,
    List<MarketMover>? topLosers,
    MarketIndexData? nifty50,
    MarketIndexData? bankNifty,
    MarketSection? activeSection,
  }) =>
      MarketState(
        isLoading:     isLoading     ?? this.isLoading,
        error:         error         ?? this.error,
        topGainers:    topGainers    ?? this.topGainers,
        topLosers:     topLosers     ?? this.topLosers,
        nifty50:       nifty50       ?? this.nifty50,
        bankNifty:     bankNifty     ?? this.bankNifty,
        activeSection: activeSection ?? this.activeSection,
      );

  @override
  List<Object?> get props => [isLoading, error, topGainers, topLosers, nifty50, bankNifty, activeSection];
}
