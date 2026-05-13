import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';

class ContactSection extends StatelessWidget {
  final PortfolioSettings settings;
  final bool isDark;

  const ContactSection({
    super.key,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(80),
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GET IN TOUCH',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted(isDark),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          _buildEmailLink(),
          const SizedBox(height: 40),
          Row(
            children: [
              if (settings.github != null)
                _buildSocialLink('GitHub', settings.github!),
              if (settings.github != null) const SizedBox(width: 40),
              if (settings.linkedin != null)
                _buildSocialLink('LinkedIn', settings.linkedin!),
              if (settings.linkedin != null) const SizedBox(width: 40),
              if (settings.twitter != null)
                _buildSocialLink('Twitter', settings.twitter!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailLink() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse('mailto:${settings.email}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Text(
            settings.email,
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(isDark),
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.primary,
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLink(String label, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: AppTheme.textMuted(isDark).withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
