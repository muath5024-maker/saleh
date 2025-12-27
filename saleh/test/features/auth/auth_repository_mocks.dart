import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mock responses for Auth Repository Tests
class AuthMockResponses {
  /// تسجيل دخول ناجح
  static http.Response loginSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'access_token': 'mock_access_token_12345',
        'refresh_token': 'mock_refresh_token_67890',
        'user': {
          'id': 'user-uuid-123',
          'email': 'test@example.com',
          'role': 'merchant',
          'user_metadata': {'full_name': 'Test User', 'role': 'merchant'},
        },
        'profile': {
          'id': 'profile-uuid-456',
          'auth_user_id': 'user-uuid-123',
          'role': 'merchant',
          'display_name': 'Test User',
          'email': 'test@example.com',
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// بيانات دخول خاطئة
  static http.Response invalidCredentials() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'INVALID_CREDENTIALS',
        'message': 'Invalid email or password',
      }),
      401,
      headers: {'content-type': 'application/json'},
    );
  }

  /// تسجيل حساب ناجح
  static http.Response registerSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'access_token': 'new_user_access_token',
        'refresh_token': 'new_user_refresh_token',
        'user': {
          'id': 'new-user-uuid',
          'email': 'newuser@example.com',
          'role': 'merchant',
        },
        'profile': {
          'id': 'new-profile-uuid',
          'auth_user_id': 'new-user-uuid',
          'role': 'merchant',
        },
      }),
      201,
      headers: {'content-type': 'application/json'},
    );
  }

  /// البريد مسجل مسبقاً
  static http.Response emailAlreadyExists() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'EMAIL_EXISTS',
        'message': 'Email already exists',
      }),
      409,
      headers: {'content-type': 'application/json'},
    );
  }

  /// تحديث التوكن ناجح
  static http.Response refreshSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'access_token': 'refreshed_access_token',
        'refresh_token': 'refreshed_refresh_token',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// خطأ في الخادم
  static http.Response serverError() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'SERVER_ERROR',
        'message': 'Internal server error',
      }),
      500,
      headers: {'content-type': 'application/json'},
    );
  }
}
