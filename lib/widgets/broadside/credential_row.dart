import 'package:flutter/material.dart';
import '../../theme/broadside_theme.dart';

/// Credentials share one left edge; dates move below the copy on small layouts.
class CredentialRow extends StatelessWidget {
  const CredentialRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.dark,
  });
  final String title;
  final String subtitle;
  final String date;
  final bool dark;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide =
          constraints.maxWidth /
              (MediaQuery.textScalerOf(context).scale(16) / 16) >=
          640;
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: BroadsideText.sans(
              size: 21,
              weight: FontWeight.w600,
              height: 1.35,
              color: Broadside.ink(dark),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: BroadsideText.sans(
                size: 14,
                height: 1.6,
                color: Broadside.inkSoft(dark),
              ),
            ),
          ],
        ],
      );
      final when = Text(
        date,
        style: BroadsideText.mono(
          size: 12,
          trackingEm: 0,
          color: Broadside.accent(dark),
        ),
      );
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Broadside.rule(dark))),
        ),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: copy),
                  if (date.isNotEmpty) ...[
                    const SizedBox(width: 28),
                    SizedBox(
                      width: 150,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: when,
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  copy,
                  if (date.isNotEmpty) ...[const SizedBox(height: 12), when],
                ],
              ),
      );
    },
  );
}
