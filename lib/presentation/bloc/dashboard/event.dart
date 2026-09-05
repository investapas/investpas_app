
import 'package:equatable/equatable.dart';

/// dash board event
abstract class DashboardEvent extends Equatable {
  /// constructor
  const DashboardEvent();
  @override
  List<Object> get props => [];
}

/// change page event
class ChangeTabDashBoardEvent extends DashboardEvent {
  /// page index
  final int pageIndex;
  /// constructor
  const ChangeTabDashBoardEvent(this.pageIndex);
  @override
  List<Object> get props => [pageIndex];
}

class LoadUserPrefsEvent extends DashboardEvent {}

class LoadChallengeEvent extends DashboardEvent {}
