// Broadside Hero section — §6.1
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideHero extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;
  final GlobalKey ctaKey;
  final VoidCallback onViewWork;
  final VoidCallback onContact;

  const BroadsideHero({
    required this.data,
    required this.dark,
    required this.ctaKey,
    required this.onViewWork,
    required this.onContact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = data.settings;

    // Split name into first part and last word
    final nameParts = settings.name.trim().split(' ');
    final String firstLine;
    final String secondLine;
    if (nameParts.length > 1) {
      firstLine = nameParts
          .sublist(0, nameParts.length - 1)
          .join(' ')
          .toUpperCase();
      secondLine = '${nameParts.last.toUpperCase()}.';
    } else {
      firstLine = '';
      secondLine = '${settings.name.toUpperCase()}.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 120, bottom: 48),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Broadside.rule(dark)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top kicker row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Kicker('№ 001 · PORTFOLIO', dark: dark),
                Kicker(
                  '${settings.location.toUpperCase()} · 2026',
                  dark: dark,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Big name
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Broadside.rule(dark)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firstLine.isNotEmpty)
                    Text(
                      firstLine,
                      style: BroadsideText.serif(
                        size: 130,
                        height: 0.88,
                        letterSpacing: -0.04,
                        color: Broadside.ink(dark),
                      ),
                    ),
                  Text(
                    secondLine,
                    style: BroadsideText.serif(
                      size: 130,
                      height: 0.88,
                      letterSpacing: -0.04,
                      color: Broadside.ink(dark),
                      style: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Two-column intro
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — statement + CTA
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: BroadsideText.serif(
                            size: 42,
                            height: 1.05,
                            letterSpacing: -0.01,
                            color: Broadside.ink(dark),
                          ),
                          children: [
                            const TextSpan(text: 'A '),
                            TextSpan(
                              text: 'software engineer',
                              style: BroadsideText.serif(
                                size: 42,
                                height: 1.05,
                                letterSpacing: -0.01,
                                color: Broadside.accent(dark),
                                style: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' who builds back-end systems, wins hackathons, and ships full-stack products.',
                              style: BroadsideText.serif(
                                size: 42,
                                height: 1.05,
                                letterSpacing: -0.01,
                                color: Broadside.ink(dark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // CTA buttons — wrapped with ctaKey
                      KeyedSubtree(
                        key: ctaKey,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            BtnPrimary(
                              label: 'View projects ↘',
                              dark: dark,
                              onTap: onViewWork,
                            ),
                            BtnGhost(
                              label: 'Email me',
                              dark: dark,
                              href: 'mailto:${settings.email}',
                            ),
                            BtnGhost(
                              label: 'Résumé ↓',
                              dark: dark,
                              onTap: onContact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Right — summary + open to work
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.summary,
                        style: BroadsideText.sans(
                          size: 15,
                          color: Broadside.inkSoft(dark),
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Kicker(
                        'OPEN TO WORK →',
                        dark: dark,
                        color: Broadside.accent(dark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
