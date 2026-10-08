import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/widgets/broadside/primitives.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('Kicker renders uppercased text', (tester) async {
    await tester.pumpWidget(wrap(const Kicker('open to work', dark: true)));
    expect(find.text('OPEN TO WORK'), findsOneWidget);
  });

  testWidgets('Section heading renders its title and context', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SectionHead(
          number: '01',
          title: 'Work',
          sub: 'Selected projects',
          dark: true,
        ),
      ),
    );
    expect(find.text('SELECTED PROJECTS'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('Primary button supports keyboard activation', (tester) async {
    var activated = false;
    await tester.pumpWidget(
      wrap(
        BtnPrimary(
          label: 'Explore work',
          dark: false,
          onTap: () => activated = true,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activated, isTrue);
  });

  testWidgets('Ghost button supports keyboard activation', (tester) async {
    var activated = false;
    await tester.pumpWidget(
      wrap(
        BtnGhost(label: 'Read more', dark: true, onTap: () => activated = true),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activated, isTrue);
  });

  testWidgets('An absent screenshot does not render a prototype placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ImagePlaceholder(aspect: 1.6, label: 'Project', dark: false)),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('drop image'), findsNothing);
  });
}
