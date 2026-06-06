// Broadside Certifications section.
import 'package:flutter/material.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideCertifications extends StatelessWidget {
  final List<Certification> certifications;
  final bool dark;

  const BroadsideCertifications({
    required this.certifications,
    required this.dark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (certifications.isEmpty) return const SizedBox.shrink();
    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          number: '§ 06',
          title: 'CERTIFICATIONS',
          sub: 'Courses & credentials',
          dark: dark,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Column(
            children: certifications.map((c) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Broadside.rule(dark)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.year,
                            style: BroadsideText.serif(
                              size: 22,
                              color: Broadside.accent(dark),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.name,
                            style: BroadsideText.serif(
                              size: 22,
                              color: Broadside.ink(dark),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.issuer,
                            style: BroadsideText.sans(
                              size: 14,
                              color: Broadside.inkSoft(dark),
                              height: 1.5,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Year (fixed 120)
                          SizedBox(
                            width: 120,
                            child: Text(
                              c.year,
                              style: BroadsideText.serif(
                                size: 22,
                                color: Broadside.accent(dark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Name
                          Expanded(
                            child: Text(
                              c.name,
                              style: BroadsideText.serif(
                                size: 22,
                                color: Broadside.ink(dark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Issuer
                          Expanded(
                            child: Text(
                              c.issuer,
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
