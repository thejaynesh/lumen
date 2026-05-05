import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated text that reveals character by character
class AnimatedRevealText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  final Duration characterDelay;
  final TextAlign? textAlign;

  const AnimatedRevealText({
    super.key,
    required this.text,
    this.style,
    this.delay = Duration.zero,
    this.characterDelay = const Duration(milliseconds: 30),
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: textAlign)
        .animate(delay: delay)
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Staggered line reveal animation
class StaggeredLineReveal extends StatelessWidget {
  final List<String> lines;
  final TextStyle? style;
  final Duration initialDelay;
  final Duration lineDelay;
  final CrossAxisAlignment alignment;

  const StaggeredLineReveal({
    super.key,
    required this.lines,
    this.style,
    this.initialDelay = Duration.zero,
    this.lineDelay = const Duration(milliseconds: 100),
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines.length, (index) {
        return Text(lines[index], style: style)
            .animate(delay: initialDelay + (lineDelay * index))
            .fadeIn(duration: 600.ms)
            .slideY(
              begin: 0.5,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            );
      }),
    );
  }
}

/// Animated counter that counts up to a number
class AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}${widget.suffix}', style: widget.style);
      },
    );
  }
}

/// Glow text effect
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double blurRadius;

  const GlowText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = const Color(0xFFFF6B35),
    this.blurRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer
        Text(
          text,
          style: style?.copyWith(
            foreground: Paint()
              ..color = glowColor
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
          ),
        ),
        // Main text
        Text(text, style: style),
      ],
    );
  }
}

/// Gradient text
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFF6B35), Color(0xFFFFD93D)],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style?.copyWith(color: Colors.white)),
    );
  }
}
