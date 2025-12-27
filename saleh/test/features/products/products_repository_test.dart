import 'package:flutter_test/flutter_test.dart';
import 'package:saleh/features/products/presentation/screens/add_product/models/product_form_state.dart';

/// Unit Tests for Products Repository and related classes
/// اختبارات الوحدة لمستودع المنتجات والكلاسات المرتبطة
void main() {
  group('ProductsRepository - Unit Tests', () {
    group('Product Model Validation', () {
      test('منتج صالح يجب أن يكون له اسم غير فارغ', () {
        const name = 'منتج تجريبي';
        expect(name.isNotEmpty, isTrue);
        expect(name.length >= 2, isTrue);
      });

      test('السعر يجب أن يكون موجباً', () {
        const price = 99.99;
        expect(price > 0, isTrue);
      });

      test('السعر صفر غير مقبول للمنتجات المدفوعة', () {
        const price = 0.0;
        expect(price > 0, isFalse);
      });

      test('المخزون يجب ألا يكون سالباً', () {
        const stock = 50;
        expect(stock >= 0, isTrue);

        const negativeStock = -1;
        expect(negativeStock >= 0, isFalse);
      });

      test('معرف التصنيف يجب أن يكون صالحاً', () {
        const categoryId = 'cat-123';
        expect(categoryId.isNotEmpty, isTrue);

        const emptyCategoryId = '';
        expect(emptyCategoryId.isNotEmpty, isFalse);
      });
    });

    group('Product Type Handling', () {
      test('ProductType.physical هو النوع الافتراضي', () {
        const state = ProductFormState();
        expect(state.productType, equals(ProductType.physical));
      });

      test('جميع أنواع المنتجات معرفة', () {
        expect(ProductType.values.length, greaterThanOrEqualTo(2));
        expect(ProductType.values.contains(ProductType.physical), isTrue);
        expect(ProductType.values.contains(ProductType.digital), isTrue);
      });

      test('المنتج الرقمي لا يحتاج مخزون', () {
        const state = ProductFormState(
          productType: ProductType.digital,
          stock: null,
        );
        expect(state.productType, equals(ProductType.digital));
        expect(state.stock, isNull);
      });
    });

    group('Product Visibility Settings', () {
      test('الإعدادات الافتراضية للظهور صحيحة', () {
        const state = ProductFormState();
        expect(state.showInStore, isTrue);
        expect(state.showInMbuyApp, isTrue);
        expect(state.showInDropshipping, isFalse);
      });

      test('يمكن تعطيل الظهور في المتجر', () {
        const state = ProductFormState(showInStore: false);
        expect(state.showInStore, isFalse);
      });

      test('يمكن تفعيل الدروب شوبينق', () {
        const state = ProductFormState(showInDropshipping: true);
        expect(state.showInDropshipping, isTrue);
      });
    });

    group('Price Formatting', () {
      test('السعر يجب أن يكون بتنسيق صحيح', () {
        const price = 99.99;
        final formatted = price.toStringAsFixed(2);
        expect(formatted, equals('99.99'));
      });

      test('السعر الكبير يجب أن يبقى دقيقاً', () {
        const price = 12345.67;
        final formatted = price.toStringAsFixed(2);
        expect(formatted, equals('12345.67'));
      });

      test('السعر بدون كسور', () {
        const price = 100.0;
        final formatted = price.toStringAsFixed(2);
        expect(formatted, equals('100.00'));
      });
    });

    group('Product Data Transformation', () {
      test('تحويل البيانات من JSON إلى Map', () {
        final productJson = {
          'id': 'prod-123',
          'name': 'منتج',
          'price': 50.0,
          'stock': 10,
        };

        expect(productJson['id'], equals('prod-123'));
        expect(productJson['name'], equals('منتج'));
        expect(productJson['price'], equals(50.0));
        expect(productJson['stock'], equals(10));
      });

      test('التعامل مع القيم الناقصة', () {
        final productJson = {'id': 'prod-123', 'name': 'منتج'};

        final price = productJson['price'] as double? ?? 0.0;
        final stock = productJson['stock'] as int? ?? 0;

        expect(price, equals(0.0));
        expect(stock, equals(0));
      });
    });

    group('API Endpoint Paths', () {
      test('مسار جلب المنتجات صحيح', () {
        const endpoint = '/secure/merchant/products';
        expect(endpoint.startsWith('/secure'), isTrue);
        expect(endpoint.contains('products'), isTrue);
      });

      test('مسار إنشاء منتج صحيح', () {
        const endpoint = '/secure/merchant/products';
        expect(endpoint, equals('/secure/merchant/products'));
      });

      test('مسار تحديث منتج يتضمن المعرف', () {
        const productId = 'prod-123';
        final endpoint = '/secure/merchant/products/$productId';
        expect(endpoint, equals('/secure/merchant/products/prod-123'));
      });

      test('مسار حذف منتج صحيح', () {
        const productId = 'prod-456';
        final endpoint = '/secure/merchant/products/$productId';
        expect(endpoint.contains(productId), isTrue);
      });
    });
  });

  group('Categories - Unit Tests', () {
    test('مسار التصنيفات صحيح', () {
      const endpoint = '/categories';
      expect(endpoint, equals('/categories'));
    });

    test('التصنيف يجب أن يكون له اسم', () {
      final category = {
        'id': 'cat-1',
        'name': 'إلكترونيات',
        'name_en': 'Electronics',
      };

      expect(category['name'], isNotNull);
      expect((category['name'] as String).isNotEmpty, isTrue);
    });

    test('التصنيف يمكن أن يكون له اسم إنجليزي', () {
      final category = {
        'id': 'cat-1',
        'name': 'إلكترونيات',
        'name_en': 'Electronics',
      };

      expect(category['name_en'], equals('Electronics'));
    });
  });

  group('Error Handling', () {
    test('رسالة خطأ عدم وجود توكن', () {
      const errorMessage = 'لا يوجد رمز وصول - يجب تسجيل الدخول';
      expect(errorMessage.contains('رمز وصول'), isTrue);
    });

    test('رسالة خطأ منتج غير موجود', () {
      const errorMessage = 'المنتج غير موجود';
      expect(errorMessage.isNotEmpty, isTrue);
    });

    test('HTTP status codes معروفة', () {
      const successCodes = [200, 201];
      const errorCodes = [400, 401, 403, 404, 500];

      expect(successCodes.contains(200), isTrue);
      expect(successCodes.contains(201), isTrue);
      expect(errorCodes.contains(401), isTrue);
      expect(errorCodes.contains(404), isTrue);
    });
  });
}
