import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/portfolio_data.dart';
import '../../../theme/app_theme.dart';
import '../widgets/project_card.dart';

class ProjectsSection extends StatelessWidget {
  final List<Project> projects;
  final bool isDark;
  final double scrollOffset;
  final double screenHeight;

  const ProjectsSection({
    super.key,
    required this.projects,
    required this.isDark,
    required this.scrollOffset,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Parallax for section
    final sectionParallax = (scrollOffset - screenHeight) * 0.1;

    return Transform.translate(
      offset: Offset(0, sectionParallax.clamp(-50, 50)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Text(
                'SELECTED WORK',
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
              height: 580,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 80),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: projects[index],
                    index: index,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
