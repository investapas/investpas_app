import 'package:equatable/equatable.dart';

import '../../../data/models/market_item.dart';
import '../../../data/models/portfolio_position.dart';

enum MarketTab { indices, global }
enum TerminalSubView { main, positions, watchlist, orders }

class TerminalState extends Equatable {
  final MarketTab marketTab;
  final List<MarketItem> items;

  final List<MarketItem> searchItems;
  final bool isLoading;
  final String searchQuery;

  final List<PortfolioPosition> portfolioPositions;
  final bool portfolioLoading;
  final double totalPortfolioPnL;

  final List<MarketItem> instrumentItems;
  final int instrumentsPage;
  final int instrumentsTotalPages;
  final bool instrumentsLoading;
  final TerminalSubView subView;
  final Map<String, double> livePrices; // securityId -> ltp
  final bool isSocketConnected;

  const TerminalState({
    this.marketTab = MarketTab.indices,
    this.items = const [],
    this.searchItems = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.portfolioPositions = const [],
    this.portfolioLoading = false,
    this.totalPortfolioPnL = 0.0,
    this.instrumentItems = const [],
    this.instrumentsPage = 0,
    this.instrumentsTotalPages = 1,
    this.instrumentsLoading = false,
    this.subView = TerminalSubView.main,
    this.livePrices = const {},
    this.isSocketConnected = false,
  });

  bool get hasMoreInstruments => instrumentsPage < instrumentsTotalPages;

  TerminalState copyWith({
    MarketTab? marketTab,
    List<MarketItem>? items,
    List<MarketItem>? searchItems,
    bool? isLoading,
    String? searchQuery,
    List<PortfolioPosition>? portfolioPositions,
    bool? portfolioLoading,
    double? totalPortfolioPnL,
    List<MarketItem>? instrumentItems,
    int? instrumentsPage,
    int? instrumentsTotalPages,
    bool? instrumentsLoading,
    TerminalSubView? subView,
    Map<String, double>? livePrices,
    bool? isSocketConnected,
  }) {
    return TerminalState(
      marketTab: marketTab ?? this.marketTab,
      items: items ?? this.items,
      searchItems: searchItems ?? this.searchItems,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      portfolioPositions: portfolioPositions ?? this.portfolioPositions,
      portfolioLoading: portfolioLoading ?? this.portfolioLoading,
      totalPortfolioPnL: totalPortfolioPnL ?? this.totalPortfolioPnL,
      instrumentItems: instrumentItems ?? this.instrumentItems,
      instrumentsPage: instrumentsPage ?? this.instrumentsPage,
      instrumentsTotalPages: instrumentsTotalPages ?? this.instrumentsTotalPages,
      instrumentsLoading: instrumentsLoading ?? this.instrumentsLoading,
      subView: subView ?? this.subView,
      livePrices: livePrices ?? this.livePrices,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
    );
  }

  @override
  List<Object> get props => [
    marketTab, items, searchItems, isLoading, searchQuery,
    portfolioPositions, portfolioLoading, totalPortfolioPnL,
    instrumentItems, instrumentsPage, instrumentsTotalPages, instrumentsLoading,
    subView, livePrices, isSocketConnected,
  ];
}
