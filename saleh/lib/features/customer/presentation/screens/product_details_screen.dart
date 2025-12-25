import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../../core/services/api_service.dart';
import '../../../../core/permissions_helper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/cart_service.dart';
import '../../data/favorites_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _product;
  Map<String, dynamic>? _store;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get product details from Worker API
      final productResponse = await _api.get('/products/${widget.productId}');

      if (productResponse.statusCode != 200) {
        throw Exception('فشل في جلب بيانات المنتج');
      }

      final productData = json.decode(productResponse.body);
      final storeId = productData['store_id'];

      // Get store details
      final storeResponse = await _api.get('/stores/$storeId');
      final storeData = storeResponse.statusCode == 200
          ? json.decode(storeResponse.body)
          : null;

      final isFav = await FavoritesService.isFavorite(widget.productId);

      setState(() {
        _product = productData;
        _store = storeData;
        _isFavorite = isFav;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في جلب التفاصيل: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    final canAdd = await PermissionsHelper.canAddToCart();
    if (!canAdd) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('التجار لا يمكنهم الشراء من المتاجر الأخرى'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await CartService.addToCart(widget.productId, quantity: _quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة $_quantity من المنتج إلى السلة'),
            backgroundColor: AppTheme.primaryColor,
            action: SnackBarAction(
              label: 'عرض السلة',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _buyNow() async {
    await _addToCart();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _toggleFavorite() async {
    // Check if user is authenticated by checking if we have tokens
    final hasAuth = await _api.hasValidTokens();
    if (!hasAuth) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final newState = await FavoritesService.toggleFavorite(widget.productId);
      setState(() {
        _isFavorite = newState;
        _isTogglingFavorite = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة',
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTogglingFavorite = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: const Center(child: Text('لم يتم العثور على المنتج')),
      );
    }

    final price = (_product!['price'] as num?)?.toDouble() ?? 0;
    final stock = (_product!['stock'] as num?)?.toInt() ?? 0;
    final imageUrl = _product!['image_url'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'تفاصيل المنتج',
          style: GoogleFonts.cairo(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: مشاركة المنتج')),
              );
            },
          ),
          _isTogglingFavorite
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppTheme.primaryColor : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductImage(imageUrl),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!['name'] ?? 'منتج',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$price ر.س',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      _buildStockBadge(stock),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStoreInfo(),
                  const SizedBox(height: 24),
                  if (_product!['description'] != null &&
                      (_product!['description'] as String).isNotEmpty) ...[
                    Text(
                      'الوصف',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product!['description'],
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildQuantitySelector(stock),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(stock),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(color: AppTheme.surfaceColor),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 64,
                color: AppTheme.textSecondaryColor,
              ),
            ),
    );
  }

  Widget _buildStockBadge(int stock) {
    final isAvailable = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withValues(alpha: 0.1)
            : AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? Colors.green : AppTheme.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 14,
            color: isAvailable ? Colors.green : AppTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'متوفر ($stock)' : 'غير متوفر',
            style: GoogleFonts.cairo(
              color: isAvailable ? Colors.green : AppTheme.errorColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    if (_store == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.surfaceColor,
            child: const Icon(
              Icons.store_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _store!['name'] ?? 'متجر',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_store!['city'] != null)
                  Text(
                    _store!['city'],
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(int stock) {
    final isAvailable = stock > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية',
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.textPrimaryColor,
              iconSize: 28,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_quantity',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: isAvailable && _quantity < stock
                  ? () {
                      setState(() {
                        _quantity++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.textPrimaryColor,
              iconSize: 28,
            ),
            const Spacer(),
            if (isAvailable)
              Text(
                'متوفر: $stock',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات إضافية',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.inventory_2_outlined,
            'رمز المنتج',
            widget.productId.substring(0, 8),
          ),
          const Divider(height: 24, color: AppTheme.borderColor),
          _buildInfoRow(
            Icons.local_shipping_outlined,
            'التوصيل',
            'متوفر في معظم المناطق',
          ),
          const Divider(height: 24, color: AppTheme.borderColor),
          _buildInfoRow(Icons.replay, 'الإرجاع', 'خلال 7 أيام من الاستلام'),
          const Divider(height: 24, color: AppTheme.borderColor),
          _buildInfoRow(Icons.verified_user_outlined, 'الضمان', 'ضمان البائع'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(int stock) {
    final isAvailable = stock > 0;
    final totalPrice =
        ((_product!['price'] as num?)?.toDouble() ?? 0) * _quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإجمالي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(2)} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isAvailable && !_isAddingToCart
                          ? _addToCart
                          : null,
                      icon: _isAddingToCart
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        'أضف للسلة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAvailable && !_isAddingToCart
                          ? _buyNow
                          : null,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        'اشتر الآن',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
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
}
