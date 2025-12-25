import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_icon.dart';

/// Ø´Ø§Ø´Ø© من Ù†Ø­Ù†
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: AppDimensions.paddingL,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // الØ´Ø¹Ø§Ø±
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.metallicGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: AppIcon(AppIcons.store, size: 48, color: Colors.white),
              ),
            ),

            const SizedBox(height: 24),

            // Ø§Ø³Ù… التطبيق
            const Text(
              'Mbuy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 8),

            // الÙˆØµÙ القصير
            Text(
              'منØµØ© الØªØ¬Ø§Ø±Ø© الØ¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØ© الØ°ÙƒÙŠØ©',
              style: TextStyle(fontSize: 16, color: AppTheme.mutedSlate),
            ),

            const SizedBox(height: 8),

            // الØ¥ØµØ¯Ø§Ø±
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'الØ¥ØµØ¯Ø§Ø± 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Ù‚ØµØªÙ†Ø§
            _buildSection(
              title: 'Ù‚ØµØªÙ†Ø§',
              content: '''
Ø¨Ø¯Ø£Øª Mbuy من ÙÙƒØ±Ø© Ø¨Ø³ÙŠØ·Ø©: تمÙƒÙŠÙ† كل Ø´Ø®Øµ من Ø§Ù…ØªلاÙƒ Ù…ØªØ¬Ø±Ù‡ الØ¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ Ø¨Ø³Ù‡ÙˆÙ„Ø©.

Ù†Ø¤من Ø¨Ø£Ù† الØªØ¬Ø§Ø±Ø© الØ¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØ© ÙŠØ¬Ø¨ Ø£Ù† ØªÙƒÙˆÙ† Ù…ØªØ§Ø­Ø© Ù„Ù„Ø¬Ù…ÙŠØ¹ØŒ ÙˆÙ„ÙŠØ³ ÙÙ‚Ø· Ù„Ù„Ø´Ø±ÙƒØ§Øª الÙƒØ¨ÙŠØ±Ø©. Ù„Ø°Ù„Ùƒ Ø£Ù†Ø´Ø£Ù†Ø§ منØµØ© ØªØ¬مع Ø¨ÙŠÙ† الØ³Ù‡ÙˆÙ„Ø© ÙˆالÙ‚ÙˆØ©ØŒ مع Ø£Ø¯ÙˆØ§Øª Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù…ØªÙ‚Ø¯Ù…Ø© Ù„Ù…Ø³Ø§Ø¹Ø¯Ø© الØªØ¬Ø§Ø± على الÙ†Ø¬Ø§Ø­.

اليومØŒ ÙŠØ³ØªØ®Ø¯Ù… Ø¢لاÙ الØªØ¬Ø§Ø± Mbuy Ù„Ø¥Ø¯Ø§Ø±Ø© Ù…ØªØ§Ø¬Ø±Ù‡Ù… ÙˆØªÙ†Ù…ÙŠØ© Ø£Ø¹Ù…الÙ‡Ù….
''',
            ),

            // Ø±Ø¤ÙŠØªÙ†Ø§
            _buildSection(
              title: 'Ø±Ø¤ÙŠØªÙ†Ø§',
              content: '''
Ø£Ù† Ù†ÙƒÙˆÙ† المنØµØ© الØ£ÙˆÙ„Ù‰ Ù„Ù„ØªØ¬Ø§Ø±Ø© الØ¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØ© ÙÙŠ المنØ·Ù‚Ø© الØ¹Ø±Ø¨ÙŠØ©ØŒ ÙˆÙ†Ù…ÙƒÙ‘Ù† Ù…Ù„ÙŠÙˆÙ† ØªØ§Ø¬Ø± من ØªØ­Ù‚ÙŠÙ‚ Ø£Ø­لاÙ…Ù‡Ù… الØªØ¬Ø§Ø±ÙŠØ© Ø¨Ø­Ù„ÙˆÙ„ 2030.
''',
            ),

            // Ù…Ù…ÙŠØ²Ø§ØªÙ†Ø§
            const Text(
              'Ù„Ù…Ø§Ø°Ø§ MbuyØŸ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureCard(
              icon: AppIcons.bot,
              title: 'Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù…ØªÙ‚Ø¯Ù…',
              description: 'أدوات AI Ù„ØªÙˆÙ„ÙŠØ¯ الØµÙˆØ± ÙˆالÙ…Ø­ØªÙˆÙ‰ ÙˆØªØ­Ø³ÙŠÙ† الÙ…Ø¨ÙŠØ¹Ø§Øª',
              color: const Color(0xFF8B5CF6),
            ),
            _buildFeatureCard(
              icon: AppIcons.chart,
              title: 'ØªØ­Ù„ÙŠلاØª Ø´Ø§Ù…Ù„Ø©',
              description: 'Ø±Ø¤Ù‰ Ø¹Ù…ÙŠÙ‚Ø© Ù„ÙÙ‡Ù… Ø¹Ù…لاØ¦Ùƒ ÙˆØªØ­Ø³ÙŠÙ† Ø£Ø¯Ø§Ø¦Ùƒ',
              color: const Color(0xFF10B981),
            ),
            _buildFeatureCard(
              icon: AppIcons.shield,
              title: 'Ø£Ù…Ø§Ù† Ø¹الÙŠ',
              description: 'Ø­Ù…Ø§ÙŠØ© Ø¨ÙŠØ§Ù†Ø§ØªÙƒ ÙˆمعØ§Ù…لاØªÙƒ Ø¨Ø£على المعØ§ÙŠÙŠØ±',
              color: const Color(0xFFEF4444),
            ),
            _buildFeatureCard(
              icon: AppIcons.supportAgent,
              title: 'Ø¯Ø¹Ù… Ù…ØªÙˆØ§ØµÙ„',
              description: 'ÙØ±ÙŠÙ‚ Ø¯Ø¹Ù… Ù…ØªØ§Ø­ 24/7 Ù„Ù…Ø³Ø§Ø¹Ø¯ØªÙƒ',
              color: const Color(0xFF3B82F6),
            ),

            const SizedBox(height: 32),

            // ØªÙˆØ§ØµÙ„ معÙ†Ø§
            const Text(
              'ØªÙˆØ§ØµÙ„ معÙ†Ø§',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: AppIcons.globe,
                  label: 'الÙ…ÙˆÙ‚Ø¹',
                  onTap: () => _launchUrl('https://mbuy.app'),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: AppIcons.chat,
                  label: 'ØªÙˆÙŠØªØ±',
                  onTap: () => _launchUrl('https://twitter.com/mbuyapp'),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: AppIcons.camera,
                  label: 'Ø§Ù†Ø³ØªÙ‚Ø±Ø§Ù…',
                  onTap: () => _launchUrl('https://instagram.com/mbuyapp'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Ø­Ù‚ÙˆÙ‚ الÙ†Ø´Ø±
            Text(
              'Â© 2025 Mbuy. Ø¬Ù…ÙŠØ¹ الØ­Ù‚ÙˆÙ‚ Ù…Ø­ÙÙˆØ¸Ø©.',
              style: TextStyle(fontSize: 12, color: AppTheme.mutedSlate),
            ),

            const SizedBox(height: 8),

            Text(
              'ØµÙ†Ø¹ Ø¨Ù€ â¤ï¸ ÙÙŠ الÙ…Ù…Ù„ÙƒØ© الØ¹Ø±Ø¨ÙŠØ© الØ³Ø¹ودية',
              style: TextStyle(fontSize: 12, color: AppTheme.mutedSlate),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content.trim(),
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.mutedSlate,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppDimensions.paddingM,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: AppIcon(icon, size: 24, color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: AppTheme.mutedSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            AppIcon(icon, size: 24, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppTheme.mutedSlate),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
