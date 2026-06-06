// Broadside Experience section — §6.3
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideExperience extends StatelessWidget {
  final List<Experience> experiences;
  final bool dark;

  const BroadsideExperience({
    required this.experiences,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 01',
          title: 'EXPERIENCE',
          sub: 'Where the time went',
          dark: dark,
        ),
        ...experiences.map((e) => Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Broadside.rule(dark)),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: mobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row: date (accent) + city kicker
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              e.period,
                              style: BroadsideText.serif(
                                size: 26,
                                color: Broadside.accent(dark),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(child: Kicker(e.city, dark: dark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Role + company
                        Text(
                          e.role,
                          style: BroadsideText.serif(
                            size: 24,
                            color: Broadside.ink(dark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.company,
                          style: BroadsideText.sans(
                            size: 13,
                            color: Broadside.inkSoft(dark),
                            style: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Blurb
                        Text(
                          e.description,
                          style: BroadsideText.sans(
                            size: 14,
                            color: Broadside.inkSoft(dark),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tags (left-aligned)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: e.tags
                              .map((t) => BroadTag(t, dark: dark, mini: true))
                              .toList(),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Col 1 — date + city (fixed 120)
                        SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.period,
                                style: BroadsideText.serif(
                                  size: 26,
                                  color: Broadside.accent(dark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Kicker(e.city, dark: dark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Col 2 — role + company (flex 14)
                        Expanded(
                          flex: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.role,
                                style: BroadsideText.serif(
                                  size: 24,
                                  color: Broadside.ink(dark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.company,
                                style: BroadsideText.sans(
                                  size: 13,
                                  color: Broadside.inkSoft(dark),
                                  style: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Col 3 — description (flex 20)
                        Expanded(
                          flex: 20,
                          child: Text(
                            e.description,
                            style: BroadsideText.sans(
                              size: 14,
                              color: Broadside.inkSoft(dark),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Col 4 — tags (fixed 130)
                        SizedBox(
                          width: 130,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 6,
                            runSpacing: 6,
                            children: e.tags
                                .map((t) => BroadTag(t, dark: dark, mini: true))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
            )),
      ],
    );
  }
}
