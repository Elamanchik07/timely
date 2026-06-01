import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final biometricServiceProvider = Provider((ref) => BiometricService());

final biometricEnabledProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(false) {
    _loadSettings();
  }

  static const _key = 'biometric_enabled';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    state = enabled;
  }
}
