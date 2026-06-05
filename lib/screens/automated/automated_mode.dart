// Automated mode — fullscreen 10-slide Broadside deck.
// Arrow keys / Space / click-anywhere advances; Esc exits to selector.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';

// ---------------------------------------------------------------------------
// AutomatedMode
// ---------------------------------------------------------------------------

class AutomatedMode extends StatefulWidget {
  const AutomatedMode({super.key});

  @override
  State<AutomatedMode> createState() => _AutomatedModeState();
}

class _AutomatedModeState extends State<AutomatedMode> {
  static const _total = 10;
  int _slide = 0;
  late Future<PortfolioViewData> _dataFuture;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _dataFuture =
          context.read<PortfolioService>().getPortfolioViewData(null);
    }
  }

  void _next() {
    setState(() => _slide = (_slide + 1).clamp(0, _total - 1));
  }

  void _prev() {
    setState(() => _slide = (_slide - 1).clamp(0, _total - 1));
  }

  void _exit() {
    context.read<ExperienceProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    final accent = Broadside.accent(dark);
    final ink = Broadside.ink(dark);
    final rule = Broadside.rule(dark);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.space) {
          _next();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _prev();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          _exit();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: FutureBuilder<PortfolioViewData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          return Container(
            color: Broadside.paper(dark),
            constraints: const BoxConstraints.expand(),
            child: Stack(
              children: [
                // ── Stage (tap-to-advance layer, bottommost) ──────────────
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 60),
                      child: Center(
                        child: snapshot.connectionState ==
                                ConnectionState.done
                            ? (snapshot.hasData
                                ? _buildSlide(
                                    _slide, snapshot.data!, dark)
                                : Center(
                                    child: Text(
                                      'Failed to load data.',
                                      style: BroadsideText.sans(
                                          color: Broadside.inkSoft(dark)),
                                    ),
                                  ))
                            : CircularProgressIndicator(color: accent),
                      ),
                    ),
                  ),
                ),

                // ── Progress bar (top, 3 px) ──────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: rule,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        widthFactor: (_slide + 1) / _total,
                        heightFactor: 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: Container(color: accent),
                      ),
                    ),
                  ),
                ),

                // ── Top chrome (slide counter + hints + EXIT) ─────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Kicker(
                          '${(_slide + 1).toString().padLeft(2, '0')} / $_total',
                          dark: dark,
                        ),
                        Row(
                          children: [
                            Kicker(
                              '← → to navigate · ESC to exit',
                              dark: dark,
                            ),
                            const SizedBox(width: 12),
                            // EXIT button — GestureDetector on top of stage,
                            // Flutter hit-testing stops here.
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _exit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: rule),
                                ),
                                child: Text(
                                  'EXIT ×',
                                  style: BroadsideText.mono(
                                    size: 10,
                                    color: ink,
                                    trackingEm: 0.16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Left arrow ────────────────────────────────────────────
                if (_slide > 0)
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _prev,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: rule),
                          ),
                          child: Center(
                            child: Text(
                              '←',
                              style: BroadsideText.serif(
                                  size: 24, color: ink),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Right arrow ───────────────────────────────────────────
                if (_slide < _total - 1)
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _next,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: rule),
                          ),
                          child: Center(
                            child: Text(
                              '→',
                              style: BroadsideText.serif(
                                  size: 24, color: ink),
                            ),
                          ),
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

  // -------------------------------------------------------------------------
  // Slide dispatcher
  // -------------------------------------------------------------------------

  Widget _buildSlide(int i, PortfolioViewData data, bool dark) {
    switch (i) {
      case 0:
        return _SlideIntro(data: data, dark: dark);
      case 1:
        return _SlideAbout(data: data, dark: dark);
      case 2:
        return _SlideStats(data: data, dark: dark);
      case 3:
      case 4:
      case 5:
      case 6:
        return _SlideProject(idx: i - 3, data: data, dark: dark);
      case 7:
        return _SlideExperience(data: data, dark: dark);
      case 8:
        return _SlideSkills(data: data, dark: dark);
      case 9:
        return _SlideContact(data: data, dark: dark);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Slide 0 — Intro
// ---------------------------------------------------------------------------

class _SlideIntro extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideIntro({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final s = data.settings;
    final ink = Broadside.ink(dark);
    final inkSoft = Broadside.inkSoft(dark);
    final accent = Broadside.accent(dark);

    // Split name into two lines: first token uppercase, rest italic + '.'
    final parts = s.name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first.toUpperCase() : '';
    final rest = parts.length > 1
        ? parts.sublist(1).join(' ').toUpperCase()
        : '';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Kicker('№ 001 · PORTFOLIO PRESENTATION', dark: dark),
          const SizedBox(height: 20),
          // Name — two lines
          Column(
            children: [
              Text(
                firstName,
                style: BroadsideText.serif(
                  size: 130,
                  color: ink,
                  height: 0.88,
                  letterSpacing: -0.04,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${rest.isNotEmpty ? rest : s.name.toUpperCase()}.',
                style: BroadsideText.serif(
                  size: 130,
                  color: ink,
                  height: 0.88,
                  letterSpacing: -0.04,
                  style: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '${s.role} · Full-Stack · ${s.location}',
            style: BroadsideText.sans(size: 18, color: inkSoft),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Kicker(
            'CLICK OR PRESS → TO BEGIN',
            dark: dark,
            color: accent,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 1 — About
// ---------------------------------------------------------------------------

class _SlideAbout extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideAbout({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final s = data.settings;
    final ink = Broadside.ink(dark);
    final inkSoft = Broadside.inkSoft(dark);
    final accent = Broadside.accent(dark);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker('01 · ABOUT', dark: dark),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: BroadsideText.serif(
                size: 52,
                color: ink,
                height: 1.1,
                letterSpacing: -0.02,
              ),
              children: [
                const TextSpan(text: 'A '),
                TextSpan(
                  text: 'software engineer',
                  style: BroadsideText.serif(
                    size: 52,
                    color: accent,
                    height: 1.1,
                    letterSpacing: -0.02,
                    style: FontStyle.italic,
                  ),
                ),
                const TextSpan(
                  text:
                      ' who builds back-end systems, wins hackathons, and ships full-stack products.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              s.summary,
              style: BroadsideText.sans(
                size: 18,
                color: inkSoft,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 2 — Stats / Key Numbers
// ---------------------------------------------------------------------------

class _SlideStats extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideStats({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final s = data.settings;
    final ink = Broadside.ink(dark);
    final inkSoft = Broadside.inkSoft(dark);
    final accent = Broadside.accent(dark);
    final accentInk = Broadside.accentInk(dark);
    final rule = Broadside.rule(dark);
    final highlights = s.highlights;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker('02 · KEY NUMBERS', dark: dark),
          const SizedBox(height: 24),
          if (highlights.isEmpty)
            Text('No highlights yet.',
                style: BroadsideText.sans(color: inkSoft))
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: rule),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(highlights.length, (i) {
                    final h = highlights[i];
                    final isFirst = i == 0;
                    final isLast = i == highlights.length - 1;
                    final cellBg =
                        isFirst ? accent : Colors.transparent;
                    final labelColor = isFirst ? accentInk : inkSoft;
                    final valueColor = isFirst ? accentInk : ink;
                    final noteColor = isFirst ? accentInk : inkSoft;

                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 36),
                        decoration: BoxDecoration(
                          color: cellBg,
                          border: isLast
                              ? null
                              : Border(
                                  right: BorderSide(color: rule),
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: Kicker(
                                h.label,
                                dark: dark,
                                color: labelColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              h.value,
                              style: BroadsideText.serif(
                                size: 72,
                                color: valueColor,
                                height: 1.0,
                              ),
                            ),
                            if (h.note.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: 0.7,
                                child: Text(
                                  h.note,
                                  style: BroadsideText.sans(
                                    size: 14,
                                    color: noteColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slides 3–6 — Project (idx 0–3)
// ---------------------------------------------------------------------------

class _SlideProject extends StatelessWidget {
  final int idx;
  final PortfolioViewData data;
  final bool dark;

  const _SlideProject(
      {required this.idx, required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final ink = Broadside.ink(dark);
    final inkSoft = Broadside.inkSoft(dark);
    final accent = Broadside.accent(dark);

    if (idx >= data.projects.length) {
      return Center(
        child: Text(
          'More work soon.',
          style: BroadsideText.serif(size: 48, color: inkSoft),
        ),
      );
    }

    final p = data.projects[idx];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big index number
          SizedBox(
            width: 100,
            child: Text(
              '0${idx + 1}',
              style: BroadsideText.serif(
                size: 100,
                color: accent,
                height: 0.85,
                letterSpacing: -0.04,
              ),
            ),
          ),
          const SizedBox(width: 40),
          // Content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag + KPI row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (p.tag.isNotEmpty) Kicker(p.tag, dark: dark),
                    if (p.tag.isNotEmpty && p.kpi.isNotEmpty)
                      const SizedBox(width: 16),
                    if (p.kpi.isNotEmpty)
                      Kicker('↳ ${p.kpi}', dark: dark, color: accent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  p.title,
                  style: BroadsideText.serif(
                    size: 52,
                    color: ink,
                    height: 1.0,
                    letterSpacing: -0.02,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(
                    p.description,
                    style: BroadsideText.sans(
                      size: 17,
                      color: inkSoft,
                      height: 1.6,
                    ),
                  ),
                ),
                if (p.techStack.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.techStack
                        .map((t) => BroadTag(t, dark: dark))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                ImagePlaceholder(
                  aspect: 16 / 7,
                  label: 'FIG. 0${idx + 1} · ${p.title.toUpperCase()}',
                  dark: dark,
                  imageUrl: p.imageUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 7 — Experience
// ---------------------------------------------------------------------------

class _SlideExperience extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideExperience({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final ink = Broadside.ink(dark);
    final inkSoft = Broadside.inkSoft(dark);
    final accent = Broadside.accent(dark);
    final rule = Broadside.rule(dark);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker('07 · EXPERIENCE', dark: dark),
          const SizedBox(height: 24),
          Text(
            'Where the time went.',
            style: BroadsideText.serif(
              size: 48,
              color: ink,
              height: 1.0,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 28),
          ...data.experiences.map((e) => Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: rule)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        e.period,
                        style: BroadsideText.serif(
                          size: 22,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: BroadsideText.serif(
                                size: 22,
                                color: ink,
                              ),
                              children: [
                                TextSpan(text: '${e.role}, '),
                                TextSpan(
                                  text: e.company,
                                  style: BroadsideText.serif(
                                    size: 22,
                                    color: inkSoft,
                                    style: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.description,
                            style: BroadsideText.sans(
                              size: 14,
                              color: inkSoft,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 8 — Skills
// ---------------------------------------------------------------------------

class _SlideSkills extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideSkills({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final s = data.settings;
    final ink = Broadside.ink(dark);
    final accent = Broadside.accent(dark);
    final rule = Broadside.rule(dark);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker('08 · STACK', dark: dark),
          const SizedBox(height: 24),
          Text(
            'What I reach for.',
            style: BroadsideText.serif(
              size: 48,
              color: ink,
              height: 1.0,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 28),
          ...s.skillGroups.map((sg) => Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: rule)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Kicker(sg.category, dark: dark),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sg.items
                            .map((t) => BroadTag(t, dark: dark))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              )),
          if (s.awards.isNotEmpty) ...[
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: rule)),
              ),
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('Awards', dark: dark),
                  const SizedBox(height: 12),
                  ...s.awards.map((a) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              '★',
                              style: BroadsideText.serif(
                                size: 14,
                                color: accent,
                                style: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              a,
                              style: BroadsideText.sans(
                                  size: 14, color: ink),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 9 — Contact
// ---------------------------------------------------------------------------

class _SlideContact extends StatelessWidget {
  final PortfolioViewData data;
  final bool dark;

  const _SlideContact({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    final s = data.settings;
    final ink = Broadside.ink(dark);
    final accent = Broadside.accent(dark);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Kicker("09 · LET'S TALK", dark: dark),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: BroadsideText.serif(
                size: 64,
                color: ink,
                height: 1.0,
                letterSpacing: -0.02,
              ),
              children: [
                const TextSpan(text: 'Interested?\n'),
                TextSpan(
                  text: "Let's build something.",
                  style: BroadsideText.serif(
                    size: 64,
                    color: accent,
                    height: 1.0,
                    letterSpacing: -0.02,
                    style: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('mailto:${s.email}')),
            child: Container(
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accent, width: 2),
                ),
              ),
              child: Text(
                s.email,
                style: BroadsideText.serif(
                  size: 36,
                  color: ink,
                  style: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Kicker(
            [
              if (s.phone.isNotEmpty) s.phone,
              if (s.linkedin != null && s.linkedin!.isNotEmpty) s.linkedin!,
            ].join(' · '),
            dark: dark,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              BtnPrimary(
                label: 'Email me ↗',
                dark: dark,
                href: 'mailto:${s.email}',
              ),
              if (s.linkedin != null && s.linkedin!.isNotEmpty)
                BtnGhost(
                  label: 'LinkedIn ↗',
                  dark: dark,
                  href: 'https://${s.linkedin}',
                ),
              if (s.github != null && s.github!.isNotEmpty)
                BtnGhost(
                  label: 'GitHub ↗',
                  dark: dark,
                  href: 'https://${s.github}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
