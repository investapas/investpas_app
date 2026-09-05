import 'package:equatable/equatable.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_state.dart';

abstract class OptionChangeEvent extends Equatable {
  const OptionChangeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeOptionTab extends OptionChangeEvent {
  final optionTab tab;
  const ChangeOptionTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class LoadOptionList extends OptionChangeEvent {}

class SearchOptionList extends OptionChangeEvent {
  final String query;
  const SearchOptionList(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeOptionDuration extends OptionChangeEvent {
  final String duration;
  const ChangeOptionDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class SetOptionData extends OptionChangeEvent {
  final List<dynamic> items;
  const SetOptionData(this.items);

  @override
  List<Object?> get props => [items];
}