import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mock responses for Merchant Repository Tests
class MerchantMockResponses {
  /// متجر موجود
  static http.Response getStoreSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'store-uuid-123',
          'owner_id': 'user-uuid-456',
          'name': 'متجر تجريبي',
          'description': 'وصف المتجر التجريبي',
          'city': 'الرياض',
          'status': 'active',
          'is_active': true,
          'logo_url': 'https://example.com/logo.png',
          'banner_url': 'https://example.com/banner.jpg',
          'created_at': '2025-01-01T00:00:00Z',
          'settings': {'currency': 'SAR', 'language': 'ar'},
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// لا يوجد متجر
  static http.Response noStore() {
    return http.Response(
      jsonEncode({'ok': true, 'data': null}),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// إنشاء متجر ناجح
  static http.Response createStoreSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'new-store-uuid',
          'owner_id': 'user-uuid-789',
          'name': 'متجر جديد',
          'description': 'متجر جديد تم إنشاؤه',
          'city': 'جدة',
          'status': 'pending',
          'is_active': false,
          'created_at': '2025-12-26T12:00:00Z',
        },
      }),
      201,
      headers: {'content-type': 'application/json'},
    );
  }

  /// متجر موجود مسبقاً
  static http.Response storeAlreadyExists() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'Conflict',
        'detail': 'User already has a store',
      }),
      409,
      headers: {'content-type': 'application/json'},
    );
  }

  /// تحديث متجر ناجح
  static http.Response updateStoreSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'store-uuid-123',
          'name': 'متجر محدث',
          'description': 'وصف محدث',
          'city': 'الدمام',
          'status': 'active',
          'is_active': true,
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// لا يوجد توكن
  static http.Response unauthorized() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'UNAUTHORIZED',
        'message': 'لا يوجد رمز وصول',
      }),
      401,
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
