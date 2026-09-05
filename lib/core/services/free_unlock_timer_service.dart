import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service that manages the FREE quick-unlock countdown timer.
///
/// Usage:
///   • Call [init] once at app startup to restore any persisted timer.
///   • Call [startTimer] when the user chooses "Free Unlock".
///   • Listen via [ListenableBuilder] / [AnimatedBuilder] anywhere in the tree.
class FreeUnlockTimerService extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────────
  static final FreeUnlockTimerService _instance =
      FreeUnlockTimerService._internal();
  static FreeUnlockTimerService get instance => _instance;
  FreeUnlockTimerService._internal();

  // ── SharedPrefs key ──────────────────────────────────────────────────────────
  static const String _kResumeAt = 'free_unlock_resume_at';

  // ── Internal state ───────────────────────────────────────────────────────────
  Timer? _ticker;
  DateTime? _resumeAt;
  String _countdown = '';
  bool _isActive = false;

  // ── Public getters ───────────────────────────────────────────────────────────
  bool get isActive => _isActive;
  String get countdown => _countdown;

  // ── Init (call once at startup) ──────────────────────────────────────────────
  /// Restores a persisted timer if one exists and hasn't expired.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kResumeAt);
    if (saved != null) {
      final resumeAt = DateTime.tryParse(saved);
      if (resumeAt != null && resumeAt.isAfter(DateTime.now())) {
        _startInternal(resumeAt);
      } else {
        await prefs.remove(_kResumeAt);
      }
    }
  }

  // ── Start ────────────────────────────────────────────────────────────────────
  /// Call this when user picks "Free Unlock" and dismisses the sheet.
  Future<void> startTimer(DateTime resumeAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResumeAt, resumeAt.toIso8601String());
    _startInternal(resumeAt);
  }

  // ── Internal helpers ─────────────────────────────────────────────────────────
  void _startInternal(DateTime resumeAt) {
    _resumeAt = resumeAt;
    _isActive = true;
    _updateCountdown();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_resumeAt == null) return;
    if (DateTime.now().isAfter(_resumeAt!)) {
      _stopTimer();
    } else {
      _updateCountdown();
      notifyListeners();
    }
  }

  void _updateCountdown() {
    if (_resumeAt == null) return;
    final diff = _resumeAt!.difference(DateTime.now());
    if (diff.isNegative) {
      _countdown = '00:00';
      return;
    }
    final mins = diff.inMinutes.toString().padLeft(2, '0');
    final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');
    _countdown = '$mins:$secs';
  }

  Future<void> _stopTimer() async {
    _ticker?.cancel();
    _ticker = null;
    _isActive = false;
    _resumeAt = null;
    _countdown = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kResumeAt);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
