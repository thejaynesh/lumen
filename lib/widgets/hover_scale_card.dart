import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium card with hover scale, glow, and reveal animations
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const HoverScaleCard({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.02,
    this.padding = const EdgeInsets.all(32),
    this.showBorder = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(24);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isHovered ? widget.scale : 1.0,
            _isHovered ? widget.scale : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.darkSurface,
            borderRadius: borderRadius,
            border: widget.showBorder
                ? Border.all(
                    color: _isHovered
                        ? AppTheme.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  )
                : null,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

/// Image card with overlay and hover effect
class HoverImageCard extends StatefulWidget {
  final String? imageUrl;
  final Widget? placeholder;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double aspectRatio;

  const HoverImageCard({
    super.key,
    this.imageUrl,
    this.placeholder,
    required this.title,
    this.subtitle,
    this.onTap,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<HoverImageCard> createState() => _HoverImageCardState();
}

class _HoverImageCardState extends State<HoverImageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            transform: Matrix4.diagonal3Values(
              _isHovered ? 1.03 : 1.0,
              _isHovered ? 1.03 : 1.0,
              1.0,
            ),
            transformAlignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  if (widget.imageUrl != null)
                    Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          widget.placeholder ?? _buildPlaceholder(),
                    )
                  else
                    widget.placeholder ?? _buildPlaceholder(),

                  // Gradient overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(
                            alpha: _isHovered ? 0.9 : 0.7,
                          ),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: _isHovered
                                    ? AppTheme.primary
                                    : Colors.white,
                              ),
                          child: Text(widget.title),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHovered ? 1.0 : 0.7,
                            child: Text(
                              widget.subtitle!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow indicator
                  Positioned(
                    right: 24,
                    top: 24,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: _isHovered
                            ? Offset.zero
                            : const Offset(0.5, -0.5),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Icons.arrow_outward,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkSurface, AppTheme.darkSurfaceLight],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppTheme.darkTextMuted,
        ),
      ),
    );
  }
}
