import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc() : super(const MarketState()) {
    on<LoadMarketDataEvent>(_onLoad);
    on<ChangeMarketSectionEvent>((event, emit) =>
        emit(state.copyWith(activeSection: event.section)));
  }

  Future<void> _onLoad(LoadMarketDataEvent event, Emitter<MarketState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final resp = await ApiHelper.get(ApiEndpoints.marketDataApi);
      if (resp == null || resp['status'] != true) {
        final msg = resp?['message']?.toString() ?? 'Failed to load market data';
        emit(state.copyWith(isLoading: false, error: msg));
        return;
      }

      final data = resp['data'] as Map<String, dynamic>? ?? {};

      final gainers = (data['topGainers'] as List? ?? [])
          .map((e) => MarketMover.fromJson(e as Map<String, dynamic>))
          .toList();

      final losers = (data['topLosers'] as List? ?? [])
          .map((e) => MarketMover.fromJson(e as Map<String, dynamic>))
          .toList();

      final nifty50Raw   = data['nifty50']   as Map<String, dynamic>?;
      final bankNiftyRaw = data['bankNifty'] as Map<String, dynamic>?;

      emit(state.copyWith(
        isLoading:  false,
        error:      '',
        topGainers: gainers,
        topLosers:  losers,
        nifty50:    nifty50Raw   != null ? MarketIndexData.fromJson(nifty50Raw)   : null,
        bankNifty:  bankNiftyRaw != null ? MarketIndexData.fromJson(bankNiftyRaw) : null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
