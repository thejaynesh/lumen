import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/experience_provider.dart';
import '../../../providers/narrator_provider.dart';
import '../../../theme/app_theme.dart';

/// Bottom-right floating cluster: prev / play-pause / next / exit.
class NarratorFloatingControls extends StatelessWidget {
  final bool isDark;
  const NarratorFloatingControls({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NarratorProvider>();
    if (!n.isActive) return const SizedBox.shrink();

    return Positioned(
      bottom: 32,
      right: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous section',
            isDark: isDark,
            onTap: n.prev,
          ),
          const SizedBox(width: 12),
          _ControlButton(
            icon: n.isPlaying
                ? Icons.pause_rounded
                : (n.hasFinished
                    ? Icons.replay_rounded
                    : Icons.play_arrow_rounded),
            tooltip: n.isPlaying
                ? 'Pause'
                : (n.hasFinished ? 'Replay' : 'Resume'),
            isDark: isDark,
            big: true,
            onTap: n.togglePlay,
          ),
          const SizedBox(width: 12),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next section',
            isDark: isDark,
            onTap: n.next,
          ),
          const SizedBox(width: 12),
          _ControlButton(
            icon: Icons.close_rounded,
            tooltip: 'Exit auto mode',
            isDark: isDark,
            onTap: () {
              n.stop();
              context.read<ExperienceProvider>().setMode(ExperienceMode.manual);
            },
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isDark;
  final bool big;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.onTap,
    this.big = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.big ? 64.0 : 48.0;
    final iconSize = widget.big ? 32.0 : 22.0;
    final iconColor = widget.big
        ? Colors.black
        : AppTheme.primary;
    final bgColor = widget.big
        ? null
        : (widget.isDark ? Colors.white : Colors.black)
            .withOpacity(_hover ? 0.18 : 0.10);
    final gradient = widget.big ? AppTheme.accentGradient : null;
    final borderColor = widget.big
        ? Colors.transparent
        : AppTheme.primary.withOpacity(0.5);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              gradient: gradient,
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: (widget.big || _hover)
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(
                          widget.big ? 0.55 : 0.35,
                        ),
                        blurRadius: widget.big ? 24 : 14,
                        spreadRadius: widget.big ? 2 : 0,
                      ),
                    ]
                  : null,
            ),
            child: Icon(widget.icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}
