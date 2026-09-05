import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/shared_prefs_helper.dart';
import '../../data/models/trade_history.dart';

class TradeHistoryRepository {
  TradeHistoryRepository._();

  static final TradeHistoryRepository instance = TradeHistoryRepository._();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  Future<Map<String, dynamic>> getTradeHistory({
    required String fromDate,
    required String toDate,
    int page = 0,
  }) async {
    final accessToken = await _prefs.getAccessToken() ?? '';

    final response = await ApiHelper.post(
      ApiEndpoints.tradeHistoryApi,
      {
        "dhanAccessToken": accessToken,
        "fromDate": fromDate,
        "toDate": toDate,
        "page": page,
      },
    );

    if (response != null && response["status"] == true) {
      final List summaryData = response["summary"] ?? [];
      final Map<String, dynamic> data = response["data"] ?? {};

      // Parse summary
      final summary = summaryData
          .map((e) => TradeHistorySummary.fromJson(e))
          .toList();

      // Parse trade positions by date
      final tradesByDate = <String, List<TradePosition>>{};
      data.forEach((dateKey, trades) {
        if (trades is List) {
          tradesByDate[dateKey] = trades
              .map((e) => TradePosition.fromJson(e))
              .toList();
        }
      });

      return {
        'status': true,
        'summary': summary,
        'data': tradesByDate,
        'totalRawTrades': response['totalRawTrades'] ?? 0,
      };
    }

    return {
      'status': false,
      'summary': [],
      'data': {},
      'totalRawTrades': 0,
    };
  }
}
