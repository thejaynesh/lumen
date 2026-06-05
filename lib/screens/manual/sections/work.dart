// Broadside Work section — §6.2
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideWork extends StatelessWidget {
  final List<Project> projects;
  final bool dark;

  const BroadsideWork({
    required this.projects,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 01',
          title: 'WORK',
          sub: 'A selection — newest first',
          dark: dark,
        ),
        ...List.generate(projects.length, (i) {
          final p = projects[i];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Broadside.rule(dark)),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number column
                SizedBox(
                  width: 90,
                  child: Text(
                    '0${i + 1}',
                    style: BroadsideText.serif(
                      size: 80,
                      height: 0.85,
                      letterSpacing: -0.04,
                      color: Broadside.accent(dark),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                // Content column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag + KPI kickers
                      Row(
                        children: [
                          if (p.tag.isNotEmpty) ...[
                            Kicker(p.tag, dark: dark),
                            const SizedBox(width: 16),
                          ],
                          if (p.kpi.isNotEmpty)
                            Kicker(
                              '↳ ${p.kpi}',
                              dark: dark,
                              color: Broadside.accent(dark),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        p.title,
                        style: BroadsideText.serif(
                          size: 40,
                          height: 1.0,
                          letterSpacing: -0.02,
                          color: Broadside.ink(dark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Text(
                          p.description,
                          style: BroadsideText.sans(
                            size: 14.5,
                            color: Broadside.inkSoft(dark),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Image placeholder
                      ImagePlaceholder(
                        aspect: 16 / 7,
                        label:
                            'FIG. 0${i + 1} · ${p.title.toUpperCase()}',
                        dark: dark,
                        imageUrl: p.imageUrl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                // Tech stack tags column
                SizedBox(
                  width: 220,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: p.techStack
                        .map((s) => BroadTag(s, dark: dark, mini: true))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
