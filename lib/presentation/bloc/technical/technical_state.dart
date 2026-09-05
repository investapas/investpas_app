import 'package:equatable/equatable.dart';
import 'package:investapas/data/models/pivot_model.dart';

import '../../../data/models/technical_type_model.dart';

enum TechnicalDuration { min1, min5, min15, min30, hour1 }

class TechnicalState extends Equatable {
  final TechnicalDuration duration;
  final List<String> typeDropdown;
  final String selectedDropdown;
  final int buy;
  final int sell;
  final int neutral;
  final double oscillatorScore;
  final List<TechnicalTypeModel> oscillatorList;
  final List<TechnicalTypeModel> movingList;
  final List<PivotModel> pivotList;
  final bool isLoading;
  final String error;
  final String securityId;
  final String exchangeSegment;
  final String instrument;

  const TechnicalState({
    this.duration = TechnicalDuration.min1,
    this.typeDropdown = const ["Oscillators", "Moving Averages", "Pivots"],
    this.selectedDropdown = "Oscillators",
    this.buy = 0,
    this.sell = 0,
    this.neutral = 0,
    this.oscillatorScore = 50,
    this.oscillatorList = const [],
    this.movingList = const [],
    this.pivotList = const [],
    this.isLoading = false,
    this.error = '',
    this.securityId = '',
    this.exchangeSegment = '',
    this.instrument = '',
  });

  TechnicalState copyWith({
    TechnicalDuration? duration,
    List<String>? typeDropdown,
    String? selectedDropdown,
    int? buy,
    int? sell,
    int? neutral,
    double? oscillatorScore,
    List<TechnicalTypeModel>? oscillatorList,
    List<TechnicalTypeModel>? movingList,
    List<PivotModel>? pivotList,
    bool? isLoading,
    String? error,
    String? securityId,
    String? exchangeSegment,
    String? instrument,
  }) {
    return TechnicalState(
      duration: duration ?? this.duration,
      typeDropdown: typeDropdown ?? this.typeDropdown,
      selectedDropdown: selectedDropdown ?? this.selectedDropdown,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      neutral: neutral ?? this.neutral,
      oscillatorScore: oscillatorScore ?? this.oscillatorScore,
      oscillatorList: oscillatorList ?? this.oscillatorList,
      movingList: movingList ?? this.movingList,
      pivotList: pivotList ?? this.pivotList,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      securityId: securityId ?? this.securityId,
      exchangeSegment: exchangeSegment ?? this.exchangeSegment,
      instrument: instrument ?? this.instrument,
    );
  }

  @override
  List<Object> get props => [
    duration, typeDropdown, selectedDropdown, buy, sell, neutral,
    oscillatorScore, oscillatorList, movingList, pivotList,
    isLoading, error, securityId, exchangeSegment, instrument,
  ];
}
