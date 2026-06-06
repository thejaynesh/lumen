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

  Widget _buildCell({
    required int i,
    required int total,
    required bool isRightBorder,
    required bool isBottomBorder,
    required dynamic h,
    required double valueSize,
  }) {
    final isFirst = i == 0;
    final bg = isFirst ? Broadside.accent(dark) : Colors.transparent;
    final textColor =
        isFirst ? Broadside.accentInk(dark) : Broadside.ink(dark);
    final labelColor =
        isFirst ? Broadside.accentInk(dark) : Broadside.inkSoft(dark);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: isRightBorder
                ? BorderSide(color: Broadside.rule(dark))
                : BorderSide.none,
            bottom: isBottomBorder
                ? BorderSide(color: Broadside.rule(dark))
                : BorderSide.none,
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
                size: valueSize,
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
  }

  @override
  Widget build(BuildContext context) {
    final highlights = settings.highlights;
    if (highlights.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < 760;

    if (mobile) {
      // 2-column grid: two rows of two cells
      // Pad to even number if needed
      final paddedLength = highlights.length % 2 == 0
          ? highlights.length
          : highlights.length + 1;
      final rows = <Widget>[];
      for (var r = 0; r < paddedLength; r += 2) {
        final leftIdx = r;
        final rightIdx = r + 1;
        final isLastRow = r + 2 >= paddedLength;
        Widget leftCell;
        Widget rightCell;
        if (leftIdx < highlights.length) {
          leftCell = _buildCell(
            i: leftIdx,
            total: highlights.length,
            isRightBorder: true,
            isBottomBorder: !isLastRow,
            h: highlights[leftIdx],
            valueSize: 44,
          );
        } else {
          leftCell = const Expanded(child: SizedBox.shrink());
        }
        if (rightIdx < highlights.length) {
          rightCell = _buildCell(
            i: rightIdx,
            total: highlights.length,
            isRightBorder: false,
            isBottomBorder: !isLastRow,
            h: highlights[rightIdx],
            valueSize: 44,
          );
        } else {
          rightCell = const Expanded(child: SizedBox.shrink());
        }
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [leftCell, rightCell],
          ),
        ));
      }
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Broadside.rule(dark)),
          ),
        ),
        child: Column(children: rows),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Broadside.rule(dark)),
        ),
      ),
      // IntrinsicHeight bounds the Row's cross-axis (height) so that
      // CrossAxisAlignment.stretch is valid. Without it, the Row sits under
      // the SingleChildScrollView's UNBOUNDED vertical constraint and stretch
      // resolves to an infinite tight height → RenderFlex layout throw, which
      // (in a release web build) silently blanks the entire scroll subtree.
      child: IntrinsicHeight(
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
      ),
    );
  }
}
