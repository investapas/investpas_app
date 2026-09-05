import 'package:equatable/equatable.dart';
import 'package:investapas/data/models/market_item.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';
import 'package:investapas/data/models/portfolio_position.dart';

abstract class StockDetailsEvent extends Equatable {
  const StockDetailsEvent();
  @override
  List<Object?> get props => [];
}

class ChangeDetailsTab extends StockDetailsEvent {
  final DetailsTab tab;
  const ChangeDetailsTab(this.tab);
  @override
  List<Object?> get props => [tab];
}

class ChangeDuration extends StockDetailsEvent {
  final ChartDuration duration;
  const ChangeDuration(this.duration);
  @override
  List<Object?> get props => [duration];
}

class ChangeInterval extends StockDetailsEvent {
  final int interval; // valid Dhan intraday intervals: 1, 5, 15, 25, 60
  const ChangeInterval(this.interval);
  @override
  List<Object?> get props => [interval];
}

class ChangeConstituentDuration extends StockDetailsEvent {
  final String duration;
  const ChangeConstituentDuration(this.duration);
  @override
  List<Object?> get props => [duration];
}

class InitializeWithPosition extends StockDetailsEvent {
  final PortfolioPosition position;
  const InitializeWithPosition(this.position);
  @override
  List<Object?> get props => [position];
}

class InitializeWithMarketItem extends StockDetailsEvent {
  final MarketItem item;
  const InitializeWithMarketItem(this.item);
  @override
  List<Object?> get props => [item];
}

class LoadConstituents extends StockDetailsEvent {}

class LoadNews extends StockDetailsEvent {}

class LoadChartEvent extends StockDetailsEvent {
  final ChartDuration duration;
  const LoadChartEvent(this.duration);
  @override
  List<Object?> get props => [duration];
}

class LoadOptionChainEvent extends StockDetailsEvent {
  final String expiry;
  const LoadOptionChainEvent(this.expiry);
  @override
  List<Object?> get props => [expiry];
}

class ChangeOptionExpiryEvent extends StockDetailsEvent {
  final String expiry;
  const ChangeOptionExpiryEvent(this.expiry);
  @override
  List<Object?> get props => [expiry];
}

class LoadRelatedFNOEvent extends StockDetailsEvent {}

class LoadExpiryDatesEvent extends StockDetailsEvent {}

// Fetches an older window of intraday candles (before the currently-loaded
// oldest candle) and merges it in — triggered by panning back past the
// loaded range in OverviewChart.
class LoadOlderCandlesEvent extends StockDetailsEvent {
  const LoadOlderCandlesEvent();
}

