import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget that animates when it enters the viewport
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double scaleFrom;
  final bool fadeIn;
  final bool slideIn;
  final bool scaleIn;
  final Curve curve;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.slideOffset = const Offset(0, 50),
    this.scaleFrom = 0.95,
    this.fadeIn = true,
    this.slideIn = true,
    this.scaleIn = false,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  bool _isVisible = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;

      if (position.dy < screenHeight * 0.9) {
        setState(() => _isVisible = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_isVisible) {
          _checkVisibility();
        }
        return false;
      },
      child: Container(
        key: _key,
        child: _isVisible
            ? _buildAnimatedChild()
            : Opacity(opacity: 0, child: widget.child),
      ),
    );
  }

  Widget _buildAnimatedChild() {
    Widget child = widget.child;

    child = child.animate(delay: widget.delay);

    if (widget.fadeIn) {
      child = (child as Animate).fadeIn(
        duration: widget.duration,
        curve: widget.curve,
      );
    }

    if (widget.slideIn) {
      child = (child as Animate).slideY(
        begin: widget.slideOffset.dy / 100,
        end: 0,
        duration: widget.duration,
        curve: widget.curve,
      );
    }

    if (widget.scaleIn) {
      child = (child as Animate).scale(
        begin: Offset(widget.scaleFrom, widget.scaleFrom),
        end: const Offset(1, 1),
        duration: widget.duration,
        curve: widget.curve,
      );
    }

    return child;
  }
}

/// Staggered children animation
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const StaggeredList({
    super.key,
    required this.children,
    this.initialDelay = Duration.zero,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final animatedChildren = List.generate(children.length, (index) {
      return children[index]
          .animate(delay: initialDelay + (staggerDelay * index))
          .fadeIn(duration: animationDuration, curve: Curves.easeOut)
          .slideY(
            begin: 0.2,
            end: 0,
            duration: animationDuration,
            curve: Curves.easeOutCubic,
          );
    });

    if (direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(animatedChildren),
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(animatedChildren),
      );
    }
  }

  List<Widget> _addSpacing(List<Widget> children) {
    if (spacing == 0) return children;

    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          direction == Axis.vertical
              ? SizedBox(height: spacing)
              : SizedBox(width: spacing),
        );
      }
    }
    return result;
  }
}

/// Parallax scroll effect
class ParallaxContainer extends StatefulWidget {
  final Widget child;
  final double parallaxFactor;
  final ScrollController? scrollController;

  const ParallaxContainer({
    super.key,
    required this.child,
    this.parallaxFactor = 0.3,
    this.scrollController,
  });

  @override
  State<ParallaxContainer> createState() => _ParallaxContainerState();
}

class _ParallaxContainerState extends State<ParallaxContainer> {
  double _offset = 0;
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateOffset();
        return false;
      },
      child: Container(
        key: _key,
        child: Transform.translate(
          offset: Offset(0, _offset * widget.parallaxFactor),
          child: widget.child,
        ),
      ),
    );
  }

  void _updateOffset() {
    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        _offset = (position.dy - screenHeight / 2);
      });
    }
  }
}
