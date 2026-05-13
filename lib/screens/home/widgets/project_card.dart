import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  final bool isDark;

  const ProjectCard({
    super.key,
    required this.project,
    required this.index,
    required this.isDark,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 550,
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surface(widget.isDark),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.5)
                    : AppTheme.textMuted(widget.isDark).withValues(alpha: 0.1),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered ? AppTheme.glowShadow(widget.isDark) : [],
            ),
            transform: _isHovered
                ? Matrix4.translationValues(0.0, -8.0, 0.0)
                : Matrix4.identity(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder with glow
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundAlt(widget.isDark),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppTheme.textMuted(widget.isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Category
                Text(
                  widget.project.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  widget.project.title,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(widget.isDark),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Expanded(
                  child: Text(
                    widget.project.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary(widget.isDark),
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // Tech stack
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.project.techStack.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        tech,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
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
