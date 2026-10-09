import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Reveal once upon entering the actual scroll viewport, including on resize.
class ScrollArrival extends StatefulWidget {
  const ScrollArrival({
    super.key,
    required this.controller,
    required this.child,
  });
  final ScrollController controller;
  final Widget child;
  @override
  State<ScrollArrival> createState() => _ScrollArrivalState();
}

class _ScrollArrivalState extends State<ScrollArrival>
    with WidgetsBindingObserver {
  bool _arrived = false;
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_check);
  }

  @override
  void didChangeMetrics() => _check();

  @override
  void didUpdateWidget(covariant ScrollArrival oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_check);
      widget.controller.addListener(_check);
    }
  }

  void _check() {
    if (_arrived || _pending) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (!mounted || _arrived) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final RenderObject? viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport is! RenderBox || !viewport.hasSize) return;
      final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      if (top < viewport.size.height - 32 && top + box.size.height > 0) {
        setState(() => _arrived = true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    _check();
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) {
        if (focused && !_arrived) setState(() => _arrived = true);
      },
      child: AnimatedSlide(
        offset: _arrived || reduced ? Offset.zero : const Offset(0, .035),
        duration: reduced ? Duration.zero : const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _arrived || reduced ? 1 : 0,
          duration: reduced ? Duration.zero : const Duration(milliseconds: 650),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
