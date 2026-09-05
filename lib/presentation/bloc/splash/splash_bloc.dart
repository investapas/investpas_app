import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/free_unlock_timer_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
      SplashStarted event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());

    await Future.delayed(const Duration(seconds: 3));

    final prefs = SharedPrefsHelper();
    final isAuthenticated = await prefs.getAuthenticationStatus();

    if (!isAuthenticated) {
      emit(SplashCompleted());
      return;
    }

    // Skip lock if: free-unlock timer is still running OR session is within 5 min
    final freeUnlockActive = FreeUnlockTimerService.instance.isActive;
    final withinSession   = await prefs.isWithinQuickUnlockWindow();
    if (freeUnlockActive || withinSession) {
      await prefs.saveLastActiveTime();
      emit(SplashAuthenticate());
      return;
    }

    final hasPinSet = await prefs.hasPinSet();
    if (!hasPinSet) {
      emit(SplashNeedsPin());
    } else {
      emit(SplashShowLock());
    }
  }
}