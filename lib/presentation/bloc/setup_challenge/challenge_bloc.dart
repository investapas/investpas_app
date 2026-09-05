import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/network/api_service.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import 'challenge_event.dart';
import 'challenge_state.dart';

class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {

  final SharedPrefsHelper prefs = SharedPrefsHelper();

  ChallengeBloc() : super(const ChallengeState()) {

    on<LoadCapitalListEvent>((event, emit) {
      emit(state.copyWith(
        capitalList: [100, 200, 300, 500, 1000],
      ));
    });
    on<LoadTradeListEvent>((event, emit) {
      emit(state.copyWith(
        tradeList: List.generate(20, (i) => i + 1),
      ));
    });
    on<SelectCapitalEvent>((event, emit) {
      final capital = event.capital;
      final riskPct = state.suggestedRiskPct;
      final targetPct = state.suggestedTargetPct;

      int? minLoss, maxLoss, minProfit, maxProfit;
      if (riskPct > 0 && targetPct > 0 && capital > 0) {
        maxLoss   = (capital * riskPct   / 100).round();
        minLoss   = (maxLoss * 0.7).round();
        maxProfit = (capital * targetPct / 100).round();
        minProfit = (maxProfit * 0.7).round();
      }

      emit(state.copyWith(
        selectedCapital: capital,
        message: '',
        isSuccess: false,
        selectMinLoss:   minLoss,
        selectMaxLoss:   maxLoss,
        selectMinProfit: minProfit,
        selectMaxProfit: maxProfit,
      ));
    });
    on<SelectMinProfitEvent>((event, emit) {
      emit(state.copyWith(selectMinProfit: event.capital,message: '',isSuccess: false));
    });
    on<SelectMaxProfitEvent>((event, emit) {
      emit(state.copyWith(selectMaxProfit: event.capital,message: '',isSuccess: false));
    });
    on<SelectMinLossEvent>((event, emit) {
      emit(state.copyWith(selectMinLoss: event.capital,message: '',isSuccess: false));
    });
    on<SelectMaxLossEvent>((event, emit) {
      emit(state.copyWith(selectMaxLoss: event.capital,message: '',isSuccess: false));
    });
    on<SelectMaxTradeEvent>((event, emit) {
      // Each index lot limit is independent — no reset needed
      emit(state.copyWith(
        selectMaxTrade: event.capital,
        message: '',
        isSuccess: false,
      ));
    });
    on<SelectNiftyEvent>((event, emit) {
      emit(state.copyWith(selectNifty: event.capital,message: '',isSuccess: false));
    });
    on<SelectBankNiftyEvent>((event, emit) {
      emit(state.copyWith(selectBankNifty: event.capital,message: '',isSuccess: false));
    });
    on<SelectFinNiftyEvent>((event, emit) {
      emit(state.copyWith(selectFinNifty: event.capital,message: '',isSuccess: false));
    });
    on<SelectMidCapNiftyEvent>((event, emit) {
      emit(state.copyWith(selectMidCapNifty: event.capital,message: '',isSuccess: false));
    });
    on<SelectSenSexEvent>((event, emit) {
      emit(state.copyWith(selectSenSex: event.capital,message: '',isSuccess: false));
    });
    on<SelectDurationEvent>((event, emit) {
      if (state.selectedDuration == event.duration) {
        emit(state.copyWith(selectedDuration: null,message: '',isSuccess: false));
      } else {
        emit(state.copyWith(selectedDuration: event.duration,message: '',isSuccess: false));
      }
    });
    // on<SelectTradingStyleEvent>((event, emit) async {
    //   // Trading style selector temporarily removed from UI
    // });
    on<SelectCooldownEvent>((event, emit) {
      emit(state.copyWith(cooldownMinutes: event.minutes, message: '', isSuccess: false));
    });
    on<SelectConsecutiveLossLimitEvent>((event, emit) {
      emit(state.copyWith(consecutiveLossLimit: event.limit, message: '', isSuccess: false));
    });
    on<SelectMaxCapitalPerTradeEvent>((event, emit) {
      emit(state.copyWith(maxCapitalPerTradePct: event.pct, message: '', isSuccess: false));
    });
    on<ToggleHeroTradeEvent>((event, emit) {
      emit(state.copyWith(heroTradeAllowed: event.allowed, message: '', isSuccess: false));
    });

    on<LoadChallengeDataEvent>((event, emit) async {

      emit(state.copyWith(isLoading: true));

      try {
        final token = await prefs.getToken() ?? '';

        final response = await ApiHelper.get(
          ApiEndpoints.challengeFetchApi,
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        if (response["status"] == true) {
          final data = response["data"];

          print(data);
          print("Asdsadsdsadasdasdsadd");

          emit(state.copyWith(
            isLoading: false,

            selectedCapital: double.parse(data["trading_capital"]).toInt(),
            selectMinProfit: double.parse(data["min_profit"]).toInt(),
            selectMaxProfit: double.parse(data["max_profit"]).toInt(),
            selectMinLoss: double.parse(data["min_loss"]).toInt(),
            selectMaxLoss: double.parse(data["max_loss"]).toInt(),
            selectMaxTrade: data["max_trades_per_day"],

            selectNifty: data["nifty_lots"],
            selectBankNifty: data["banknifty_lots"],
            selectFinNifty: data["finnifty_lots"],
            selectMidCapNifty: data["midcapnifty_lots"],
            selectSenSex: data["sensex_lots"],

            selectedDuration: _mapDaysToDuration(data["challenge_days"]),
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            message: "No data found",
          ));
        }

      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          message: e.toString(),
        ));
      }

    });

