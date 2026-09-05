import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class DemoModeService extends ChangeNotifier {
  static final DemoModeService instance = DemoModeService._();
  DemoModeService._();

  static const String _kDemoMode = 'demo_mode_active';
  final _box = GetStorage();

  bool _isActive = false;
  bool get isActive => _isActive;

  void init() {
    _isActive = _box.read<bool>(_kDemoMode) ?? false;
    notifyListeners();
  }

  Future<void> setActive(bool value) async {
    _isActive = value;
    await _box.write(_kDemoMode, value);
    notifyListeners();
  }
}
