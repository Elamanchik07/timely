import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient, storage);
});

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<User?> getCurrentUser() async {
    try {
      final jsonString = await _storage.read(key: AppConstants.userDataKey);
      if (jsonString != null) {
        return User.fromJson(jsonDecode(jsonString));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data['success'] == true) {
        await _storage.write(key: AppConstants.tokenKey, value: data['token']);
        final user = User.fromJson(data['user']);
        await _storage.write(
            key: AppConstants.userDataKey, value: jsonEncode(user.toJson()));
        return user;
      } else {
        throw Exception(data['msg'] ?? 'Ошибка входа');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final msg = e.response!.data['msg'] ?? 'Ошибка входа';
        throw Exception(msg);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания. Проверьте подключение.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception('Ошибка сети');
    }
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? groupCode,
    int? course,
    String? faculty,
  }) async {
    try {
      final response = await _apiClient.client.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'groupCode': groupCode,
        'course': course,
        'faculty': faculty,
      });

      if (response.data['success'] == true) {
        return response.data['msg'] ?? 'Регистрация успешна!';
      } else {
        throw Exception(response.data['msg'] ?? 'Ошибка регистрации');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['msg'] ?? 'Ошибка регистрации');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания. Проверьте подключение.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception('Ошибка сети');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userDataKey);
  }

  /// Step 1: Request a 6-digit reset code to be sent to the user's email
  Future<String> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/password/reset/request',
        data: {'email': email},
      );
      if (response.data['success'] == true) {
        return response.data['msg'] ?? 'Код отправлен';
      }
      throw Exception(response.data['msg'] ?? 'Ошибка отправки кода');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['msg'] ?? 'Ошибка отправки кода');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception('Ошибка сети');
    }
  }

  /// Step 2: Verify the 6-digit code; returns a one-time resetToken
  Future<String> verifyResetCode(String email, String code) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/password/reset/verify',
        data: {'email': email, 'code': code},
      );
      if (response.data['success'] == true) {
        return response.data['resetToken'];
      }
      throw Exception(response.data['msg'] ?? 'Неверный код');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['msg'] ?? 'Ошибка верификации');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception('Ошибка сети');
    }
  }

  /// Step 3: Set new password using the resetToken from Step 2
  Future<String> confirmPasswordReset(String resetToken, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/password/reset/confirm',
        data: {'resetToken': resetToken, 'password': password},
      );
      if (response.data['success'] == true) {
        return response.data['msg'] ?? 'Пароль изменён';
      }
      throw Exception(response.data['msg'] ?? 'Ошибка сброса пароля');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['msg'] ?? 'Ошибка сброса пароля');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Нет соединения с сервером');
      }
      throw Exception('Ошибка сети');
    }
  }
}
