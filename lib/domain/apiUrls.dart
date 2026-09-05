
/// This class contains all the api urls
class Apiurls {
  Apiurls._();
  /// Base Url
  static const String _baseUrl = 'https://api.escuelajs.co/api/v1';
/// Auth Url
  static const String login = '$_baseUrl/auth/login';
/// register Url
  static const String register = '$_baseUrl/users/';

/// Product Url
  static const String getProducts = '$_baseUrl/products/';

/// profile Url
  static const String profile='$_baseUrl/auth/profile';
/// update profile Url
  static  String  updateProfile(String id)=>'$_baseUrl/users/$id';

  /// Dhan Portfolio URL
  static const String getPortfolio = 'https://api.investapas.in/dhan/portfolio';
}
