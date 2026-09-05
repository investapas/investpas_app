import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/trade_history.dart';
import '../../../domain/repositories/portfolio.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final TradeHistoryRepository _tradeHistoryRepository = TradeHistoryRepository.instance;
  final PortfolioRepository _portfolioRepository = PortfolioRepository.instance;

  JournalBloc() : super(JournalState()) {

    on<ToggleWeightedAverage>((event, emit) {
      if (state.isWeightedAvg != event.value) {
        emit(state.copyWith(isWeightedAvg: event.value));
      }
    });

    on<ChangeJournalView>((event, emit) {
      if (state.viewType != event.viewType) {
        emit(state.copyWith(viewType: event.viewType));
      }
    });

    on<SelectJournalDate>((event, emit) {
      if (state.selectedDate != event.date) {
        emit(state.copyWith(selectedDate: event.date));
      }
    });

    on<SelectYearMonth>((event, emit) {
      final newDate = DateTime(event.year, event.month, 1);

      emit(
        state.copyWith(
          selectedDate: newDate,
          viewType: JournalViewType.month,
        ),
      );
    });

    on<LoadTradeHistoryEvent>((event, emit) async {
      emit(state.copyWith(isLoadingTrades: true, tradeError: null));

      try {
        final result = await _tradeHistoryRepository.getTradeHistory(
          fromDate: '${event.fromDate.year}-${event.fromDate.month.toString().padLeft(2, '0')}-${event.fromDate.day.toString().padLeft(2, '0')}',
          toDate: '${event.toDate.year}-${event.toDate.month.toString().padLeft(2, '0')}-${event.toDate.day.toString().padLeft(2, '0')}',
        );

        if (result['status'] == true) {
          emit(state.copyWith(
            tradesByDate: result['data'],
            tradeSummary: result['summary'],
            isLoadingTrades: false,
          ));
        } else {
          emit(state.copyWith(
            isLoadingTrades: false,
            tradeError: 'Failed to load trade history',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          isLoadingTrades: false,
          tradeError: e.toString(),
        ));
      }
    });

    on<LoadPositionsEvent>((event, emit) async {
      emit(state.copyWith(isLoadingPositions: true, positionsError: null));

      try {
        final positions = await _portfolioRepository.getPortfolio();
        emit(state.copyWith(
          positions: positions,
          isLoadingPositions: false,
          positionsDate: event.date,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoadingPositions: false,
          positionsError: e.toString(),
        ));
      }
    });

    // Initial load - load trade history for current month
    add(LoadTradeHistoryEvent(
      fromDate: DateTime(state.selectedDate.year, state.selectedDate.month, 1),
      toDate: DateTime.now(),
    ));
    add(LoadPositionsEvent(date: DateTime.now()));
  }
}