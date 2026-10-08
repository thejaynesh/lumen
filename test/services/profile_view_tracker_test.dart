import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/services/profile_view_tracker.dart';

void main() {
  test(
    'deduplicates concurrent and repeated views within one service session',
    () async {
      final gate = Completer<void>();
      final calls = <String>[];
      final tracker = ProfileViewTracker((slug) async {
        calls.add(slug);
        await gate.future;
      });
      final first = tracker.record('one');
      await tracker.record('one');
      expect(calls, ['one']);
      gate.complete();
      await first;
      await tracker.record('one');
      await tracker.record('two');
      expect(calls, ['one', 'two']);
    },
  );

  test('missing or failing analytics never fails content loading', () async {
    await ProfileViewTracker(null).record('one');
    var calls = 0;
    final tracker = ProfileViewTracker((_) async {
      calls++;
      throw StateError('blocked');
    });
    await tracker.record('one');
    await tracker.record('one');
    expect(calls, 1);
  });
}
