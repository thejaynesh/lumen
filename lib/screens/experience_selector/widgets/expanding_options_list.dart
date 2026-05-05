import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/experience_provider.dart';

/// Vertically stacked experience options.
/// Hovering/selecting expands the option to reveal description.
class ExpandingOptionsList extends StatefulWidget {
  final List<ExperienceMode> modes;
  final Function(ExperienceMode) onSelect;
  final Function(ExperienceMode) getIcon;
  final Function(ExperienceMode) getName;
  final Function(ExperienceMode) getDescription;
  final Function(ExperienceMode) getSubtitle;

  const ExpandingOptionsList({
    super.key,
    required this.modes,
    required this.onSelect,
    required this.getIcon,
    required this.getName,
    required this.getDescription,
    required this.getSubtitle,
  });

  @override
  State<ExpandingOptionsList> createState() => _ExpandingOptionsListState();
}

class _ExpandingOptionsListState extends State<ExpandingOptionsList> {
  int? _hoveredIndex;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.modes.length, (index) {
        final mode = widget.modes[index];
        final isExpanded = _hoveredIndex == index || _selectedIndex == index;
        final isOtherExpanded =
            (_hoveredIndex != null && _hoveredIndex != index) ||
            (_selectedIndex != null && _selectedIndex != index);

        return _ExpandingOption(
          mode: mode,
          index: index,
          icon: widget.getIcon(mode) as IconData,
          title: widget.getName(mode).toString(),
          subtitle: widget.getSubtitle(mode).toString(),
          description: widget.getDescription(mode).toString(),
          isExpanded: isExpanded,
          isDimmed: isOtherExpanded,
          onHover: (hovering) {
            setState(() {
              _hoveredIndex = hovering ? index : null;
            });
          },
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            // Small delay before navigating for visual feedback
            Future.delayed(const Duration(milliseconds: 200), () {
              widget.onSelect(mode);
            });
          },
        );
      }),
    );
  }
}

class _ExpandingOption extends StatelessWidget {
  final ExperienceMode mode;
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool isExpanded;
  final bool isDimmed;
  final Function(bool) onHover;
  final VoidCallback onTap;

  const _ExpandingOption({
    required this.mode,
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isExpanded,
    required this.isDimmed,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 1),
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: isExpanded ? 32 : 20,
          ),
          decoration: BoxDecoration(
            color: isExpanded
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.transparent,
            border: Border(
              top: index == 0
                  ? BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    )
                  : BorderSide.none,
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDimmed ? 0.3 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row
                Row(
                  children: [
                    // Index number
                    SizedBox(
                      width: 40,
                      child: Text(
                        '0${index + 1}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isExpanded ? 0.2 : 0.08,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white.withValues(
                          alpha: isExpanded ? 0.9 : 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(
                                alpha: isExpanded ? 1.0 : 0.7,
                              ),
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.35),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.25 : 0,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.white.withValues(
                          alpha: isExpanded ? 0.6 : 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Expanded description
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 40, top: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.5),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Enter button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'ENTER',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
