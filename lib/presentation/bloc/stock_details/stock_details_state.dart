import 'package:equatable/equatable.dart';
import '../../../data/models/chart_data.dart';
import '../../../data/models/constituent_stock.dart';
import '../../../data/models/market_item.dart';
export '../../../data/models/market_item.dart' show MarketItem;
import '../../../data/models/news_model.dart';
import '../../../data/models/portfolio_position.dart';

enum DetailsTab { overview, technical, news, options }
enum ChartDuration { d1, w1, m1, m3, m6, ytd, y1 }

class OptionStrike {
  final double strike;
  final Map<String, dynamic>? ce;
  final Map<String, dynamic>? pe;
  const OptionStrike({required this.strike, this.ce, this.pe});
}

class StockDetailsState extends Equatable {
  final DetailsTab marketTab;
  final ChartDuration duration;
  final int chartInterval;               // intraday candle interval in minutes
  final List<double> chartData;           // legacy — kept for compatibility
  final List<ChartCandle> candles;         // real chart candles
  final bool isChartLoading;
  final List<ConstituentStock> constituents;
  final List<String> durationDropdown;
  final String selectedDropdown;
  final List<StockNews> news;
  final PortfolioPosition? position;
  final MarketItem? marketItem;

  // Available expiry dates for current underlying
  final List<String> availableExpiries;

  // Related F&O instruments (same underlying, nearby strikes)
  final List<MarketItem> relatedFNO;

  // Option chain
  final List<String> expiryDates;
  final String selectedExpiry;
  final double lastPrice;
  final List<OptionStrike> optionStrikes;
  final bool isOptionChainLoading;
  final String optionChainError;
  final double dailyOpen; // today's pre-open auction open from daily historical candle
  final bool isNewsLoading;
  final String newsError;

  // Progressive intraday history loading (backward pan in OverviewChart)
  final bool hasMoreIntradayHistory;
  final bool isLoadingOlderCandles;

  const StockDetailsState({
    this.marketTab = DetailsTab.overview,
    this.duration = ChartDuration.d1,
    this.chartInterval = 0,
    this.chartData = const [],
    this.candles = const [],
    this.isChartLoading = false,
    this.constituents = const [],
    this.durationDropdown = const ["1 Week", "1 Month", "3 Month", "6 Month"],
    this.selectedDropdown = "1 Week",
    this.news = const [],
    this.position,
    this.marketItem,
    this.availableExpiries = const [],
    this.relatedFNO = const [],
    this.expiryDates = const [],
    this.selectedExpiry = '',
    this.lastPrice = 0,
    this.optionStrikes = const [],
    this.isOptionChainLoading = false,
    this.optionChainError = '',
    this.dailyOpen = 0,
    this.isNewsLoading = false,
    this.newsError = '',
    this.hasMoreIntradayHistory = true,
    this.isLoadingOlderCandles = false,
  });

  String get displayName =>
      marketItem?.name ?? position?.tradingSymbol ?? '';
  String get displayExchange =>
      marketItem?.exchange ?? position?.exchangeSegment ?? '';
  String get securityId =>
      marketItem?.securityId ?? position?.securityId ?? '';
  String get exchangeSegment =>
      marketItem?.exchangeSegment ?? position?.exchangeSegment ?? '';

  StockDetailsState copyWith({
    DetailsTab? marketTab,
    ChartDuration? duration,
    int? chartInterval,
    List<double>? chartData,
    List<ChartCandle>? candles,
    bool? isChartLoading,
    List<ConstituentStock>? constituents,
    List<String>? durationDropdown,
    String? selectedDropdown,
    List<StockNews>? news,
    PortfolioPosition? position,
    MarketItem? marketItem,
    List<String>? availableExpiries,
    List<MarketItem>? relatedFNO,
    List<String>? expiryDates,
    String? selectedExpiry,
    double? lastPrice,
    List<OptionStrike>? optionStrikes,
    bool? isOptionChainLoading,
    String? optionChainError,
    double? dailyOpen,
    bool? isNewsLoading,
    String? newsError,
    bool? hasMoreIntradayHistory,
    bool? isLoadingOlderCandles,
  }) {
    return StockDetailsState(
      marketTab: marketTab ?? this.marketTab,
      duration: duration ?? this.duration,
      chartInterval: chartInterval ?? this.chartInterval,
      chartData: chartData ?? this.chartData,
      candles: candles ?? this.candles,
      isChartLoading: isChartLoading ?? this.isChartLoading,
      constituents: constituents ?? this.constituents,
      durationDropdown: durationDropdown ?? this.durationDropdown,
      selectedDropdown: selectedDropdown ?? this.selectedDropdown,
      news: news ?? this.news,
      position: position ?? this.position,
      marketItem: marketItem ?? this.marketItem,
      availableExpiries: availableExpiries ?? this.availableExpiries,
      relatedFNO: relatedFNO ?? this.relatedFNO,
      expiryDates: expiryDates ?? this.expiryDates,
      selectedExpiry: selectedExpiry ?? this.selectedExpiry,
      lastPrice: lastPrice ?? this.lastPrice,
      optionStrikes: optionStrikes ?? this.optionStrikes,
      isOptionChainLoading: isOptionChainLoading ?? this.isOptionChainLoading,
      optionChainError: optionChainError ?? this.optionChainError,
      dailyOpen: dailyOpen ?? this.dailyOpen,
      isNewsLoading: isNewsLoading ?? this.isNewsLoading,
      newsError: newsError ?? this.newsError,
      hasMoreIntradayHistory: hasMoreIntradayHistory ?? this.hasMoreIntradayHistory,
      isLoadingOlderCandles: isLoadingOlderCandles ?? this.isLoadingOlderCandles,
    );
  }

  @override
  List<Object?> get props => [
    marketTab, duration, chartInterval, chartData, candles, isChartLoading,
    constituents, durationDropdown, selectedDropdown, news,
    position, marketItem, availableExpiries, relatedFNO, expiryDates,
    selectedExpiry, lastPrice, optionStrikes, isOptionChainLoading, optionChainError,
    dailyOpen, isNewsLoading, newsError, hasMoreIntradayHistory, isLoadingOlderCandles,
  ];
}
