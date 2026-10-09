import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/widgets/broadside/motion.dart';
import 'package:lumen/widgets/broadside/scroll_arrival.dart';

Widget app(Widget child, {bool reduced = false}) => MaterialApp(
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: child,
    ),
  ),
);

void main() {
  testWidgets(
    'Entrance visibly moves, settles, and does not replay on rebuild',
    (tester) async {
      Widget content() => app(const MotionEntrance(child: Text('Hello')));
      await tester.pumpWidget(content());
      final initial = tester.getTopLeft(find.text('Hello')).dy;
      await tester.pump(const Duration(milliseconds: 300));
      final middle = tester.getTopLeft(find.text('Hello')).dy;
      expect(middle, lessThan(initial));
      await tester.pumpAndSettle();
      final settled = tester.getTopLeft(find.text('Hello')).dy;
      expect(settled, lessThan(middle));
      await tester.pumpWidget(content());
      expect(tester.getTopLeft(find.text('Hello')).dy, settled);
    },
  );

  testWidgets(
    'Below-fold sections reveal on scroll and stay revealed on return',
    (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        app(
          SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                const SizedBox(height: 900),
                ScrollArrival(
                  controller: scroll,
                  child: const SizedBox(height: 200, child: Text('Section')),
                ),
                const SizedBox(height: 800),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0,
      );
      scroll.jumpTo(650);
      await tester.pump();
      await tester.pump();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
      await tester.pumpAndSettle();
      scroll.jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Reduced motion renders immediately and disables hero parallax', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      app(
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              HeroParallax(
                controller: scroll,
                child: const MotionEntrance(child: Text('Hero')),
              ),
              ScrollArrival(controller: scroll, child: const Text('Section')),
              const SizedBox(height: 1200),
            ],
          ),
        ),
        reduced: true,
      ),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
      Offset.zero,
    );
    final before = tester.getTopLeft(find.text('Hero')).dy;
    scroll.jumpTo(100);
    await tester.pump();
    expect(tester.getTopLeft(find.text('Hero')).dy, before - 100);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hero layers move at different depths while scrolling', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      app(
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              HeroParallax(
                controller: scroll,
                depth: .1,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Front'),
                ),
              ),
              HeroParallax(
                controller: scroll,
                depth: -.1,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Back'),
                ),
              ),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      ),
    );
    final front = tester.getTopLeft(find.text('Front')).dy;
    final back = tester.getTopLeft(find.text('Back')).dy;
    scroll.jumpTo(100);
    await tester.pump();
    final frontMove = tester.getTopLeft(find.text('Front')).dy - front;
    final backMove = tester.getTopLeft(find.text('Back')).dy - back;
    expect(frontMove, greaterThan(backMove + 10));
    expect(tester.takeException(), isNull);
  });
}
