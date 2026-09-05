 part of 'bloc.dart';

/// theme events
abstract class ThemeEvent  extends Equatable{
  @override
  List<Object> get props => [];
}

/// toggle theme
class ToggleThemeEvent extends ThemeEvent {
   /// true if Dark Mode, false if Light Mode

  ToggleThemeEvent();
}


/// get current theme
class GetThemeEvent extends ThemeEvent {
  /// constructor
  GetThemeEvent();
}
