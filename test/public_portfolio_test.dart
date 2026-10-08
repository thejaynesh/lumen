import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/providers/experience_provider.dart';
import 'package:lumen/providers/theme_provider.dart';
import 'package:lumen/screens/automated/automated_mode.dart';
import 'package:lumen/screens/lucky/lucky_mode.dart';
import 'package:lumen/screens/manual/manual_page.dart';
import 'package:lumen/screens/manual/sections/hero.dart';
import 'package:lumen/screens/manual/sections/nav.dart';
import 'package:lumen/screens/manual/sections/work.dart';
import 'package:lumen/services/portfolio_service.dart';
import 'package:lumen/theme/app_theme.dart';
import 'package:provider/provider.dart';

PortfolioSettings _settings() => PortfolioSettings(
  name: 'Test Engineer',
  role: 'Software engineer',
  tagline: 'Build thoughtful products.',
  about: 'General profile.',
  email: 'test@example.com',
  availability: 'Available for collaboration',
  highlights: [Highlight(label: 'Projects', value: '2', note: 'Selected work')],
  education: [
    EducationEntry(
      when: '2020–2024',
      where: 'University',
      what: 'Computer science',
    ),
  ],
  skillGroups: [
    SkillGroup(category: 'Languages', items: ['Dart', 'Python']),
  ],
  quiz: [
    QuizQuestion(q: 'Which language?', options: ['Dart', 'Python'], answer: 0),
  ],
  personality: [PersonalityItem(label: 'Outside work', value: 'Walking')],
);

PortfolioViewData _data({String? slug, int projectCount = 1}) =>
    PortfolioViewData(
      settings: _settings(),
      projects: List.generate(
        projectCount,
        (i) => Project(
          id: 'project-$i',
          title: 'Project $i',
          category: 'Software',
          description: 'A real project description.',
          techStack: ['Dart'],
          tag: i == 0 ? 'Hackathon' : '',
          problem: 'A problem to solve.',
          contribution: 'The implementation work.',
          outcome: 'A documented outcome.',
        ),
      ),
      experiences: [
        Experience(
          id: 'work',
          role: 'Engineer',
          company: 'Company',
          period: '2024–2025',
          description: 'Product development.',
          highlights: ['Shipped a reliable service.'],
        ),
      ],
      jobPosting: slug == null
          ? null
          : JobPosting(
              id: slug,
              slug: slug,
              title: 'Role',
              company: 'Company',
              customTagline: 'Tailored introduction for $slug',
              customAbout: 'Tailored background for $slug',
            ),
    );

class _FakePortfolioService extends PortfolioService {
  final calls = <String?>[];
  bool fail = false;
  int settingsCalls = 0;
  int projectCount = 1;
  @override
  Future<PortfolioViewData> getPortfolioViewData(String? jobId) async {
    calls.add(jobId);
    if (fail) throw StateError('Test unavailable');
    return _data(slug: jobId, projectCount: projectCount);
  }

  @override
  Future<PortfolioSettings> getSettings() async {
    settingsCalls++;
    if (fail) throw StateError('Test unavailable');
    return _settings();
  }
}

Widget _app(Widget child, {_FakePortfolioService? service}) => MultiProvider(
  providers: [
    Provider<PortfolioService>.value(value: service ?? _FakePortfolioService()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => ExperienceProvider()),
  ],
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: SelectionArea(child: child)),
  ),
);

void main() {
  testWidgets('Hero shows tailored copy and configured availability', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(
          child: BroadsideHero(
            data: _data(slug: 'role-one'),
            dark: false,
            ctaKey: GlobalKey(),
            onViewWork: () {},
          ),
        ),
      ),
    );
    expect(find.text('Tailored introduction for role-one'), findsOneWidget);
    expect(find.text('Tailored background for role-one'), findsOneWidget);
    expect(find.text('Available for collaboration'), findsOneWidget);
    expect(find.text('OPEN TO WORK →'), findsNothing);
  });

  testWidgets('Mobile navigation keeps the main sections reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var workSelected = false;
    void noop() {}
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.topCenter,
          child: BroadsideNav(
            dark: false,
            scrolled: false,
            name: 'Test Engineer',
            onWork: () => workSelected = true,
            onExperience: noop,
            onAwards: noop,
            onSkills: noop,
            onEducation: noop,
            onCertifications: noop,
            onContact: noop,
            onToggle: noop,
            onHome: noop,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Experience'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(workSelected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Case study details reveal real content and keep hackathon projects',
    (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: BroadsideWork(projects: _data().projects, dark: false),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.header == true,
          ),
          matching: find.text('Project 0'),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Project details'));
      await tester.tap(find.text('Project details'));
      await tester.pumpAndSettle();
      expect(find.text('A problem to solve.'), findsOneWidget);
      expect(find.text('The implementation work.'), findsOneWidget);
      expect(find.text('A documented outcome.'), findsOneWidget);
    },
  );

  testWidgets('Manual portfolio reloads when the application profile changes', (
    tester,
  ) async {
    final service = _FakePortfolioService();
    await tester.pumpWidget(
      _app(const ManualPage(jobId: 'first'), service: service),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tailored introduction for first'), findsOneWidget);
    await tester.pumpWidget(
      _app(const ManualPage(jobId: 'second'), service: service),
    );
    await tester.pumpAndSettle();
    expect(service.calls, ['first', 'second']);
    expect(find.text('Tailored introduction for second'), findsOneWidget);
    expect(find.text('Tailored introduction for first'), findsNothing);
    expect(find.text('Shipped a reliable service.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Manual portfolio reports failures and retries successfully', (
    tester,
  ) async {
    final service = _FakePortfolioService()..fail = true;
    await tester.pumpWidget(_app(const ManualPage(), service: service));
    await tester.pumpAndSettle();
    expect(find.text('A moment, please.'), findsOneWidget);
    service.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(BroadsideHero), findsOneWidget);
    expect(service.calls.length, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Portfolio reflows at narrow width with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: const ManualPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BroadsideHero), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tour includes every project and keeps tailored copy', (
    tester,
  ) async {
    final service = _FakePortfolioService()..projectCount = 5;
    await tester.pumpWidget(
      _app(const AutomatedMode(jobId: 'tour'), service: service),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tailored introduction for tour'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byTooltip('Next slide'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Project 4'), findsWidgets);
    expect(find.textContaining('drop image'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quiz recovers from loading failure and completes on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _FakePortfolioService()..fail = true;
    await tester.pumpWidget(_app(const LuckyMode(), service: service));
    await tester.pumpAndSettle();
    expect(find.text('This page could not load.'), findsOneWidget);
    service.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start 1-question quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dart'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('See results →'));
    await tester.tap(find.text('See results →'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
