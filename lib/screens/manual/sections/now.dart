// Broadside "Currently" section — what I'm up to right now.
import 'package:flutter/material.dart';

import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideNow extends StatelessWidget {
  final List<String> items;
  final bool dark;

  const BroadsideNow({
    required this.items,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 07',
          title: 'CURRENTLY',
          sub: "What I'm up to",
          dark: dark,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Column(
            children: items.map((item) {
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
                    Text(
                      '→',
                      style: BroadsideText.serif(
                        size: 22,
                        color: Broadside.accent(dark),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        item,
                        style: BroadsideText.serif(
                          size: 24,
                          color: Broadside.ink(dark),
                          height: 1.25,
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
