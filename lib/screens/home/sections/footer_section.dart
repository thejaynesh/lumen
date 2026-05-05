import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  final bool isDark;

  const FooterSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© ${DateTime.now().year} All rights reserved',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted(isDark),
            ),
          ),
          Text(
            'Built with Flutter',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
