import 'package:equatable/equatable.dart';
import 'package:investapas/data/models/option_chain_model.dart';

enum optionTab { oi, greeks }

class OptionChainState extends Equatable {
  final optionTab marketTab;
  final List<OptionChainModel> allItems;
  final List<OptionChainModel> visibleItems;
  final String search;
  final List<String> durationDropdown;
  final String selectedDropdown;

  const OptionChainState({
    this.marketTab = optionTab.oi,
    this.allItems = const [],
    this.visibleItems = const [],
    this.search = '',
    this.durationDropdown = const ["30 Dec", "31 Dec", "1 Jan", "2 Jan"],
    this.selectedDropdown = "30 Dec",
  });

  OptionChainState copyWith({
    optionTab? marketTab,
    List<OptionChainModel>? allItems,
    List<OptionChainModel>? visibleItems,
    String? search,
    List<String>? durationDropdown,
    String? selectedDropdown,
  }) {
    return OptionChainState(
      marketTab: marketTab ?? this.marketTab,
      allItems: allItems ?? this.allItems,
      visibleItems: visibleItems ?? this.visibleItems,
      search: search ?? this.search,
      durationDropdown: durationDropdown ?? this.durationDropdown,
      selectedDropdown: selectedDropdown ?? this.selectedDropdown,
    );
  }

  @override
  List<Object> get props =>
      [marketTab, allItems, visibleItems, search, durationDropdown, selectedDropdown];
}
