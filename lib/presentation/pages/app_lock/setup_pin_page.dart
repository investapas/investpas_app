import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../routes/appRoutes.dart';
import '../../../Widgets/app_background.dart';
import '_pin_pad.dart';

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  String _pin       = '';
  String _firstPin  = '';
  bool   _confirming = false;
  bool   _loading    = false;

  String get _title   => _confirming ? 'Confirm your PIN' : 'Set App PIN';
  String get _subtitle => _confirming
      ? 'Re-enter your PIN to confirm'
      : 'Create a 4-digit PIN to keep your account private';

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
    if (!_confirming) {
      // First entry — move to confirm step
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() {
        _firstPin   = _pin;
        _pin        = '';
        _confirming = true;
      });
      return;
    }

    // Confirm step — check match
    if (_pin != _firstPin) {
      ToastHelper.showToast("PINs don't match. Try again.", isSuccess: false);
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() {
        _pin        = '';
        _firstPin   = '';
        _confirming = false;
      });
      return;
    }

    // Call API
    setState(() => _loading = true);
    try {
      final res = await ApiHelper.post(ApiEndpoints.setPinApi, {'pin': _pin});
      if (res['status'] == true) {
        await SharedPrefsHelper().setPinConfigured(true);
        // Ask about biometric after PIN is set
        if (mounted) _showBiometricDialog();
      } else {
        ToastHelper.showToast(res['message'] ?? 'Failed to set PIN', isSuccess: false);
        setState(() { _pin = ''; _loading = false; });
      }
    } catch (e) {
      ToastHelper.showToast('Error: ${e.toString()}', isSuccess: false);
      setState(() { _pin = ''; _loading = false; });
    }
  }

  void _showBiometricDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colorz.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colorz.primary, size: 28),
            const SizedBox(width: 10),
            Text('Enable Biometric?',
                style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor)),
          ],
        ),
        content: Text(
          'Use fingerprint or face unlock to open the app faster.',
          style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _navigateToHome(); },
            child: Text('Skip', style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorz.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _enableBiometric();
            },
            child: Text('Enable', style: AppTextStyles.small.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _enableBiometric() async {
    try {
      await ApiHelper.put(ApiEndpoints.biometricApi, {'enabled': true});
      await SharedPrefsHelper().setBiometricEnabled(true);
    } catch (_) {}
    _navigateToHome();
  }

  void _navigateToHome() {
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homePage);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Lock icon
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colorz.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded,
                    color: Colorz.primary, size: 36),
              ),
              const SizedBox(height: 24),

              Text(_title,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor, fontSize: SizeConfig.largeFont)),
              const SizedBox(height: 8),
              Text(_subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallFont)),

              const SizedBox(height: 40),

              // PIN dots
              PinDots(filledCount: _pin.length),

              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colorz.primary),
                  ),
                ),

              const Spacer(),

              // Number pad
              PinPad(onKey: _onKey),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
