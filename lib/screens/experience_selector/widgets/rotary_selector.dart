import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/experience_provider.dart';

/// A rotary dial-style selector for experience modes.
/// Shows one option prominently at a time with elegant rotation animation.
class RotarySelector extends StatefulWidget {
  final List<ExperienceMode> modes;
  final Function(ExperienceMode) onSelect;
  final Function(ExperienceMode) getIcon;
  final Function(ExperienceMode) getName;
  final Function(ExperienceMode) getDescription;
  final Function(ExperienceMode) getSubtitle;

  const RotarySelector({
    super.key,
    required this.modes,
    required this.onSelect,
    required this.getIcon,
    required this.getName,
    required this.getDescription,
    required this.getSubtitle,
  });

  @override
  State<RotarySelector> createState() => _RotarySelectorState();
}

class _RotarySelectorState extends State<RotarySelector>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _rotationController;
  bool _isAnimating = false;
  bool _isHovering = false;

  // For gesture tracking
  double _dragStartY = 0;
  double _dragDelta = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_isAnimating) return;
    _animateTo((_currentIndex + 1) % widget.modes.length);
  }

  void _goToPrevious() {
    if (_isAnimating) return;
    _animateTo((_currentIndex - 1 + widget.modes.length) % widget.modes.length);
  }

  void _animateTo(int newIndex) {
    if (newIndex == _currentIndex || _isAnimating) return;

    setState(() {
      _isAnimating = true;
      _currentIndex = newIndex;
    });

    _rotationController.forward(from: 0).then((_) {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _handleScroll(PointerScrollEvent event) {
    if (event.scrollDelta.dy > 0) {
      _goToNext();
    } else if (event.scrollDelta.dy < 0) {
      _goToPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = widget.modes[_currentIndex];
    final prevIndex =
        (_currentIndex - 1 + widget.modes.length) % widget.modes.length;
    final nextIndex = (_currentIndex + 1) % widget.modes.length;

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleScroll(event);
        }
      },
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartY = details.localPosition.dy;
          _dragDelta = 0;
        },
        onVerticalDragUpdate: (details) {
          _dragDelta = details.localPosition.dy - _dragStartY;
        },
        onVerticalDragEnd: (details) {
          if (_dragDelta.abs() > 30) {
            if (_dragDelta > 0) {
              _goToPrevious();
            } else {
              _goToNext();
            }
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous option (faded, small)
                _buildAdjacentOption(
                  widget.modes[prevIndex],
                  isAbove: true,
                  onTap: _goToPrevious,
                ),

                const SizedBox(height: 32),

                // Current selection indicator line
                _buildDivider(),

                const SizedBox(height: 40),

                // Main selected option
                _buildMainOption(currentMode),

                const SizedBox(height: 40),

                // Current selection indicator line
                _buildDivider(),

                const SizedBox(height: 32),

                // Next option (faded, small)
                _buildAdjacentOption(
                  widget.modes[nextIndex],
                  isAbove: false,
                  onTap: _goToNext,
                ),

                const SizedBox(height: 48),

                // Select button
                _buildSelectButton(currentMode),

                const SizedBox(height: 24),

                // Navigation hint
                _buildNavigationHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 120,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAdjacentOption(
    ExperienceMode mode, {
    required bool isAbove,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            final progress = _rotationController.value;
            final opacity = 0.25 + (0.1 * (1 - progress));

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(
                  0,
                  isAbove ? -10 * (1 - progress) : 10 * (1 - progress),
                ),
                child: child,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAbove ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.3),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.getName(mode).toString().toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainOption(ExperienceMode mode) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        final curve = Curves.easeOutCubic.transform(_rotationController.value);
        return Transform.scale(
          scale: 0.9 + (0.1 * curve),
          child: Opacity(opacity: 0.5 + (0.5 * curve), child: child),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Index number
          Text(
            '${_currentIndex + 1}'.padLeft(2, '0'),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            widget.getName(mode).toString().toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle badge
          Text(
            widget.getSubtitle(mode).toString(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          SizedBox(
            width: 320,
            child: Text(
              widget.getDescription(mode).toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton(ExperienceMode mode) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSelect(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationHint() {
    return Text(
          'SCROLL OR DRAG TO NAVIGATE',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.2),
            letterSpacing: 2,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: 1500.ms)
        .then()
        .fadeOut(duration: 1500.ms);
  }
}
