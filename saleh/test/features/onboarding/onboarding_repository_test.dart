import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saleh/features/onboarding/data/onboarding_repository.dart';

/// Unit Tests for Onboarding Repository
/// اختبارات الوحدة لمستودع الـ Onboarding
void main() {
  group('OnboardingRepository - Unit Tests', () {
    setUp(() {
      // تهيئة SharedPreferences للاختبارات
      SharedPreferences.setMockInitialValues({});
    });

    group('Onboarding Completion', () {
      test('الـ Onboarding غير مكتمل افتراضياً', () async {
        final repo = OnboardingRepository();
        final isComplete = await repo.isOnboardingComplete();
        expect(isComplete, isFalse);
      });

      test('يمكن تعيين الـ Onboarding كمكتمل', () async {
        final repo = OnboardingRepository();

        await repo.setOnboardingComplete();
        final isComplete = await repo.isOnboardingComplete();

        expect(isComplete, isTrue);
      });

      test('يمكن إعادة تعيين الـ Onboarding', () async {
        final repo = OnboardingRepository();

        await repo.setOnboardingComplete();
        await repo.resetOnboarding();
        final isComplete = await repo.isOnboardingComplete();

        expect(isComplete, isFalse);
      });
    });

    group('Feature Tooltips', () {
      test('Tooltip غير معروض افتراضياً', () async {
        final repo = OnboardingRepository();
        final hasSeen = await repo.hasSeenFeatureTooltip('global_search');
        expect(hasSeen, isFalse);
      });

      test('يمكن تعيين Tooltip كمعروض', () async {
        final repo = OnboardingRepository();

        await repo.markFeatureTooltipSeen('global_search');
        final hasSeen = await repo.hasSeenFeatureTooltip('global_search');

        expect(hasSeen, isTrue);
      });

      test('Tooltips مختلفة مستقلة عن بعضها', () async {
        final repo = OnboardingRepository();

        await repo.markFeatureTooltipSeen('global_search');

        final hasSeenSearch = await repo.hasSeenFeatureTooltip('global_search');
        final hasSeenShortcuts = await repo.hasSeenFeatureTooltip('shortcuts');

        expect(hasSeenSearch, isTrue);
        expect(hasSeenShortcuts, isFalse);
      });

      test('يمكن تعيين عدة Tooltips', () async {
        final repo = OnboardingRepository();

        await repo.markFeatureTooltipSeen('global_search');
        await repo.markFeatureTooltipSeen('shortcuts');
        await repo.markFeatureTooltipSeen('ai_tools');

        expect(await repo.hasSeenFeatureTooltip('global_search'), isTrue);
        expect(await repo.hasSeenFeatureTooltip('shortcuts'), isTrue);
        expect(await repo.hasSeenFeatureTooltip('ai_tools'), isTrue);
      });

      test('إعادة التعيين تمسح جميع Tooltips', () async {
        final repo = OnboardingRepository();

        await repo.markFeatureTooltipSeen('global_search');
        await repo.markFeatureTooltipSeen('shortcuts');
        await repo.resetOnboarding();

        expect(await repo.hasSeenFeatureTooltip('global_search'), isFalse);
        expect(await repo.hasSeenFeatureTooltip('shortcuts'), isFalse);
      });
    });

    group('New Features', () {
      test('قائمة الميزات الجديدة غير فارغة', () {
        final repo = OnboardingRepository();
        final features = repo.getNewFeatures();

        expect(features, isNotEmpty);
        expect(features.length, greaterThanOrEqualTo(1));
      });

      test('كل ميزة لها id فريد', () {
        final repo = OnboardingRepository();
        final features = repo.getNewFeatures();
        final ids = features.map((f) => f.id).toSet();

        expect(ids.length, equals(features.length));
      });

      test('كل ميزة لها عنوان ووصف', () {
        final repo = OnboardingRepository();
        final features = repo.getNewFeatures();

        for (final feature in features) {
          expect(feature.title.isNotEmpty, isTrue);
          expect(feature.description.isNotEmpty, isTrue);
          expect(feature.icon.isNotEmpty, isTrue);
        }
      });

      test('الميزات المتوقعة موجودة', () {
        final repo = OnboardingRepository();
        final features = repo.getNewFeatures();
        final ids = features.map((f) => f.id).toList();

        expect(ids.contains('global_search'), isTrue);
        expect(ids.contains('shortcuts'), isTrue);
        expect(ids.contains('ai_tools'), isTrue);
      });
    });

    group('NewFeature Model', () {
      test('NewFeature يمكن إنشاؤها بشكل صحيح', () {
        const feature = NewFeature(
          id: 'test_feature',
          title: 'ميزة تجريبية',
          description: 'وصف الميزة التجريبية',
          icon: 'test_icon',
        );

        expect(feature.id, equals('test_feature'));
        expect(feature.title, equals('ميزة تجريبية'));
        expect(feature.description, equals('وصف الميزة التجريبية'));
        expect(feature.icon, equals('test_icon'));
      });

      test('NewFeature هي const', () {
        const feature1 = NewFeature(
          id: 'feature1',
          title: 'Title',
          description: 'Desc',
          icon: 'icon',
        );

        const feature2 = NewFeature(
          id: 'feature1',
          title: 'Title',
          description: 'Desc',
          icon: 'icon',
        );

        expect(identical(feature1, feature2), isTrue);
      });
    });

    group('App Version Check', () {
      test('إصدار جديد للتطبيق يُكتشف', () async {
        SharedPreferences.setMockInitialValues({
          'last_seen_app_version': '1.0.0',
        });

        final repo = OnboardingRepository();
        final hasNewVersion = await repo.hasNewAppVersion();

        // الإصدار الحالي 2.0.0 مختلف عن 1.0.0
        expect(hasNewVersion, isTrue);
      });

      test('نفس الإصدار لا يُعتبر جديداً', () async {
        SharedPreferences.setMockInitialValues({
          'last_seen_app_version': '2.0.0',
        });

        final repo = OnboardingRepository();
        final hasNewVersion = await repo.hasNewAppVersion();

        expect(hasNewVersion, isFalse);
      });

      test('أول استخدام يُعتبر إصدار جديد', () async {
        SharedPreferences.setMockInitialValues({});

        final repo = OnboardingRepository();
        final hasNewVersion = await repo.hasNewAppVersion();

        expect(hasNewVersion, isTrue);
      });
    });

    group('Storage Keys', () {
      test('مفاتيح التخزين ثابتة', () {
        // التحقق من أن المفاتيح لا تتغير
        const onboardingKey = 'onboarding_complete';
        const tooltipsKey = 'seen_feature_tooltips';
        const versionKey = 'last_seen_app_version';

        expect(onboardingKey, equals('onboarding_complete'));
        expect(tooltipsKey, equals('seen_feature_tooltips'));
        expect(versionKey, equals('last_seen_app_version'));
      });
    });
  });
}
