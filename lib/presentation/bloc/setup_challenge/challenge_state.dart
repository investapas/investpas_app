import 'challenge_event.dart';

class ChallengeState {
  final List<int> capitalList;
  final List<int> tradeList;
  final String? tradingStyle;
  final int? selectedCapital;
  final int? selectMinProfit;
  final int? selectMaxProfit;
  final int? selectMinLoss;
  final int? selectMaxLoss;
  final int? selectMaxTrade;
  final int? cooldownMinutes;
  final int? consecutiveLossLimit;
  final int? maxCapitalPerTradePct;
  final bool heroTradeAllowed;
  final double suggestedRiskPct;
  final double suggestedTargetPct;
  final int? selectNifty;
  final int? selectBankNifty;
  final int? selectFinNifty;
  final int? selectMidCapNifty;
  final int? selectSenSex;
  final ChallengeDuration? selectedDuration;
  final bool isLoading;
  final bool isSuccess;
  final String message;

  const ChallengeState({
    this.capitalList = const [],
    this.tradeList = const [],
    this.tradingStyle,
    this.selectedCapital,
    this.selectMinProfit,
    this.selectMaxProfit,
    this.selectMinLoss,
    this.selectMaxLoss,
    this.selectMaxTrade,
    this.cooldownMinutes,
    this.consecutiveLossLimit,
    this.maxCapitalPerTradePct,
    this.heroTradeAllowed = true,
    this.suggestedRiskPct = 0,
    this.suggestedTargetPct = 0,
    this.selectNifty,
    this.selectBankNifty,
    this.selectFinNifty,
    this.selectMidCapNifty,
    this.selectSenSex,
    this.selectedDuration,
    this.isLoading = false,
    this.isSuccess = true,
    this.message = '',
  });

  ChallengeState copyWith({
    List<int>? capitalList,
    List<int>? tradeList,
    String? tradingStyle,
    int? selectedCapital,
    int? selectMinProfit,
    int? selectMaxProfit,
    int? selectMinLoss,
    int? selectMaxLoss,
    int? selectMaxTrade,
    int? cooldownMinutes,
    int? consecutiveLossLimit,
    int? maxCapitalPerTradePct,
    bool? heroTradeAllowed,
    double? suggestedRiskPct,
    double? suggestedTargetPct,
    Object? selectNifty = _noChange,
    Object? selectBankNifty = _noChange,
    int? selectFinNifty,
    int? selectMidCapNifty,
    int? selectSenSex,
    Object? selectedDuration = _noChange,
    bool? isLoading,
    bool? isSuccess,
    String? message,
  }) {
    return ChallengeState(
      capitalList: capitalList ?? this.capitalList,
      tradeList: tradeList ?? this.tradeList,
      tradingStyle: tradingStyle ?? this.tradingStyle,
      selectedCapital: selectedCapital ?? this.selectedCapital,
      selectMinProfit: selectMinProfit ?? this.selectMinProfit,
      selectMaxProfit: selectMaxProfit ?? this.selectMaxProfit,
      selectMinLoss: selectMinLoss ?? this.selectMinLoss,
      selectMaxLoss: selectMaxLoss ?? this.selectMaxLoss,
      selectMaxTrade: selectMaxTrade ?? this.selectMaxTrade,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      consecutiveLossLimit: consecutiveLossLimit ?? this.consecutiveLossLimit,
      maxCapitalPerTradePct: maxCapitalPerTradePct ?? this.maxCapitalPerTradePct,
      heroTradeAllowed: heroTradeAllowed ?? this.heroTradeAllowed,
      suggestedRiskPct: suggestedRiskPct ?? this.suggestedRiskPct,
      suggestedTargetPct: suggestedTargetPct ?? this.suggestedTargetPct,
      selectNifty: selectNifty == _noChange ? this.selectNifty : selectNifty as int?,
      selectBankNifty: selectBankNifty == _noChange ? this.selectBankNifty : selectBankNifty as int?,
      selectFinNifty: selectFinNifty ?? this.selectFinNifty,
      selectMidCapNifty: selectMidCapNifty ?? this.selectMidCapNifty,
      selectSenSex: selectSenSex ?? this.selectSenSex,
      selectedDuration: selectedDuration == _noChange
          ? this.selectedDuration
          : selectedDuration as ChallengeDuration?,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
    );
  }
}

const _noChange = Object();