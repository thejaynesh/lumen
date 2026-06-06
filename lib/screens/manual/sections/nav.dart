// Broadside Nav — fixed top bar with blur-on-scroll.
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideNav extends StatelessWidget {
  final bool dark;
  final bool scrolled;
  final String name;
  final VoidCallback onWork;
  final VoidCallback onExperience;
  final VoidCallback onAwards;
  final VoidCallback onSkills;
  final VoidCallback onEducation;
  final VoidCallback onCertifications;
  final VoidCallback onNow;
  final VoidCallback onContact;
  final VoidCallback onToggle;
  final VoidCallback onHome;

  const BroadsideNav({
    required this.dark,
    required this.scrolled,
    required this.name,
    required this.onWork,
    required this.onExperience,
    required this.onAwards,
    required this.onSkills,
    required this.onEducation,
    required this.onCertifications,
    required this.onNow,
    required this.onContact,
    required this.onToggle,
    required this.onHome,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget bar = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scrolled ? Broadside.paper(dark) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scrolled ? Broadside.rule(dark) : Colors.transparent,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Broadside.maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Broadside.pagePad,
              vertical: 18,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand
                GestureDetector(
                  onTap: onHome,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: BroadsideText.serif(
                            size: 22,
                            color: Broadside.ink(dark),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Kicker('· SWE', dark: dark, size: 9),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Nav links + toggle. Wrap (not Row) so the link set can never
                // overflow the bar on narrower windows — it wraps to a second
                // line instead.
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _NavLink(label: 'Projects', dark: dark, onTap: onWork),
                      _NavLink(
                          label: 'Experience',
                          dark: dark,
                          onTap: onExperience),
                      _NavLink(label: 'Awards', dark: dark, onTap: onAwards),
                      _NavLink(label: 'Skills', dark: dark, onTap: onSkills),
                      _NavLink(
                          label: 'Education', dark: dark, onTap: onEducation),
                      _NavLink(
                          label: 'Certifications',
                          dark: dark,
                          onTap: onCertifications),
                      _NavLink(label: 'Now', dark: dark, onTap: onNow),
                      _NavLink(label: 'Contact', dark: dark, onTap: onContact),
                      ThemeToggleButton(dark: dark, onToggle: onToggle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Blur backdrop when scrolled
    if (scrolled) {
      bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: bar,
        ),
      );
    }

    return bar;
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool dark;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.dark,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label.toUpperCase(),
          style: BroadsideText.mono(
            size: 10,
            color: _hover
                ? Broadside.ink(widget.dark)
                : Broadside.inkSoft(widget.dark),
            trackingEm: 0.16,
          ),
        ),
      ),
    );
  }
}
