import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../routes/appRoutes.dart';
import '../../../Widgets/app_background.dart';
import '_pin_pad.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _pin          = '';
  bool   _loading      = false;
  bool   _bioAvailable = false;
  bool   _bioEnabled   = false;
  int    _attempts     = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs     = SharedPrefsHelper();
    _bioEnabled     = await prefs.isBiometricEnabled();
    _bioAvailable   = await _checkBiometricAvailable();

    if (_bioEnabled && _bioAvailable) {
      // Small delay so the page is fully rendered before the system dialog appears
      await Future.delayed(const Duration(milliseconds: 400));
      _triggerBiometric();
    }
  }

  Future<bool> _checkBiometricAvailable() async {
    try {
      final canCheck  = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<void> _triggerBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use biometric to unlock Investapas',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) _unlock();
    } catch (_) {}
  }

  void _onKey(String key) {
    if (_loading) return;
    setState(() {
      if (key == 'del') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < 4) {
        _pin += key;
        if (_pin.length == 4) _onPinComplete();
      }
    });
  }

  void _onPinComplete() async {
    setState(() => _loading = true);
    try {
      final res = await ApiHelper.post(ApiEndpoints.verifyPinApi, {'pin': _pin});
      if (res['status'] == true) {
        _unlock();
      } else {
        _attempts++;
        ToastHelper.showToast(
          _attempts >= 3
              ? 'Incorrect PIN (attempt $_attempts). Please try again.'
              : 'Incorrect PIN. Please try again.',
          isSuccess: false,
        );
        setState(() { _pin = ''; _loading = false; });
      }
    } catch (e) {
      ToastHelper.showToast('Error verifying PIN', isSuccess: false);
      setState(() { _pin = ''; _loading = false; });
    }
  }

  void _unlock() {
    SharedPrefsHelper().saveLastActiveTime();
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homePage);
  }

  Widget _biometricButton() {
    if (!_bioEnabled || !_bioAvailable) return const SizedBox();
    return GestureDetector(
      onTap: _triggerBiometric,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colorz.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colorz.primary.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.fingerprint, color: Colorz.primary, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 56),

              // App logo / lock icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colorz.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, color: Colorz.primary, size: 40),
              ),
              const SizedBox(height: 24),

              Text('Welcome Back',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.largeFont)),
              const SizedBox(height: 8),
              Text('Enter your PIN to continue',
                  style: AppTextStyles.small.copyWith(
                      color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),

              const SizedBox(height: 40),

              // PIN dots
              PinDots(filledCount: _pin.length),

              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colorz.primary),
                  ),
                ),

              const Spacer(),

              // Number pad — biometric button on bottom-left
              PinPad(onKey: _onKey, extraBottomLeft: _biometricButton()),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
