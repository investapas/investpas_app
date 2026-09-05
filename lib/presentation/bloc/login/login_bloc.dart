import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/utils/navigationService.dart';
import 'package:investapas/data/models/login_model.dart';
import 'package:investapas/routes/appRoutes.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/generate_consent_model.dart';
import '../dashboard/bloc.dart';
import '../dashboard/event.dart';
import '../profile/profile_bloc.dart';
import '../profile/profile_event.dart' as profile_event;

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginStarted>(_onLoginStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterTapped);
    on<ConsumeConsent>(_consumeConsent);
  }

  void _onLoginStarted(
      LoginStarted event,
      Emitter<LoginState> emit,
      ) {
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event,
      Emitter<LoginState> emit,
      ) async {

    emit(LoginLoading());

    try {

      final response = await ApiHelper.get(ApiEndpoints.generateConsentApi);

      /// JSON → MODEL
      final model = GenerateConsentModel.fromJson(response);

      if (model.status == true && model.data?.consentId != null) {

        final consentId = model.data!.consentId!;
        final url =
            "https://auth.dhan.co/consent-login?consentId=$consentId";
        emit(LoginOpenWebview(url));

      } else {
        emit(LoginError(model.message ?? "Something went wrong"));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _consumeConsent(
      ConsumeConsent event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    try {
      // Get FCM token so backend can store it immediately on login
      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getToken();
      } catch (_) {}

      final response = await ApiHelper.post(
        ApiEndpoints.consumeConsentApi, {
          "tokenId":  event.tokenId,
          if (fcmToken != null && fcmToken.isNotEmpty) "fcmToken": fcmToken,
        },
      );

      final model = LoginModel.fromJson(response);
      if (model.status == true) {
        final prefs = SharedPrefsHelper();
        await prefs.saveAuthData(
          model.token ?? "",
          model.dhanAccessToken ?? "",
          model.user!.dhanClientId ?? "",
          model.user!.dhanClientName ?? "",
          model.user!.dhanClientUcc ?? "",
        );
        // Always go to PIN setup on fresh login — user must set/re-confirm PIN
        await prefs.setPinConfigured(false);
        NavigatorService.markSessionActive();
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.setupPinPage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = NavigatorService.navigatorKey.currentContext;
          if (ctx != null) {
            // reset to home tab
            ctx.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(0));
            // reload dashboard name + challenge
            ctx.read<DashBoardBloc>().add(LoadUserPrefsEvent());
            ctx.read<DashBoardBloc>().add(LoadChallengeEvent());
            // reload profile name
            ctx.read<ProfileBloc>().add(profile_event.LoadUserPrefsEvent());
          }
        });
      } else {
        emit(LoginError(model.message ?? "Login Failed"));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  void _onRegisterTapped(
      RegisterButtonPressed event,
      Emitter<LoginState> emit,
      ) {
    emit(NavigateToRegister());
  }
}
