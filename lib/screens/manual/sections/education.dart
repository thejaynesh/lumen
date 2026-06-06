// Broadside Education section — §6.5
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideEducation extends StatelessWidget {
  final List<EducationEntry> education;
  final bool dark;

  const BroadsideEducation({
    required this.education,
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
          title: 'EDUCATION',
          sub: 'The formal stuff',
          dark: dark,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Broadside.rule(dark)),
            ),
          ),
          child: Column(
            children: education.map((ed) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Broadside.rule(dark)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year (fixed 120)
                    SizedBox(
                      width: 120,
                      child: Text(
                        ed.when,
                        style: BroadsideText.serif(
                          size: 22,
                          color: Broadside.accent(dark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // School
                    Expanded(
                      child: Text(
                        ed.where,
                        style: BroadsideText.serif(
                          size: 22,
                          color: Broadside.ink(dark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Degree
                    Expanded(
                      child: Text(
                        ed.what,
                        style: BroadsideText.sans(
                          size: 14,
                          color: Broadside.inkSoft(dark),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
