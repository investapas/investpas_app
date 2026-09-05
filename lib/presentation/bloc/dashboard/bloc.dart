
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import 'event.dart';
import 'state.dart';

/// dash board bloc
 class DashBoardBloc extends Bloc<DashboardEvent, DashBoardState> {

   final SharedPrefsHelper prefs = SharedPrefsHelper();

  /// constructor
  DashBoardBloc() : super(const DashBoardState()) {
    on<ChangeTabDashBoardEvent>(_onChangePage);
    on<LoadUserPrefsEvent>(_loadUserPrefs);
    on<LoadChallengeEvent>(_loadChallenge);

    add(LoadUserPrefsEvent());
    add(LoadChallengeEvent());
  }

  /// Changes the page index in the dashboard state.
  ///
  /// This function is called when a [ChangeTabDashBoardEvent] is emitted. It updates
  /// the [DashBoardState] with the new [pageIndex] from the event.
  ///
  /// Parameters:
  /// - [event]: The [ChangeTabDashBoardEvent] that triggered the function.
  /// - [emit]: The [Emitter] used to emit the updated [DashBoardState].
  ///
  /// Returns: void
  void _onChangePage(ChangeTabDashBoardEvent event, Emitter<DashBoardState> emit) { 
    if(event.pageIndex>=0){
      emit(state.copyWith(pageIndex: event.pageIndex));
    }
  }
  Future<void> _loadUserPrefs(
    LoadUserPrefsEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final name = await prefs.getClientName() ?? '';
    final id = await prefs.getClientId() ?? '';
    final ucc = await prefs.getClientUcc() ?? '';

    emit(state.copyWith(
      clientName: name,
      clientId: id,
      clientUcc: ucc,
    ));
  }

  Future<void> _loadChallenge(
    LoadChallengeEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(challengeLoading: true));

    try {
      final token = await prefs.getToken() ?? '';

      final response = await ApiHelper.get(
        ApiEndpoints.challengeFetchApi,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response["status"] == true) {
        final data = response["data"];
        print(data);
        print("Asdsadsdsad");

        final int totalDays = (data["challenge_days"] ?? 0) as int;

        DateTime? startDate;
        DateTime? endDate;

        if (data["challenge_start_date"] != null) {
          startDate = DateTime.tryParse(data["challenge_start_date"].toString());
        }
        if (data["challenge_end_date"] != null) {
          endDate = DateTime.tryParse(data["challenge_end_date"].toString());
        }

        final now = DateTime.now();
        int completedDays = 0;
        if (startDate != null) {
          // compare calendar dates only (strip time component)
          final startDay = DateTime(startDate.year, startDate.month, startDate.day);
          final today = DateTime(now.year, now.month, now.day);
          completedDays = today.difference(startDay).inDays + 1;
          if (completedDays < 0) completedDays = 0;
          if (completedDays > totalDays) completedDays = totalDays;
        }

        print(DateTime(now.year, now.month, now.day));
        print("dasdasdsadsadsadsadasd");

        final String startStr = startDate != null
            ? "${startDate.day} ${_monthName(startDate.month)} ${startDate.year}"
            : '';
        final String endStr = endDate != null
            ? "${endDate.day} ${_monthName(endDate.month)} ${endDate.year}"
            : '';

        final String name = "$totalDays Day Challenge";

        emit(state.copyWith(
          challengeLoading: false,
          hasChallenge: true,
          totalDays: totalDays,
          completedDays: completedDays,
          challengeName: name,
          startDate: startStr,
          endDate: endStr,
          tradingCapital: double.tryParse(data["trading_capital"]?.toString() ?? '0') ?? 0,
          minProfit: double.tryParse(data["min_profit"]?.toString() ?? '0') ?? 0,
          maxProfit: double.tryParse(data["max_profit"]?.toString() ?? '0') ?? 0,
          minLoss: double.tryParse(data["min_loss"]?.toString() ?? '0') ?? 0,
          maxLoss: double.tryParse(data["max_loss"]?.toString() ?? '0') ?? 0,
          maxTradesPerDay: (data["max_trades_per_day"] ?? 0) as int,
          niftyLots: (data["nifty_lots"] ?? 0) as int,
          bankNiftyLots: (data["banknifty_lots"] ?? 0) as int,
          finNiftyLots: (data["finnifty_lots"] ?? 0) as int,
          midcapNiftyLots: (data["midcapnifty_lots"] ?? 0) as int,
          sensexLots: (data["sensex_lots"] ?? 0) as int,
        ));
      } else {
        emit(state.copyWith(
          challengeLoading: false,
          hasChallenge: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        challengeLoading: false,
        hasChallenge: false,
      ));
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
