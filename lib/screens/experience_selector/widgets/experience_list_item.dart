import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/experience_provider.dart';

/// A sleek list item with a large watermark number and hover effects.
class ExperienceListItem extends StatefulWidget {
  final ExperienceMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String indexString; // '01', '02', etc.
  final VoidCallback onTap;

  const ExperienceListItem({
    super.key,
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.indexString,
    required this.onTap,
  });

  @override
  State<ExperienceListItem> createState() => _ExperienceListItemState();
}

class _ExperienceListItemState extends State<ExperienceListItem> {
  bool _isHovered = false;

  Color get _accentColor {
    switch (widget.mode) {
      case ExperienceMode.narrator:
        return const Color(0xFF60A5FA); // Blue
      case ExperienceMode.fun:
        return const Color(0xFFFB923C); // Orange
      case ExperienceMode.manual:
        return const Color(0xFF34D399); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), // Smoother corners
            color: const Color(0xFF0A0A0F), // Base opaque color
            gradient: _isHovered
                ? LinearGradient(
                    colors: [const Color(0xFF15151A), const Color(0xFF0F0F14)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: _isHovered
                  ? _accentColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Large Watermark Number
              Positioned(
                right: 24,
                top: -10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isHovered ? 0.1 : 0.03,
                  child: Text(
                    widget.indexString,
                    style: GoogleFonts.montserrat(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? _accentColor.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: _isHovered
                            ? _accentColor
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.title.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (widget.subtitle.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isHovered
                                        ? _accentColor.withValues(alpha: 0.1)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _isHovered
                                          ? _accentColor.withValues(alpha: 0.3)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.subtitle,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _isHovered
                                          ? _accentColor
                                          : Colors.white.withValues(alpha: 0.5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Animated Description
                          AnimatedCrossFade(
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                widget.description,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            crossFadeState: _isHovered
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.centerLeft,
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    TweenAnimationBuilder<Offset>(
                      tween: Tween(
                        end: _isHovered ? const Offset(5, 0) : Offset.zero,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _isHovered
                            ? _accentColor
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
