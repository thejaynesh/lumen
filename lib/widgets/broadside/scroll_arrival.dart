import 'package:flutter/material.dart';

/// Scroll-linked translation keeps content readable even before it enters view.
class ScrollArrival extends StatelessWidget {
  const ScrollArrival({
    super.key,
    required this.controller,
    required this.child,
  });
  final ScrollController controller;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final box = context.findRenderObject();
        var offset = 0.0;
        if (box is RenderBox && box.hasSize) {
          final viewport = MediaQuery.sizeOf(context).height;
          final y = box.localToGlobal(Offset.zero).dy;
          offset =
              ((y - viewport * .55) / (viewport * .45)).clamp(0.0, 1.0) * 45;
        }
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
    );
  }
}
