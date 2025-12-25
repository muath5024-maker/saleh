import 'dart:convert';
import '../../../core/services/api_service.dart';

/// Service for managing shopping cart operations via Worker API
class CartService {
  static final _api = ApiService();

  /// Add product to cart
  static Future<void> addToCart(String productId, {int quantity = 1}) async {
    final response = await _api.post(
      '/cart/items',
      body: {'product_id': productId, 'quantity': quantity},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل في إضافة المنتج إلى السلة');
    }
  }

  /// Remove product from cart
  static Future<void> removeFromCart(String productId) async {
    final response = await _api.delete('/cart/items/$productId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('فشل في حذف المنتج من السلة');
    }
  }

  /// Update cart item quantity
  static Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final response = await _api.put(
      '/cart/items/$productId',
      body: {'quantity': quantity},
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في تحديث الكمية');
    }
  }

  /// Get cart items
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final response = await _api.get('/cart/items');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    }

    return [];
  }

  /// Get cart items count
  static Future<int> getCartCount() async {
    final response = await _api.get('/cart/count');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    }

    return 0;
  }

  /// Clear cart
  static Future<void> clearCart() async {
    await _api.delete('/cart/items');
  }
}
