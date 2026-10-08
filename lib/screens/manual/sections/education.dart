import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../widgets/broadside/primitives.dart';
import '../../../widgets/broadside/credential_row.dart';

class BroadsideEducation extends StatelessWidget {
  const BroadsideEducation({
    super.key,
    required this.education,
    required this.dark,
  });
  final List<EducationEntry> education;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (education.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          number: '',
          title: 'Education',
          sub: 'Study & foundations',
          dark: dark,
          compact: true,
        ),
        for (final entry in education)
          CredentialRow(
            title: entry.where,
            subtitle: entry.what,
            date: entry.when,
            dark: dark,
          ),
      ],
    );
  }
}
