import 'package:flutter_riverpod/flutter_riverpod.dart';

/// نوع الـ Overlay المفتوح
enum OverlayType {
  none,
  menu, // القائمة الرئيسية
  search, // البحث
  ai, // المساعد الذكي
  notifications, // الإشعارات
  shortcuts, // الاختصارات
  addProduct, // إضافة منتج
  viewStore, // عرض متجري
  wallet, // المحفظة
  points, // نقاط الولاء
  customers, // العملاء
  sales, // المبيعات
  reports, // التقارير
  marketing, // الحملات التسويقية
  about, // عن التطبيق
  store, // التطبيقات
  boostSales, // ضاعف ظهورك
  projects, // المشاريع
  custom, // صفحة مخصصة
}

/// حالة الـ Overlay
class OverlayState {
  final OverlayType type;
  final String? route; // المسار للصفحات المخصصة
  final String? title; // عنوان الصفحة

  const OverlayState({this.type = OverlayType.none, this.route, this.title});

  bool get isOpen => type != OverlayType.none;

  OverlayState copyWith({OverlayType? type, String? route, String? title}) {
    return OverlayState(
      type: type ?? this.type,
      route: route ?? this.route,
      title: title ?? this.title,
    );
  }
}

/// Provider للتحكم في الـ Overlay
class OverlayNotifier extends Notifier<OverlayState> {
  @override
  OverlayState build() => const OverlayState();

  /// فتح القائمة الرئيسية
  void openMenu() {
    state = const OverlayState(type: OverlayType.menu);
  }

  /// فتح البحث
  void openSearch() {
    state = const OverlayState(type: OverlayType.search);
  }

  /// فتح المساعد الذكي
  void openAI() {
    state = const OverlayState(type: OverlayType.ai);
  }

  /// فتح الإشعارات
  void openNotifications() {
    state = const OverlayState(type: OverlayType.notifications);
  }

  /// فتح الاختصارات
  void openShortcuts() {
    state = const OverlayState(type: OverlayType.shortcuts);
  }

  /// فتح إضافة منتج
  void openAddProduct() {
    state = const OverlayState(type: OverlayType.addProduct);
  }

  /// فتح عرض متجري
  void openViewStore() {
    state = const OverlayState(type: OverlayType.viewStore);
  }

  /// فتح المحفظة
  void openWallet() {
    state = const OverlayState(type: OverlayType.wallet);
  }

  /// فتح نقاط الولاء
  void openPoints() {
    state = const OverlayState(type: OverlayType.points);
  }

  /// فتح العملاء
  void openCustomers() {
    state = const OverlayState(type: OverlayType.customers);
  }

  /// فتح المبيعات
  void openSales() {
    state = const OverlayState(type: OverlayType.sales);
  }

  /// فتح التقارير
  void openReports() {
    state = const OverlayState(type: OverlayType.reports);
  }

  /// فتح الحملات التسويقية
  void openMarketing() {
    state = const OverlayState(type: OverlayType.marketing);
  }

  /// فتح عن التطبيق
  void openAbout() {
    state = const OverlayState(type: OverlayType.about);
  }

  /// فتح التطبيقات
  void openStore() {
    state = const OverlayState(type: OverlayType.store);
  }

  /// فتح ضاعف ظهورك
  void openBoostSales() {
    state = const OverlayState(type: OverlayType.boostSales);
  }

  /// فتح المشاريع
  void openProjects() {
    state = const OverlayState(type: OverlayType.projects);
  }

  /// فتح صفحة مخصصة
  void openCustom(String route, {String? title}) {
    state = OverlayState(type: OverlayType.custom, route: route, title: title);
  }

  /// إغلاق الـ Overlay
  void close() {
    state = const OverlayState(type: OverlayType.none);
  }
}

/// Provider
final overlayProvider = NotifierProvider<OverlayNotifier, OverlayState>(
  OverlayNotifier.new,
);
