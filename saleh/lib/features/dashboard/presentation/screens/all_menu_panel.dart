import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// قائمة "الكل" - صفحة كاملة مع تبويبات على اليمين وخيارات على اليسار
class AllMenuPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const AllMenuPanel({super.key, this.onClose});

  @override
  ConsumerState<AllMenuPanel> createState() => _AllMenuPanelState();
}

class _AllMenuPanelState extends ConsumerState<AllMenuPanel> {
  String _selectedTab = 'الطلبات';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header: عنوان "الكل" على اليمين + زر X على اليسار
            _buildHeader(),
            // المحتوى: عمودين
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العمود الأيمن: العناصر الرئيسية مع أيقونات
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.48,
                    child: _buildMainItemsColumn(),
                  ),
                  // خط فاصل عمودي
                  Container(
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                  // العمود الأيسر: العناصر الفرعية
                  Expanded(child: _buildSubItemsColumn()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header مع عنوان "الكل" وزر الإغلاق
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان "الكل" على اليمين
          const Text(
            'الكل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          // زر الإغلاق على اليسار
          GestureDetector(
            onTap: () {
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close,
              size: 24,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// العمود الأيمن: العناصر الرئيسية مع أيقونات
  Widget _buildMainItemsColumn() {
    final mainItems = _getMainItems();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: mainItems.length,
      itemBuilder: (context, index) {
        final item = mainItems[index];
        final isSelected = _selectedTab == item.title;

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedTab = item.title;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // الأيقونة
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 12),
                // النص
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// العمود الأيسر: العناصر الفرعية للتبويب المحدد
  Widget _buildSubItemsColumn() {
    final section = _getAllSections().firstWhere(
      (s) => s.title == _selectedTab,
      orElse: () => _getAllSections().first,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, right: 8),
      itemCount: section.items.length,
      itemBuilder: (context, index) {
        final item = section.items[index];

        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onClose?.call();
            context.push(item.route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Text(
              item.title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  /// العناصر الرئيسية مع أيقوناتها (العمود الأيمن)
  List<_MainItem> _getMainItems() {
    return [
      _MainItem('الطلبات', Icons.receipt_long_outlined),
      _MainItem('المنتجات', Icons.inventory_2_outlined),
      _MainItem('التسويق', Icons.campaign_outlined),
      _MainItem('المتجر الإلكتروني', Icons.store_outlined),
      _MainItem('العملاء', Icons.people_outline),
      _MainItem('التقارير', Icons.insert_chart_outlined),
      _MainItem('مركز الدعم', Icons.support_agent_outlined),
      _MainItem('الشحن والتوصيل', Icons.local_shipping_outlined),
      _MainItem('الدفع', Icons.payment_outlined),
      _MainItem('الأدوات المساعدة', Icons.apps_outlined),
      _MainItem('السجلات', Icons.history_outlined),
    ];
  }

  /// الحصول على جميع الأقسام مع بياناتها
  List<_TabSection> _getAllSections() {
    return [
      _TabSection(
        title: 'الطلبات',
        icon: Icons.receipt_long,
        items: [
          _MenuItem('إدارة الطلبات', '/dashboard/orders'),
          _MenuItem('إعدادات الطلبات', '/dashboard/feature/إعدادات الطلبات'),
          _MenuItem('حالات الطلب', '/dashboard/feature/حالات الطلبات'),
          _MenuItem(
            'تحديث حالة مجموعة طلبات',
            '/dashboard/feature/تحديث حالة مجموعة طلبات',
          ),
          _MenuItem('الإسناد التلقائي', '/dashboard/feature/الإسناد التلقائي'),
          _MenuItem('تخصيص الفواتير', '/dashboard/feature/تخصيص الفاتورة'),
          _MenuItem('الحجوزات', '/dashboard/feature/الحجوزات'),
          _MenuItem('الحقول المخصصة', '/dashboard/feature/الحقول المخصصة'),
          _MenuItem('خيارات الطلب', '/dashboard/feature/خيارات الطلب'),
          _MenuItem('قوالب التصدير', '/dashboard/feature/قوالب التصدير'),
        ],
      ),
      _TabSection(
        title: 'المنتجات',
        icon: Icons.inventory_2,
        items: [
          _MenuItem('إدارة المنتجات', '/dashboard/products'),
          _MenuItem('إعدادات المنتجات', '/dashboard/feature/إعدادات المنتجات'),
          _MenuItem('التصنيفات', '/dashboard/feature/التصنيفات'),
          _MenuItem('تحرير المنتجات', '/dashboard/products/add'),
          _MenuItem('المخزون', '/dashboard/inventory'),
          _MenuItem(
            'الاستيراد والتصدير',
            '/dashboard/feature/الاستيراد والتصدير',
          ),
        ],
      ),
      _TabSection(
        title: 'التسويق',
        icon: Icons.campaign,
        items: [
          _MenuItem('الكوبونات', '/dashboard/coupons'),
          _MenuItem('السلات المتروكة', '/dashboard/abandoned-cart'),
          _MenuItem('أدوات التتبع', '/dashboard/feature/أدوات التتبع'),
          _MenuItem('العروض الخاصة', '/dashboard/flash-sales'),
          _MenuItem('الحملات التسويقية', '/dashboard/marketing'),
          _MenuItem('كاش باك', '/dashboard/feature/كاش باك'),
          _MenuItem('الولاء', '/dashboard/loyalty-program'),
          _MenuItem('دعم الظهور', '/dashboard/boost-sales'),
          _MenuItem(
            'تحسين محركات البحث',
            '/dashboard/feature/تحسين محركات البحث',
          ),
        ],
      ),
      _TabSection(
        title: 'المتجر الإلكتروني',
        icon: Icons.store,
        items: [
          _MenuItem('معلومات المتجر', '/dashboard/store-management'),
          _MenuItem('تصميم المتجر', '/dashboard/webstore'),
          _MenuItem('الثيم', '/dashboard/feature/الثيم'),
          _MenuItem('دومين المتجر', '/dashboard/feature/دومين المتجر'),
          _MenuItem(
            'الصفحات التعريفية',
            '/dashboard/feature/الصفحات التعريفية',
          ),
          _MenuItem('SEO', '/dashboard/feature/SEO'),
          _MenuItem('المشاريع', '/dashboard/projects'),
          _MenuItem('الإشعارات', '/dashboard/inbox'),
          _MenuItem('إعدادات الإشعارات', '/notification-settings'),
          _MenuItem('إعدادات المظهر', '/appearance-settings'),
          _MenuItem('إعدادات الحساب', '/settings'),
        ],
      ),
      _TabSection(
        title: 'العملاء',
        icon: Icons.people,
        items: [
          _MenuItem('إدارة العملاء', '/dashboard/customers'),
          _MenuItem('إعدادات العملاء', '/dashboard/feature/إعدادات العملاء'),
          _MenuItem('إدارة المجموعات', '/dashboard/customer-segments'),
          _MenuItem('الموظفين', '/dashboard/feature/الموظفين'),
        ],
      ),
      _TabSection(
        title: 'التقارير',
        icon: Icons.insert_chart,
        items: [
          _MenuItem('أداء المتجر', '/dashboard/sales'),
          _MenuItem('التحليلات الذكية', '/dashboard/smart-analytics'),
          _MenuItem('التقارير', '/dashboard/reports'),
        ],
      ),
      _TabSection(
        title: 'مركز الدعم',
        icon: Icons.support_agent,
        items: [
          _MenuItem('الدعم الفني', '/support'),
          _MenuItem('سياسة الخصوصية', '/privacy-policy'),
          _MenuItem('الشروط والأحكام', '/terms'),
          _MenuItem('عن التطبيق', '/dashboard/about'),
        ],
      ),
      _TabSection(
        title: 'الشحن والتوصيل',
        icon: Icons.local_shipping,
        items: [
          _MenuItem('الشحن والتوصيل', '/dashboard/shipping'),
          _MenuItem('إعدادات الشحن', '/dashboard/feature/إعدادات الشحن'),
        ],
      ),
      _TabSection(
        title: 'الدفع',
        icon: Icons.payment,
        items: [
          _MenuItem('طرق الدفع', '/dashboard/payment-methods'),
          _MenuItem('المحفظة والفواتير', '/dashboard/wallet'),
          _MenuItem('قيود الدفع', '/dashboard/feature/قيود الدفع'),
          _MenuItem(
            'ضريبة القيمة المضافة',
            '/dashboard/feature/ضريبة القيمة المضافة',
          ),
          _MenuItem('العمليات', '/dashboard/feature/العمليات'),
        ],
      ),
      _TabSection(
        title: 'الأدوات المساعدة',
        icon: Icons.apps,
        items: [
          _MenuItem('الأدوات الذكية', '/dashboard/tools'),
          _MenuItem('المساعد الذكي', '/dashboard/ai-assistant'),
          _MenuItem('مولد المحتوى', '/dashboard/content-generator'),
          _MenuItem('التسعير الذكي', '/dashboard/smart-pricing'),
          _MenuItem('الخرائط الحرارية', '/dashboard/heatmap'),
          _MenuItem('التقارير التلقائية', '/dashboard/auto-reports'),
          _MenuItem('استديو المحتوى', '/dashboard/studio'),
          _MenuItem('مولد السكريبت', '/dashboard/studio/script-generator'),
          _MenuItem('محرر المشاهد', '/dashboard/studio/editor'),
          _MenuItem('محرر الكانفاس', '/dashboard/studio/canvas'),
          _MenuItem('التصدير', '/dashboard/studio/export'),
        ],
      ),
      _TabSection(
        title: 'السجلات',
        icon: Icons.history,
        items: [_MenuItem('السجلات', '/dashboard/audit-logs')],
      ),
    ];
  }
}

/// عنصر رئيسي في العمود الأيمن
class _MainItem {
  final String title;
  final IconData icon;

  _MainItem(this.title, this.icon);
}

/// قسم في التبويبات مع عنوان وأيقونة وعناصر
class _TabSection {
  final String title;
  final IconData icon;
  final List<_MenuItem> items;

  _TabSection({required this.title, required this.icon, required this.items});
}

/// عنصر في القائمة
class _MenuItem {
  final String title;
  final String route;

  _MenuItem(this.title, this.route);
}
