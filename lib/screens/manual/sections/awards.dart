// Broadside Awards section — honors & hackathon wins.
import 'package:flutter/material.dart';

import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideAwards extends StatelessWidget {
  final List<String> awards;
  final bool dark;

  const BroadsideAwards({required this.awards, required this.dark, super.key});

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 05',
          title: 'Recognition',
          sub: 'Honors & wins',
          dark: dark,
          compact: true,
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
                    ExcludeSemantics(
                      child: Icon(
                        Icons.star_outline,
                        size: 20,
                        color: Broadside.inkSoft(dark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        awards[i],
                        style: BroadsideText.sans(
                          size: 17,
                          weight: FontWeight.w500,
                          color: Broadside.ink(dark),
                          height: 1.6,
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
