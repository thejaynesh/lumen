import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/narrator_provider.dart';
import '../../../theme/app_theme.dart';

/// Top-of-screen automated-flow timeline.
///
///  - Horizontal track with one dot per section.
///  - Filled portion grows smoothly with `totalProgress`.
///  - Dots are clickable; clicking jumps the narrator to that section.
class NarratorProgressBar extends StatelessWidget {
  final bool isDark;
  const NarratorProgressBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NarratorProvider>();
    if (!n.isActive || n.sections.isEmpty) return const SizedBox.shrink();

    final label = n.sections[n.currentIndex].label;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 16, 80, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 18,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: [
                            // base track
                            Center(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            // animated fill
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 80),
                              curve: Curves.linear,
                              height: 2,
                              width: (width * n.totalProgress).clamp(0.0, width),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            // dots
                            ...List.generate(n.sections.length, (i) {
                              final fraction = n.sections.length == 1
                                  ? 0.5
                                  : i / (n.sections.length - 1);
                              return Align(
                                alignment: Alignment(2 * fraction - 1, 0),
                                child: _SectionDot(
                                  isPast: i < n.currentIndex,
                                  isCurrent: i == n.currentIndex,
                                  isDark: isDark,
                                  label: n.sections[i].label,
                                  onTap: () => n.goTo(i),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDot extends StatefulWidget {
  final bool isPast;
  final bool isCurrent;
  final bool isDark;
  final String label;
  final VoidCallback onTap;

  const _SectionDot({
    required this.isPast,
    required this.isCurrent,
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SectionDot> createState() => _SectionDotState();
}

class _SectionDotState extends State<_SectionDot> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.isCurrent || widget.isPast;
    final size = widget.isCurrent ? 14.0 : (_hover ? 12.0 : 10.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.label,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? AppTheme.primary
                      : (widget.isDark
                            ? const Color(0xFF111111)
                            : Colors.white),
                  border: Border.all(
                    color: AppTheme.primary,
                    width: widget.isCurrent ? 2.5 : 2,
                  ),
                  boxShadow: widget.isCurrent || _hover
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.7),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
