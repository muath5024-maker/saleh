import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mock responses for Products Repository Tests
class ProductsMockResponses {
  /// قائمة منتجات ناجحة
  static http.Response getProductsSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': [
          {
            'id': 'product-1',
            'name': 'منتج تجريبي 1',
            'description': 'وصف المنتج الأول',
            'price': 99.99,
            'stock': 50,
            'category_id': 'cat-1',
            'store_id': 'store-1',
            'is_active': true,
            'image_url': 'https://example.com/image1.jpg',
            'created_at': '2025-01-01T00:00:00Z',
          },
          {
            'id': 'product-2',
            'name': 'منتج تجريبي 2',
            'description': 'وصف المنتج الثاني',
            'price': 149.99,
            'stock': 25,
            'category_id': 'cat-2',
            'store_id': 'store-1',
            'is_active': true,
            'image_url': 'https://example.com/image2.jpg',
            'created_at': '2025-01-02T00:00:00Z',
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// قائمة فارغة
  static http.Response getProductsEmpty() {
    return http.Response(
      jsonEncode({'ok': true, 'data': []}),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// منتج واحد ناجح
  static http.Response getProductSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'product-1',
          'name': 'منتج تجريبي',
          'description': 'وصف المنتج',
          'price': 99.99,
          'stock': 50,
          'category_id': 'cat-1',
          'store_id': 'store-1',
          'is_active': true,
          'image_url': 'https://example.com/image.jpg',
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// منتج غير موجود
  static http.Response productNotFound() {
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'NOT_FOUND',
        'message': 'Product not found',
      }),
      404,
      headers: {'content-type': 'application/json'},
    );
  }

  /// إنشاء منتج ناجح
  static http.Response createProductSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'new-product-id',
          'name': 'منتج جديد',
          'description': 'وصف المنتج الجديد',
          'price': 199.99,
          'stock': 100,
          'category_id': 'cat-1',
          'store_id': 'store-1',
          'is_active': true,
        },
      }),
      201,
      headers: {'content-type': 'application/json'},
    );
  }

  /// تحديث منتج ناجح
  static http.Response updateProductSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'data': {
          'id': 'product-1',
          'name': 'منتج محدث',
          'description': 'وصف محدث',
          'price': 129.99,
          'stock': 75,
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// حذف منتج ناجح
  static http.Response deleteProductSuccess() {
    return http.Response(
      jsonEncode({'ok': true, 'message': 'Product deleted successfully'}),
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
        'message': 'Invalid or missing token',
      }),
      401,
      headers: {'content-type': 'application/json'},
    );
  }
}

/// Mock responses for Categories
class CategoriesMockResponses {
  /// قائمة تصنيفات ناجحة
  static http.Response getCategoriesSuccess() {
    return http.Response(
      jsonEncode({
        'ok': true,
        'categories': [
          {
            'id': 'cat-1',
            'name': 'إلكترونيات',
            'name_en': 'Electronics',
            'icon': 'devices',
            'is_active': true,
          },
          {
            'id': 'cat-2',
            'name': 'ملابس',
            'name_en': 'Clothing',
            'icon': 'shopping_bag',
            'is_active': true,
          },
          {
            'id': 'cat-3',
            'name': 'أثاث',
            'name_en': 'Furniture',
            'icon': 'chair',
            'is_active': true,
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  /// قائمة فارغة
  static http.Response getCategoriesEmpty() {
    return http.Response(
      jsonEncode({'ok': true, 'categories': []}),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
