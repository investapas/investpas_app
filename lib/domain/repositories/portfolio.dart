import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/shared_prefs_helper.dart';
import '../../data/models/portfolio_position.dart';

class UnauthorizedException implements Exception {}

class PortfolioRepository {
  PortfolioRepository._();

  static final PortfolioRepository instance = PortfolioRepository._();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  Future<List<PortfolioPosition>> getPortfolio() async {
    final accessToken = await _prefs.getAccessToken() ?? '';

    final response = await ApiHelper.get(
      ApiEndpoints.portfolioApi,
      body: {"mode": "REAL", "dhanAccessToken": accessToken},
    );

    if (response != null && response["status"] == false) {
      final message = (response["message"] as String? ?? '').toLowerCase();
      if (message.contains('invalid') || message.contains('expired')) {
        throw UnauthorizedException();
      }
    }

    if (response != null && response["data"] is List) {
      final List data = response["data"];
      return data.map((e) => PortfolioPosition.fromJson(e)).toList();
    }

    return [];
  }
}
