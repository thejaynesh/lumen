import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';

class BackgroundGlow extends StatelessWidget {
  final double scrollOffset;
  final bool isDark;

  const BackgroundGlow({
    super.key,
    required this.scrollOffset,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -200 + (scrollOffset * 0.1),
      right: -200,
      child: Container(
        width: 600,
        height: 600,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1.seconds);
  }
}
