import 'package:equatable/equatable.dart';
import 'package:investapas/presentation/bloc/technical/technical_state.dart';

abstract class TechnicalEvent extends Equatable {
  const TechnicalEvent();

  @override
  List<Object?> get props => [];
}

class ChangeDuration extends TechnicalEvent {
  final TechnicalDuration duration;
  const ChangeDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class ChangeTypeDuration extends TechnicalEvent {
  final String duration;
  const ChangeTypeDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class LoadTechnicalDataEvent extends TechnicalEvent {
  final String securityId;
  final String exchangeSegment;
  final String instrument;

  const LoadTechnicalDataEvent({
    required this.securityId,
    required this.exchangeSegment,
    required this.instrument,
  });

  @override
  List<Object?> get props => [securityId, exchangeSegment, instrument];
}
