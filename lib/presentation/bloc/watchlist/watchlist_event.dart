import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object?> get props => [];
}

class LoadWatchlist extends WatchlistEvent {}

class SearchWatchlistLocal extends WatchlistEvent {
  final String query;
  const SearchWatchlistLocal(this.query);
  @override
  List<Object?> get props => [query];
}

class AddToWatchlist extends WatchlistEvent {
  final String securityId;
  const AddToWatchlist(this.securityId);
  @override
  List<Object?> get props => [securityId];
}

class RemoveFromWatchlist extends WatchlistEvent {
  final String securityId;
  const RemoveFromWatchlist(this.securityId);
  @override
  List<Object?> get props => [securityId];
}
