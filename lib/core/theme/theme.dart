import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colours/app_colors.dart';

/// Returns a `ThemeData` object based on the provided `isDark` parameter.
///
/// Parameters:
/// - `isDark`: A boolean value that determines the brightness of the theme.
///
/// Returns:
/// - A `ThemeData` object with the specified brightness, primary color, and various other theme properties.
ThemeData theme(bool isDark) {
 
  final WidgetStateProperty<Color?> _property =
      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return null;
    }
    if (states.contains(WidgetState.selected)) {
      return AppColors.primaryColor(isDark);
    }
    return null;
  });

  final ThemeData baseTheme = ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    useMaterial3: false,
  ).copyWith(
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'Inter',
    ),
    primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
      fontFamily: 'Inter',
    ),
  );

  return baseTheme.copyWith(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor(isDark),
    unselectedWidgetColor: AppColors.inactiveColor(isDark),
    appBarTheme: AppBarTheme(
      foregroundColor: AppColors.foregroundColor(isDark),
      color: AppColors.backgroundColor(isDark),
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 23.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor(isDark)),
    ),
    switchTheme: SwitchThemeData(thumbColor: _property, trackColor: _property),
    radioTheme: RadioThemeData(fillColor: _property),
    checkboxTheme: CheckboxThemeData(fillColor: _property),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        color: AppColors.textColor(isDark),
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18.sp,
        color: AppColors.textColor(isDark),
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: AppColors.textColor(isDark),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: AppColors.foregroundColor(isDark),
        backgroundColor: AppColors.primaryColor(isDark)),
  );
}
