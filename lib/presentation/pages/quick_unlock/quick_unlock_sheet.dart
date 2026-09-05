import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/free_unlock_timer_service.dart';
import '../../../core/utils/app_dialog.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';

/// Shows the two Quick Unlock options: Instant (paid) or Free (wait timer).
/// Call via: QuickUnlockSheet.show(context, onUnlocked: () { … })
class QuickUnlockSheet {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onUnlocked,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: _QuickUnlockSheetBody(onUnlocked: onUnlocked),
      ),
    );
  }
}

class _QuickUnlockSheetBody extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _QuickUnlockSheetBody({required this.onUnlocked});

  @override
  State<_QuickUnlockSheetBody> createState() => _QuickUnlockSheetBodyState();
}

class _QuickUnlockSheetBodyState extends State<_QuickUnlockSheetBody> {
  bool _loading = true;
  bool _acting  = false;
  Map<String, dynamic>? _options;
  String? _error;

  // For FREE unlock countdown
  bool _freeChosen = false;
  DateTime? _resumeAt;
  Timer? _countdownTimer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    try {
      final resp = await ApiHelper.get(ApiEndpoints.walletUnlockOptionsApi);
      if (mounted) {
        setState(() {
          _loading = false;
          if (resp != null && resp['status'] == true) {
            _options = resp;
          } else {
            _error = resp?['message'] ?? 'Failed to load options';
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _doUnlock(String type) async {
    setState(() => _acting = true);
    try {
      final resp = await ApiHelper.post(
        ApiEndpoints.challengeQuickUnlockApi,
        {'type': type},
      );
      if (!mounted) return;

      if (resp != null && resp['status'] == true) {
        // Update wallet balance
        final newBalance = (resp['newBalance'] as num?)?.toInt();
        if (newBalance != null) {
          context.read<WalletBloc>().add(UpdateBalance(newBalance));
        }

        if (type == 'FREE') {
          // Show countdown inside the sheet
          final resumeStr = resp['resumeAt'] as String?;
          setState(() {
            _acting = false;
            _freeChosen = true;
            _resumeAt = resumeStr != null ? DateTime.parse(resumeStr) : null;
          });
          _startCountdown();
        } else {
          // Instant — close sheet and resume
          Navigator.pop(context);
          AppSnackBar.showSuccess(context, resp['message'] ?? 'Trading resumed!');
          widget.onUnlocked();
        }
      } else {
        setState(() => _acting = false);
        AppSnackBar.showError(context, resp?['message'] ?? 'Unlock failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _acting = false);
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final resume = _resumeAt;
      if (resume == null || now.isAfter(resume)) {
        _countdownTimer?.cancel();
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, 'Trading resumed!');
        widget.onUnlocked();
        return;
      }
      final diff = resume.difference(now);
      final mins = diff.inMinutes.toString().padLeft(2, '0');
      final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');
      setState(() => _countdown = '$mins:$secs');
    });
  }

  String _fmtWait(int minutes) =>
      minutes >= 60 ? '${minutes ~/ 60}h' : '${minutes}min';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colorz.dividerColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // Icon + title
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colorz.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_open_rounded, color: Colorz.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text('Quick Unlock',
              style: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.headerTwoFont, color: Colorz.textColor)),
          const SizedBox(height: 6),
          Text('Choose how you want to unlock trading',
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
          const SizedBox(height: 24),

          if (_loading)
            const CircularProgressIndicator(color: Colorz.primary)
          else if (_error != null)
            Text(_error!, style: AppTextStyles.medium.copyWith(color: Colorz.redColor))
          else if (_freeChosen)
            _buildCountdown()
          else if (_options?['canUnlock'] == false)
            _buildMaxReached()
          else
            _buildOptions(),

          const SizedBox(height: 8),
          if (!_freeChosen)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor, fontSize: SizeConfig.mediumFont)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final instant = _options?['instant'] as Map?;
    final free    = _options?['free'] as Map?;
    final done    = _options?['unlocksUsed'] as int? ?? 0;
    final max     = _options?['maxUnlocks'] as int? ?? 5;
    final coins   = (instant?['coins'] as num?)?.toInt() ?? 50;
    final balance = (instant?['userBalance'] as num?)?.toInt() ?? 0;
    final canAfford = instant?['canAfford'] == true;
    final waitMins  = (free?['waitMinutes'] as num?)?.toInt() ?? 20;

    return Column(
      children: [
        // Unlock counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colorz.bottomPillBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Unlock ${done + 1} of $max today',
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont)),
        ),
        const SizedBox(height: 16),

        // ── INSTANT card ──────────────────────────────────────────────────
        _OptionCard(
          icon: Icons.bolt_rounded,
          iconColor: Colors.amber,
          title: 'Instant Unlock',
          subtitle: 'Start trading right now',
          badge: '$coins coins',
          badgeColor: Colorz.primary,
          footer: 'Your balance: $balance coins',
          footerColor: canAfford ? Colorz.greenColor : Colorz.redColor,
          enabled: canAfford && !_acting,
          onTap: () => _doUnlock('INSTANT'),
          isLoading: _acting,
        ),
        const SizedBox(height: 12),

        // ── FREE card ─────────────────────────────────────────────────────
        _OptionCard(
          icon: Icons.access_time_rounded,
          iconColor: Colorz.primary,
          title: 'Free Unlock',
          subtitle: 'Wait ${_fmtWait(waitMins)} to resume trading',
          badge: 'Free',
          badgeColor: Colorz.greenColor,
          footer: 'Starts the timer, you can still cancel',
          enabled: !_acting,
          onTap: () => _doUnlock('FREE'),
          isLoading: false,
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Colorz.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(_countdown,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.primary, fontSize: SizeConfig.headerTwoFont)),
          ),
        ),
        const SizedBox(height: 12),
        Text('Trading resumes when timer ends',
            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorz.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              // Hand off the timer to the global service so the top bar
              // continues counting down even after the sheet is closed.
              if (_resumeAt != null) {
                FreeUnlockTimerService.instance.startTimer(_resumeAt!);
              }
              Navigator.pop(context);
            },
            child: Text('OK, I\'ll wait',
                style: AppTextStyles.semiBold.copyWith(
                    color: Colors.white, fontSize: SizeConfig.mediumFont)),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxReached() {
    return Column(
      children: [
        const Icon(Icons.block_rounded, color: Colorz.redColor, size: 40),
        const SizedBox(height: 12),
        Text(
          _options?['message'] ?? 'Max unlocks reached for today.',
          textAlign: TextAlign.center,
          style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String footer;
  final Color? footerColor;
  final bool enabled;
  final VoidCallback onTap;
  final bool isLoading;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.footer,
    this.footerColor,
    required this.enabled,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colorz.bottomPillBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? Colorz.primary : Colorz.dividerColor,
            width: 1.5,
          ),
          boxShadow: enabled
              ? [BoxShadow(color: Colorz.primary.withValues(alpha: 0.08),
                          blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: enabled ? iconColor : Colorz.hintTextColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.semiBold.copyWith(
                          color: enabled ? Colorz.textColor : Colorz.hintTextColor,
                          fontSize: SizeConfig.mediumFont)),
                  Text(subtitle,
                      style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
                  const SizedBox(height: 4),
                  Text(footer,
                      style: AppTextStyles.medium.copyWith(
                          color: footerColor ?? Colorz.hintTextColor,
                          fontSize: SizeConfig.smallerFont)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colorz.primary))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: enabled ? badgeColor : Colorz.dividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge,
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colors.white, fontSize: SizeConfig.smallerFont)),
                  ),
          ],
        ),
      ),
    );
  }
}
