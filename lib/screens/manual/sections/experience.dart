import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/folder_tabs.dart';

class BroadsideExperience extends StatelessWidget {
  final List<Experience> experiences;
  final bool dark;
  final bool showHeading;
  const BroadsideExperience({
    required this.experiences,
    required this.dark,
    this.showHeading = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading)
          Semantics(
            header: true,
            child: Text(
              'Experience',
              style: BroadsideText.editorial(
                size: 34,
                color: Broadside.ink(dark),
                height: 1.15,
                letterSpacing: -0.02,
              ),
            ),
          ),
        if (showHeading) const SizedBox(height: 24),
        if (experiences.isEmpty)
          Text(
            'Experience details will be available here soon.',
            style: BroadsideText.sans(color: Broadside.inkSoft(dark)),
          ),
        if (experiences.isNotEmpty)
          FolderTabs(
            dark: dark,
            tabPrefix: 'experience',
            entries: [
              for (final experience in experiences)
                FolderEntry(
                  id: experience.id,
                  label: experience.company,
                  child: _ExperienceRow(experience: experience, dark: dark),
                ),
            ],
          ),
      ],
    ),
  );
}

class _ExperienceRow extends StatelessWidget {
  final Experience experience;
  final bool dark;
  const _ExperienceRow({required this.experience, required this.dark});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final wide = constraints.maxWidth / textScale >= 620;
      final e = experience;
      final dates = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.period.isNotEmpty)
            Text(
              e.period,
              style: BroadsideText.sans(
                size: 12,
                color: Broadside.ink(dark),
                weight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          if (e.city.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              e.city,
              style: BroadsideText.sans(
                size: 12,
                color: Broadside.inkSoft(dark),
                height: 1.5,
              ),
            ),
          ],
        ],
      );
      final body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              e.company,
              style: BroadsideText.display(
                size: 23,
                weight: FontWeight.w500,
                height: 1.25,
                letterSpacing: -0.025,
                color: Broadside.ink(dark),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            e.role,
            style: BroadsideText.sans(
              size: 14,
              weight: FontWeight.w500,
              height: 1.5,
              color: Broadside.ink(dark),
            ),
          ),
          if (e.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              e.description,
              style: BroadsideText.sans(
                size: 14,
                color: Broadside.inkSoft(dark),
                height: 1.75,
              ),
            ),
          ],
          if (e.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final highlight in e.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ExcludeSemantics(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Broadside.inkSoft(dark),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        highlight,
                        style: BroadsideText.sans(
                          size: 14,
                          color: Broadside.inkSoft(dark),
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (e.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final tag in e.tags)
                  Text(
                    tag,
                    style: BroadsideText.sans(
                      size: 12,
                      color: Broadside.inkSoft(dark),
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
      final hasDates = e.period.isNotEmpty || e.city.isNotEmpty;
      return Container(
        padding: EdgeInsets.all(wide ? 30 : 20),
        child: wide && hasDates
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 150, child: dates),
                  const SizedBox(width: 28),
                  Expanded(child: body),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDates) ...[dates, const SizedBox(height: 16)],
                  body,
                ],
              ),
      );
    },
  );
}
