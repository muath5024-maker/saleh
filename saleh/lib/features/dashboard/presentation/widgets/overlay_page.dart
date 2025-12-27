import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// صفحة Overlay - تغطي الشاشة مع زر إغلاق
/// تستخدم لعرض الصفحات فوق المحتوى مع إبقاء BottomNav ظاهراً
class OverlayPage extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;
  final List<Widget>? actions;

  const OverlayPage({
    super.key,
    required this.title,
    required this.child,
    required this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppTheme.background(isDark),
      child: SafeArea(
        child: Column(
          children: [
            // Header مع زر إغلاق
            _buildHeader(context, isDark),
            // المحتوى
            Expanded(child: child),
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
          // العنوان على اليمين
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(isDark),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          // الإجراءات
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
          // زر الإغلاق على اليسار
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onClose();
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
}
