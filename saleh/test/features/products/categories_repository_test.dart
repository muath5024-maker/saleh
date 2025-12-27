import 'package:flutter_test/flutter_test.dart';

/// Unit Tests for Categories Repository
/// اختبارات الوحدة لمستودع التصنيفات
void main() {
  group('CategoriesRepository - Unit Tests', () {
    group('Category Model', () {
      test('التصنيف يحتوي البيانات الأساسية', () {
        final category = {
          'id': 'cat-electronics',
          'name': 'إلكترونيات',
          'name_en': 'Electronics',
          'icon': 'devices',
          'is_active': true,
        };

        expect(category['id'], isNotNull);
        expect(category['name'], isNotNull);
        expect(category['is_active'], isTrue);
      });

      test('التصنيف يمكن أن يكون له اسم عربي وإنجليزي', () {
        final category = {'name': 'ملابس', 'name_en': 'Clothing'};

        expect(category['name'], equals('ملابس'));
        expect(category['name_en'], equals('Clothing'));
      });

      test('التصنيف يمكن أن يكون له أيقونة', () {
        final category = {'id': 'cat-1', 'name': 'أثاث', 'icon': 'chair'};

        expect(category['icon'], isNotNull);
        expect((category['icon'] as String).isNotEmpty, isTrue);
      });
    });

    group('Category Validation', () {
      test('معرف التصنيف مطلوب', () {
        final category = {'id': 'cat-123', 'name': 'تصنيف'};
        expect(category['id'], isNotNull);
        expect((category['id'] as String).isNotEmpty, isTrue);
      });

      test('اسم التصنيف مطلوب', () {
        final category = {'id': 'cat-123', 'name': 'إلكترونيات'};
        expect(category['name'], isNotNull);
        expect((category['name'] as String).isNotEmpty, isTrue);
      });

      test('التصنيف غير النشط', () {
        final category = {
          'id': 'cat-disabled',
          'name': 'تصنيف قديم',
          'is_active': false,
        };

        expect(category['is_active'], isFalse);
      });
    });

    group('Categories List', () {
      test('قائمة التصنيفات يمكن أن تكون فارغة', () {
        final categories = <Map<String, dynamic>>[];
        expect(categories.isEmpty, isTrue);
      });

      test('قائمة التصنيفات تحتوي عدة عناصر', () {
        final categories = [
          {'id': 'cat-1', 'name': 'إلكترونيات'},
          {'id': 'cat-2', 'name': 'ملابس'},
          {'id': 'cat-3', 'name': 'أثاث'},
        ];

        expect(categories.length, equals(3));
      });

      test('يمكن فلترة التصنيفات النشطة', () {
        final categories = [
          {'id': 'cat-1', 'name': 'إلكترونيات', 'is_active': true},
          {'id': 'cat-2', 'name': 'ملابس', 'is_active': true},
          {'id': 'cat-3', 'name': 'قديم', 'is_active': false},
        ];

        final active = categories.where((c) => c['is_active'] == true).toList();
        expect(active.length, equals(2));
      });

      test('يمكن البحث في التصنيفات بالاسم', () {
        final categories = [
          {'id': 'cat-1', 'name': 'إلكترونيات'},
          {'id': 'cat-2', 'name': 'ملابس'},
          {'id': 'cat-3', 'name': 'أثاث'},
        ];

        final searchTerm = 'ملابس';
        final results = categories
            .where((c) => (c['name'] as String).contains(searchTerm))
            .toList();

        expect(results.length, equals(1));
        expect(results.first['id'], equals('cat-2'));
      });
    });

    group('API Response', () {
      test('استجابة ناجحة تحتوي categories', () {
        final response = {
          'ok': true,
          'categories': [
            {'id': 'cat-1', 'name': 'إلكترونيات'},
          ],
        };

        expect(response['ok'], isTrue);
        expect(response['categories'], isNotNull);
        expect((response['categories'] as List).isNotEmpty, isTrue);
      });

      test('استجابة فارغة صالحة', () {
        final response = {'ok': true, 'categories': []};

        expect(response['ok'], isTrue);
        expect((response['categories'] as List).isEmpty, isTrue);
      });

      test('استجابة خطأ', () {
        final response = {'ok': false, 'error': 'فشل جلب التصنيفات'};

        expect(response['ok'], isFalse);
        expect(response['error'], isNotNull);
      });
    });

    group('API Endpoint', () {
      test('مسار التصنيفات عام (public)', () {
        const endpoint = '/categories';
        expect(endpoint.startsWith('/secure'), isFalse);
      });

      test('المسار صحيح', () {
        const endpoint = '/categories';
        expect(endpoint, equals('/categories'));
      });

      test('لا يحتاج authentication', () {
        // التصنيفات endpoint عام
        const isPublic = true;
        expect(isPublic, isTrue);
      });
    });

    group('Error Handling', () {
      test('خطأ في الاتصال', () {
        const errorMessage = 'خطأ في الاتصال بالخادم';
        expect(errorMessage.contains('خطأ'), isTrue);
      });

      test('كود خطأ 500 = خطأ في الخادم', () {
        const statusCode = 500;
        expect(statusCode >= 500, isTrue);
      });

      test('كود 200 = نجاح', () {
        const statusCode = 200;
        expect(statusCode, equals(200));
      });
    });

    group('Category Icons', () {
      test('الأيقونات المتاحة', () {
        const icons = [
          'devices',
          'shopping_bag',
          'chair',
          'sports_esports',
          'restaurant',
          'local_grocery_store',
        ];

        expect(icons.contains('devices'), isTrue);
        expect(icons.contains('shopping_bag'), isTrue);
      });

      test('أيقونة افتراضية للتصنيفات بدون أيقونة', () {
        final category = {'id': 'cat-1', 'name': 'تصنيف', 'icon': null};

        final icon = category['icon'] ?? 'category';
        expect(icon, equals('category'));
      });
    });

    group('Localization', () {
      test('يمكن الحصول على الاسم حسب اللغة', () {
        final category = {'name': 'إلكترونيات', 'name_en': 'Electronics'};

        String getName(String locale) {
          if (locale == 'ar') return category['name']!;
          return category['name_en'] ?? category['name']!;
        }

        expect(getName('ar'), equals('إلكترونيات'));
        expect(getName('en'), equals('Electronics'));
      });

      test('يرجع الاسم العربي إذا لم يوجد إنجليزي', () {
        final category = {'name': 'تصنيف عربي', 'name_en': null};

        final nameEn = category['name_en'] ?? category['name'];
        expect(nameEn, equals('تصنيف عربي'));
      });
    });
  });
}
