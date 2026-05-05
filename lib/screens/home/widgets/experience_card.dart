import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';

class ExperienceCard extends StatefulWidget {
  final Experience experience;
  final int index;
  final bool isDark;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.index,
    required this.isDark,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 450,
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppTheme.surfaceLight(widget.isDark)
                  : AppTheme.background(widget.isDark),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.primary.withOpacity(0.5)
                    : AppTheme.textMuted(widget.isDark).withOpacity(0.1),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered ? AppTheme.glowShadow(widget.isDark) : [],
            ),
            transform: _isHovered
                ? (Matrix4.identity()..translate(0.0, -8.0))
                : Matrix4.identity(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period with glow
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    widget.experience.period,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Role
                Text(
                  widget.experience.role,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(widget.isDark),
                  ),
                ),
                const SizedBox(height: 8),
                // Company
                Text(
                  widget.experience.company,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.textSecondary(widget.isDark),
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                Expanded(
                  child: Text(
                    widget.experience.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary(widget.isDark),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Highlights
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.experience.highlights.map((highlight) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.textMuted(
                            widget.isDark,
                          ).withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        highlight,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary(widget.isDark),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * widget.index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
