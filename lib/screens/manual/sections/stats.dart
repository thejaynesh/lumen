import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';

class BroadsideStats extends StatelessWidget {
  final PortfolioSettings settings;
  final bool dark;
  const BroadsideStats({required this.settings, required this.dark, super.key});

  @override
  Widget build(BuildContext context) {
    if (settings.highlights.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final readingWidth = constraints.maxWidth / textScale;
        final columns = readingWidth >= 780
            ? 3
            : readingWidth >= 480
            ? 2
            : 1;
        const gap = 28.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'A few outcomes',
                  style: BroadsideText.sans(
                    size: 13,
                    color: Broadside.inkSoft(dark),
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: gap,
                runSpacing: 24,
                children: [
                  for (final highlight in settings.highlights)
                    SizedBox(
                      width: width,
                      child: Semantics(
                        container: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  highlight.value,
                                  style: BroadsideText.sans(
                                    size: 21,
                                    color: Broadside.ink(dark),
                                    weight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  highlight.label,
                                  style: BroadsideText.sans(
                                    size: 13,
                                    color: Broadside.ink(dark),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            if (highlight.note.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Text(
                                highlight.note,
                                style: BroadsideText.sans(
                                  size: 12,
                                  color: Broadside.inkSoft(dark),
                                  height: 1.65,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
