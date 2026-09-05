import 'package:equatable/equatable.dart';
import 'package:investapas/presentation/bloc/trading_terminal/terminal_state.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
}

class ChangeMarketTab extends TerminalEvent {
  final MarketTab tab;
  const ChangeMarketTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SearchStockEvent extends TerminalEvent {
  final String query;
  const SearchStockEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadPortfolioEvent extends TerminalEvent {
  const LoadPortfolioEvent();
}

class LoadInstrumentsEvent extends TerminalEvent {
  final int page;
  const LoadInstrumentsEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ChangeTerminalSubViewEvent extends TerminalEvent {
  final TerminalSubView subView;
  const ChangeTerminalSubViewEvent(this.subView);

  @override
  List<Object?> get props => [subView];
}

class RefreshPortfolioSilentEvent extends TerminalEvent {
  const RefreshPortfolioSilentEvent();
}

class LivePriceUpdateEvent extends TerminalEvent {
  final String securityId;
  final double ltp;
  final double open;
  final double close;
  final double high;
  final double low;

  const LivePriceUpdateEvent({
    required this.securityId,
    required this.ltp,
    this.open = 0.0,
    this.close = 0.0,
    this.high = 0.0,
    this.low = 0.0,
  });

  @override
  List<Object?> get props => [securityId, ltp];
}

class SubscribeMarketEvent extends TerminalEvent {
  const SubscribeMarketEvent();
}

class DisconnectMarketEvent extends TerminalEvent {
  const DisconnectMarketEvent();
}

class SocketConnectedEvent extends TerminalEvent {
  const SocketConnectedEvent();
}

class SocketDisconnectedEvent extends TerminalEvent {
  const SocketDisconnectedEvent();
}

class SubscribeAdditionalItemsEvent extends TerminalEvent {
  final List<dynamic> items;
  const SubscribeAdditionalItemsEvent(this.items);

  @override
  List<Object?> get props => [items];
}