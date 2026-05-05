import 'package:flutter/material.dart';

/// Enum defining the different portfolio experience modes
enum ExperienceMode {
  /// Automated storytelling experience - narrates through the portfolio
  narrator,

  /// Fun experience with music snippets and memes
  fun,

  /// Manual scrolling experience (default)
  manual,
}

/// Provider to manage the selected experience mode
class ExperienceProvider extends ChangeNotifier {
  ExperienceMode _mode = ExperienceMode.manual;
  bool _hasSelectedMode = false;

  ExperienceMode get mode => _mode;
  bool get hasSelectedMode => _hasSelectedMode;

  void setMode(ExperienceMode mode) {
    _mode = mode;
    _hasSelectedMode = true;
    notifyListeners();
  }

  void reset() {
    _hasSelectedMode = false;
    notifyListeners();
  }

  /// Returns display name for the mode
  String getModeName(ExperienceMode mode) {
    switch (mode) {
      case ExperienceMode.narrator:
        return 'Automated';
      case ExperienceMode.fun:
        return "I'm Feeling Lucky";
      case ExperienceMode.manual:
        return 'Manual';
    }
  }

  /// Returns description for the mode
  String getModeDescription(ExperienceMode mode) {
    switch (mode) {
      case ExperienceMode.narrator:
        return 'Sit back and relax. An automated guided tour of my work.';
      case ExperienceMode.fun:
        return 'Surprise me! A unique, random way to explore.';
      case ExperienceMode.manual:
        return 'The traditional way. Scroll and explore at your own pace.';
    }
  }

  /// Returns icon for the mode
  IconData getModeIcon(ExperienceMode mode) {
    switch (mode) {
      case ExperienceMode.narrator:
        return Icons.auto_stories_rounded;
      case ExperienceMode.fun:
        return Icons.celebration_rounded;
      case ExperienceMode.manual:
        return Icons.touch_app_rounded;
    }
  }
}
