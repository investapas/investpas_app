
part of 'bloc.dart';

 /// theme state
 class ThemeState extends Equatable {
  /// theme data
 final ThemeData? themeData;
 /// is dark mode
 final bool isDark;
/// constructor
 const ThemeState({ this.themeData, this.isDark = false});

 @override
 List<Object?> get props => [themeData, isDark];

 /// copyWith method
 ThemeState copyWith({
   ThemeData? themeData,
   bool? isDark
 }) {
   return ThemeState(
     themeData: themeData ?? this.themeData,
     isDark: isDark ?? this.isDark
   );
 }
}
