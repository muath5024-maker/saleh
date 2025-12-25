import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/skeleton_loading.dart';
import '../../../merchant/data/merchant_store_provider.dart';
import '../../../merchant/domain/models/store.dart';

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                    🎨 Design System - Brand Primary #215950               ║
// ║                                                                           ║
// ║   تصميم موحد مع Brand Primary                                             ║
// ║   تاريخ التحديث: 24 ديسمبر 2025                                          ║
// ║   ملاحظة: الهيدر العلوي موجود في DashboardShell                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

/// الصفحة الرئيسية للتاجر - تصميم زجاجي
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await ref
        .read(merchantStoreControllerProvider.notifier)
        .loadMerchantStore();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(merchantStoreControllerProvider);
    final store = storeState.store;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.background(isDark),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryColor,
        child: _isLoading
            ? const SkeletonHomeDashboard()
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),
                        // رابط المتجر
                        _buildStoreLinkCard(store?.name ?? 'mbuy'),
                        const SizedBox(height: 16),
                        // شبكة الإحصائيات 2×2
                        _buildStatsGrid(context, store),
                        const SizedBox(height: 16),
                        // شبكة الأيقونات المربعة
                        _buildFeaturesGrid(context),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// بطاقة رابط المتجر
  Widget _buildStoreLinkCard(String storeName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeSlug = storeName.replaceAll(' ', '-').toLowerCase();
    final storeUrl = 'tabayu.com/$storeSlug';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surface(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow(isDark),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أزرار المشاركة والنسخ
          Row(
            children: [
              // زر المشاركة
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  SharePlus.instance.share(
                    ShareParams(text: 'تسوق من متجري: https://$storeUrl'),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // زر النسخ
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: storeUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الرابط'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.copy,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // الرابط
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رابط المتجر',
                  style: TextStyle(
                    fontSize: AppDimensions.fontCaption,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHintColorDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  storeUrl,
                  style: TextStyle(
                    fontSize: AppDimensions.fontBody2,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'monospace',
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شبكة الإحصائيات 2×2 - Minimal Design
  Widget _buildStatsGrid(BuildContext context, Store? store) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet_outlined,
                value: '0.00',
                suffix: 'ر.س',
                label: 'الرصيد',
                onTap: () => context.push('/dashboard/wallet'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.stars_outlined,
                value: '0',
                suffix: 'نقطة',
                label: 'النقاط',
                onTap: () => context.push('/dashboard/points'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                value: '${store?.followersCount ?? 0}',
                suffix: '',
                label: 'العملاء',
                onTap: () => context.push('/dashboard/customers'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_bag_outlined,
                value: '0',
                suffix: '',
                label: 'المبيعات',
                onTap: () => context.push('/dashboard/sales'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// كارت إحصائية - Minimal مع أيقونة مربعة
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String suffix,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.border(isDark).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // أيقونة مربعة
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            // القيمة والنص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(isDark),
                        ),
                      ),
                      if (suffix.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          suffix,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textHint(isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// شبكة الميزات - أيقونات مربعة Minimal
  Widget _buildFeaturesGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.info_outline,
                label: 'من نحن',
                onTap: () => context.push('/dashboard/about'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.receipt_long_outlined,
                label: 'السجلات',
                onTap: () => context.push('/dashboard/reports'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.campaign_outlined,
                label: 'التسويق',
                onTap: () => context.push('/dashboard/marketing'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.store_outlined,
                label: 'التطبيقات',
                onTap: () => context.push('/dashboard/store'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.trending_up_outlined,
                label: 'ضاعف ظهورك',
                onTap: () => context.push('/dashboard/boost-sales'),
                isDark: isDark,
                showBadge: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.card_giftcard_outlined,
                label: 'حزم التوفير',
                onTap: () => context.push('/dashboard/packages'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// كارت ميزة - أيقونة مربعة Minimal
  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.border(isDark).withValues(alpha: 0.3),
          ),
        ),
        child: Stack(
          children: [
            // Badge
            if (showBadge)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // المحتوى
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة مربعة
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(isDark),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
