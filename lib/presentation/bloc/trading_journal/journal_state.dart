import 'package:equatable/equatable.dart';
import '../../../data/models/trade_history.dart';
import '../../../data/models/portfolio_position.dart';

enum JournalViewType { list, month, year }

class JournalState extends Equatable {
  final bool isWeightedAvg;
  final JournalViewType viewType;
  final DateTime selectedDate;
  
  // Trade history data
  final Map<String, List<TradePosition>> tradesByDate;
  final List<TradeHistorySummary> tradeSummary;
  final bool isLoadingTrades;
  final String? tradeError;
  
  // Positions data
  final List<PortfolioPosition> positions;
  final bool isLoadingPositions;
  final String? positionsError;
  final DateTime? positionsDate;

  JournalState({
    this.isWeightedAvg = false,
    this.viewType = JournalViewType.month,
    DateTime? selectedDate,
    this.tradesByDate = const {},
    this.tradeSummary = const [],
    this.isLoadingTrades = false,
    this.tradeError,
    this.positions = const [],
    this.isLoadingPositions = false,
    this.positionsError,
    this.positionsDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  JournalState copyWith({
    bool? isWeightedAvg,
    JournalViewType? viewType,
    DateTime? selectedDate,
    Map<String, List<TradePosition>>? tradesByDate,
    List<TradeHistorySummary>? tradeSummary,
    bool? isLoadingTrades,
    String? tradeError,
    List<PortfolioPosition>? positions,
    bool? isLoadingPositions,
    String? positionsError,
    DateTime? positionsDate,
  }) {
    return JournalState(
      isWeightedAvg: isWeightedAvg ?? this.isWeightedAvg,
      viewType: viewType ?? this.viewType,
      selectedDate: selectedDate ?? this.selectedDate,
      tradesByDate: tradesByDate ?? this.tradesByDate,
      tradeSummary: tradeSummary ?? this.tradeSummary,
      isLoadingTrades: isLoadingTrades ?? this.isLoadingTrades,
      tradeError: tradeError ?? this.tradeError,
      positions: positions ?? this.positions,
      isLoadingPositions: isLoadingPositions ?? this.isLoadingPositions,
      positionsError: positionsError ?? this.positionsError,
      positionsDate: positionsDate ?? this.positionsDate,
    );
  }

  @override
  List<Object?> get props => [
    isWeightedAvg,
    viewType,
    selectedDate,
    tradesByDate,
    tradeSummary,
    isLoadingTrades,
    tradeError,
    positions,
    isLoadingPositions,
    positionsError,
    positionsDate,
  ];
}
