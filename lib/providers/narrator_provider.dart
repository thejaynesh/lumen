import 'dart:async';
import 'package:flutter/material.dart';

class NarratorSection {
  final String id;
  final String label;
  final Duration duration;
  final GlobalKey key;
  NarratorSection({
    required this.id,
    required this.label,
    required this.duration,
    required this.key,
  });
}

/// Drives the automated portfolio walkthrough.
///
/// Owns:
///  - section list (id, label, duration, scroll key)
///  - current section + within-section progress
///  - play/pause state
///  - timer that advances progress and auto-scrolls to next section
class NarratorProvider extends ChangeNotifier {
  final List<NarratorSection> _sections = [];
  int _currentIndex = 0;
  double _sectionProgress = 0.0;
  bool _isPlaying = false;
  bool _isActive = false;
  Timer? _timer;
  DateTime? _lastTick;

  static const _tickInterval = Duration(milliseconds: 50);
  static const _scrollDuration = Duration(milliseconds: 800);

  List<NarratorSection> get sections => List.unmodifiable(_sections);
  int get currentIndex => _currentIndex;
  double get sectionProgress => _sectionProgress;
  bool get isPlaying => _isPlaying;
  bool get isActive => _isActive;
  bool get hasFinished =>
      _isActive &&
      !_isPlaying &&
      _currentIndex == _sections.length - 1 &&
      _sectionProgress >= 1.0;

  /// 0..1 across all sections.
  double get totalProgress {
    if (_sections.isEmpty) return 0;
    return (_currentIndex + _sectionProgress) / _sections.length;
  }

  /// Replace the section list. If active, clamps current index.
  void registerSections(List<NarratorSection> sections) {
    _sections
      ..clear()
      ..addAll(sections);
    if (_currentIndex >= _sections.length) {
      _currentIndex = _sections.isEmpty ? 0 : _sections.length - 1;
    }
    notifyListeners();
  }

  /// Begin auto-flow from the first section.
  void start() {
    if (_sections.isEmpty) return;
    _isActive = true;
    _isPlaying = true;
    _currentIndex = 0;
    _sectionProgress = 0;
    _lastTick = DateTime.now();
    _scheduleScroll();
    _startTimer();
    notifyListeners();
  }

  /// Stop entirely. Resets state.
  void stop() {
    _isActive = false;
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _lastTick = null;
    _currentIndex = 0;
    _sectionProgress = 0;
    notifyListeners();
  }

  void pause() {
    if (!_isActive || !_isPlaying) return;
    _isPlaying = false;
    _lastTick = null;
    notifyListeners();
  }

  void resume() {
    if (!_isActive || _isPlaying) return;
    if (hasFinished) {
      // restart from beginning
      _currentIndex = 0;
      _sectionProgress = 0;
      _scheduleScroll();
    }
    _isPlaying = true;
    _lastTick = DateTime.now();
    _startTimer();
    notifyListeners();
  }

  void togglePlay() => _isPlaying ? pause() : resume();

  /// Jump to a specific section. Resets within-section progress; flow continues
  /// (or stays paused) per current playing state.
  void goTo(int index) {
    if (_sections.isEmpty) return;
    final clamped = index.clamp(0, _sections.length - 1);
    _currentIndex = clamped;
    _sectionProgress = 0;
    _lastTick = DateTime.now();
    _scheduleScroll();
    notifyListeners();
  }

  void next() => goTo(_currentIndex + 1);
  void prev() => goTo(_currentIndex - 1);

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, _onTick);
  }

  void _onTick(Timer _) {
    if (!_isPlaying || _sections.isEmpty) return;
    final now = DateTime.now();
    final dtMs = now.difference(_lastTick ?? now).inMilliseconds;
    _lastTick = now;
    final secMs = _sections[_currentIndex].duration.inMilliseconds;
    if (secMs <= 0) return;
    _sectionProgress += dtMs / secMs;
    if (_sectionProgress >= 1.0) {
      if (_currentIndex + 1 < _sections.length) {
        _currentIndex++;
        _sectionProgress = 0;
        _scheduleScroll();
      } else {
        _sectionProgress = 1.0;
        _isPlaying = false;
        _timer?.cancel();
        _timer = null;
      }
    }
    notifyListeners();
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sections.isEmpty) return;
      final ctx = _sections[_currentIndex].key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: _scrollDuration,
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
