import 'package:equatable/equatable.dart';
import '../../../data/models/demo_order_model.dart';

class DemoState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final List<DemoOrderModel> orders;
  final List<DemoPositionModel> portfolio;

  // Today's realized P&L (from positions fully or partially sold today)
  final double realizedPnl;
  final List<DemoClosedPositionModel> closedToday;     // today's sells only
  final List<DemoClosedPositionModel> closedAllTime;   // all-time sells

  // Coin wallet
  final double availableCoins;
  final double totalGrantedCoins;
  final double coinPackPrice;
  final int    coinPackCoins;

  // First-time activation flag — set true once so UI can show welcome dialog
  final bool showWelcomeDialog;

  final String error;
  final String actionMessage;
  final bool actionSuccess;

  const DemoState({
    this.isLoading          = false,
    this.isActionLoading    = false,
    this.orders             = const [],
    this.portfolio          = const [],
    this.realizedPnl        = 0,
    this.closedToday        = const [],
    this.closedAllTime      = const [],
    this.availableCoins     = 0,
    this.totalGrantedCoins  = 0,
    this.coinPackPrice      = 100,
    this.coinPackCoins      = 100000,
    this.showWelcomeDialog  = false,
    this.error              = '',
    this.actionMessage      = '',
    this.actionSuccess      = false,
  });

  DemoState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<DemoOrderModel>? orders,
    List<DemoPositionModel>? portfolio,
    double? realizedPnl,
    List<DemoClosedPositionModel>? closedToday,
    List<DemoClosedPositionModel>? closedAllTime,
    double? availableCoins,
    double? totalGrantedCoins,
    double? coinPackPrice,
    int?    coinPackCoins,
    bool?   showWelcomeDialog,
    String? error,
    String? actionMessage,
    bool?   actionSuccess,
  }) => DemoState(
    isLoading:         isLoading         ?? this.isLoading,
    isActionLoading:   isActionLoading   ?? this.isActionLoading,
    orders:            orders            ?? this.orders,
    portfolio:         portfolio         ?? this.portfolio,
    realizedPnl:       realizedPnl       ?? this.realizedPnl,
    closedToday:       closedToday       ?? this.closedToday,
    closedAllTime:     closedAllTime     ?? this.closedAllTime,
    availableCoins:    availableCoins    ?? this.availableCoins,
    totalGrantedCoins: totalGrantedCoins ?? this.totalGrantedCoins,
    coinPackPrice:     coinPackPrice     ?? this.coinPackPrice,
    coinPackCoins:     coinPackCoins     ?? this.coinPackCoins,
    showWelcomeDialog: showWelcomeDialog ?? this.showWelcomeDialog,
    error:             error             ?? this.error,
    actionMessage:     actionMessage     ?? this.actionMessage,
    actionSuccess:     actionSuccess     ?? this.actionSuccess,
  );

  @override
  List<Object?> get props => [
    isLoading, isActionLoading, orders, portfolio,
    realizedPnl, closedToday, closedAllTime,
    availableCoins, totalGrantedCoins, coinPackPrice, coinPackCoins,
    showWelcomeDialog, error, actionMessage, actionSuccess,
  ];
}
