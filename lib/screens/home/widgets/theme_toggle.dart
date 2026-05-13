import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isDark;

  const ThemeToggleButton({
    super.key,
    required this.themeProvider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: IconButton(
        onPressed: () => themeProvider.toggleTheme(),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: AppTheme.textPrimary(isDark),
          ),
        ),
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0);
  }
}
