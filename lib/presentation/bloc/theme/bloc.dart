
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../core/theme/theme.dart';
import '../../../core/utils/getStorage.dart';

part 'event.dart';
part 'state.dart';

/// theme bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// constructor
  ThemeBloc() : super(const ThemeState()) {
    on<ToggleThemeEvent>(_toggleTheme);
    on<GetThemeEvent>(_getTheme);
  }

  void _toggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit)  {
    /// Save to Hive
   final bool isDarkMode =  AppGetXStorage.getIsDarkTheme();
    AppGetXStorage.setThemeMode(!isDarkMode);
    
   
    /// Emit new theme
    emit(state.copyWith(themeData: theme(!isDarkMode), isDark: !isDarkMode));
  }

  void _getTheme(GetThemeEvent event, Emitter<ThemeState> emit) {
    /// Get from Hive
    final bool isDarkMode = AppGetXStorage.getIsDarkTheme();

    /// Emit the correct theme
    emit(state.copyWith(themeData: theme(isDarkMode), isDark: isDarkMode));
  }
}
