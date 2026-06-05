import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';

// ---------------------------------------------------------------------------
// Data model for each door
// ---------------------------------------------------------------------------

class _ModeData {
  final ExperienceMode id;
  final String num;
  final String name;
  final String sub;
  final String long;
  final String icon;

  const _ModeData({
    required this.id,
    required this.num,
    required this.name,
    required this.sub,
    required this.long,
    required this.icon,
  });
}

const List<_ModeData> _modes = [
  _ModeData(
    id: ExperienceMode.automated,
    num: '01',
    name: 'Automated',
    sub: 'Recommended · 3 min',
    long:
        'Let me give you the tour. A guided presentation through my work, chapter by chapter. Sit back and click through.',
    icon: '▷',
  ),
  _ModeData(
    id: ExperienceMode.manual,
    num: '02',
    name: 'Manual',
    sub: 'Traditional',
    long:
        'Scroll, click, read. Projects, experience, contact. The recruiter\'s view — nothing surprising, everything useful.',
    icon: '☞',
  ),
  _ModeData(
    id: ExperienceMode.lucky,
    num: '03',
    name: "I'm Feeling Lucky",
    sub: 'Experimental',
    long:
        'A quiz, some personality, and the side of me that doesn\'t belong on a résumé. Browse at your own risk.',
    icon: '✦',
  ),
];

// ---------------------------------------------------------------------------
// ModeSelectorScreen
// ---------------------------------------------------------------------------

class ModeSelectorScreen extends StatefulWidget {
  const ModeSelectorScreen({super.key});

  @override
  State<ModeSelectorScreen> createState() => _ModeSelectorScreenState();
}

class _ModeSelectorScreenState extends State<ModeSelectorScreen> {
  ExperienceMode? _hoveredId;

  void _pick(BuildContext context, ExperienceMode mode) {
    context.read<ExperienceProvider>().setMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;

    return FutureBuilder<PortfolioSettings>(
      future: context.read<PortfolioService>().getSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data;
        final name =
            (settings?.name.isNotEmpty ?? false)
                ? settings!.name.toUpperCase()
                : 'JAYNESH BHANDARI';
        final email = settings?.email ?? '';
        final location = settings?.location ?? '';

        final grid = Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(_modes.length, (i) {
              final m = _modes[i];
              final isLast = i == _modes.length - 1;
              return Expanded(
                child: _DoorCell(
                  mode: m,
                  dark: dark,
                  hovered: _hoveredId == m.id,
                  isLast: isLast,
                  onEnter: () => setState(() => _hoveredId = m.id),
                  onExit: () => setState(() => _hoveredId = null),
                  onTap: () => _pick(context, m.id),
                ),
              );
            }),
          ),
        );

        final title = Padding(
          padding: const EdgeInsets.fromLTRB(48, 56, 48, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Kicker('↓ Select your route', dark: dark),
              const SizedBox(height: 18),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'THREE\n',
                      style: BroadsideText.serif(
                        size: 150,
                        height: 0.84,
                        letterSpacing: -0.045,
                        color: Broadside.ink(dark),
                      ),
                    ),
                    TextSpan(
                      text: 'doors.',
                      style: BroadsideText.serif(
                        size: 150,
                        height: 0.84,
                        letterSpacing: -0.045,
                        color: Broadside.accent(dark),
                        style: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return Container(
          color: Broadside.paper(dark),
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    dark: dark,
                    name: name,
                    email: email,
                    onToggle: () =>
                        context.read<ThemeProvider>().toggleTheme(),
                  ),
                  title,
                  const SizedBox(height: 40),
                  grid,
                  _BottomBar(dark: dark, location: location),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final bool dark;
  final String name;
  final String email;
  final VoidCallback onToggle;

  const _TopBar({
    required this.dark,
    required this.name,
    required this.email,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Broadside.rule(dark))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: name + portfolio kicker
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                name,
                style: BroadsideText.serif(
                  size: 28,
                  height: 1.0,
                  color: Broadside.ink(dark),
                ),
              ),
              const SizedBox(width: 18),
              Kicker('· portfolio', dark: dark, size: 9),
            ],
          ),
          // Right: email + theme toggle
          Row(
            children: [
              if (email.isNotEmpty) ...[
                Kicker(email, dark: dark),
                const SizedBox(width: 16),
              ],
              ThemeToggleButton(dark: dark, onToggle: onToggle),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Door cell
// ---------------------------------------------------------------------------

class _DoorCell extends StatelessWidget {
  final _ModeData mode;
  final bool dark;
  final bool hovered;
  final bool isLast;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _DoorCell({
    required this.mode,
    required this.dark,
    required this.hovered,
    required this.isLast,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor =
        hovered ? Broadside.accentInk(dark) : Broadside.ink(dark);
    final numColor =
        hovered ? Broadside.accentInk(dark) : Broadside.inkSoft(dark);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          constraints: const BoxConstraints(minHeight: 280),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            color: hovered ? Broadside.accent(dark) : Colors.transparent,
            border: Border(
              right: isLast
                  ? BorderSide.none
                  : BorderSide(color: Broadside.rule(dark)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: num / icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mode.num} / 03',
                    style: BroadsideText.mono(
                      size: 11,
                      color: numColor,
                      trackingEm: 0.18,
                    ),
                  ),
                  Opacity(
                    opacity: hovered ? 1.0 : 0.4,
                    child: Text(
                      mode.icon,
                      style: BroadsideText.serif(
                        size: 32,
                        color: contentColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 72),

              // Bottom block: name + long + sub row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.name,
                    style: BroadsideText.serif(
                      size: 44,
                      height: 0.95,
                      letterSpacing: -0.02,
                      color: contentColor,
                      style: mode.id == ExperienceMode.lucky
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Opacity(
                      opacity: hovered ? 0.95 : 0.6,
                      child: Text(
                        mode.long,
                        style: BroadsideText.sans(
                          size: 13.5,
                          height: 1.55,
                          color: contentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mode.sub.toUpperCase(),
                        style: BroadsideText.mono(
                          size: 10,
                          color: contentColor,
                          trackingEm: 0.18,
                        ),
                      ),
                      Text(
                        'ENTER →',
                        style: BroadsideText.mono(
                          size: 10,
                          color: contentColor,
                          trackingEm: 0.18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final bool dark;
  final String location;

  const _BottomBar({required this.dark, required this.location});

  @override
  Widget build(BuildContext context) {
    final locationText =
        location.isNotEmpty ? '${location.toUpperCase()} · 2026' : '· 2026';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Broadside.rule(dark))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Kicker('Software Engineer · Full-Stack', dark: dark),
          Kicker(locationText, dark: dark),
        ],
      ),
    );
  }
}