    on<SubmitChallengeEvent>((event, emit) async {

      final error = _validate(state);

      if (error != null) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: error,
        ));
        return;
      }

      emit(state.copyWith(isLoading: true));

      try {

        final token = await prefs.getToken() ?? '';

        final body = {
          "inputdata": {
            // "tradingStyle": state.tradingStyle ?? 'SCALPER',  // temporarily removed from UI
            "tradingCapital": state.selectedCapital,
            "minProfit": state.selectMinProfit,
            "maxProfit": state.selectMaxProfit,
            "minLoss": state.selectMinLoss,
            "maxLoss": state.selectMaxLoss,
            "maxTradesPerDay": state.selectMaxTrade,
            "cooldownMinutes": state.cooldownMinutes ?? 5,
            "consecutiveLossLimit": state.consecutiveLossLimit ?? 3,
            "maxCapitalPerTradePct": state.maxCapitalPerTradePct ?? 25,
            "heroTradeAllowed": state.heroTradeAllowed ? 1 : 0,
            "niftyLots": state.selectNifty ?? 0,
            "bankNiftyLots": state.selectBankNifty ?? 0,
            "finNiftyLots": state.selectFinNifty ?? 0,
            "midcapNiftyLots": state.selectMidCapNifty ?? 0,
            "sensexLots": state.selectSenSex ?? 0,
            "challengeDays": _mapDuration(state.selectedDuration),
          }
        };

        final response = await ApiHelper.post(
          ApiEndpoints.challengeCreateApi,
          body,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (response["status"] == true) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            message: response["message"],
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: false,
            message: response["message"],
          ));
        }

      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: e.toString(),
        ));
      }

    });
  }

  int _mapDuration(ChallengeDuration? duration) {
    switch (duration) {
      case ChallengeDuration.fiveDays:
        return 5;
      case ChallengeDuration.tenDays:
        return 10;
      case ChallengeDuration.paid:
        return 30;
      default:
        return 0;
    }
  }

  String? _validate(ChallengeState state) {

    if (state.selectedCapital == null) return "Select trading capital";
    if (state.selectMinProfit == null) return "Select minimum profit";
    if (state.selectMaxProfit == null) return "Select maximum profit";
    if (state.selectMinLoss == null) return "Select minimum loss";
    if (state.selectMaxLoss == null) return "Select maximum loss";
    if (state.selectMaxTrade == null) return "Select max trades per day";
    if (state.selectNifty == null) return "Select nifty lots";
    if (state.selectBankNifty == null) return "Select bank nifty lots";
    if (state.selectFinNifty == null) return "Select FinNifty lots";
    if (state.selectMidCapNifty == null) return "Select MidcapNifty lots";
    if (state.selectSenSex == null) return "Select Sensex lots";
    if (state.selectedDuration == null) return "Select challenge duration";

    final capital = state.selectedCapital!;
    final minProfit = state.selectMinProfit!;
    final maxProfit = state.selectMaxProfit!;
    final minLoss = state.selectMinLoss!;
    final maxLoss = state.selectMaxLoss!;
    final maxTrades = state.selectMaxTrade!;

    if (capital <= 0) return "Capital must be greater than 0";
    if (maxProfit <= 0) return "Max profit must be greater than 0";
    if (maxLoss <= 0) return "Max loss must be greater than 0";
    if (maxTrades <= 0) return "At least 1 trade required";
    if (minProfit > maxProfit) return "Min profit cannot be greater than max profit";
    if (minLoss > maxLoss) return "Min loss cannot be greater than max loss";

    final days = _mapDuration(state.selectedDuration);
    if (days <= 0) return "Invalid challenge duration";

    return null;
  }

  ChallengeDuration? _mapDaysToDuration(int days) {
    switch (days) {
      case 5:
        return ChallengeDuration.fiveDays;
      case 10:
        return ChallengeDuration.tenDays;
      case 30:
        return ChallengeDuration.paid;
      default:
        return null;
    }
  }

}