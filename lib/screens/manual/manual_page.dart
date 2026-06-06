// Broadside Manual Mode — full portfolio page.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import 'sections/awards.dart';
import 'sections/certifications.dart';
import 'sections/contact.dart';
import 'sections/education.dart';
import 'sections/experience.dart';
import 'sections/floating_cta.dart';
import 'sections/hero.dart';
import 'sections/nav.dart';
import 'sections/skills.dart';
import 'sections/stats.dart';
import 'sections/work.dart';

class ManualPage extends StatefulWidget {
  final String? jobId;
  const ManualPage({super.key, this.jobId});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  late final ScrollController _scroll;
  late final Future<PortfolioViewData> _dataFuture;

  // Section anchor keys
  final _workKey = GlobalKey();
  final _experienceKey = GlobalKey();
  final _awardsKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _educationKey = GlobalKey();
  final _certificationsKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _heroCtaKey = GlobalKey();

  bool _scrolled = false;
  bool _ctaVisible = false;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    // Read service via context in initState (safe because we use read, not watch)
    _dataFuture = context.read<PortfolioService>().getPortfolioViewData(widget.jobId);
  }

  void _onScroll() {
    final newScrolled = _scroll.hasClients && _scroll.offset > 40;

    // Determine if hero CTA has scrolled out of view
    bool newCtaVisible = false;
    final heroCtaCtx = _heroCtaKey.currentContext;
    if (heroCtaCtx != null) {
      final box = heroCtaCtx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final dy = box.localToGlobal(Offset.zero).dy;
        newCtaVisible = dy + box.size.height < 0;
      }
    }

    if (newScrolled != _scrolled || newCtaVisible != _ctaVisible) {
      setState(() {
        _scrolled = newScrolled;
        _ctaVisible = newCtaVisible;
      });
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;

    return AnimatedContainer(
      duration: Broadside.themeAnim,
      color: Broadside.paper(dark),
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          // ── Scrollable content (fills the stack so the scroll view gets a
          // bounded height; a non-positioned child would get loose 0-min
          // constraints and collapse). ──
          Positioned.fill(
            child: FutureBuilder<PortfolioViewData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final PortfolioViewData data;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Broadside.accent(dark),
                    strokeWidth: 2,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                data = PortfolioViewData(
                  settings: PortfolioSettings.empty(),
                  projects: const [],
                  experiences: const [],
                );
              } else {
                data = snapshot.data!;
              }

              final settings = data.settings;

              return SingleChildScrollView(
                controller: _scroll,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Broadside.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Broadside.pagePad,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero (top 120px clears fixed nav)
                          BroadsideHero(
                            data: data,
                            dark: dark,
                            ctaKey: _heroCtaKey,
                            onViewWork: () => _scrollTo(_workKey),
                            onContact: () => _scrollTo(_contactKey),
                          ),
                          // Stats strip
                          BroadsideStats(settings: settings, dark: dark),
                          // § 01 Experience
                          KeyedSubtree(
                            key: _experienceKey,
                            child: BroadsideExperience(
                              experiences: data.experiences,
                              dark: dark,
                            ),
                          ),
                          // § 02 Projects (with "Currently" sub-block)
                          KeyedSubtree(
                            key: _workKey,
                            child: BroadsideWork(
                              projects: data.projects,
                              now: settings.now,
                              dark: dark,
                            ),
                          ),
                          // § 03 Education
                          KeyedSubtree(
                            key: _educationKey,
                            child: BroadsideEducation(
                              education: settings.education,
                              dark: dark,
                            ),
                          ),
                          // § 04 Skills
                          KeyedSubtree(
                            key: _skillsKey,
                            child: BroadsideSkills(
                              settings: settings,
                              dark: dark,
                            ),
                          ),
                          // § 05 Awards
                          KeyedSubtree(
                            key: _awardsKey,
                            child: BroadsideAwards(
                              awards: settings.awards,
                              dark: dark,
                            ),
                          ),
                          // § 06 Certifications
                          KeyedSubtree(
                            key: _certificationsKey,
                            child: BroadsideCertifications(
                              certifications: settings.certifications,
                              dark: dark,
                            ),
                          ),
                          // Contact / Footer
                          KeyedSubtree(
                            key: _contactKey,
                            child: BroadsideContact(
                              settings: settings,
                              dark: dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ),

          // ── Fixed Nav ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FutureBuilder<PortfolioViewData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                final name = snapshot.data?.settings.name ?? '';
                return BroadsideNav(
                  dark: dark,
                  scrolled: _scrolled,
                  name: name,
                  onWork: () => _scrollTo(_workKey),
                  onExperience: () => _scrollTo(_experienceKey),
                  onAwards: () => _scrollTo(_awardsKey),
                  onSkills: () => _scrollTo(_skillsKey),
                  onEducation: () => _scrollTo(_educationKey),
                  onCertifications: () => _scrollTo(_certificationsKey),
                  onContact: () => _scrollTo(_contactKey),
                  onToggle: () => context.read<ThemeProvider>().toggleTheme(),
                  onHome: () => context.read<ExperienceProvider>().reset(),
                );
              },
            ),
          ),

          // ── Floating CTA ──
          Positioned(
            bottom: 28,
            right: 28,
            child: FutureBuilder<PortfolioViewData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                final email = snapshot.data?.settings.email ?? '';
                return FloatingCTA(
                  dark: dark,
                  email: email,
                  visible: _ctaVisible,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
