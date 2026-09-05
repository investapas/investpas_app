import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/presentation/bloc/splash/splash_bloc.dart';
import 'package:investapas/routes/appRoutes.dart';

import '../../../Widgets/app_background.dart';
import '../../../core/utils/navigationService.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SplashBloc>().add(SplashStarted());

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginPage);
        }
        if (state is SplashAuthenticate) {
          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homePage);
        }
        if (state is SplashNeedsPin) {
          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.setupPinPage);
        }
        if (state is SplashShowLock) {
          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.appLockPage);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Center(
              child: Image.asset(
                Assets.logoTransparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}