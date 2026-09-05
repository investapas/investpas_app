import 'package:flutter/material.dart';
import '../../routes/appRoutes.dart';
import '../constants/constants.dart';
import 'navigationService.dart';

/// Unified dialog and snackbar utility — all popups use this so the app
/// always looks consistent with the blue primary theme.
class AppDialog {
  // ── Shared dialog wrapper ─────────────────────────────────────────────────

  static Widget _buildDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colorz.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.headerThreeFont,
                color: Colorz.textColor,
              ),
            ),
            const SizedBox(height: 10),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium.copyWith(
                color: Colorz.hintTextColor,
                fontSize: SizeConfig.smallFont,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            ...actions,
          ],
        ),
      ),
    );
  }

  // ── Confirm dialog (for destructive actions like cancel order) ────────────

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Go Back',
    bool isDestructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => _buildDialog(
        context: dCtx,
        icon: isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
        iconColor: isDestructive ? Colorz.redColor : Colorz.primary,
        title: title,
        message: message,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colorz.redColor : Colorz.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dCtx, true),
              child: Text(confirmText,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colors.white, fontSize: SizeConfig.mediumFont)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colorz.dividerColor),
                ),
              ),
              onPressed: () => Navigator.pop(dCtx, false),
              child: Text(cancelText,
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.mediumFont)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Alert dialog (single OK button — for info / errors) ───────────────────

  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    bool isError = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => _buildDialog(
        context: dCtx,
        icon: isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
        iconColor: isError ? Colorz.redColor : Colorz.primary,
        title: title,
        message: message,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isError ? Colorz.redColor : Colorz.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dCtx),
              child: Text(buttonText,
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colors.white, fontSize: SizeConfig.mediumFont)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Challenge blocked dialog ───────────────────────────────────────────────
  // canUnlock = true  → shows "Quick Unlock" button (trade/PnL limits hit)
  // canUnlock = false → shows only "OK" button (quantity rule — fix your input)

  static void showBlocked(
    BuildContext context, {
    required String title,
    required String message,
    bool canUnlock = true,
    VoidCallback? onUnlock,
    bool isUnlocking = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => _buildDialog(
          context: ctx,
          icon: canUnlock ? Icons.lock_outline_rounded : Icons.block_rounded,
          iconColor: canUnlock ? Colorz.primary : Colorz.redColor,
          title: title,
          message: message,
          actions: [
            if (canUnlock) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isUnlocking
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          onUnlock?.call();
                        },
                  child: isUnlocking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_open_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('Quick Unlock',
                                style: AppTextStyles.semiBold.copyWith(
                                    color: Colors.white,
                                    fontSize: SizeConfig.mediumFont)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colorz.dividerColor),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(canUnlock ? 'Cancel' : 'OK',
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.hintTextColor,
                        fontSize: SizeConfig.mediumFont)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Challenge completed dialog ─────────────────────────────────────────────
  // Shown instead of Quick Unlock once the challenge's day duration is over —
  // user must set up a new challenge to keep trading.

  static void showChallengeCompleted(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => _buildDialog(
        context: dCtx,
        icon: Icons.flag_circle_rounded,
        iconColor: Colorz.primary,
        title: 'Challenge Completed',
        message:
            'Your challenge duration has ended. Please set up a new challenge to continue trading.',
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorz.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dCtx);
                NavigatorService.pushNamed(AppRoutes.setupChallengePage);
              },
              child: Text('Setup New Challenge',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colors.white, fontSize: SizeConfig.mediumFont)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── In-app snackbar ───────────────────────────────────────────────────────────

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.medium.copyWith(
                    color: Colors.white, fontSize: SizeConfig.smallFont),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colorz.greenColor : Colorz.redColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isSuccess ? 2 : 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message, isSuccess: true);

  static void showError(BuildContext context, String message) =>
      show(context, message, isSuccess: false);
}
