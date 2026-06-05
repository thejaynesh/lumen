// Broadside Skills section — §6.4
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideSkills extends StatelessWidget {
  final PortfolioSettings settings;
  final bool dark;

  const BroadsideSkills({
    required this.settings,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 03',
          title: 'STACK',
          sub: 'What I reach for',
          dark: dark,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Broadside.rule(dark)),
            ),
          ),
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — skill groups (flex 2)
              Expanded(
                flex: 2,
                child: Column(
                  children: settings.skillGroups.map((group) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Broadside.rule(dark)),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            child: Kicker(group.category, dark: dark),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: group.items
                                  .map((s) => BroadTag(s, dark: dark))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 40),
              // Right — awards (flex 1)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('Awards', dark: dark),
                    const SizedBox(height: 12),
                    ...settings.awards.map(
                      (award) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Broadside.rule(dark)),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '★',
                              style: BroadsideText.serif(
                                size: 14,
                                color: Broadside.accent(dark),
                                style: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                award,
                                style: BroadsideText.sans(
                                  size: 13,
                                  color: Broadside.ink(dark),
                                  height: 1.5,
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
            ],
          ),
        ),
      ],
    );
  }
}
