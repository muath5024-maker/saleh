import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// صفحة إضافة منتج - صفحة كاملة مع زر إغلاق
class AddProductPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const AddProductPanel({super.key, this.onClose});

  @override
  State<AddProductPanel> createState() => _AddProductPanelState();
}

class _AddProductPanelState extends State<AddProductPanel> {
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
            // Header
            _buildHeader(isDark),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // إدراج سريع
                  _buildQuickAddOption(context, isDark),
                  const SizedBox(height: 16),
                  Divider(color: AppTheme.border(isDark)),
                  const SizedBox(height: 16),
                  // أنواع المنتجات
                  _buildSectionTitle('أو اختر نوع المنتج', isDark),
                  const SizedBox(height: 16),
                  _buildProductTypeOption(
                    context,
                    type: 'physical',
                    title: 'منتج مادي 📦',
                    description: 'ملابس، إلكترونيات، أثاث، إلخ',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  _buildProductTypeOption(
                    context,
                    type: 'digital',
                    title: 'منتج رقمي 💾',
                    description: 'كتب، دورات، برامج، ملفات',
                    icon: Icons.download,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  _buildProductTypeOption(
                    context,
                    type: 'service',
                    title: 'خدمة 🛠',
                    description: 'استشارات، تصميم، صيانة',
                    icon: Icons.construction,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                  _buildProductTypeOption(
                    context,
                    type: 'subscription',
                    title: 'اشتراك 🔄',
                    description: 'عضويات، باقات شهرية/سنوية',
                    icon: Icons.repeat,
                    color: Colors.green,
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
          // العنوان
          Expanded(
            child: Text(
              'إضافة منتج',
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

  Widget _buildQuickAddOption(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showQuickAddDialog(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentColor,
              AppTheme.accentColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'إدراج سريع ⚡',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أضف منتج بسرعة (اسم + سعر + صورة)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary(isDark),
      ),
    );
  }

  Widget _buildProductTypeOption(
    BuildContext context, {
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _close();
          context.push('/dashboard/products/add', extra: {'productType': type});
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدراج سريع', textAlign: TextAlign.right),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج *',
                  hintText: 'مثال: هاتف آيفون 15',
                  prefixIcon: const Icon(Icons.inventory_2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'السعر *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'ر.س',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'سعر غير صالح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // حفظ المنتج
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة المنتج بنجاح')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
