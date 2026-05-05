import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AnimatedNavBar extends StatefulWidget {
  final ScrollController? scrollController;
  final List<String> items;
  final List<GlobalKey>? sectionKeys;
  final VoidCallback? onLogoTap;
  final VoidCallback? onContactTap;

  const AnimatedNavBar({
    super.key,
    this.scrollController,
    this.items = const ['Work', 'Projects', 'About', 'Contact'],
    this.sectionKeys,
    this.onLogoTap,
    this.onContactTap,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> {
  bool _isScrolled = false;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = (widget.scrollController?.offset ?? 0) > 50;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  void _scrollToSection(int index) {
    if (widget.sectionKeys != null && index < widget.sectionKeys!.length) {
      final key = widget.sectionKeys![index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      decoration: BoxDecoration(
        color: _isScrolled
            ? AppTheme.background(true).withValues(alpha: 0.9)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _isScrolled
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isScrolled ? 20 : 0,
            sigmaY: _isScrolled ? 20 : 0,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onLogoTap,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'T',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'theja',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                  ),
                ),

                // Nav items
                Row(
                  children: List.generate(widget.items.length, (index) {
                    return _NavItem(
                          label: widget.items[index],
                          isHovered: _hoveredIndex == index,
                          onTap: () => _scrollToSection(index),
                          onHover: (hovered) {
                            setState(
                              () => _hoveredIndex = hovered ? index : -1,
                            );
                          },
                        )
                        .animate(delay: (100 * index).ms)
                        .fadeIn()
                        .slideY(begin: -0.5);
                  }),
                ),

                // CTA Button
                FilledButton(
                  onPressed: onContactTap,
                  child: const Text('Get in Touch'),
                ).animate(delay: 400.ms).fadeIn().scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _NavItem({
    required this.label,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isHovered
                      ? AppTheme.primary
                      : AppTheme.textSecondary(true),
                  letterSpacing: 1,
                ),
                child: Text(label.toUpperCase()),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHovered ? 20 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
