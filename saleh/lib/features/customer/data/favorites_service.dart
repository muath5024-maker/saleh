import 'dart:convert';
import '../../../core/services/api_service.dart';

/// Service for managing user favorites via Worker API
class FavoritesService {
  static final _api = ApiService();

  /// Toggle favorite status for a product
  static Future<bool> toggleFavorite(String productId) async {
    final response = await _api.post(
      '/favorites/toggle',
      body: {'product_id': productId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_favorite'] ?? false;
    }

    throw Exception('فشل في تحديث المفضلة');
  }

  /// Check if product is in favorites
  static Future<bool> isFavorite(String productId) async {
    final response = await _api.get('/favorites/check/$productId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_favorite'] ?? false;
    }

    return false;
  }

  /// Get all favorite products
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _api.get('/favorites');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['favorites'] ?? []);
    }

    return [];
  }

  /// Remove from favorites
  static Future<void> removeFavorite(String productId) async {
    final response = await _api.delete('/favorites/$productId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('فشل في حذف المنتج من المفضلة');
    }
  }

  /// Get favorites count
  static Future<int> getFavoritesCount() async {
    final response = await _api.get('/favorites/count');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    }

    return 0;
  }
}
