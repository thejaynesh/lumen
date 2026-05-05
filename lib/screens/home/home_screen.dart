import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/portfolio_data.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/experience_provider.dart';
import '../../providers/narrator_provider.dart';

// Sections
import 'sections/hero_section.dart';
import 'sections/projects_section.dart';
import 'sections/experience_section.dart';
import 'sections/skills_section.dart';
import 'sections/contact_section.dart';
import 'sections/footer_section.dart';

// Widgets
import 'widgets/background_glow.dart';
import 'widgets/theme_toggle.dart';
import 'widgets/narrator_progress_bar.dart';
import 'widgets/narrator_floating_controls.dart';

// Utils
import 'utils/mock_data.dart';

class HomeScreen extends StatefulWidget {
  final String? jobId;
  const HomeScreen({super.key, this.jobId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<PortfolioViewData> _dataFuture;
  double _scrollOffset = 0;

  // Section anchor keys, used by the narrator to scroll to each section.
  // Footer is intentionally excluded (transient sign-off, not a narration step).
  final GlobalKey _heroKey = GlobalKey(debugLabel: 'narrator-hero');
  final GlobalKey _projectsKey = GlobalKey(debugLabel: 'narrator-projects');
  final GlobalKey _experienceKey = GlobalKey(debugLabel: 'narrator-experience');
  final GlobalKey _skillsKey = GlobalKey(debugLabel: 'narrator-skills');
  final GlobalKey _contactKey = GlobalKey(debugLabel: 'narrator-contact');

  ExperienceMode? _lastBootedMode;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  void _loadData() {
    final service = context.read<PortfolioService>();
    _dataFuture = service.getPortfolioViewData(widget.jobId);
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jobId != oldWidget.jobId) {
      setState(() => _loadData());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Boot or tear down narrator based on selected experience mode.
  void _syncNarrator(ExperienceMode mode, bool hasContent) {
    final narrator = context.read<NarratorProvider>();
    if (mode == _lastBootedMode) return;
    _lastBootedMode = mode;

    if (mode == ExperienceMode.narrator && hasContent) {
      narrator.registerSections([
        NarratorSection(
          id: 'hero',
          label: 'Hello',
          duration: const Duration(seconds: 7),
          key: _heroKey,
        ),
        NarratorSection(
          id: 'projects',
          label: 'Selected Work',
          duration: const Duration(seconds: 12),
          key: _projectsKey,
        ),
        NarratorSection(
          id: 'experience',
          label: 'Experience',
          duration: const Duration(seconds: 12),
          key: _experienceKey,
        ),
        NarratorSection(
          id: 'skills',
          label: 'Skills',
          duration: const Duration(seconds: 6),
          key: _skillsKey,
        ),
        NarratorSection(
          id: 'contact',
          label: 'Get in Touch',
          duration: const Duration(seconds: 5),
          key: _contactKey,
        ),
      ]);
      // Defer start until after first frame so section keys have contexts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        narrator.start();
      });
    } else {
      narrator.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final experienceProvider = context.watch<ExperienceProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.background(isDark),
      body: Stack(
        children: [
          // Visual background (non-interactive).
          BackgroundGlow(scrollOffset: _scrollOffset, isDark: isDark),

          // Main scrollable content. Wrapped in IgnorePointer when in
          // narrator mode so user input cannot fight the auto-flow.
          Consumer<NarratorProvider>(
            builder: (context, narrator, child) {
              return IgnorePointer(
                ignoring: narrator.isActive,
                child: child!,
              );
            },
            child: FutureBuilder<PortfolioViewData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final data = (snapshot.hasError || snapshot.data == null)
                    ? MockPortfolioData.getMockData()
                    : snapshot.data!;

                if (snapshot.hasError) {
                  debugPrint('Error loading portfolio: ${snapshot.error}');
                }

                // Sync narrator to selected mode now that data is ready.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _syncNarrator(experienceProvider.mode, true);
                });

                return _buildContent(data, isDark);
              },
            ),
          ),

          // Always-interactive overlays (must remain outside the IgnorePointer).
          ThemeToggleButton(themeProvider: themeProvider, isDark: isDark),
          _buildModeIndicator(experienceProvider, isDark),
          NarratorProgressBar(isDark: isDark),
          NarratorFloatingControls(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildModeIndicator(ExperienceProvider provider, bool isDark) {
    Color modeColor;
    switch (provider.mode) {
      case ExperienceMode.narrator:
        modeColor = const Color(0xFF0066FF);
        break;
      case ExperienceMode.fun:
        modeColor = const Color(0xFFFF6B35);
        break;
      case ExperienceMode.manual:
        modeColor = const Color(0xFF00D9A4);
        break;
    }

    return Positioned(
      top: 20,
      left: 20,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Going back to selector — make sure narrator is torn down first.
            context.read<NarratorProvider>().stop();
            provider.reset();
            _lastBootedMode = null;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: modeColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.getModeIcon(provider.mode),
                  size: 18,
                  color: modeColor,
                ),
                const SizedBox(width: 8),
                Text(
                  provider.getModeName(provider.mode),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(isDark),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 16,
                  color: AppTheme.textSecondary(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PortfolioViewData data, bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: _heroKey,
            child: HeroSection(
              data: data,
              isDark: isDark,
              scrollOffset: _scrollOffset,
            ),
          ),
        ),
        if (data.projects.isNotEmpty)
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _projectsKey,
              child: ProjectsSection(
                projects: data.projects,
                isDark: isDark,
                scrollOffset: _scrollOffset,
                screenHeight: screenHeight,
              ),
            ),
          ),
        if (data.experiences.isNotEmpty)
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _experienceKey,
              child: ExperienceSection(
                experiences: data.experiences,
                isDark: isDark,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: _skillsKey,
            child: SkillsSection(settings: data.settings, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: _contactKey,
            child: ContactSection(settings: data.settings, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(child: FooterSection(isDark: isDark)),
      ],
    );
  }
}
