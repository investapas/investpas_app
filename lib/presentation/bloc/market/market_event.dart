import 'market_state.dart';

abstract class MarketEvent {}

class LoadMarketDataEvent extends MarketEvent {}

class ChangeMarketSectionEvent extends MarketEvent {
  final MarketSection section;
  ChangeMarketSectionEvent(this.section);
}
