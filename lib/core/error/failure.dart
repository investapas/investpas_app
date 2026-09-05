import 'package:equatable/equatable.dart';

/// failure class
abstract class Failure extends Equatable {
  /// message
  final String message;
  /// constructor
  const Failure(this.message);

  @override
  List<Object> get props => <Object>[message];
}

/// ServerFailure class
class ServerFailure extends Failure {
  /// constructor
  const ServerFailure(super.message);
}

/// ConnectionFailure class
class ConnectionFailure extends Failure {
  /// constructor
  const ConnectionFailure(super.message);
}

/// DatabaseFailure class
class DatabaseFailure extends Failure {
  /// constructor
  const DatabaseFailure(super.message);
}
