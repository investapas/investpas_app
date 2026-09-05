import 'package:equatable/equatable.dart';

class DashBoardState extends Equatable {
  final int pageIndex;
  final String clientName;
  final String clientId;
  final String clientUcc;

  // challenge progress
  final bool challengeLoading;
  final bool hasChallenge;
  final int completedDays;
  final int totalDays;
  final String challengeName;
  final String startDate;
  final String endDate;

  // challenge rules
  final double tradingCapital;
  final double minProfit;
  final double maxProfit;
  final double minLoss;
  final double maxLoss;
  final int maxTradesPerDay;
  final int niftyLots;
  final int bankNiftyLots;
  final int finNiftyLots;
  final int midcapNiftyLots;
  final int sensexLots;

  const DashBoardState({
    this.pageIndex = 0,
    this.clientName = '',
    this.clientId = '',
    this.clientUcc = '',
    this.challengeLoading = false,
    this.hasChallenge = false,
    this.completedDays = 0,
    this.totalDays = 0,
    this.challengeName = '',
    this.startDate = '',
    this.endDate = '',
    this.tradingCapital = 0,
    this.minProfit = 0,
    this.maxProfit = 0,
    this.minLoss = 0,
    this.maxLoss = 0,
    this.maxTradesPerDay = 0,
    this.niftyLots = 0,
    this.bankNiftyLots = 0,
    this.finNiftyLots = 0,
    this.midcapNiftyLots = 0,
    this.sensexLots = 0,
  });

  // Max lots allowed per index — used in buy order check
  int lotsFor(String index) {
    switch (index.toUpperCase()) {
      case 'BANKNIFTY': return bankNiftyLots;
      case 'FINNIFTY':  return finNiftyLots;
      case 'MIDCAPNIFTY': return midcapNiftyLots;
      case 'SENSEX':    return sensexLots;
      case 'NIFTY':
      default:           return niftyLots;
    }
  }

  @override
  List<Object?> get props => [
    pageIndex, clientName, clientId, clientUcc,
    challengeLoading, hasChallenge, completedDays, totalDays,
    challengeName, startDate, endDate,
    tradingCapital, minProfit, maxProfit, minLoss, maxLoss,
    maxTradesPerDay, niftyLots, bankNiftyLots, finNiftyLots, midcapNiftyLots, sensexLots,
  ];

  DashBoardState copyWith({
    int? pageIndex,
    String? clientName,
    String? clientId,
    String? clientUcc,
    bool? challengeLoading,
    bool? hasChallenge,
    int? completedDays,
    int? totalDays,
    String? challengeName,
    String? startDate,
    String? endDate,
    double? tradingCapital,
    double? minProfit,
    double? maxProfit,
    double? minLoss,
    double? maxLoss,
    int? maxTradesPerDay,
    int? niftyLots,
    int? bankNiftyLots,
    int? finNiftyLots,
    int? midcapNiftyLots,
    int? sensexLots,
  }) {
    return DashBoardState(
      pageIndex: pageIndex ?? this.pageIndex,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      clientUcc: clientUcc ?? this.clientUcc,
      challengeLoading: challengeLoading ?? this.challengeLoading,
      hasChallenge: hasChallenge ?? this.hasChallenge,
      completedDays: completedDays ?? this.completedDays,
      totalDays: totalDays ?? this.totalDays,
      challengeName: challengeName ?? this.challengeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tradingCapital: tradingCapital ?? this.tradingCapital,
      minProfit: minProfit ?? this.minProfit,
      maxProfit: maxProfit ?? this.maxProfit,
      minLoss: minLoss ?? this.minLoss,
      maxLoss: maxLoss ?? this.maxLoss,
      maxTradesPerDay: maxTradesPerDay ?? this.maxTradesPerDay,
      niftyLots: niftyLots ?? this.niftyLots,
      bankNiftyLots: bankNiftyLots ?? this.bankNiftyLots,
      finNiftyLots: finNiftyLots ?? this.finNiftyLots,
      midcapNiftyLots: midcapNiftyLots ?? this.midcapNiftyLots,
      sensexLots: sensexLots ?? this.sensexLots,
    );
  }
}
