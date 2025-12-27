import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mock responses for Payment Repository Tests
class PaymentMockResponses {
  /// باقات النقاط
  static http.Response getPackagesSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'packages': [
          {
            'id': 'pkg-basic',
            'name': 'الباقة الأساسية',
            'points': 100,
            'price': 10.0,
            'currency': 'SAR',
            'bonus_points': 0,
            'is_popular': false,
          },
          {
            'id': 'pkg-standard',
            'name': 'الباقة القياسية',
            'points': 500,
            'price': 45.0,
            'currency': 'SAR',
            'bonus_points': 50,
            'is_popular': true,
          },
          {
            'id': 'pkg-premium',
            'name': 'الباقة المميزة',
            'points': 1000,
            'price': 80.0,
            'currency': 'SAR',
            'bonus_points': 200,
            'is_popular': false,
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// إنشاء نية دفع ناجحة
  static http.Response createPaymentIntentSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'payment_intent_id': 'pi_12345678',
        'client_secret': 'cs_secret_key',
        'amount': 4500,
        'currency': 'SAR',
        'status': 'requires_payment_method',
      }),
      201,
      headers: {'content-type': 'application/json'},
    );
  }

  /// حالة دفع ناجحة
  static http.Response getPaymentStatusSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'payment': {
          'id': 'pay-123',
          'status': 'completed',
          'amount': 45.0,
          'currency': 'SAR',
          'points_added': 550,
          'completed_at': '2025-12-26T12:00:00Z',
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// حالة دفع معلقة
  static http.Response getPaymentStatusPending() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'payment': {
          'id': 'pay-456',
          'status': 'pending',
          'amount': 80.0,
          'currency': 'SAR',
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// سجل المدفوعات
  static http.Response getPaymentHistorySuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'payments': [
          {
            'id': 'pay-001',
            'amount': 45.0,
            'currency': 'SAR',
            'points': 550,
            'status': 'completed',
            'created_at': '2025-12-25T10:00:00Z',
          },
          {
            'id': 'pay-002',
            'amount': 10.0,
            'currency': 'SAR',
            'points': 100,
            'status': 'completed',
            'created_at': '2025-12-20T14:30:00Z',
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// محاكاة دفع ناجحة
  static http.Response simulatePaymentSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'simulation': true,
        'points_added': 550,
        'new_balance': 1550,
        'message': 'تمت إضافة النقاط بنجاح (محاكاة)',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// خطأ في الدفع
  static http.Response paymentFailed() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'PAYMENT_FAILED',
        'message': 'فشل في معالجة الدفع',
      }),
      400,
      headers: {'content-type': 'application/json'},
    );
  }
}
