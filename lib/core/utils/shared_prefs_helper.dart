import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  Future<void> setAuthenticated(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', isAuthenticated);
  }

  Future<bool> getAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_authenticated') ?? false;
  }

  Future<void> saveAuthData(String token,String accessToken, String clientId,String clientName,String clientUcc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('auth_token', token);
    await prefs.setString('access_token', accessToken);
    await prefs.setString('client_id', clientId);
    await prefs.setString('client_name', clientName);
    await prefs.setString('client_ucc', clientUcc);
    await prefs.setInt('last_active_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('client_id');
  }

  Future<String?> getClientName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('client_name');
  }

  Future<String?> getClientUcc() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('client_ucc');
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('access_token');
    await prefs.remove('client_id');
    await prefs.remove('client_name');
    await prefs.remove('client_ucc');
    await prefs.remove('is_authenticated');
    await prefs.remove('has_pin_set');
    await prefs.remove('biometric_enabled');
    await prefs.remove('last_active_time');
  }

  // ── Quick Unlock (5-min session window) ──────────────────────────────────────
  static const int _quickUnlockWindowMs = 5 * 60 * 1000; // 5 minutes

  Future<void> saveLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_active_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> isWithinQuickUnlockWindow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt('last_active_time');
    if (lastActive == null) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
    return elapsed < _quickUnlockWindowMs;
  }

  // ── App PIN ──────────────────────────────────────────────────────────────────
  Future<void> setPinConfigured(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_pin_set', value);
  }

  Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_pin_set') ?? false;
  }

  // ── Biometric ────────────────────────────────────────────────────────────────
  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }
}