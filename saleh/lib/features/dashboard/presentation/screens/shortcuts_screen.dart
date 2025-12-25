import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../ai_studio/data/mbuy_studio_service.dart';
import '../../../auth/data/auth_controller.dart';

/// ØµÙØ­Ø© اختصاراتي الÙ…ÙØ¹Ø§Ø¯ تصميمها
/// - ØµÙØ­Ø© ÙØ§Ø±ØºØ© مع نص توضيحي ÙÙŠ البداية
/// - Ø¥Ø¶Ø§ÙØ© اختصارات كمربعات أيقونات Ø¨Ù†ÙØ³ مقاس الØµÙØ­Ø© الرئيسية
/// - Ø­ÙØ¸ التعديلات تلقائياً
/// - بدون خلفÙŠØ© بيضاء خلف الأيقونات
/// - إعادة ترتيب الأيقونات بالسحب ÙˆالØ¥ÙلاØª
class ShortcutsScreen extends ConsumerStatefulWidget {
  const ShortcutsScreen({super.key});

  @override
  ConsumerState<ShortcutsScreen> createState() => _ShortcutsScreenState();
}

class _ShortcutsScreenState extends ConsumerState<ShortcutsScreen>
    with SingleTickerProviderStateMixin {
  List<ShortcutItemData> _savedShortcuts = [];
  bool _isLoading = true;
  bool _isEditing = false;
  String _searchQuery = '';

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadShortcuts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKeys = prefs.getStringList('user_shortcuts') ?? [];

      _savedShortcuts = savedKeys
          .map(
            (key) => _availableShortcuts.firstWhere(
              (s) => s.key == key,
              orElse: () => _availableShortcuts.first,
            ),
          )
          .where((s) => savedKeys.contains(s.key))
          .toList();
    } catch (e) {
      debugPrint('Error loading shortcuts: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveShortcuts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'user_shortcuts',
        _savedShortcuts.map((s) => s.key).toList(),
      );
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم Ø­ÙØ¸ الاختصارات'),
            backgroundColor: AppTheme.accentColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving shortcuts: $e');
    }
  }

  void _addShortcut(ShortcutItemData shortcut) {
    if (!_savedShortcuts.any((s) => s.key == shortcut.key)) {
      setState(() {
        _savedShortcuts.add(shortcut);
      });
      _saveShortcuts();
    }
  }

  void _removeShortcut(ShortcutItemData shortcut) {
    setState(() {
      _savedShortcuts.removeWhere((s) => s.key == shortcut.key);
    });
    _saveShortcuts();
  }

  void _navigateToShortcut(ShortcutItemData shortcut) {
    if (shortcut.route.isNotEmpty) {
      context.push(shortcut.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Ù…Ø®ØµØµ
            _buildHeader(context),
            // TabBar
            _buildTabBar(),
            // الÙ…Ø­ØªÙˆÙ‰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ØªØ¨ÙˆÙŠØ¨ اختصاراتي
                  _buildShortcutsTab(),
                  // ØªØ¨ÙˆÙŠØ¨ أدوات AI
                  _buildAiToolsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0 && _isEditing
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                onPressed: _showAddShortcutSheet,
                backgroundColor: AppTheme.primaryColor,
                elevation: 4,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Ø¥Ø¶Ø§ÙØ© Ø§Ø®ØªØµØ§Ø±',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                extendedPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacing8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusS,
              ),
              child: SvgPicture.asset(
                AppIcons.arrowBack,
                width: AppDimensions.iconS,
                height: AppDimensions.iconS,
                colorFilter: const ColorFilter.mode(
                  AppTheme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'اختصاراتي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontHeadline,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const Spacer(),
          // Ø²Ø± التعديل
          GestureDetector(
            onTap: () {
              if (_isEditing) {
                _saveShortcuts();
              }
              setState(() => _isEditing = !_isEditing);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
              decoration: BoxDecoration(
                color: _isEditing
                    ? AppTheme.accentColor
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusS,
              ),
              child: Text(
                _isEditing ? 'تم' : 'تعديل',
                style: TextStyle(
                  color: _isEditing ? Colors.white : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppDimensions.fontBody,
        ),
        tabs: const [
          Tab(text: 'اختصاراتي'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: AppDimensions.iconS),
                SizedBox(width: AppDimensions.spacing4),
                Text('أدوات AI'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedShortcuts.isEmpty && !_isEditing
              ? _buildEmptyState()
              : _buildShortcutsGrid(),
        ),
      ],
    );
  }

  Widget _buildAiToolsTab() {
    return _AiToolsTestTab(ref: ref);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.borderRadiusM,
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          decoration: InputDecoration(
            hintText: 'الØ¨Ø­Ø« ÙÙŠ الاختصارات...',
            hintStyle: TextStyle(color: AppTheme.textHintColor),
            prefixIcon: Icon(Icons.search, color: AppTheme.textHintColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: 60,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لا ØªÙˆØ¬Ø¯ اختصارات',
              style: TextStyle(
                fontSize: AppDimensions.fontDisplay2,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ø£Ø¶Ù اختصاراتÙƒ الÙ…ÙØ¶Ù„Ø© Ù„Ù„ÙˆØµÙˆÙ„ الØ³Ø±ÙŠØ¹\nإلى Ø£Ù‡Ù… الØµÙØ­Ø§Øª ÙˆالØ£Ø¯ÙˆØ§Øª',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontTitle,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isEditing = true);
                _showAddShortcutSheet();
              },
              icon: const Icon(Icons.add),
              label: const Text('Ø¥Ø¶Ø§ÙØ© Ø§Ø®ØªØµØ§Ø±'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsGrid() {
    // ÙÙ„ØªØ±Ø© الاختصارات Ø­Ø³Ø¨ الØ¨Ø­Ø«
    final filteredShortcuts = _searchQuery.isEmpty
        ? _savedShortcuts
        : _savedShortcuts
              .where(
                (s) =>
                    s.title.contains(_searchQuery) ||
                    s.key.contains(_searchQuery),
              )
              .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ø§Ø³Ø­Ø¨ الØ§Ø®ØªØµØ§Ø± Ù„ØªØºÙŠÙŠØ± Ù…ÙƒØ§Ù†Ù‡ØŒ Ø£Ùˆ Ø§Ø¶ØºØ· Ø¹Ù„ÙŠÙ‡ Ù„حذفÙ‡',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppDimensions.fontBody2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isEditing
                ? ReorderableGridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: filteredShortcuts.length,
                    itemBuilder: (context, index) {
                      final shortcut = filteredShortcuts[index];
                      return _buildShortcutItem(
                        shortcut,
                        key: ValueKey(shortcut.key),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _savedShortcuts.removeAt(oldIndex);
                        _savedShortcuts.insert(newIndex, item);
                      });
                      _saveShortcuts();
                    },
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: filteredShortcuts.length,
                    itemBuilder: (context, index) {
                      final shortcut = filteredShortcuts[index];
                      return _buildShortcutItem(shortcut);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Ø¨Ù†Ø§Ø¡ Ø¹نصØ± الØ§Ø®ØªØµØ§Ø± - Ø¨Ù†ÙØ³ ØªØµÙ…ÙŠÙ… الØµÙØ­Ø© الرئيسية بدون خلفÙŠØ© بيضاء
  Widget _buildShortcutItem(ShortcutItemData shortcut, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: _isEditing
          ? () => _showDeleteDialog(shortcut)
          : () => _navigateToShortcut(shortcut),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ø£ÙŠÙ‚ÙˆÙ†Ø© Ø¨Ù†ÙØ³ Ø­Ø¬Ù… الØµÙØ­Ø© الرئيسية
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          shortcut.color.withValues(alpha: 0.1),
                          shortcut.color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        shortcut.icon,
                        size: 36, // Ù†ÙØ³ Ø­Ø¬Ù… أيقونات الØµÙØ­Ø© الرئيسية
                        color: AppTheme.darkSlate,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Text(
                    shortcut.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimensions.fontLabel,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ShortcutItemData shortcut) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الØ§Ø®ØªØµØ§Ø±'),
        content: Text('هل ØªØ±ÙŠØ¯ حذف "${shortcut.title}" من اختصاراتÙƒØŸ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeShortcut(shortcut);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddShortcutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ø§Ø®ØªØ± Ø§Ø®ØªØµØ§Ø±Ø§Ù‹',
                    style: TextStyle(
                      fontSize: AppDimensions.fontDisplay3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _shortcutCategories.length,
                    itemBuilder: (context, index) {
                      final category = _shortcutCategories[index];
                      return _buildCategorySection(category, setSheetState);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    ShortcutCategory category,
    StateSetter setSheetState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category.title,
            style: TextStyle(
              fontSize: AppDimensions.fontTitle,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: category.shortcuts.map((shortcut) {
            final isAdded = _savedShortcuts.any((s) => s.key == shortcut.key);
            return GestureDetector(
              onTap: isAdded
                  ? null
                  : () {
                      _addShortcut(shortcut);
                      setSheetState(() {}); // ØªØ­Ø¯ÙŠØ« Ø­الØ© الÙ€ sheet
                      setState(() {}); // ØªØ­Ø¯ÙŠØ« Ø­الØ© الØ´Ø§Ø´Ø© الرئيسية
                      // لا Ù†ØºÙ„Ù‚ الÙ€ sheet - Ù†Ø³Ù…Ø­ Ø¨Ø¥Ø¶Ø§ÙØ© الÙ…Ø²ÙŠØ¯
                    },
              child: Container(
                width: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAdded
                      ? Colors.grey[200]
                      : shortcut.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isAdded
                      ? Border.all(color: AppTheme.accentColor, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      shortcut.icon,
                      size: 28,
                      color: isAdded ? AppTheme.accentColor : shortcut.color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcut.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppDimensions.fontCaption - 1,
                        fontWeight: FontWeight.w500,
                        color: isAdded
                            ? AppTheme.accentColor
                            : AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (isAdded)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppTheme.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

// =============================================================================
// Ø¨ÙŠØ§Ù†Ø§Øª الاختصارات
// =============================================================================

class ShortcutItemData {
  final String key;
  final String title;
  final String route;
  final IconData icon;
  final Color color;

  const ShortcutItemData({
    required this.key,
    required this.title,
    required this.route,
    required this.icon,
    required this.color,
  });
}

class ShortcutCategory {
  final String title;
  final List<ShortcutItemData> shortcuts;

  const ShortcutCategory({required this.title, required this.shortcuts});
}

// Ø¬Ù…ÙŠØ¹ الاختصارات الÙ…ØªØ§Ø­Ø©
// Ù…لاØ­Ø¸Ø©: تم Ø¥Ø²الØ© ØµÙØ­Ø§Øª الØ¨Ø§Ø± الØ³ÙÙ„ÙŠ (الرئيسيةØŒ الØ·Ù„Ø¨Ø§ØªØŒ الÙ…Ø­Ø§Ø¯Ø«Ø§ØªØŒ Ø¯Ø±ÙˆØ¨ Ø´ÙŠØ¨)
final List<ShortcutItemData> _availableShortcuts = [
  const ShortcutItemData(
    key: 'products',
    title: 'المنØªØ¬Ø§Øª',
    route: '/dashboard/products',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFF10B981),
  ),
  const ShortcutItemData(
    key: 'add_product',
    title: 'Ø¥Ø¶Ø§ÙØ© منØªØ¬',
    route: '/dashboard/products/add',
    icon: Icons.add_box_outlined,
    color: Color(0xFF8B5CF6),
  ),
  const ShortcutItemData(
    key: 'inventory',
    title: 'الÙ…Ø®Ø²ÙˆÙ†',
    route: '/dashboard/inventory',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFFEC4899),
  ),
  const ShortcutItemData(
    key: 'customers',
    title: 'الØ¹Ù…لاØ¡',
    route: '/dashboard/customers',
    icon: Icons.people_outline,
    color: Color(0xFF06B6D4),
  ),
  const ShortcutItemData(
    key: 'wallet',
    title: 'الÙ…Ø­ÙØ¸Ø©',
    route: '/dashboard/wallet',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF14B8A6),
  ),
  const ShortcutItemData(
    key: 'marketing',
    title: 'الØªØ³ÙˆÙŠÙ‚',
    route: '/dashboard/marketing',
    icon: Icons.campaign_outlined,
    color: Color(0xFFEF4444),
  ),
  const ShortcutItemData(
    key: 'coupons',
    title: 'الÙƒÙˆØ¨ÙˆÙ†Ø§Øª',
    route: '/dashboard/coupons',
    icon: Icons.local_offer_outlined,
    color: Color(0xFFF97316),
  ),
  // الÙ…ØªØ¬Ø± (تمØª Ø¥Ø²الØ© الÙ…Ø­Ø§Ø¯Ø«Ø§Øª - Ù…ÙˆØ¬ÙˆØ¯Ø© ÙÙŠ الØ¨Ø§Ø± الØ³ÙÙ„ÙŠ)
  const ShortcutItemData(
    key: 'store_settings',
    title: 'Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª الÙ…ØªØ¬Ø±',
    route: '/dashboard/store-management',
    icon: Icons.store_outlined,
    color: Color(0xFF6366F1),
  ),
  const ShortcutItemData(
    key: 'webstore',
    title: 'الÙ…ØªØ¬Ø± الØ¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
    route: '/dashboard/webstore',
    icon: Icons.language_outlined,
    color: Color(0xFF0EA5E9),
  ),
  const ShortcutItemData(
    key: 'whatsapp',
    title: 'ÙˆØ§ØªØ³Ø§Ø¨',
    route: '/dashboard/whatsapp-integration',
    icon: Icons.chat_outlined,
    color: Color(0xFF22C55E),
  ),
  const ShortcutItemData(
    key: 'qrcode',
    title: 'Ø±Ù…Ø² QR',
    route: '/dashboard/qrcode-generator',
    icon: Icons.qr_code_outlined,
    color: AppTheme.slate500,
  ),
  // الØ´Ø­Ù† ÙˆالØ¯ÙØ¹
  const ShortcutItemData(
    key: 'shipping',
    title: 'الØ´Ø­Ù†',
    route: '/dashboard/shipping-integration',
    icon: Icons.local_shipping_outlined,
    color: Color(0xFF8B5CF6),
  ),
  const ShortcutItemData(
    key: 'delivery',
    title: 'الØªÙˆØµÙŠÙ„',
    route: '/dashboard/delivery-options',
    icon: Icons.delivery_dining_outlined,
    color: Color(0xFFD946EF),
  ),
  const ShortcutItemData(
    key: 'payments',
    title: 'الÙ…Ø¯ÙÙˆØ¹Ø§Øª',
    route: '/dashboard/payment-methods',
    icon: Icons.payment_outlined,
    color: Color(0xFF059669),
  ),
  const ShortcutItemData(
    key: 'cod',
    title: 'الØ¯ÙØ¹ Ø¹Ù†Ø¯ الØ§Ø³ØªلاÙ…',
    route: '/dashboard/cod-settings',
    icon: Icons.attach_money_outlined,
    color: Color(0xFFCA8A04),
  ),
  // الØ°ÙƒØ§Ø¡ الØ§ØµØ·Ù†Ø§Ø¹ÙŠ
  const ShortcutItemData(
    key: 'ai_studio',
    title: 'Ø§Ø³ØªØ¯ÙŠÙˆ AI',
    route: '/dashboard/studio',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFA855F7),
  ),
  const ShortcutItemData(
    key: 'ai_tools',
    title: 'أدوات AI',
    route: '/dashboard/tools',
    icon: Icons.psychology_outlined,
    color: Color(0xFF7C3AED),
  ),
  // المنØªØ¬Ø§Øª الØ±Ù‚Ù…ÙŠØ©
  const ShortcutItemData(
    key: 'digital_products',
    title: 'المنØªØ¬Ø§Øª الØ±Ù‚Ù…ÙŠØ©',
    route: '/dashboard/digital-products',
    icon: Icons.cloud_download_outlined,
    color: Color(0xFF0891B2),
  ),
  // الØªÙ‚Ø§Ø±ÙŠØ±
  const ShortcutItemData(
    key: 'reports',
    title: 'الØªÙ‚Ø§Ø±ÙŠØ±',
    route: '/dashboard/audit-logs',
    icon: Icons.analytics_outlined,
    color: Color(0xFF4F46E5),
  ),
  const ShortcutItemData(
    key: 'sales',
    title: 'الÙ…Ø¨ÙŠØ¹Ø§Øª',
    route: '/dashboard/sales',
    icon: Icons.trending_up_outlined,
    color: Color(0xFF16A34A),
  ),
  // === الاختصارات الÙ…Ø±Ø¬Ø¹Ø© من الØªØ³ÙˆÙŠÙ‚ ===
  const ShortcutItemData(
    key: 'flash_sales',
    title: 'الØ¹Ø±ÙˆØ¶ الØ®Ø§Ø·ÙØ©',
    route: '/dashboard/flash-sales',
    icon: Icons.flash_on_outlined,
    color: Color(0xFFEF4444),
  ),
  const ShortcutItemData(
    key: 'abandoned_cart',
    title: 'الØ³لاØª الÙ…ØªØ±ÙˆÙƒØ©',
    route: '/dashboard/abandoned-cart',
    icon: Icons.shopping_cart_outlined,
    color: Color(0xFFF59E0B),
  ),
  const ShortcutItemData(
    key: 'referral',
    title: 'Ø¨Ø±Ù†Ø§Ù…Ø¬ الØ¥Ø­الØ©',
    route: '/dashboard/referral',
    icon: Icons.share_outlined,
    color: Color(0xFF10B981),
  ),
  const ShortcutItemData(
    key: 'loyalty_program',
    title: 'Ø¨Ø±Ù†Ø§Ù…Ø¬ الÙˆلاØ¡',
    route: '/dashboard/loyalty-program',
    icon: Icons.loyalty_outlined,
    color: Color(0xFF8B5CF6),
  ),
  const ShortcutItemData(
    key: 'smart_analytics',
    title: 'ØªØ­Ù„ÙŠلاØª Ø°ÙƒÙŠØ©',
    route: '/dashboard/smart-analytics',
    icon: Icons.insights_outlined,
    color: Color(0xFF06B6D4),
  ),
  const ShortcutItemData(
    key: 'auto_reports',
    title: 'ØªÙ‚Ø§Ø±ÙŠØ± ØªÙ„Ù‚Ø§Ø¦ÙŠØ©',
    route: '/dashboard/auto-reports',
    icon: Icons.summarize_outlined,
    color: Color(0xFF14B8A6),
  ),
  const ShortcutItemData(
    key: 'heatmap',
    title: 'Ø®Ø±ÙŠØ·Ø© الØ­Ø±Ø§Ø±Ø©',
    route: '/dashboard/heatmap',
    icon: Icons.grid_view_outlined,
    color: Color(0xFFEC4899),
  ),
  const ShortcutItemData(
    key: 'ai_assistant',
    title: 'Ù…Ø³Ø§Ø¹Ø¯ AI',
    route: '/dashboard/ai-assistant',
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF7C3AED),
  ),
  const ShortcutItemData(
    key: 'content_generator',
    title: 'Ù…ÙˆÙ„Ø¯ الÙ…Ø­ØªÙˆÙ‰',
    route: '/dashboard/content-generator',
    icon: Icons.auto_fix_high_outlined,
    color: Color(0xFFA855F7),
  ),
  const ShortcutItemData(
    key: 'smart_pricing',
    title: 'ØªØ³Ø¹ÙŠØ± Ø°ÙƒÙŠ',
    route: '/dashboard/smart-pricing',
    icon: Icons.price_change_outlined,
    color: Color(0xFF059669),
  ),
  const ShortcutItemData(
    key: 'customer_segments',
    title: 'Ø´Ø±Ø§Ø¦Ø­ الØ¹Ù…لاØ¡',
    route: '/dashboard/customer-segments',
    icon: Icons.group_work_outlined,
    color: Color(0xFF3B82F6),
  ),
  const ShortcutItemData(
    key: 'custom_messages',
    title: 'Ø±Ø³Ø§Ø¦Ù„ Ù…Ø®ØµØµØ©',
    route: '/dashboard/custom-messages',
    icon: Icons.message_outlined,
    color: Color(0xFF22C55E),
  ),
  const ShortcutItemData(
    key: 'product_variants',
    title: 'Ù…ØªغيرØ§Øª المنØªØ¬',
    route: '/dashboard/product-variants',
    icon: Icons.style_outlined,
    color: Color(0xFF6366F1),
  ),
  const ShortcutItemData(
    key: 'product_bundles',
    title: 'Ø­Ø²Ù… المنØªØ¬Ø§Øª',
    route: '/dashboard/product-bundles',
    icon: Icons.inventory_outlined,
    color: Color(0xFFD946EF),
  ),
];

// ØªØµÙ†ÙŠÙØ§Øª الاختصارات
// Ù…لاØ­Ø¸Ø©: تم Ø¥Ø²الØ© ØµÙØ­Ø§Øª الØ¨Ø§Ø± الØ³ÙÙ„ÙŠ من الØªØµÙ†ÙŠÙØ§Øª
final List<ShortcutCategory> _shortcutCategories = [
  ShortcutCategory(
    title: 'الØ£Ø³Ø§Ø³ÙŠØ©',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'products',
            'add_product',
            'inventory',
            'customers',
          ].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'الÙ…الÙŠØ© ÙˆالØªØ³ÙˆÙŠÙ‚',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'wallet',
            'marketing',
            'coupons',
            'sales',
            'flash_sales',
            'abandoned_cart',
            'referral',
            'loyalty_program',
          ].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'الÙ…ØªØ¬Ø± ÙˆالØªÙˆØ§ØµÙ„',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'store_settings',
            'webstore',
            'whatsapp',
            'qrcode',
          ].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'الØ´Ø­Ù† ÙˆالØ¯ÙØ¹',
    shortcuts: _availableShortcuts
        .where(
          (s) => ['shipping', 'delivery', 'payments', 'cod'].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'الØ°ÙƒØ§Ø¡ الØ§ØµØ·Ù†Ø§Ø¹ÙŠ',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'ai_studio',
            'ai_tools',
            'ai_assistant',
            'content_generator',
            'smart_pricing',
          ].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'الØªØ­Ù„ÙŠلاØª ÙˆالØªÙ‚Ø§Ø±ÙŠØ±',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'smart_analytics',
            'auto_reports',
            'heatmap',
            'reports',
          ].contains(s.key),
        )
        .toList(),
  ),
  ShortcutCategory(
    title: 'Ø¥Ø¯Ø§Ø±Ø© الØ¹Ù…لاØ¡',
    shortcuts: _availableShortcuts
        .where((s) => ['customer_segments', 'custom_messages'].contains(s.key))
        .toList(),
  ),
  ShortcutCategory(
    title: 'المنØªØ¬Ø§Øª الÙ…ØªÙ‚Ø¯Ù…Ø©',
    shortcuts: _availableShortcuts
        .where(
          (s) => [
            'digital_products',
            'product_variants',
            'product_bundles',
          ].contains(s.key),
        )
        .toList(),
  ),
];

// =============================================================================
// ReorderableGridView Widget
// =============================================================================

/// Ø¹نصØ± GridView Ù‚Ø§Ø¨Ù„ Ù„إعادة الترتيب
class ReorderableGridView extends StatefulWidget {
  final SliverGridDelegate gridDelegate;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  const ReorderableGridView.builder({
    super.key,
    required this.gridDelegate,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
  });

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Opacity(
                opacity: 0.8,
                child: widget.itemBuilder(context, index),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: widget.itemBuilder(context, index),
          ),
          onDragStarted: () {
            HapticFeedback.mediumImpact();
          },
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) => details.data != index,
            onAcceptWithDetails: (details) {
              widget.onReorder(details.data, index);
              HapticFeedback.lightImpact();
            },
            builder: (context, candidateData, rejectedData) {
              final isTarget = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: isTarget
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                ),
                child: widget.itemBuilder(context, index),
              );
            },
          ),
        );
      },
    );
  }
}

// =============================================================================
// AI Tools Test Tab - ØªØ¨ÙˆÙŠØ¨ Ø§Ø®ØªØ¨Ø§Ø± Ø£Ø¯ÙˆØ§Øª الØ°ÙƒØ§Ø¡ الØ§ØµØ·Ù†Ø§Ø¹ÙŠ
// =============================================================================

class _AiToolsTestTab extends StatefulWidget {
  final WidgetRef ref;

  const _AiToolsTestTab({required this.ref});

  @override
  State<_AiToolsTestTab> createState() => _AiToolsTestTabState();
}

class _AiToolsTestTabState extends State<_AiToolsTestTab> {
  final TextEditingController _promptController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedTool = 'text'; // الØ£Ø¯Ø§Ø© الÙ…Ø­Ø¯Ø¯Ø© Ø­الÙŠØ§Ù‹
  String? _generatedImageUrl; // Ø±Ø§Ø¨Ø· الØµÙˆØ±Ø© الÙ…ÙˆÙ„Ø¯Ø©
  String? _currentTaskId; // معØ±Ù Ù…Ù‡Ù…Ø© NanoBanana

  // Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª Ø¥Ø¶Ø§ÙÙŠØ© Ù„كل Ø£Ø¯Ø§Ø©
  String _textTone = 'marketing'; // تسويقي / رسمي / مختصر
  String _textLength = 'medium'; // قصير / متوسط / طويل
  String _productTone = 'friendly'; // ودية / Ø§Ø­ØªØ±Ø§ÙÙŠØ©

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  bool _checkAuth() {
    final isAuthenticated = widget.ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      setState(() {
        _result = 'âŒ ÙŠØ¬Ø¨ ØªØ³Ø¬ÙŠÙ„ الØ¯Ø®ÙˆÙ„ Ø£ÙˆلاÙ‹ لاØ³ØªØ®Ø¯Ø§Ù… أدوات AI';
      });
      return false;
    }
    return true;
  }

  Future<void> _testGenerateText() async {
    if (!_checkAuth()) return;
    if (_promptController.text.isEmpty) {
      setState(() => _result = 'âš ï¸ Ø£Ø¯Ø®Ù„ Ù…ÙˆØ¶ÙˆØ¹ النص Ø£ÙˆلاÙ‹');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'â³ Ø¬Ø§Ø±ÙŠ ØªÙˆÙ„ÙŠØ¯ النص...';
    });

    try {
      final service = widget.ref.read(mbuyStudioServiceProvider);
      // Ø¨Ù†Ø§Ø¡ prompt منØ§Ø³Ø¨ Ù„ØªÙˆÙ„ÙŠØ¯ نص Ø¹Ø§Ù…
      final toneMap = {
        'marketing': 'تسويقي Ø¬Ø°Ø§Ø¨',
        'formal': 'رسمي ÙˆØ§Ø­ØªØ±Ø§ÙÙŠ',
        'short': 'مختصر ÙˆÙ…Ø¨Ø§Ø´Ø±',
      };
      final lengthMap = {
        'short': 'Ø¬Ù…Ù„ØªÙŠÙ†',
        'medium': '3-4 Ø¬Ù…Ù„',
        'long': 'ÙÙ‚Ø±Ø© ÙƒØ§Ù…Ù„Ø©',
      };

      final fullPrompt =
          'Ø§ÙƒØªØ¨ نص ${toneMap[_textTone]} Ø¹Ù† "${_promptController.text}" Ø¨Ø·ÙˆÙ„ ${lengthMap[_textLength]}';

      final response = await service.generateText(fullPrompt);
      setState(() {
        final text =
            response['text'] ?? response['content'] ?? response['data'];
        _result = 'âœ… النص الÙ…ÙˆÙ„Ù‘Ø¯:\n\n$text';
      });
    } catch (e) {
      setState(() {
        _result = 'âŒ ÙØ´Ù„: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGenerateProductDescription() async {
    if (!_checkAuth()) return;
    if (_promptController.text.isEmpty) {
      setState(
        () => _result =
            'âš ï¸ Ø£Ø¯Ø®Ù„ Ø§Ø³Ù… المنØªØ¬ ÙˆÙ…Ù…ÙŠØ²Ø§ØªÙ‡\n(Ù…Ø«ال: ساعة Ø°ÙƒÙŠØ© - Ù…Ù‚Ø§ÙˆÙ…Ø© Ù„Ù„Ù…Ø§Ø¡ - Ø¨Ø·Ø§Ø±ÙŠØ© طويلØ© - Ø´Ø§Ø´Ø© AMOLED)',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'â³ Ø¬Ø§Ø±ÙŠ ØªÙˆÙ„ÙŠØ¯ ÙˆØµÙ المنØªØ¬...';
    });

    try {
      final service = widget.ref.read(mbuyStudioServiceProvider);
      final response = await service.generateProductDescription(
        prompt: _promptController.text,
        tone: _productTone,
        language: 'ar',
      );

      final description =
          response['description'] ??
          response['content'] ??
          response['text'] ??
          response['data'];
      setState(() {
        _result = 'âœ… ÙˆØµÙ المنØªØ¬:\n\n$description';
      });
    } catch (e) {
      setState(() {
        _result = 'âŒ ÙØ´Ù„: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGenerateKeywords() async {
    if (!_checkAuth()) return;
    if (_promptController.text.isEmpty) {
      setState(
        () => _result = 'âš ï¸ Ø£Ø¯Ø®Ù„ Ø§Ø³Ù… المنØªØ¬ Ø£Ùˆ الÙØ¦Ø©\n(Ù…Ø«ال: Ø­Ù‚ÙŠØ¨Ø© Ø¬Ù„Ø¯ Ù†Ø³Ø§Ø¦ÙŠØ©)',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'â³ Ø¬Ø§Ø±ÙŠ ØªÙˆÙ„ÙŠØ¯ الكلÙ…Ø§Øª الÙ…ÙØªØ§Ø­ÙŠØ©...';
    });

    try {
      final service = widget.ref.read(mbuyStudioServiceProvider);
      final response = await service.generateKeywords(
        prompt: _promptController.text,
        language: 'ar',
      );

      final keywords = response['keywords'];
      setState(() {
        if (keywords is List && keywords.isNotEmpty) {
          _result =
              'âœ… الكلÙ…Ø§Øª الÙ…ÙØªØ§Ø­ÙŠØ©:\n\n${keywords.map((k) => 'â€¢ $k').join('\n')}';
        } else {
          _result = 'âœ… ${response['data'] ?? response}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'âŒ ÙØ´Ù„: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============= AI Image Generation =============
  Future<void> _testNanoBananaGenerate() async {
    if (!_checkAuth()) return;
    if (_promptController.text.isEmpty) {
      setState(
        () => _result =
            'âš ï¸ Ø£Ø¯Ø®Ù„ ÙˆØµÙ الØµÙˆØ±Ø© Ø¨الØ¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©\n(Ù…Ø«ال: Professional product photo of a smartwatch on white background)',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'â³ Ø¬Ø§Ø±ÙŠ ØªÙˆÙ„ÙŠØ¯ الØµÙˆØ±Ø© Ø¹Ø¨Ø± NanoBanana...';
      _generatedImageUrl = null;
      _currentTaskId = null;
    });

    try {
      final service = widget.ref.read(mbuyStudioServiceProvider);

      // ØªÙˆÙ„ÙŠØ¯ الØµÙˆØ±Ø©
      final response = await service.nanoBananaGenerate(_promptController.text);

      // الØªØ­Ù‚Ù‚ من الÙ†ØªÙŠØ¬Ø©
      final status = response['status'];
      final imageUrl = response['image_url'] ?? response['imageUrl'];

      if (status == 'completed' && imageUrl != null) {
        setState(() {
          _generatedImageUrl = imageUrl;
          _result = 'âœ… تم ØªÙˆÙ„ÙŠØ¯ الØµÙˆØ±Ø© Ø¨Ù†Ø¬Ø§Ø­!';
        });
      } else {
        setState(() {
          _result =
              'âŒ ÙØ´Ù„: ${response['error'] ?? response['details'] ?? 'Ø§Ø³ØªØ¬Ø§Ø¨Ø© غير Ù…ØªÙˆÙ‚Ø¹Ø©'}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'âŒ ÙØ´Ù„: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ignore: unused_element - Ù…Ø­ÙÙˆØ¸Ø© Ù„لاØ³ØªØ®Ø¯Ø§Ù… الÙ…Ø³ØªÙ‚Ø¨Ù„ÙŠ
  Future<void> _pollTaskStatus(String taskId) async {
    final service = widget.ref.read(mbuyStudioServiceProvider);
    int attempts = 0;
    const maxAttempts = 30; // 30 Ù…Ø­Ø§ÙˆÙ„Ø© Ã— 2 Ø«Ø§Ù†ÙŠØ© = دقيقة ÙˆØ§Ø­Ø¯Ø© ÙƒØ­Ø¯ Ø£Ù‚ØµÙ‰

    while (attempts < maxAttempts) {
      attempts++;
      await Future.delayed(const Duration(seconds: 2));

      try {
        final taskResponse = await service.nanoBananaGetTask(taskId);
        final status = taskResponse['status']?.toString().toLowerCase();

        if (status == 'completed' || status == 'success') {
          // الØ¨Ø­Ø« Ø¹Ù† Ø±Ø§Ø¨Ø· الØµÙˆØ±Ø© ÙÙŠ الÙ†ØªÙŠØ¬Ø©
          final result = taskResponse['result'];
          String? imageUrl;

          if (result is List && result.isNotEmpty) {
            imageUrl = result[0]?.toString();
          } else if (result is Map) {
            imageUrl = result['url'] ?? result['image_url'] ?? result['image'];
          } else if (result is String) {
            imageUrl = result;
          }

          // Ø£ÙŠØ¶Ø§Ù‹ ØªØ­Ù‚Ù‚ من الÙ…Ø³ØªÙˆÙ‰ الØ£على
          imageUrl ??=
              taskResponse['url'] ??
              taskResponse['image_url'] ??
              taskResponse['image'];

          setState(() {
            _generatedImageUrl = imageUrl;
            _result = imageUrl != null
                ? 'âœ… تم ØªÙˆÙ„ÙŠØ¯ الØµÙˆØ±Ø© Ø¨Ù†Ø¬Ø§Ø­!'
                : 'âœ… Ø§ÙƒتمÙ„Øª الÙ…Ù‡Ù…Ø© Ù„ÙƒÙ† Ù„Ù… ÙŠتم الØ¹Ø«ÙˆØ± على Ø±Ø§Ø¨Ø· الØµÙˆØ±Ø©\n\nالÙ†ØªÙŠØ¬Ø©: $taskResponse';
          });
          return;
        } else if (status == 'failed' || status == 'error') {
          final error =
              taskResponse['error'] ??
              taskResponse['message'] ??
              'Ø®Ø·Ø£ غير معØ±ÙˆÙ';
          setState(() {
            _result = 'âŒ ÙØ´Ù„Øª الÙ…Ù‡Ù…Ø©: $error';
          });
          return;
        } else {
          // لا Ø²الØª Ù‚ÙŠØ¯ الØªÙ†ÙÙŠØ°
          setState(() {
            _result =
                'â³ Ø­الØ© الÙ…Ù‡Ù…Ø©: ${status ?? 'processing'}\nالÙ…Ø­Ø§ÙˆÙ„Ø©: $attempts/$maxAttempts';
          });
        }
      } catch (e) {
        debugPrint('[NanoBanana] Poll error: $e');
        // Ø§Ø³تمØ± ÙÙŠ الÙ…Ø­Ø§ÙˆÙ„Ø©
      }
    }

    setState(() {
      _result = 'âš ï¸ Ø§Ù†ØªÙ‡Øª الÙ…هلØ©. ÙŠÙ…ÙƒÙ†Ùƒ الØªØ­Ù‚Ù‚ لاØ­Ù‚Ø§Ù‹ من الÙ…Ù‡Ù…Ø©: $taskId';
    });
  }

  Future<void> _checkTaskStatus() async {
    if (_currentTaskId == null) {
      setState(() => _result = 'âš ï¸ لا ØªÙˆØ¬Ø¯ Ù…Ù‡Ù…Ø© Ù„Ù„ØªØ­Ù‚Ù‚ منÙ‡Ø§');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'â³ Ø¬Ø§Ø±ÙŠ الØªØ­Ù‚Ù‚ من Ø­الØ© الÙ…Ù‡Ù…Ø©...';
    });

    try {
      final service = widget.ref.read(mbuyStudioServiceProvider);
      final response = await service.nanoBananaGetTask(_currentTaskId!);

      final status = response['status'];
      final result = response['result'];

      setState(() {
        _result =
            'ðŸ“‹ Ø­الØ© الÙ…Ù‡Ù…Ø©: $status\n\nالØªÙØ§ØµÙŠÙ„:\n${_formatJson(response)}';

        // Ø¥Ø°Ø§ Ø§ÙƒتمÙ„ØªØŒ Ø­Ø§ÙˆÙ„ Ø§Ø³ØªØ®Ø±Ø§Ø¬ الØµÙˆØ±Ø©
        if (status == 'completed' || status == 'success') {
          String? imageUrl;
          if (result is List && result.isNotEmpty) {
            imageUrl = result[0]?.toString();
          } else if (result is Map) {
            imageUrl = result['url'] ?? result['image_url'];
          }
          imageUrl ??= response['url'] ?? response['image_url'];
          _generatedImageUrl = imageUrl;
        }
      });
    } catch (e) {
      setState(() => _result = 'âŒ ÙØ´Ù„ الØªØ­Ù‚Ù‚: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    } catch (_) {
      return json.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ø­الØ© ØªØ³Ø¬ÙŠÙ„ الØ¯Ø®ÙˆÙ„
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.ref.watch(isAuthenticatedProvider)
                  ? Colors.green[50]
                  : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.ref.watch(isAuthenticatedProvider)
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.ref.watch(isAuthenticatedProvider)
                      ? Icons.check_circle
                      : Icons.error,
                  color: widget.ref.watch(isAuthenticatedProvider)
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.ref.watch(isAuthenticatedProvider)
                      ? 'تم ØªØ³Ø¬ÙŠÙ„ الØ¯Ø®ÙˆÙ„ âœ“'
                      : 'غير Ù…Ø³Ø¬Ù„ الØ¯Ø®ÙˆÙ„ - Ø³Ø¬Ù„ Ø¯Ø®ÙˆÙ„Ùƒ لاØ³ØªØ®Ø¯Ø§Ù… أدوات AI',
                  style: TextStyle(
                    color: widget.ref.watch(isAuthenticatedProvider)
                        ? Colors.green[800]
                        : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ø§Ø®ØªÙŠØ§Ø± الØ£Ø¯Ø§Ø©
          Text(
            'Ø§Ø®ØªØ± الØ£Ø¯Ø§Ø©:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontTitle,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToolChip(
                'text',
                'ØªÙˆÙ„ÙŠØ¯ نص',
                Icons.text_fields,
                Colors.blue,
              ),
              _buildToolChip(
                'description',
                'ÙˆØµÙ منØªØ¬',
                Icons.description,
                Colors.teal,
              ),
              _buildToolChip(
                'keywords',
                'كلÙ…Ø§Øª Ù…ÙØªØ§Ø­ÙŠØ©',
                Icons.key,
                Colors.indigo,
              ),
              _buildToolChip(
                'nano_banana',
                'ðŸŒ ØµÙˆØ±Ø© AI',
                Icons.image,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ø­Ù‚Ù„ الØ¥Ø¯Ø®ال مع ØªÙ„Ù…ÙŠØ­ Ù…Ø®ØµØµ
          TextField(
            controller: _promptController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _getInputLabel(),
              hintText: _getInputHint(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Ø®ÙŠØ§Ø±Ø§Øª Ø¥Ø¶Ø§ÙÙŠØ© Ø­Ø³Ø¨ الØ£Ø¯Ø§Ø©
          _buildToolOptions(),
          const SizedBox(height: 16),

          // Ø²Ø± الØªÙˆÙ„ÙŠØ¯
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _executeSelectedTool,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Ø¬Ø§Ø±ÙŠ الØªÙˆÙ„ÙŠØ¯...' : 'ØªÙˆÙ„ÙŠØ¯'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getToolColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ø¹Ø±Ø¶ الØµÙˆØ±Ø© الÙ…ÙˆÙ„Ø¯Ø© (NanoBanana)
          if (_generatedImageUrl != null) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _generatedImageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ الØµÙˆØ±Ø©',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _generatedImageUrl!,
                          style: TextStyle(
                            fontSize: AppDimensions.fontCaption,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedImageUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم Ù†Ø³Ø® الØ±Ø§Ø¨Ø·')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Ù†Ø³Ø® الØ±Ø§Ø¨Ø·'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _generatedImageUrl = null;
                    _result = '';
                  }),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Ø¥Ø®ÙØ§Ø¡'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Ø²Ø± الØªØ­Ù‚Ù‚ من الÙ…Ù‡Ù…Ø© (NanoBanana)
          if (_selectedTool == 'nano_banana' &&
              _currentTaskId != null &&
              !_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: _checkTaskStatus,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'ØªØ­Ù‚Ù‚ من الÙ…Ù‡Ù…Ø©: ${_currentTaskId!.substring(0, 8)}...',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),

          // Ù†ØªÙŠØ¬Ø©
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'الÙ†ØªÙŠØ¬Ø©:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontTitle,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _result.isEmpty ? 'Ø§Ø¶ØºØ· على Ø£ÙŠ Ø£Ø¯Ø§Ø© Ù„Ù„ØªØ¬Ø±Ø¨Ø©' : _result,
                  style: TextStyle(
                    fontSize: AppDimensions.fontBody,
                    height: 1.6,
                    color: _result.contains('âŒ')
                        ? Colors.red[800]
                        : _result.contains('âœ…')
                        ? Colors.green[800]
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ø¯Ùˆال Ù…Ø³Ø§Ø¹Ø¯Ø© Ù„Ù„Ø£Ø¯Ø§Ø© الÙ…Ø®ØªØ§Ø±Ø©
  String _getInputLabel() {
    switch (_selectedTool) {
      case 'text':
        return 'Ù…ÙˆØ¶ÙˆØ¹ النص (Ø¹Ø±Ø¨ÙŠ)';
      case 'description':
        return 'Ø§Ø³Ù… المنØªØ¬ ÙˆÙ…Ù…ÙŠØ²Ø§ØªÙ‡ (Ø¹Ø±Ø¨ÙŠ)';
      case 'keywords':
        return 'Ø§Ø³Ù… المنØªØ¬/الÙØ¦Ø© (Ø¹Ø±Ø¨ÙŠ)';
      case 'nano_banana':
        return 'ÙˆØµÙ الØµÙˆØ±Ø© (Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠ Ø£ÙØ¶Ù„)';
      default:
        return 'الØ¥Ø¯Ø®ال';
    }
  }

  String _getInputHint() {
    switch (_selectedTool) {
      case 'text':
        return 'Ù…Ø«ال: منØ´ÙˆØ± ØªØ±Ø­ÙŠØ¨ÙŠ Ø¨الØ¹Ù…لاØ¡ الØ¬Ø¯Ø¯';
      case 'description':
        return 'Ù…Ø«ال: ساعة Ø°ÙƒÙŠØ© - Ù…Ù‚Ø§ÙˆÙ…Ø© Ù„Ù„Ù…Ø§Ø¡ - Ø´Ø§Ø´Ø© AMOLED';
      case 'keywords':
        return 'Ù…Ø«ال: Ø­Ù‚ÙŠØ¨Ø© Ø¬Ù„Ø¯ Ù†Ø³Ø§Ø¦ÙŠØ©';
      case 'nano_banana':
        return 'Ù…Ø«ال: Professional product photo of a smartwatch on white background';
      default:
        return '';
    }
  }

  Color _getToolColor() {
    switch (_selectedTool) {
      case 'text':
        return Colors.blue;
      case 'description':
        return Colors.teal;
      case 'keywords':
        return Colors.indigo;
      case 'nano_banana':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _executeSelectedTool() {
    switch (_selectedTool) {
      case 'text':
        _testGenerateText();
        break;
      case 'description':
        _testGenerateProductDescription();
        break;
      case 'keywords':
        _testGenerateKeywords();
        break;
      case 'nano_banana':
        _testNanoBananaGenerate();
        break;
    }
  }

  Widget _buildToolChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedTool == value;
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => setState(() {
        _selectedTool = value;
        _result = '';
      }),
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : color),
      label: Text(label),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildToolOptions() {
    switch (_selectedTool) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ù†ÙˆØ¹ النص:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('تسويقي'),
                  selected: _textTone == 'marketing',
                  onSelected: (_) => setState(() => _textTone = 'marketing'),
                ),
                ChoiceChip(
                  label: const Text('رسمي'),
                  selected: _textTone == 'formal',
                  onSelected: (_) => setState(() => _textTone = 'formal'),
                ),
                ChoiceChip(
                  label: const Text('مختصر'),
                  selected: _textTone == 'short',
                  onSelected: (_) => setState(() => _textTone = 'short'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('الØ·ÙˆÙ„:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('قصير'),
                  selected: _textLength == 'short',
                  onSelected: (_) => setState(() => _textLength = 'short'),
                ),
                ChoiceChip(
                  label: const Text('متوسط'),
                  selected: _textLength == 'medium',
                  onSelected: (_) => setState(() => _textLength = 'medium'),
                ),
                ChoiceChip(
                  label: const Text('طويل'),
                  selected: _textLength == 'long',
                  onSelected: (_) => setState(() => _textLength = 'long'),
                ),
              ],
            ),
          ],
        );
      case 'description':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ù†Ø¨Ø±Ø© الÙˆØµÙ:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('ودية'),
                  selected: _productTone == 'friendly',
                  onSelected: (_) => setState(() => _productTone = 'friendly'),
                ),
                ChoiceChip(
                  label: const Text('Ø§Ø­ØªØ±Ø§ÙÙŠØ©'),
                  selected: _productTone == 'professional',
                  onSelected: (_) =>
                      setState(() => _productTone = 'professional'),
                ),
                ChoiceChip(
                  label: const Text('ÙØ§Ø®Ø±Ø©'),
                  selected: _productTone == 'luxury',
                  onSelected: (_) => setState(() => _productTone = 'luxury'),
                ),
              ],
            ),
          ],
        );
      case 'nano_banana':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ðŸŒ NanoBanana',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'ØªÙˆÙ„ÙŠØ¯ ØµÙˆØ± Ø¨الØ°ÙƒØ§Ø¡ الØ§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¹Ø¨Ø± OpenRouter',
              style: TextStyle(
                fontSize: AppDimensions.fontLabel,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
