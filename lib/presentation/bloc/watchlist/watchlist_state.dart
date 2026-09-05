import 'package:equatable/equatable.dart';
import '../../../data/models/market_item.dart';

class WatchlistState extends Equatable {
  final List<MarketItem> allItems;
  final List<MarketItem> visibleItems;
  final String search;
  final bool isLoading;
  final List<String> watchlistIds;

  const WatchlistState({
    this.allItems = const [],
    this.visibleItems = const [],
    this.search = '',
    this.isLoading = false,
    this.watchlistIds = const [],
  });

  WatchlistState copyWith({
    List<MarketItem>? allItems,
    List<MarketItem>? visibleItems,
    String? search,
    bool? isLoading,
    List<String>? watchlistIds,
  }) {
    return WatchlistState(
      allItems: allItems ?? this.allItems,
      visibleItems: visibleItems ?? this.visibleItems,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      watchlistIds: watchlistIds ?? this.watchlistIds,
    );
  }

  @override
  List<Object> get props => [allItems, visibleItems, search, isLoading, watchlistIds];
}
