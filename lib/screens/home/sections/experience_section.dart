import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';
import '../widgets/experience_card.dart';

class ExperienceSection extends StatelessWidget {
  final List<Experience> experiences;
  final bool isDark;

  const ExperienceSection({
    super.key,
    required this.experiences,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Text(
              'EXPERIENCE',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted(isDark),
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            height: 420,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 80),
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                return ExperienceCard(
                  experience: experiences[index],
                  index: index,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
