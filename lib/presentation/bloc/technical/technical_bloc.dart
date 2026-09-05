import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/network/api_endpoints.dart';
import 'package:investapas/core/network/api_service.dart';
import 'package:investapas/data/models/pivot_model.dart';
import 'package:investapas/data/models/technical_type_model.dart';
import 'package:investapas/presentation/bloc/technical/technical_event.dart';
import 'package:investapas/presentation/bloc/technical/technical_state.dart';

class TechnicalBloc extends Bloc<TechnicalEvent, TechnicalState> {
  TechnicalBloc() : super(const TechnicalState()) {
    on<ChangeDuration>((event, emit) {
      emit(state.copyWith(duration: event.duration));
      // Re-fetch if we already have a stock loaded
      if (state.securityId.isNotEmpty) {
        add(LoadTechnicalDataEvent(
          securityId: state.securityId,
          exchangeSegment: state.exchangeSegment,
          instrument: state.instrument,
        ));
      }
    });

    on<ChangeTypeDuration>((event, emit) {
      emit(state.copyWith(selectedDropdown: event.duration));
    });

    on<LoadTechnicalDataEvent>((event, emit) async {
      // Skip if same stock already loaded
      if (state.securityId == event.securityId && !state.isLoading &&
          state.oscillatorList.isNotEmpty) return;

      emit(state.copyWith(
        isLoading: true,
        error: '',
        securityId: event.securityId,
        exchangeSegment: event.exchangeSegment,
        instrument: event.instrument,
      ));

      try {
        final resp = await ApiHelper.post(ApiEndpoints.technicalApi, {
          'securityId': event.securityId,
          'exchangeSegment': event.exchangeSegment,
          'instrument': event.instrument,
        });

        if (resp == null || resp['success'] != true) {
          emit(state.copyWith(
            isLoading: false,
            error: resp?['message'] ?? 'Failed to load technical data',
          ));
          return;
        }

        final oscillators = (resp['oscillators'] as List? ?? [])
            .map((e) => TechnicalTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final movingAverages = (resp['movingAverages'] as List? ?? [])
            .map((e) => TechnicalTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final pivotList = (resp['pivots'] as List? ?? [])
            .map((e) => PivotModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final summary = resp['summary'] as Map<String, dynamic>? ?? {};
        final buy     = (summary['buy']     as num? ?? 0).toInt();
        final sell    = (summary['sell']    as num? ?? 0).toInt();
        final neutral = (summary['neutral'] as num? ?? 0).toInt();
        final total   = buy + sell + neutral;
        final score   = total == 0 ? 50.0 : (buy / total) * 100.0;

        emit(state.copyWith(
          isLoading: false,
          error: '',
          oscillatorList: oscillators,
          movingList: movingAverages,
          pivotList: pivotList,
          buy: buy,
          sell: sell,
          neutral: neutral,
          oscillatorScore: score,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}
