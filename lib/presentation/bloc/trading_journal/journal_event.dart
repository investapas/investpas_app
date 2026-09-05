import 'package:equatable/equatable.dart';
import 'journal_state.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class ToggleWeightedAverage extends JournalEvent {
  final bool value;
  const ToggleWeightedAverage(this.value);

  @override
  List<Object?> get props => [value];
}

class ChangeJournalView extends JournalEvent {
  final JournalViewType viewType;
  const ChangeJournalView(this.viewType);

  @override
  List<Object?> get props => [viewType];
}

class SelectJournalDate extends JournalEvent {
  final DateTime date;
  const SelectJournalDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectYearMonth extends JournalEvent {
  final int year;
  final int month;

  const SelectYearMonth(this.year, this.month);

  @override
  List<Object?> get props => [year, month];
}

class LoadTradeHistoryEvent extends JournalEvent {
  final DateTime fromDate;
  final DateTime toDate;

  const LoadTradeHistoryEvent({
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [fromDate, toDate];
}

class LoadPositionsEvent extends JournalEvent {
  final DateTime date;

  LoadPositionsEvent({DateTime? date})
      : date = date ?? DateTime.now();

  @override
  List<Object?> get props => [date];
}