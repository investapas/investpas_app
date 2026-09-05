import 'package:flutter/material.dart';

/// NavigatorService help navigation
class NavigatorService {
  NavigatorService._();
  /// navigation key
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // When true, 401 handlers skip navigation (session already ended).
  static bool _sessionEnded = false;
  static bool get isSessionEnded => _sessionEnded;
  static void markSessionEnded()  => _sessionEnded = true;
  static void markSessionActive() => _sessionEnded = false;

  // Debounce: block duplicate pushNamedAndRemoveUntil for 2 seconds.
  static DateTime? _lastRemoveUntilTime;

/// push to new route name
  static Future<dynamic> pushNamed(String routeName,
      {dynamic arguments}) async {
    return navigatorKey.currentState
        ?.pushNamed(routeName, arguments: arguments);
  }
/// back to previous page
  static void goBack() {
    return navigatorKey.currentState?.pop();
  }

/// push and remove all others
  static Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {bool routePredicate = false, dynamic arguments}) async {
    final now = DateTime.now();
    if (_lastRemoveUntilTime != null &&
        now.difference(_lastRemoveUntilTime!).inMilliseconds < 2000) {
      return null;
    }
    _lastRemoveUntilTime = now;
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routeName, (route) => routePredicate,
        arguments: arguments);
  }

/// push and replaced
  static Future<dynamic> popAndPushNamed(String routeName,
      {dynamic arguments}) async {
    return navigatorKey.currentState
        ?.popAndPushNamed(routeName, arguments: arguments);
  }
}
