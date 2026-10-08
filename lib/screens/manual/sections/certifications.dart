import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../widgets/broadside/primitives.dart';
import '../../../widgets/broadside/credential_row.dart';

class BroadsideCertifications extends StatelessWidget {
  const BroadsideCertifications({
    super.key,
    required this.certifications,
    required this.dark,
  });
  final List<Certification> certifications;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (certifications.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          number: '',
          title: 'Certifications',
          sub: 'Courses & credentials',
          dark: dark,
          compact: true,
        ),
        for (final entry in certifications)
          CredentialRow(
            title: entry.name,
            subtitle: entry.issuer,
            date: entry.year,
            dark: dark,
          ),
      ],
    );
  }
}
