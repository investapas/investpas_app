import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import '../core/services/free_unlock_timer_service.dart';

/// A top banner that appears on every screen while a FREE quick-unlock timer
/// is running.  It auto-hides when the timer expires.
///
/// Embed it via [MaterialApp.builder] so it floats above every route:
///
/// ```dart
/// builder: (context, child) => Column(
///   children: [const FreeUnlockTimerBar(), Expanded(child: child!)],
/// ),
/// ```
class FreeUnlockTimerBar extends StatelessWidget {
  const FreeUnlockTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FreeUnlockTimerService.instance,
      builder: (context, _) {
        final svc = FreeUnlockTimerService.instance;
        if (!svc.isActive) return const SizedBox.shrink();

        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colorz.primary,
                  Colorz.darkPrimary,
                ],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 6,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Clock icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                // Label
                Expanded(
                  child: Text(
                    'Free unlock timer running…',
                    style: AppTextStyles.medium.copyWith(
                      color: Colors.white,
                      fontSize: SizeConfig.smallFont,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Countdown pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        svc.countdown,
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colors.white,
                          fontSize: SizeConfig.mediumFont,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
