import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/widgets/broadside/primitives.dart';

void main() {
  Widget wrap(Widget c) => MaterialApp(home: Scaffold(body: c));

  testWidgets('Kicker renders uppercased text', (t) async {
    await t.pumpWidget(wrap(const Kicker('open to work', dark: true)));
    expect(find.text('OPEN TO WORK'), findsOneWidget);
  });

  testWidgets('SectionHead shows number + title + sub', (t) async {
    await t.pumpWidget(wrap(const SectionHead(number: '§ 01', title: 'WORK', sub: 'newest first', dark: true)));
    expect(find.text('§ 01'.toUpperCase()), findsOneWidget);
    expect(find.text('WORK'), findsOneWidget);
  });

  testWidgets('BtnPrimary fires onTap', (t) async {
    var tapped = false;
    await t.pumpWidget(wrap(BtnPrimary(label: 'Email me', dark: true, onTap: () => tapped = true)));
    await t.tap(find.byType(BtnPrimary));
    expect(tapped, isTrue);
  });
}
