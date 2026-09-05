
import 'dart:io';

/// Checks internet connectivity
class InternetService{
  InternetService._();
  static final InternetService _instance = InternetService._();
  /// public instance
  static InternetService get instance => _instance;

/// Checks internet connectivity
 static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
