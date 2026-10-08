import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../utils/external_links.dart';
import '../../../widgets/broadside/primitives.dart';
import '../../../widgets/broadside/project_folder.dart';

class BroadsideHero extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;
  final GlobalKey ctaKey;
  final VoidCallback onViewWork;
  const BroadsideHero({
    required this.data,
    required this.dark,
    required this.ctaKey,
    required this.onViewWork,
    super.key,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final settings = data.settings;
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final compact = constraints.maxWidth / textScale < 720;
      final titleSize = compact ? 43.0 : 68.0;
      final customTagline = data.jobPosting?.customTagline?.trim() ?? '';
      final customAbout = data.jobPosting?.customAbout?.trim() ?? '';
      final resume = resolveAssetUrl(
        settings.resumeUrl?.isNotEmpty == true
            ? settings.resumeUrl!
            : '/Jaynesh-Bhandari-Resume.pdf',
      );
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker('Backend / Web / Mobile', dark: dark),
          const SizedBox(height: 25),
          Semantics(
            header: true,
            child: customTagline.isNotEmpty
                ? Text(
                    customTagline,
                    style: BroadsideText.editorial(
                      size: titleSize,
                      color: Broadside.ink(dark),
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'I build apps.\n'),
                        TextSpan(
                          text: 'And their\nbackends.',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    style: BroadsideText.editorial(
                      size: titleSize,
                      height: 1.06,
                      color: Broadside.ink(dark),
                    ),
                  ),
          ),
          const SizedBox(height: 25),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              customAbout.isNotEmpty
                  ? customAbout
                  : data.tagline.isNotEmpty
                  ? data.tagline
                  : "I'm ${settings.name.split(' ').first}, a software developer. I build backend services and web and mobile applications.",
              style: BroadsideText.sans(
                size: 15,
                height: 1.8,
                color: Broadside.inkSoft(dark),
              ),
            ),
          ),
          if (settings.location.isNotEmpty ||
              settings.availability.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (settings.location.isNotEmpty)
                  Text(
                    'Based in ${settings.location}',
                    style: BroadsideText.sans(
                      size: 13,
                      color: Broadside.inkSoft(dark),
                    ),
                  ),
                if (settings.availability.isNotEmpty)
                  Text(
                    settings.availability,
                    style: BroadsideText.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: Broadside.ink(dark),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              if (settings.email.isNotEmpty)
                KeyedSubtree(
                  key: ctaKey,
                  child: BtnPrimary(
                    label: 'Email me ↗',
                    dark: dark,
                    href: 'mailto:${settings.email}',
                  ),
                ),
              TextButton(
                onPressed: onViewWork,
                style: TextButton.styleFrom(
                  foregroundColor: Broadside.ink(dark),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                ),
                child: const Text('View my projects ↓'),
              ),
              if (resume.isNotEmpty)
                BroadsideLink(label: 'Résumé ↗', href: resume, dark: dark),
            ],
          ),
        ],
      );
      final folder = ProjectFolder(
        dark: dark,
        onOpenProjects: onViewWork,
        initials: settings.initials.isEmpty
            ? settings.name
                  .split(' ')
                  .where((s) => s.isNotEmpty)
                  .take(2)
                  .map((s) => s[0])
                  .join()
            : settings.initials,
        titles: data.projects.map((p) => p.title).toList(),
      );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 35 : 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact) ...[
              copy,
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: folder,
                ),
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: copy),
                  const SizedBox(width: 40),
                  Expanded(flex: 5, child: folder),
                ],
              ),
          ],
        ),
      );
    },
  );
}
