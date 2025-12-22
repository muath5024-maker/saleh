import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/studio_colors.dart';

/// صفحة استديو التحرير - تحرير الصور والفيديو
class EditStudioPage extends ConsumerStatefulWidget {
  const EditStudioPage({super.key});

  @override
  ConsumerState<EditStudioPage> createState() => _EditStudioPageState();
}

class _EditStudioPageState extends ConsumerState<EditStudioPage>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 2; // تعديل (active by default)
  int _selectedSubToolIndex = 0; // سطوع (active by default)
  double _brightnessValue = 24;
  double _contrastValue = 0;
  double _saturationValue = 0;
  double _noiseValue = 0;
  double _shadowsValue = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.crop, activeIcon: Icons.crop, label: 'قص'),
    _NavItem(
      icon: Icons.auto_fix_high_outlined,
      activeIcon: Icons.auto_fix_high,
      label: 'فلاتر',
    ),
    _NavItem(icon: Icons.tune_outlined, activeIcon: Icons.tune, label: 'تعديل'),
    _NavItem(
      icon: Icons.title_outlined,
      activeIcon: Icons.title,
      label: 'نصوص',
    ),
    _NavItem(
      icon: Icons.sticky_note_2_outlined,
      activeIcon: Icons.sticky_note_2,
      label: 'ملصقات',
    ),
  ];

  final List<_SubTool> _subTools = const [
    _SubTool(icon: Icons.brightness_6, label: 'سطوع'),
    _SubTool(icon: Icons.contrast, label: 'تباين'),
    _SubTool(icon: Icons.water_drop_outlined, label: 'تشبع'),
    _SubTool(icon: Icons.grain, label: 'ضجيج'),
    _SubTool(icon: Icons.tonality, label: 'ظلال'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _currentSliderValue {
    switch (_selectedSubToolIndex) {
      case 0:
        return _brightnessValue;
      case 1:
        return _contrastValue;
      case 2:
        return _saturationValue;
      case 3:
        return _noiseValue;
      case 4:
        return _shadowsValue;
      default:
        return 0;
    }
  }

  void _updateSliderValue(double value) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (_selectedSubToolIndex) {
        case 0:
          _brightnessValue = value;
          break;
        case 1:
          _contrastValue = value;
          break;
        case 2:
          _saturationValue = value;
          break;
        case 3:
          _noiseValue = value;
          break;
        case 4:
          _shadowsValue = value;
          break;
      }
    });
  }

  void _selectNavItem(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedNavIndex = index);
  }

  void _selectSubTool(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedSubToolIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.bgDark,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top App Bar
                _buildTopAppBar(context),

                // Main Canvas Area
                Expanded(child: _buildCanvasArea(context)),

                // Adjustment Controls Section
                _buildAdjustmentControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StudioColors.surfaceDarkAlt.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close Button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
          ),

          // Center: Undo, Title, Redo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => HapticFeedback.lightImpact(),
                icon: Transform.flip(
                  flipX: true,
                  child: Icon(
                    Icons.undo,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'استديو التحرير',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => HapticFeedback.lightImpact(),
                icon: Icon(
                  Icons.redo,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ],
          ),

          // Export Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: StudioColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'تصدير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudioColors.surfaceDarkAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // Dot Pattern Background
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(Colors.white.withValues(alpha: 0.03)),
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Placeholder
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        StudioColors.primaryColor.withValues(alpha: 0.3),
                        StudioColors.secondaryColor.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: StudioColors.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط لإضافة صورة',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Brightness Value Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'السطوع: ${_brightnessValue.toInt()}%',
                    style: TextStyle(
                      color: StudioColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Corner Guides
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            bottom: 40,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  left: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 40,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudioColors.surfaceDarkAlt,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _subTools[_selectedSubToolIndex].label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _currentSliderValue >= 0
                          ? '+${_currentSliderValue.toInt()}'
                          : '${_currentSliderValue.toInt()}',
                      style: const TextStyle(
                        color: StudioColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: StudioColors.primaryColor,
                    inactiveTrackColor: StudioColors.surfaceLighter,
                    thumbColor: Colors.white,
                    overlayColor: StudioColors.primaryColor.withValues(alpha: 0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: -100,
                    max: 100,
                    onChanged: _updateSliderValue,
                  ),
                ),
              ],
            ),
          ),

          // Sub-tools Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _subTools.length,
              itemBuilder: (context, index) {
                final isActive = index == _selectedSubToolIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: () => _selectSubTool(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : StudioColors.surfaceLighter,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _subTools[index].icon,
                            size: 18,
                            color: isActive
                                ? StudioColors.surfaceDarkAlt
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _subTools[index].label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive
                                  ? StudioColors.surfaceDarkAlt
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
            decoration: BoxDecoration(
              color: StudioColors.bgDark.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isActive = index == _selectedNavIndex;
                return GestureDetector(
                  onTap: () => _selectNavItem(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? StudioColors.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isActive
                                ? _navItems[index].activeIcon
                                : _navItems[index].icon,
                            size: 24,
                            color: isActive
                                ? StudioColors.primaryColor
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _navItems[index].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isActive
                                ? StudioColors.primaryColor
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر التنقل السفلي
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// أداة فرعية
class _SubTool {
  final IconData icon;
  final String label;

  const _SubTool({required this.icon, required this.label});
}

/// رسم نمط النقاط
class _DotPatternPainter extends CustomPainter {
  final Color color;

  _DotPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
