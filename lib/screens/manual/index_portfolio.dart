import 'package:flutter/material.dart';
import '../../models/portfolio_data.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';
import 'sections/hero.dart';
import 'sections/work.dart';
import 'sections/experience.dart';
import 'sections/education.dart';
import 'sections/skills.dart';
import 'sections/awards.dart';
import 'sections/certifications.dart';
import 'sections/contact.dart';
import 'sections/stats.dart';
import 'sections/floating_cta.dart';

class IndexPortfolio extends StatefulWidget {
  const IndexPortfolio({
    super.key,
    required this.data,
    required this.dark,
    required this.onToggleTheme,
  });
  final PortfolioViewData data;
  final bool dark;
  final VoidCallback onToggleTheme;
  @override
  State<IndexPortfolio> createState() => _IndexPortfolioState();
}

class _IndexPortfolioState extends State<IndexPortfolio> {
  final _scroll = ScrollController();
  final _work = GlobalKey();
  final _experience = GlobalKey();
  final _contact = GlobalKey();
  final _heroCta = GlobalKey();
  final _viewport = GlobalKey();
  final _floatingContact = ValueNotifier(false);
  bool _contactUpdatePending = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scheduleContactUpdate);
  }

  void _scheduleContactUpdate() {
    if (_contactUpdatePending) return;
    _contactUpdatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contactUpdatePending = false;
      if (!mounted) return;
      final hero = _heroCta.currentContext?.findRenderObject();
      final viewport = _viewport.currentContext?.findRenderObject();
      final contact = _contact.currentContext?.findRenderObject();
      var visible = false;
      if (widget.data.settings.email.isNotEmpty &&
          hero is RenderBox &&
          viewport is RenderBox &&
          hero.hasSize &&
          viewport.hasSize) {
        final top = viewport.localToGlobal(Offset.zero).dy;
        final heroBottom = hero.localToGlobal(Offset(0, hero.size.height)).dy;
        final contactVisible =
            contact is RenderBox &&
            contact.hasSize &&
            contact.localToGlobal(Offset.zero).dy <
                top + viewport.size.height - 80;
        visible = heroBottom <= top && !contactVisible;
      }
      _floatingContact.value = visible;
    });
  }

  void _navigate(GlobalKey? key) {
    if (!_scroll.hasClients) return;
    var target = 0.0;
    if (key != null) {
      final box = key.currentContext?.findRenderObject();
      final viewport = _viewport.currentContext?.findRenderObject();
      if (box is! RenderBox || viewport is! RenderBox) return;
      target =
          (_scroll.offset +
                  box.localToGlobal(Offset.zero).dy -
                  viewport.localToGlobal(Offset.zero).dy -
                  24)
              .clamp(0.0, _scroll.position.maxScrollExtent);
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
      _scheduleContactUpdate();
      return;
    }
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scroll.removeListener(_scheduleContactUpdate);
    _scroll.dispose();
    _floatingContact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final data = widget.data;
    final settings = data.settings;
    return ColoredBox(
      color: Broadside.paper(dark),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _scheduleContactUpdate();
          final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
          final wide = constraints.maxWidth / textScale >= 850;
          final pad = wide ? 48.0 : 22.0;
          Widget inset(Widget child) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: child,
              ),
            ),
          );
          final nav = <String, GlobalKey>{
            'Projects': _work,
            'Experience': _experience,
            'Contact': _contact,
          };
          return NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              _scheduleContactUpdate();
              return false;
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Broadside.paper(dark),
                        border: Border(
                          bottom: BorderSide(color: Broadside.rule(dark)),
                        ),
                      ),
                      child: inset(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () => _navigate(null),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      foregroundColor: Broadside.ink(dark),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          settings.name,
                                          style: BroadsideText.editorial(
                                            size: wide ? 29 : 23,
                                            color: Broadside.ink(dark),
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Kicker(
                                          settings.role.isEmpty
                                              ? 'Software developer'
                                              : settings.role,
                                          dark: dark,
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (wide)
                                ...nav.entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: TextButton(
                                      onPressed: () => _navigate(e.value),
                                      child: Text(
                                        e.key,
                                        style: BroadsideText.sans(
                                          size: 13,
                                          color: Broadside.ink(dark),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              IconButton(
                                tooltip: dark
                                    ? 'Switch to light theme'
                                    : 'Switch to dark theme',
                                onPressed: widget.onToggleTheme,
                                icon: Icon(
                                  dark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  size: 20,
                                ),
                              ),
                              if (!wide)
                                PopupMenuButton<String>(
                                  tooltip: 'Open navigation',
                                  icon: Icon(
                                    Icons.menu,
                                    color: Broadside.ink(dark),
                                  ),
                                  onSelected: (value) => _navigate(nav[value]),
                                  itemBuilder: (_) => nav.keys
                                      .map(
                                        (name) => PopupMenuItem(
                                          value: name,
                                          child: Text(name),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          key: _viewport,
                          controller: _scroll,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              inset(
                                BroadsideHero(
                                  data: data,
                                  dark: dark,
                                  ctaKey: _heroCta,
                                  onViewWork: () => _navigate(_work),
                                ),
                              ),
                              inset(
                                KeyedSubtree(
                                  key: _work,
                                  child: BroadsideWork(
                                    projects: data.projects,
                                    dark: dark,
                                  ),
                                ),
                              ),
                              inset(
                                BroadsideStats(settings: settings, dark: dark),
                              ),
                              Container(
                                key: _experience,
                                margin: const EdgeInsets.only(top: 35),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 35,
                                ),
                                color: Broadside.paperDeep(dark),
                                child: inset(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Kicker(
                                        'Professional experience',
                                        dark: dark,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'Where I’ve worked.',
                                        style: BroadsideText.editorial(
                                          size: wide ? 46 : 34,
                                          color: Broadside.ink(dark),
                                        ),
                                      ),
                                      BroadsideExperience(
                                        experiences: data.experiences,
                                        dark: dark,
                                        showHeading: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              inset(
                                Padding(
                                  padding: const EdgeInsets.only(top: 35),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (data.about.trim().isNotEmpty) ...[
                                        SectionHead(
                                          number: '03',
                                          title: 'Background & toolkit',
                                          sub: 'Software development',
                                          dark: dark,
                                        ),
                                        Text(
                                          data.about,
                                          style: BroadsideText.sans(
                                            size: 16,
                                            color: Broadside.inkSoft(dark),
                                          ),
                                        ),
                                      ],
                                      if (settings.skillGroups.isNotEmpty)
                                        BroadsideSkills(
                                          settings: settings,
                                          dark: dark,
                                        ),
                                      if (settings.education.isNotEmpty)
                                        BroadsideEducation(
                                          education: settings.education,
                                          dark: dark,
                                        ),
                                      BroadsideCertifications(
                                        certifications: settings.certifications,
                                        dark: dark,
                                      ),
                                      BroadsideAwards(
                                        awards: settings.awards,
                                        dark: dark,
                                      ),
                                      if (settings.now.isNotEmpty) ...[
                                        SectionHead(
                                          number: '',
                                          title: 'Current focus',
                                          sub: 'Now',
                                          dark: dark,
                                          compact: true,
                                        ),
                                        for (final item in settings.now)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: Text(
                                              item,
                                              style: BroadsideText.sans(
                                                color: Broadside.inkSoft(dark),
                                              ),
                                            ),
                                          ),
                                      ],
                                      KeyedSubtree(
                                        key: _contact,
                                        child: BroadsideContact(
                                          settings: settings,
                                          dark: dark,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _navigate(null),
                                        child: const Text('Back to top ↑'),
                                      ),
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _scroll,
                      builder: (context, _) {
                        final progress =
                            _scroll.hasClients &&
                                _scroll.position.hasContentDimensions &&
                                _scroll.position.maxScrollExtent > 0
                            ? (_scroll.offset /
                                      _scroll.position.maxScrollExtent)
                                  .clamp(0.0, 1.0)
                            : 0.0;
                        return SizedBox(
                          height: 3,
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 3,
                              width: constraints.maxWidth * progress,
                              color: Broadside.accent(dark),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  right: wide ? 32 : 16,
                  // Firebase's local auth notice sits above the Flutter canvas.
                  bottom:
                      const String.fromEnvironment(
                            'APP_ENV',
                            defaultValue: 'emulator',
                          ) ==
                          'emulator'
                      ? (wide ? 48 : 76)
                      : 20,
                  child: SafeArea(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _floatingContact,
                      builder: (context, visible, _) => FloatingCTA(
                        dark: dark,
                        email: settings.email,
                        visible: visible,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
