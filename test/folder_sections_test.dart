import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/screens/manual/sections/experience.dart';
import 'package:lumen/screens/manual/sections/education.dart';
import 'package:lumen/screens/manual/sections/certifications.dart';
import 'package:lumen/theme/app_theme.dart';
import 'package:lumen/widgets/broadside/folder_tabs.dart';

Widget app(Widget child, {bool dark = false, double scale = 1}) => MaterialApp(
  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
  home: Scaffold(
    body: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(22), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'Experience tabs show only the selected role, dates and highlights',
    (tester) async {
      await tester.pumpWidget(
        app(
          BroadsideExperience(
            dark: false,
            experiences: [
              Experience(
                id: 'one',
                company: 'First company',
                role: 'Backend engineer',
                period: '2020–2022',
                description: 'Built services.',
                highlights: ['First result'],
              ),
              Experience(
                id: 'two',
                company: 'Second company',
                role: 'Teaching assistant',
                period: '2023–2024',
                description: 'Taught software.',
                highlights: ['Second result'],
              ),
            ],
          ),
        ),
      );
      expect(find.text('Built services.'), findsOneWidget);
      expect(find.text('Taught software.'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('experience-tab-two')));
      await tester.pumpAndSettle();
      expect(find.text('Built services.'), findsNothing);
      expect(find.text('2020–2022'), findsNothing);
      expect(find.text('Teaching assistant'), findsOneWidget);
      expect(find.text('2023–2024'), findsOneWidget);
      expect(find.text('Second result'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Every tab has a visible shape and keyboard selection works', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        FolderTabs(
          dark: false,
          tabPrefix: 'test',
          entries: const [
            FolderEntry(id: 'one', label: 'First', child: Text('First sheet')),
            FolderEntry(
              id: 'two',
              label: 'Second',
              child: Text('Second sheet'),
            ),
          ],
        ),
      ),
    );
    for (final id in ['one', 'two']) {
      final tab = find.byKey(ValueKey('test-tab-$id'));
      final surface = tester.widget<AnimatedContainer>(
        find.descendant(of: tab, matching: find.byType(AnimatedContainer)),
      );
      final decoration = surface.decoration! as BoxDecoration;
      expect(decoration.color!.a, 1);
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Second sheet'), findsOneWidget);
    expect(find.text('First sheet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 800.0, 1280.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'Credentials align at width $width, dark $dark, enlarged text',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            app(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BroadsideEducation(
                    dark: dark,
                    education: [
                      EducationEntry(
                        where: 'University',
                        what: 'M.S. in Computer Science',
                        when: '2022–2024',
                      ),
                      EducationEntry(
                        where: 'A much longer university name',
                        what: 'Engineering',
                        when: '2018–2022',
                      ),
                    ],
                  ),
                  BroadsideCertifications(
                    dark: dark,
                    certifications: [
                      Certification(
                        name: 'Cloud fundamentals',
                        issuer: 'Provider',
                        year: '2024',
                      ),
                      Certification(
                        name: 'A longer professional certification',
                        issuer: 'Professional institute',
                        year: '2025',
                      ),
                    ],
                  ),
                ],
              ),
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          for (final label in [
            'Education',
            'University',
            'A much longer university name',
            'Certifications',
            'Cloud fundamentals',
            'A longer professional certification',
          ]) {
            expect(
              tester.getTopLeft(find.text(label)).dx,
              22,
              reason: '$label should share the section left edge',
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Long folder labels remain reachable on narrow screens with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          FolderTabs(
            dark: true,
            tabPrefix: 'long',
            entries: const [
              FolderEntry(
                id: 'one',
                label: 'Northeastern University',
                child: Text('First role'),
              ),
              FolderEntry(
                id: 'two',
                label: 'Tata Consultancy Services',
                child: Text('Second role'),
              ),
            ],
          ),
          dark: true,
          scale: 2,
        ),
      );
      await tester.drag(find.byType(TabBar), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('long-tab-two')));
      await tester.pumpAndSettle();
      expect(find.text('Second role'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous long'));
      await tester.pumpAndSettle();
      expect(find.text('First role'), findsOneWidget);
      await tester.tap(find.byTooltip('Next long'));
      await tester.pumpAndSettle();
      expect(find.text('Second role'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
