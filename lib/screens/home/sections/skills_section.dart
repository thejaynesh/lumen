import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';

class SkillsSection extends StatelessWidget {
  final PortfolioSettings settings;
  final bool isDark;

  const SkillsSection({
    super.key,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (settings.skills.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKILLS',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted(isDark),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: settings.skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(isDark),
                      border: Border.all(
                        color: AppTheme.textMuted(isDark).withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Text(
                      skill.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
