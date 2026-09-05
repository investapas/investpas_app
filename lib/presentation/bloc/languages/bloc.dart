
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'event.dart';
import 'state.dart';

/// languages bloc
class LanguagesBloc extends Bloc<LanguagesEvent, LanguagesState> {
  /// local
  final Locale local;
/// constructor
  LanguagesBloc({required this.local}) : super(LanguagesState(locale:local )) {
    on<LanguagesEvent>((event, emit) {
      
    });
  }
}
