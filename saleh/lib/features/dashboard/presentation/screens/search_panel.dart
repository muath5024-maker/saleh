import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// صفحة البحث - صفحة كاملة مع زر إغلاق
class SearchPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const SearchPanel({super.key, this.onClose});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // فتح لوحة المفاتيح تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
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
            // Header مع حقل البحث وزر إغلاق
            _buildHeader(isDark),
            // النتائج
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildSearchResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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
          // حقل البحث
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.background(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.border(isDark).withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتجات، طلبات، عملاء...',
                  hintStyle: TextStyle(
                    color: AppTheme.textHint(isDark),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textHint(isDark),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textHint(isDark),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // زر الإغلاق
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _close();
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: AppTheme.textHint(isDark).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث عن أي شيء',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'منتجات، طلبات، عملاء، إحصائيات...',
            style: TextStyle(fontSize: 14, color: AppTheme.textHint(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('نتائج البحث', isDark),
        const SizedBox(height: 16),
        _buildResultItem(
          icon: Icons.inventory_2,
          title: 'منتج: ${_searchController.text}',
          subtitle: 'المنتجات',
          onTap: () {},
          isDark: isDark,
        ),
        _buildResultItem(
          icon: Icons.receipt_long,
          title: 'طلب: ${_searchController.text}',
          subtitle: 'الطلبات',
          onTap: () {},
          isDark: isDark,
        ),
        _buildResultItem(
          icon: Icons.person,
          title: 'عميل: ${_searchController.text}',
          subtitle: 'العملاء',
          onTap: () {},
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary(isDark),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.border(isDark).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textHint(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 24, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
