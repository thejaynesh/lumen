import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/screens/manual/index_portfolio.dart';
import 'package:lumen/screens/manual/sections/hero.dart';
import 'package:lumen/widgets/broadside/primitives.dart';
import 'package:lumen/theme/app_theme.dart';
import 'package:lumen/widgets/broadside/project_artwork.dart';
import 'package:lumen/screens/manual/sections/work.dart';

PortfolioViewData _profile() => PortfolioViewData(
  settings: PortfolioSettings(
    name: 'Jaynesh Bhandari',
    role: 'Software developer',
    tagline: 'Java and Spring Boot services. React and Flutter applications.',
    email: 'test@example.com',
  ),
  projects: [
    Project(
      id: 'click',
      title: 'ClickDrobe',
      category: 'Mobile application',
      techStack: ['Flutter'],
      description: 'A wardrobe application.',
    ),
    Project(
      id: 'algo',
      title: 'AlgoView',
      category: 'Web application',
      description: 'Explore algorithm execution.',
      techStack: ['React', 'TypeScript'],
      contribution: 'Background execution with web workers.',
    ),
  ],
  experiences: [
    Experience(
      id: 'tcs',
      role: 'Software engineer',
      company: 'TCS',
      period: '2022–2023',
      description: 'Backend services.',
    ),
  ],
);

Widget _app(Widget child, {bool reduced = false}) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: child,
    ),
  ),
);

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Email floats only after the original leaves and hides at contact, reduced $reduced',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _app(
            IndexPortfolio(data: _profile(), dark: false, onToggleTheme: () {}),
            reduced: reduced,
          ),
        );
        await tester.pumpAndSettle();
        final floating = find.byKey(const ValueKey('floating-email'));
        final originalKey = tester
            .widget<BroadsideHero>(find.byType(BroadsideHero))
            .ctaKey;
        expect(find.byKey(originalKey).hitTestable(), findsOneWidget);
        expect(floating.hitTestable(), findsNothing);
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -90),
        );
        await tester.pumpAndSettle();
        expect(floating.hitTestable(), findsNothing);
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -650),
        );
        await tester.pumpAndSettle();
        expect(floating.hitTestable(), findsOneWidget);
        expect(
          tester.widget<BtnPrimary>(floating).href,
          'mailto:test@example.com',
        );
        await tester.tap(find.text('Contact').first);
        await tester.pumpAndSettle();
        expect(floating.hitTestable(), findsNothing);
        await tester.tap(find.text('Jaynesh Bhandari').first);
        await tester.pumpAndSettle();
        expect(find.byKey(originalKey).hitTestable(), findsOneWidget);
        expect(floating.hitTestable(), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Hero folder reaches one project viewer and tabs switch its content',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          IndexPortfolio(data: _profile(), dark: false, onToggleTheme: () {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('project-folder')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('project-tab-click')).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('A wardrobe application.'), findsOneWidget);
      expect(find.text('Explore algorithm execution.'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('project-tab-algo')));
      await tester.pumpAndSettle();
      expect(find.text('A wardrobe application.'), findsNothing);
      expect(find.text('Explore algorithm execution.'), findsOneWidget);
      expect(find.text('Sort array').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Project details'));
      await tester.pumpAndSettle();
      expect(
        find.text('Background execution with web workers.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Mobile menu reaches experience and folder supports activation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(IndexPortfolio(data: _profile(), dark: true, onToggleTheme: () {})),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('project-folder')));
    await tester.tap(find.byKey(const ValueKey('project-folder')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('project-tab-click')).hitTestable(),
      findsOneWidget,
    );
    final nextProject = find.byTooltip('Next project');
    await tester.tap(
      nextProject.evaluate().isNotEmpty
          ? nextProject
          : find.byKey(const ValueKey('project-tab-algo')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Explore algorithm execution.'), findsOneWidget);
    expect(find.text('A wardrobe application.'), findsNothing);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Experience').last);
    await tester.pumpAndSettle();
    expect(find.text('Where I’ve worked.').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Project selection follows its ID and recovers when removed', (
    tester,
  ) async {
    final projects = _profile().projects;
    Widget viewer(List<Project> items) => _app(
      SingleChildScrollView(child: BroadsideWork(projects: items, dark: false)),
    );
    await tester.pumpWidget(viewer(projects));
    await tester.tap(find.byKey(const ValueKey('project-tab-algo')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(viewer(projects.reversed.toList()));
    await tester.pumpAndSettle();
    expect(find.text('Explore algorithm execution.'), findsOneWidget);
    await tester.pumpWidget(viewer([projects.first]));
    await tester.pumpAndSettle();
    expect(find.text('A wardrobe application.'), findsOneWidget);
    expect(find.text('Explore algorithm execution.'), findsNothing);
    await tester.pumpWidget(viewer([]));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);
    expect(
      find.text('Project details will be available here soon.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sorting demo works immediately with reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Center(
          child: SizedBox(width: 340, child: AlgorithmSortingDemo(dark: false)),
        ),
        reduced: true,
      ),
    );
    expect(find.text('Input: [3, 1, 4, 2]'), findsOneWidget);
    await tester.tap(find.text('Sort array'));
    await tester.pump();
    expect(find.text('Output: [1, 2, 3, 4]'), findsOneWidget);
    final first = tester
        .getTopLeft(find.byKey(const ValueKey('sort-card-1')))
        .dx;
    final last = tester
        .getTopLeft(find.byKey(const ValueKey('sort-card-4')))
        .dx;
    expect(first, lessThan(last));
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('sort-card-1'))).dx,
      first,
    );
    await tester.tap(find.text('Reset array'));
    await tester.pump();
    expect(find.text('Input: [3, 1, 4, 2]'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
