import 'package:flutter/material.dart';

/// Finite, staggered entrances that keep the child's layout stable.
class MotionEntrance extends StatelessWidget {
  const MotionEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.distance = 36,
  });
  final Widget child;
  final Duration delay;
  final double distance;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final total = delay.inMilliseconds + 900;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(
        delay.inMilliseconds / total,
        1,
        curve: Curves.easeOutCubic,
      ),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, distance * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

/// Scroll-driven depth for separate hero paper layers; no idle ticker.
class HeroParallax extends StatelessWidget {
  const HeroParallax({
    super.key,
    required this.controller,
    required this.child,
    this.depth = .12,
  });
  final ScrollController? controller;
  final Widget child;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final scroll = controller;
    if (scroll == null || MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: scroll,
      child: child,
      builder: (context, child) {
        final offset = scroll.hasClients
            ? scroll.offset.clamp(0.0, 650.0)
            : 0.0;
        return Transform.translate(
          offset: Offset(0, offset * depth),
          child: Transform.rotate(angle: offset * depth / 1600, child: child),
        );
      },
    );
  }
}
