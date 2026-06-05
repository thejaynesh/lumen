import 'package:flutter/foundation.dart';

enum ExperienceMode { automated, manual, lucky }

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
}
