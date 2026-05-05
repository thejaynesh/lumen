import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/experience_provider.dart';

/// A dramatic 3D carousel selector with perspective depth.
/// Shows experiences as stacked cards that rotate with parallax.
class ExperienceCarousel extends StatefulWidget {
  final List<ExperienceMode> modes;
  final Function(ExperienceMode) onSelect;
  final Function(ExperienceMode) getIcon;
  final Function(ExperienceMode) getName;
  final Function(ExperienceMode) getDescription;
  final Function(ExperienceMode) getSubtitle;

  const ExperienceCarousel({
    super.key,
    required this.modes,
    required this.onSelect,
    required this.getIcon,
    required this.getName,
    required this.getDescription,
    required this.getSubtitle,
  });

  @override
  State<ExperienceCarousel> createState() => _ExperienceCarouselState();
}

class _ExperienceCarouselState extends State<ExperienceCarousel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _animation;
  int _previousIndex = 0;
  bool _isSelectHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goToIndex(int index) {
    if (index == _currentIndex || _animController.isAnimating) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    _animController.forward(from: 0);
  }

  void _handleScroll(PointerScrollEvent event) {
    if (event.scrollDelta.dy > 0) {
      _goToIndex((_currentIndex + 1) % widget.modes.length);
    } else if (event.scrollDelta.dy < 0) {
      _goToIndex(
        (_currentIndex - 1 + widget.modes.length) % widget.modes.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleScroll(event);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The 3D stacked cards
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: List.generate(widget.modes.length, (index) {
                return _buildCard(index);
              }),
            ),
          ),

          const SizedBox(height: 48),

          // Dot indicators
          _buildDotIndicators(),

          const SizedBox(height: 40),

          // Select button
          _buildSelectButton(),

          const SizedBox(height: 20),

          // Navigation hint
          Text(
            'SCROLL TO EXPLORE',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.25),
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final mode = widget.modes[index];
    final isSelected = index == _currentIndex;

    // Calculate position relative to current
    int relativePos = index - _currentIndex;
    if (relativePos > widget.modes.length ~/ 2) {
      relativePos -= widget.modes.length;
    }
    if (relativePos < -(widget.modes.length ~/ 2)) {
      relativePos += widget.modes.length;
    }

    // Z-order: selected card on top
    final zIndex = isSelected ? 100 : 50 - relativePos.abs();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate transforms based on position
        double offsetX = relativePos * 80.0;
        double offsetY = relativePos.abs() * 20.0;
        double scale = isSelected ? 1.0 : 0.85 - (relativePos.abs() * 0.1);
        double opacity = isSelected ? 1.0 : 0.4 - (relativePos.abs() * 0.15);
        double rotateY = relativePos * 0.15;

        // Clamp values
        scale = scale.clamp(0.6, 1.0);
        opacity = opacity.clamp(0.1, 1.0);

        return Positioned(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..translate(offsetX, offsetY, -relativePos.abs() * 50.0)
              ..rotateY(rotateY)
              ..scale(scale),
            child: Opacity(
              opacity: opacity,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () =>
                      isSelected ? widget.onSelect(mode) : _goToIndex(index),
                  child: _buildCardContent(mode, isSelected),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(ExperienceMode mode, bool isSelected) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D0D12) : const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Index number
          Text(
            '0${widget.modes.indexOf(mode) + 1}',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 20),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: isSelected ? 0.2 : 0.08),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.getIcon(mode) as IconData,
              size: 28,
              color: Colors.white.withValues(alpha: isSelected ? 0.9 : 0.5),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            widget.getName(mode).toString().toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.6),
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            widget.getSubtitle(mode).toString(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: isSelected ? 0.4 : 0.25),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          // Description (only visible when selected)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: Text(
              widget.getDescription(mode).toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.modes.length, (index) {
        final isSelected = index == _currentIndex;
        return GestureDetector(
          onTap: () => _goToIndex(index),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectButton() {
    final currentMode = widget.modes[_currentIndex];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isSelectHovered = true),
      onExit: (_) => setState(() => _isSelectHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelect(currentMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: _isSelectHovered ? Colors.white : Colors.transparent,
            border: Border.all(
              color: Colors.white.withValues(
                alpha: _isSelectHovered ? 1.0 : 0.4,
              ),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ENTER',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isSelectHovered ? Colors.black : Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward,
                color: _isSelectHovered ? Colors.black : Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
