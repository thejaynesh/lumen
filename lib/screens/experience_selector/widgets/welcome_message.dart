import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean welcome header for the experience selector.
class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 4,
          ),
        ).animate().fadeIn(duration: 500.ms),

        const SizedBox(height: 8),

        Text(
              'EXPERIENCE',
              style: GoogleFonts.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 4,
              ),
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideX(begin: -0.05, end: 0, duration: 500.ms),
      ],
    );
  }
}
