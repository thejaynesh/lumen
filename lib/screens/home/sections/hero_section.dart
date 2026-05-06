import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;
  final double scrollOffset;
  final VoidCallback? onViewWorkTap;

  const HeroSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.scrollOffset,
    this.onViewWorkTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parallax offset based on scroll
    final parallaxOffset = scrollOffset * 0.4;

    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Transform.translate(
        offset: Offset(0, parallaxOffset),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name with glow effect
            _buildName(),

            const SizedBox(height: 24),

            // Tagline with blue accent
            _buildTagline(),

            const SizedBox(height: 40),

            // About
            _buildAbout(),

            const SizedBox(height: 60),

            // Stats row
            _buildStats(),

            const SizedBox(height: 60),

            // CTA Buttons
            Row(
              children: [
                _buildCTAButton(),
                const SizedBox(width: 20),
                _buildResumeButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Text(
        data.settings.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 120,
          fontWeight: FontWeight.w900,
          color: AppTheme.textPrimary(isDark),
          letterSpacing: -4,
          height: 0.9,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildTagline() {
    return Text(
          data.tagline,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
            letterSpacing: 8,
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAbout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Text(
        data.about,
        style: GoogleFonts.inter(
          fontSize: 18,
          color: AppTheme.textSecondary(isDark),
          height: 1.6,
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 600.ms);
  }

  Widget _buildStats() {
    final stats = data.settings.stats;
    if (stats.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 48,
      runSpacing: 20,
      children: stats.asMap().entries.map((entry) {
        final stat = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stat.value,
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(isDark),
                letterSpacing: 1.5,
              ),
            ),
          ],
        )
            .animate(delay: Duration(milliseconds: 600 + 80 * entry.key))
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildCTAButton() {
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onViewWorkTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.glowShadow(isDark),
              ),
              child: Text(
                'VIEW WORK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildResumeButton() {
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              if (data.settings.resumeUrl != null) {
                final uri = Uri.parse(data.settings.resumeUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.textMuted(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_rounded,
                    size: 18,
                    color: AppTheme.textPrimary(isDark),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'RESUME',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(isDark),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 700.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
