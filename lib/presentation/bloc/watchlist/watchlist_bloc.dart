import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/market_item.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc() : super(const WatchlistState()) {

    on<LoadWatchlist>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final response = await ApiHelper.get(ApiEndpoints.wishlistApi);
        if (response != null && response["status"] == true) {
          final List data = response["data"] ?? [];
          final items = data.map<MarketItem>((e) => MarketItem(
            securityId: e['securityId']?.toString() ?? '',
            name: e['name'] ?? '',
            symbol: e['symbol'] ?? '',
            exchange: e['exchange'] ?? '',
            exchangeSegment: e['exchangeSegment'] ?? '',
            lotSize: e['lotSize']?.toString() ?? '1',
            isUp: true,
            strikePrice: e['strikePrice']?.toString(),
            optionType: e['optionType']?.toString(),
            expiry: e['expiry']?.toString(),
          )).toList();
          final ids = items.map((e) => e.securityId).toList();
          emit(state.copyWith(
            allItems: items,
            visibleItems: items,
            watchlistIds: ids,
            isLoading: false,
          ));
        } else {
          emit(state.copyWith(isLoading: false));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<SearchWatchlistLocal>((event, emit) {
      final q = event.query.toLowerCase();
      final filtered = q.isEmpty
          ? state.allItems
          : state.allItems.where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.symbol.toLowerCase().contains(q)).toList();
      emit(state.copyWith(search: event.query, visibleItems: filtered));
    });

    on<AddToWatchlist>((event, emit) async {
      try {
        final response = await ApiHelper.post(
          ApiEndpoints.wishlistAddApi,
          {"securityId": event.securityId},
        );

        if (response != null && response["status"] == true) {
          final d = response["data"];
          final newItem = MarketItem(
            securityId: d['securityId']?.toString() ?? '',
            name: d['name'] ?? '',
            symbol: d['symbol'] ?? '',
            exchange: d['exchange'] ?? '',
            exchangeSegment: '',
            lotSize: d['lotSize']?.toString() ?? '1',
            isUp: true,
            strikePrice: d['strikePrice']?.toString(),
            optionType: d['optionType']?.toString(),
            expiry: d['expiry']?.toString(),
          );


          final updatedAll = [...state.allItems, newItem];
          final updatedIds = [...state.watchlistIds, event.securityId];
          final updatedVisible = state.search.isEmpty
              ? updatedAll
              : updatedAll.where((e) =>
                  e.name.toLowerCase().contains(state.search.toLowerCase()) ||
                  e.symbol.toLowerCase().contains(state.search.toLowerCase())).toList();
          emit(state.copyWith(
            allItems: updatedAll,
            visibleItems: updatedVisible,
            watchlistIds: updatedIds,
          ));
        }
      } catch (_) {}
    });

    on<RemoveFromWatchlist>((event, emit) async {
      try {
        final response = await ApiHelper.post(
          ApiEndpoints.wishlistRemoveApi,
          {"securityId": event.securityId},
        );
        if (response != null && response["status"] == true) {
          final updatedAll = state.allItems.where((e) => e.securityId != event.securityId).toList();
          final updatedIds = state.watchlistIds.where((id) => id != event.securityId).toList();
          final updatedVisible = state.visibleItems.where((e) => e.securityId != event.securityId).toList();
          emit(state.copyWith(
            allItems: updatedAll,
            visibleItems: updatedVisible,
            watchlistIds: updatedIds,
          ));
        }
      } catch (_) {}
    });

    add(LoadWatchlist());
  }
}
