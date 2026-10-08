import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/folio_mark.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideNav extends StatelessWidget {
  final bool dark;
  final bool scrolled;
  final String name;
  final VoidCallback onWork,
      onExperience,
      onAwards,
      onSkills,
      onEducation,
      onCertifications,
      onContact,
      onToggle,
      onHome;
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
    required this.onContact,
    required this.onToggle,
    required this.onHome,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = <String, VoidCallback>{
      'Work': onWork,
      'Experience': onExperience,
      'About': onEducation,
      'Contact': onContact,
    };
    return Container(
      color: Broadside.paper(dark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onHome,
                style: TextButton.styleFrom(
                  foregroundColor: Broadside.ink(dark),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FolioMark(dark: dark, size: 34),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        name.isEmpty ? 'Portfolio' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BroadsideText.editorial(
                          size: 19,
                          color: Broadside.ink(dark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Open navigation',
            icon: Icon(Icons.menu, color: Broadside.ink(dark)),
            color: Broadside.paper(dark),
            onSelected: (label) => destinations[label]!(),
            itemBuilder: (_) => destinations.keys
                .map(
                  (label) => PopupMenuItem(
                    value: label,
                    child: Text(
                      label,
                      style: BroadsideText.sans(color: Broadside.ink(dark)),
                    ),
                  ),
                )
                .toList(),
          ),
          ThemeToggleButton(dark: dark, onToggle: onToggle),
        ],
      ),
    );
  }
}

class BroadsideProfileRail extends StatelessWidget {
  final PortfolioSettings settings;
  final bool dark;
  final String activeSection;
  final VoidCallback onHome, onWork, onExperience, onAbout, onContact, onToggle;

  const BroadsideProfileRail({
    required this.settings,
    required this.dark,
    required this.activeSection,
    required this.onHome,
    required this.onWork,
    required this.onExperience,
    required this.onAbout,
    required this.onContact,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final links = <String, (String, VoidCallback)>{
      'Work': ('Selected work', onWork),
      'Experience': ('Experience', onExperience),
      'About': ('A little about me', onAbout),
      'Contact': ('Get in touch', onContact),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: onHome,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Semantics(
              label: settings.name,
              excludeSemantics: true,
              child: FolioMark(
                dark: dark,
                size: 48,
                initials: settings.initials,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            settings.name,
            style: BroadsideText.editorial(
              size: 30,
              color: Broadside.ink(dark),
              height: 1.06,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            settings.role,
            style: BroadsideText.sans(size: 12, color: Broadside.inkSoft(dark)),
          ),
          if (settings.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              settings.location,
              style: BroadsideText.sans(
                size: 11,
                color: Broadside.inkSoft(dark),
              ),
            ),
          ],
          const SizedBox(height: 35),
          ...links.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: TextButton(
                onPressed: entry.value.$2,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  foregroundColor: Broadside.ink(dark),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 2,
                      color: activeSection == entry.key
                          ? Broadside.ink(dark)
                          : Colors.transparent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value.$1,
                        style: BroadsideText.sans(
                          size: 12,
                          color: activeSection == entry.key
                              ? Broadside.ink(dark)
                              : Broadside.inkSoft(dark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 38),
          ThemeToggleButton(dark: dark, onToggle: onToggle),
          if (settings.education.isNotEmpty) ...[
            const SizedBox(height: 46),
            Text(
              'Study & foundations',
              style: BroadsideText.sans(
                size: 11,
                weight: FontWeight.w600,
                color: Broadside.ink(dark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              settings.education.first.where,
              style: BroadsideText.sans(
                size: 11,
                color: Broadside.inkSoft(dark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
