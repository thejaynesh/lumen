// Broadside Awards section — honors & hackathon wins.
import 'package:flutter/material.dart';

import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideAwards extends StatelessWidget {
  final List<String> awards;
  final bool dark;

  const BroadsideAwards({
    required this.awards,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) return const SizedBox.shrink();
    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 05',
          title: 'AWARDS',
          sub: 'Honors & wins',
          dark: dark,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Column(
            children: List.generate(awards.length, (i) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Broadside.rule(dark)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Index
                    SizedBox(
                      width: 64,
                      child: Text(
                        '0${i + 1}',
                        style: BroadsideText.serif(
                          size: mobile ? 24 : 32,
                          color: Broadside.accent(dark),
                          letterSpacing: -0.02,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Star
                    Text(
                      '★',
                      style: BroadsideText.serif(
                        size: 18,
                        color: Broadside.accent(dark),
                        style: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Award text
                    Expanded(
                      child: Text(
                        awards[i],
                        style: BroadsideText.serif(
                          size: mobile ? 18 : 22,
                          color: Broadside.ink(dark),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
