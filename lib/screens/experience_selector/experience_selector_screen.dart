import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/experience_provider.dart';
import 'widgets/expanding_options_list.dart';
import 'widgets/marquee_background.dart';
import 'widgets/welcome_message.dart';

/// The initial screen where users select their portfolio experience mode.
/// Features an animated marquee background with a solid selector panel.
class ExperienceSelectorScreen extends StatefulWidget {
  const ExperienceSelectorScreen({super.key});

  @override
  State<ExperienceSelectorScreen> createState() =>
      _ExperienceSelectorScreenState();
}

class _ExperienceSelectorScreenState extends State<ExperienceSelectorScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the experience mode when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExperienceProvider>().reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated marquee background
          const Positioned.fill(child: MarqueeBackground()),

          // Solid center panel for selector
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                // Solid background to mask marquee
                color: const Color(0xFF0A0A0F),
                borderRadius: BorderRadius.circular(24),
                // Soft edge glow to blend with background
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A0A0F),
                    blurRadius: 60,
                    spreadRadius: 30,
                  ),
                  BoxShadow(
                    color: const Color(0xFF0A0A0F),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0F),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      const WelcomeMessage(),

                      const SizedBox(height: 40),

                      // Options list
                      _buildOptionsList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    final experienceProvider = context.read<ExperienceProvider>();

    final orderedModes = [
      ExperienceMode.narrator,
      ExperienceMode.manual,
      ExperienceMode.fun,
    ];

    return ExpandingOptionsList(
      modes: orderedModes,
      onSelect: _selectExperience,
      getIcon: (mode) => experienceProvider.getModeIcon(mode),
      getName: (mode) => experienceProvider.getModeName(mode),
      getDescription: (mode) => experienceProvider.getModeDescription(mode),
      getSubtitle: (mode) => _getSubtitle(mode),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  String _getSubtitle(ExperienceMode mode) {
    switch (mode) {
      case ExperienceMode.narrator:
        return 'RECOMMENDED';
      case ExperienceMode.manual:
        return 'TRADITIONAL';
      case ExperienceMode.fun:
        return 'EXPERIMENTAL';
    }
  }

  void _selectExperience(ExperienceMode mode) {
    context.read<ExperienceProvider>().setMode(mode);
  }
}
