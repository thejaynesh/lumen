import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';

class ModeSelectorScreen extends StatefulWidget {
  const ModeSelectorScreen({super.key});
  @override
  State<ModeSelectorScreen> createState() => _ModeSelectorScreenState();
}

class _ModeSelectorScreenState extends State<ModeSelectorScreen> {
  late Future<PortfolioSettings> _settings;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _settings = context.read<PortfolioService>().getSettings();
  }

  void _readPortfolio() => context.go(
    Uri(
      path: '/',
      queryParameters: GoRouterState.of(context).uri.queryParameters,
    ).toString(),
  );

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return ColoredBox(
      color: Broadside.paper(dark),
      child: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 20 : 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _readPortfolio,
                            style: TextButton.styleFrom(
                              foregroundColor: Broadside.ink(dark),
                            ),
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Portfolio'),
                          ),
                        ),
                      ),
                      ThemeToggleButton(
                        dark: dark,
                        onToggle: () =>
                            context.read<ThemeProvider>().toggleTheme(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  Kicker('Choose your pace', dark: dark),
                  const SizedBox(height: 18),
                  Text(
                    'A few ways to get to know me.',
                    style: BroadsideText.display(
                      letterSpacing: 0,
                      size: compact ? 42 : 64,
                      height: 1.1,
                      color: Broadside.ink(dark),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<PortfolioSettings>(
                    future: _settings,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Text(
                              'The profile could not load.',
                              style: BroadsideText.sans(
                                color: Broadside.inkSoft(dark),
                              ),
                            ),
                            BtnGhost(
                              label: 'Retry',
                              dark: dark,
                              onTap: () => setState(_load),
                            ),
                          ],
                        );
                      }
                      return Text(
                        snapshot.data?.name ?? 'Portfolio',
                        style: BroadsideText.sans(
                          size: 18,
                          color: Broadside.inkSoft(dark),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = <Widget>[
                        _ModeCard(
                          title: 'Read the portfolio',
                          caption: 'At your own pace',
                          icon: Icons.article_outlined,
                          description:
                              'Projects, experience, background, and contact details in one place.',
                          dark: dark,
                          onTap: _readPortfolio,
                        ),
                        _ModeCard(
                          title: 'Take the tour',
                          caption: 'A guided presentation',
                          icon: Icons.slideshow_outlined,
                          description:
                              'Move through the work one project at a time. Use the arrows or your keyboard.',
                          dark: dark,
                          onTap: () => context
                              .read<ExperienceProvider>()
                              .setMode(ExperienceMode.automated),
                        ),
                        _ModeCard(
                          title: 'Beyond the résumé',
                          caption: 'A little personality',
                          icon: Icons.auto_awesome_outlined,
                          description:
                              'A short quiz and the interests behind the work. Entirely optional.',
                          dark: dark,
                          onTap: () => context
                              .read<ExperienceProvider>()
                              .setMode(ExperienceMode.lucky),
                        ),
                      ];
                      if (constraints.maxWidth >= 920) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cards.indexed
                              .expand(
                                (e) => <Widget>[
                                  if (e.$1 > 0) const SizedBox(width: 18),
                                  Expanded(child: e.$2),
                                ],
                              )
                              .toList(),
                        );
                      }
                      return Column(
                        children: cards
                            .map(
                              (card) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: card,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, caption, description;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  const _ModeCard({
    required this.title,
    required this.caption,
    required this.description,
    required this.icon,
    required this.dark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Broadside.ink(dark),
        padding: const EdgeInsets.all(24),
        shape: const RoundedRectangleBorder(),
        side: BorderSide(color: Broadside.rule(dark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Broadside.accent(dark)),
          const SizedBox(height: 22),
          Kicker(caption, dark: dark),
          const SizedBox(height: 12),
          Text(
            title,
            style: BroadsideText.display(
              height: 1.0,
              letterSpacing: 0,
              size: 32,
              color: Broadside.ink(dark),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: BroadsideText.sans(size: 15, color: Broadside.inkSoft(dark)),
          ),
          const SizedBox(height: 24),
          Text(
            'Explore →',
            style: BroadsideText.sans(size: 15, color: Broadside.accent(dark)),
          ),
        ],
      ),
    ),
  );
}
