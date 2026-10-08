class ProfileViewTracker {
  final Future<void> Function(String slug)? _record;
  final Set<String> _seen = {};

  ProfileViewTracker(this._record);

  Future<void> record(String slug) async {
    if (_record == null || !_seen.add(slug)) return;
    try {
      await _record(slug);
    } catch (_) {
      // Analytics must never block or break the portfolio. Keep the session
      // marker on failures too, so denied analytics is not retried on reloads.
    }
  }
}
