import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// صفحة اختصاراتي - صفحة كاملة مع زر إغلاق
class ShortcutsPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const ShortcutsPanel({super.key, this.onClose});

  void _close(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppTheme.background(isDark),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildShortcutCard(
                    context,
                    icon: Icons.add_box,
                    title: 'منتج جديد',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      _close(context);
                      context.push('/dashboard/products/add');
                    },
                    isDark: isDark,
                  ),
                  _buildShortcutCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'طلب جديد',
                    color: AppTheme.successColor,
                    onTap: () {
                      _close(context);
                      context.push('/dashboard/orders');
                    },
                    isDark: isDark,
                  ),
                  _buildShortcutCard(
                    context,
                    icon: Icons.person_add,
                    title: 'عميل جديد',
                    color: AppTheme.secondaryColor,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildShortcutCard(
                    context,
                    icon: Icons.analytics,
                    title: 'التقارير',
                    color: AppTheme.accentColor,
                    onTap: () {
                      _close(context);
                      context.push('/dashboard/reports');
                    },
                    isDark: isDark,
                  ),
                  _buildShortcutCard(
                    context,
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    color: AppTheme.slate600,
                    onTap: () {
                      _close(context);
                      context.push('/settings');
                    },
                    isDark: isDark,
                  ),
                  _buildShortcutCard(
                    context,
                    icon: Icons.campaign,
                    title: 'حملة تسويقية',
                    color: AppTheme.infoColor,
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border(isDark).withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // العنوان
          Expanded(
            child: Text(
              'اختصاراتي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(isDark),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          // زر الإغلاق
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _close(context);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.border(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close,
                size: 22,
                color: AppTheme.textSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.border(isDark).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
