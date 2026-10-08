import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';
import '../manual/sections/contact.dart';
import '../manual/sections/experience.dart';
import '../manual/sections/skills.dart';
import '../manual/sections/stats.dart';
import '../manual/sections/work.dart';

class AutomatedMode extends StatefulWidget {
  final String? jobId;
  const AutomatedMode({this.jobId, super.key});
  @override
  State<AutomatedMode> createState() => _AutomatedModeState();
}

class _AutomatedModeState extends State<AutomatedMode> {
  late Future<PortfolioViewData> _dataFuture;
  int _slide = 0;
  int _total = 1;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _slide = 0;
    _total = 1;
    _dataFuture = context.read<PortfolioService>().getPortfolioViewData(
      widget.jobId,
    );
  }

  @override
  void didUpdateWidget(covariant AutomatedMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId) {
      _slide = 0;
      _load();
    }
  }

  void _move(int by) =>
      setState(() => _slide = (_slide + by).clamp(0, _total - 1));
  void _exit() => context.read<ExperienceProvider>().reset();

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _move(1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _move(-1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          _exit();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ColoredBox(
        color: Broadside.paper(dark),
        child: SizedBox.expand(
          child: FutureBuilder<PortfolioViewData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Broadside.accent(dark),
                  ),
                );
              }
              if (snapshot.hasError || data == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'The tour could not load.',
                          style: BroadsideText.display(
                            height: 1.0,
                            letterSpacing: 0,
                            size: 32,
                            color: Broadside.ink(dark),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            BtnPrimary(
                              label: 'Try again',
                              dark: dark,
                              onTap: () => setState(_load),
                            ),
                            BtnGhost(
                              label: 'Back to experiences',
                              dark: dark,
                              onTap: _exit,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              final slides = <(String, Widget)>[
                ('Introduction', _TourIntro(data: data, dark: dark)),
                ...data.projects.map(
                  (p) => (p.title, BroadsideWork(projects: [p], dark: dark)),
                ),
                if (data.experiences.isNotEmpty)
                  (
                    'Experience',
                    BroadsideExperience(
                      experiences: data.experiences,
                      dark: dark,
                    ),
                  ),
                if (data.settings.skillGroups.isNotEmpty)
                  (
                    'Skills',
                    BroadsideSkills(settings: data.settings, dark: dark),
                  ),
                (
                  'Contact',
                  BroadsideContact(settings: data.settings, dark: dark),
                ),
              ];
              _total = slides.length;
              final current = slides[_slide.clamp(0, slides.length - 1)];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: _exit,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Experiences'),
                          style: TextButton.styleFrom(
                            foregroundColor: Broadside.ink(dark),
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          liveRegion: true,
                          child: Kicker('${_slide + 1} / $_total', dark: dark),
                        ),
                        const SizedBox(width: 8),
                        ThemeToggleButton(
                          dark: dark,
                          onToggle: () =>
                              context.read<ThemeProvider>().toggleTheme(),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: (_slide + 1) / _total,
                    minHeight: 2,
                    color: Broadside.accent(dark),
                    backgroundColor: Broadside.rule(dark),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(_slide),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: current.$2,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Previous slide',
                            onPressed: _slide > 0 ? () => _move(-1) : null,
                            icon: const Icon(Icons.arrow_back),
                            color: Broadside.ink(dark),
                          ),
                          Expanded(
                            child: Text(
                              current.$1,
                              textAlign: TextAlign.center,
                              style: BroadsideText.sans(
                                size: 14,
                                color: Broadside.inkSoft(dark),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: _slide == _total - 1
                                ? 'Finish tour'
                                : 'Next slide',
                            onPressed: _slide == _total - 1
                                ? _exit
                                : () => _move(1),
                            icon: Icon(
                              _slide == _total - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                            ),
                            color: Broadside.ink(dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TourIntro extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;
  const _TourIntro({required this.data, required this.dark});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 30),
      Kicker(data.settings.role, dark: dark),
      const SizedBox(height: 20),
      Text(
        data.settings.name,
        style: BroadsideText.display(
          letterSpacing: 0,
          size: MediaQuery.sizeOf(context).width < 760 ? 46 : 72,
          color: Broadside.ink(dark),
          height: 1.1,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        data.tagline,
        style: BroadsideText.display(
          letterSpacing: 0,
          size: 30,
          color: Broadside.accent(dark),
          height: 1.2,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        data.about.isEmpty ? data.settings.summary : data.about,
        style: BroadsideText.sans(size: 17, color: Broadside.inkSoft(dark)),
      ),
      const SizedBox(height: 32),
      BroadsideStats(settings: data.settings, dark: dark),
      const SizedBox(height: 24),
      Text(
        'Use the arrows to explore. Scroll on any slide to read more.',
        style: BroadsideText.sans(size: 14, color: Broadside.inkSoft(dark)),
      ),
    ],
  );
}
