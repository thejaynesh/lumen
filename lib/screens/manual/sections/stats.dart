// Broadside Stats strip — §5.6 / §6
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideStats extends StatelessWidget {
  final PortfolioSettings settings;
  final bool dark;

  const BroadsideStats({
    required this.settings,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final highlights = settings.highlights;
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Broadside.rule(dark)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(highlights.length, (i) {
          final h = highlights[i];
          final isFirst = i == 0;
          final isLast = i == highlights.length - 1;

          final bg = isFirst ? Broadside.accent(dark) : Colors.transparent;
          final textColor =
              isFirst ? Broadside.accentInk(dark) : Broadside.ink(dark);
          final labelColor =
              isFirst ? Broadside.accentInk(dark) : Broadside.inkSoft(dark);

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                color: bg,
                border: Border(
                  right: isLast
                      ? BorderSide.none
                      : BorderSide(color: Broadside.rule(dark)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(
                    h.label,
                    dark: dark,
                    size: 10,
                    color: labelColor,
                    trackingEm: 0.16,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    h.value,
                    style: BroadsideText.serif(
                      size: 60,
                      height: 1.0,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (h.note.isNotEmpty)
                    Text(
                      h.note,
                      style: BroadsideText.sans(
                        size: 12,
                        color: textColor.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
