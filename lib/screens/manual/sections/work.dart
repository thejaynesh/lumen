import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';
import '../../../widgets/broadside/project_artwork.dart';
import '../../../widgets/broadside/folder_tabs.dart';

class BroadsideWork extends StatelessWidget {
  const BroadsideWork({super.key, required this.projects, required this.dark});
  final List<Project> projects;
  final bool dark;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Kicker(
              'Selected work / ${projects.length.toString().padLeft(2, '0')} projects',
              dark: dark,
            ),
            const SizedBox(height: 14),
            Semantics(
              header: true,
              child: Text(
                'Software I’ve built.',
                style: BroadsideText.editorial(
                  size: 42,
                  color: Broadside.ink(dark),
                ),
              ),
            ),
          ],
        ),
      ),
      if (projects.isEmpty)
        Text(
          'Project details will be available here soon.',
          style: BroadsideText.sans(color: Broadside.inkSoft(dark)),
        ),
      if (projects.isNotEmpty) ...[
        FolderTabs(
          dark: dark,
          tabPrefix: 'project',
          entries: [
            for (final project in projects)
              FolderEntry(
                id: project.id,
                label: project.title,
                child: _ProjectFile(project: project, dark: dark),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    ],
  );
}

class _ProjectFile extends StatelessWidget {
  const _ProjectFile({required this.project, required this.dark});
  final Project project;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final details = <String, String>{
      if (p.problem.isNotEmpty) 'The problem': p.problem,
      if (p.contribution.isNotEmpty) 'My contribution': p.contribution,
      if (p.outcome.isNotEmpty) 'The outcome': p.outcome,
    };
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.category.isNotEmpty) Kicker(p.category, dark: dark),
        if (p.tag.isNotEmpty) ...[
          const SizedBox(height: 8),
          Kicker(p.tag, dark: dark),
        ],
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            p.title,
            style: BroadsideText.editorial(
              size: 39,
              color: Broadside.ink(dark),
            ),
          ),
        ),
        if (p.description.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            p.description,
            style: BroadsideText.sans(
              size: 15,
              height: 1.8,
              color: Broadside.inkSoft(dark),
            ),
          ),
        ],
        if (p.techStack.isNotEmpty) ...[
          const SizedBox(height: 21),
          Text(
            p.techStack.join(' / '),
            style: BroadsideText.mono(
              size: 11,
              trackingEm: 0,
              color: Broadside.ink(dark),
            ),
          ),
        ],
        if (p.kpi.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            p.kpi,
            style: BroadsideText.sans(
              size: 14,
              weight: FontWeight.w500,
              color: Broadside.ink(dark),
            ),
          ),
        ],
        if (details.isNotEmpty) ...[
          const SizedBox(height: 20),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  'Project details',
                  style: BroadsideText.sans(
                    size: 14,
                    color: Broadside.ink(dark),
                  ),
                ),
                children: [
                  for (final entry in details.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: BroadsideText.sans(
                              size: 13,
                              weight: FontWeight.w600,
                              color: Broadside.ink(dark),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value,
                            style: BroadsideText.sans(
                              size: 14,
                              color: Broadside.inkSoft(dark),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        Wrap(
          spacing: 15,
          runSpacing: 8,
          children: [
            if (p.link?.isNotEmpty == true)
              BroadsideLink(
                label: p.sourceUrl.isNotEmpty
                    ? 'Live demo ↗'
                    : 'Visit project ↗',
                href: p.link!,
                dark: dark,
              ),
            if (p.sourceUrl.isNotEmpty)
              BroadsideLink(
                label: 'View source ↗',
                href: p.sourceUrl,
                dark: dark,
              ),
          ],
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth /
                (MediaQuery.textScalerOf(context).scale(16) / 16) >=
            740;
        final art = ProjectArtwork(project: p, dark: dark);
        final hasVisual = ProjectArtwork.hasVisual(p);
        return Padding(
          padding: EdgeInsets.all(wide ? 30 : 18),
          child: !hasVisual
              ? copy
              : wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: 40),
                    Expanded(flex: 5, child: art),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 30), art],
                ),
        );
      },
    );
  }
}
