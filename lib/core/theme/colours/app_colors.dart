
import 'package:flutter/material.dart';

part 'dark_mode.dart';
part 'light_mode.dart';

/// app colors

class AppColors {
  AppColors._();

/// primary color
  static Color primaryColor(bool isDark) {
    return isDark ? DarkColors.primary : LightColors.primary;
  }

  /// secondary color
  static Color secondaryColor(bool isDark) {
    return isDark ? DarkColors.secondary : LightColors.secondary;
  }
  /// background color
  static Color backgroundColor(bool isDark) {
    return isDark ? DarkColors.background : LightColors.background;
  }
  /// card color
  static Color cardColor(bool isDark) {
    return isDark ? DarkColors.card : LightColors.card;
  }
  /// text color
  static Color textColor(bool isDark) {
    return isDark ? DarkColors.text : LightColors.text;
  }
  /// icon color
  static Color iconColor(bool isDark) {
    return isDark ? DarkColors.icon : LightColors.icon;
  }

  ///  foreground color
  static Color foregroundColor(bool isDark) {
    return isDark ? DarkColors.foregroundColor : LightColors.foregroundColor;
  }
 

  /// scaffold background color
  static Color scaffoldBackgroundColor(bool isDark) {
    return isDark ? DarkColors.scaffoldBackgroundColor : LightColors.scaffoldBackgroundColor;
  }

  /// inactive color
  static Color inactiveColor(bool isDark) {
    return isDark ? DarkColors.inactiveColor : LightColors.inactiveColor;
  }

}
