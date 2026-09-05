import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/data/models/option_chain_model.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_state.dart';
import 'package:investapas/presentation/bloc/option_chain/option_change_event.dart';

class OptionChainBloc extends Bloc<OptionChangeEvent, OptionChainState> {
  OptionChainBloc() : super(const OptionChainState()) {
    on<ChangeOptionTab>((event, emit) {
      print("OLD: ${state.marketTab} NEW: ${event.tab}");
      emit(state.copyWith(marketTab: event.tab));
    });

    on<LoadOptionList>((event, emit) {
      final data = [
        OptionChainModel(callOi: "13,600", putOi: "1,02,182", changeOi: "-99", strike: "25,850", callVolume: "10,116"),
        OptionChainModel(callOi: "68,325", putOi: "1,50,263", changeOi: "-94", strike: "25,900", callVolume: "41,186"),
        OptionChainModel(callOi: "1,23,100", putOi: "97,531", changeOi: "-84", strike: "25,950", callVolume: "1,06,547"),
        OptionChainModel(callOi: "3,07,118", putOi: "1,51,630", changeOi: "-70", strike: "26,000", callVolume: "1,58,127"),
        OptionChainModel(callOi: "1,57,169", putOi: "28,039", changeOi: "-52", strike: "26,050", callVolume: "48,456"),
      ];

      emit(state.copyWith(
        allItems: data,
        visibleItems: data,
      ));
    });

    /// SEARCH FILTER
    on<SearchOptionList>((event, emit) {
      final query = event.query.toLowerCase();
      final filtered = state.allItems.where((e) =>
          e.callOi.toLowerCase().contains(query)
      ).toList();

      emit(state.copyWith(
        search: event.query,
        visibleItems: filtered,
      ));
    });

    on<ChangeOptionDuration>((event, emit) {
      emit(state.copyWith(selectedDropdown: event.duration));
    });

    on<SetOptionData>((event, emit) {
      final items = List<OptionChainModel>.from(event.items);
      emit(state.copyWith(allItems: items, visibleItems: items));
    });

    add(const ChangeOptionTab(optionTab.oi));
  }
}