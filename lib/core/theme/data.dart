
import 'package:flutter/material.dart';

import '../utils/navigationService.dart';

/// Theme data
///  this class is used to store the theme data without context
class AppThemeData{
  AppThemeData._();
/// primary color
  static Color get primaryColor => Theme.of(NavigatorService.navigatorKey.currentContext!).primaryColor;

  /// secondary color
  static Color get secondaryColor => Theme.of(NavigatorService.navigatorKey.currentContext!).colorScheme.secondary;

  /// inactive color
  static Color get inactiveColor => Theme.of(NavigatorService.navigatorKey.currentContext!).unselectedWidgetColor;

  /// text color
  static Color get textColor => Theme.of(NavigatorService.navigatorKey.currentContext!).textTheme.bodyLarge!.color!;
}
