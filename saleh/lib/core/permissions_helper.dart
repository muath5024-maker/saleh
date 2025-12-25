import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_config.dart';

/// Helper class for managing app permissions and user capabilities
class PermissionsHelper {
  static const _storage = FlutterSecureStorage();

  /// Check if user can add products to cart (customers only)
  static Future<bool> canAddToCart() async {
    try {
      final role = await _storage.read(key: AppConfig.userRoleKey);
      // Only customers can add to cart, merchants cannot
      return role == 'customer';
    } catch (e) {
      return false;
    }
  }
}
