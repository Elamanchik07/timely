import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/user.dart';

// Separate state for registration result (success/error message)
final registerStateProvider = StateProvider<AsyncValue<String?>>((ref) {
  return const AsyncValue.data(null);
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    debugPrint('[AUTH] _init: loading current user from storage');
    try {
      final user = await _repository.getCurrentUser();
      debugPrint('[AUTH] _init: user=${user?.email ?? "null"}');
      state = AsyncValue.data(user);
    } catch (e) {
      debugPrint('[AUTH] _init error: $e');
      state = const AsyncValue.data(null); // Fallback to logged out on init error
    }
  }

  Future<void> login(String email, String password) async {
    debugPrint('[AUTH] login: starting for $email');
    // Reset error state before new attempt
    state = const AsyncValue.data(null);
    await Future.delayed(Duration.zero); // Allow listeners to process reset
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      debugPrint('[AUTH] login: success, user=${user.email}, role=${user.role}, status=${user.status}');
      
      // Store for biometrics if enabled
      if (_ref.read(biometricEnabledProvider)) {
        final storage = _ref.read(secureStorageProvider);
        await storage.write(key: 'bio_email', value: email);
        await storage.write(key: 'bio_pass', value: password);
      }

      state = AsyncValue.data(user);
    } catch (e, st) {
      debugPrint('[AUTH] login: error=$e');
      state = AsyncValue.error(e, st);
      rethrow; // Let the UI handle it AND re-throw so await catches it
    }
  }

  Future<void> loginWithBiometrics(String reason) async {
    final bioService = _ref.read(biometricServiceProvider);
    final bioEnabled = _ref.read(biometricEnabledProvider);
    
    if (!bioEnabled) return;

    final authenticated = await bioService.authenticate(reason: reason);
    if (!authenticated) return;

    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(secureStorageProvider);
      final email = await storage.read(key: 'bio_email');
      final pass = await storage.read(key: 'bio_pass');

      if (email == null || pass == null) {
        throw Exception('Stored credentials not found');
      }

      final user = await _repository.login(email, pass);
      state = AsyncValue.data(user);
    } catch (e, st) {
      debugPrint('[AUTH] biometric_login: error=$e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('[AUTH] logout');
    state = const AsyncValue.data(null);
    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('[AUTH] logout background error: $e');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? groupCode,
    int? course,
    String? faculty,
  }) async {
    final registerState = _ref.read(registerStateProvider.notifier);
    registerState.state = const AsyncValue.loading();
    try {
      final msg = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        groupCode: groupCode,
        course: course,
        faculty: faculty,
      );
      registerState.state = AsyncValue.data(msg);
    } catch (e, st) {
      debugPrint('[AUTH] register error: $e');
      registerState.state = AsyncValue.error(e, st);
    }
  }
}
