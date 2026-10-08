import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/screens/admin/admin_dashboard.dart';
import 'package:lumen/screens/admin/editor_fields.dart';
import 'package:lumen/screens/admin/form_dialogs.dart';
import 'package:lumen/services/portfolio_service.dart';

class _PortfolioFake extends PortfolioService {
  Project? savedProject;
  JobPosting? savedJob;
  PortfolioSettings? savedSettings;
  Object? failure;
  PortfolioSettings settings = PortfolioSettings(
    name: 'Owner',
    tagline: 'Builds useful software',
    email: 'owner@example.com',
  );
  List<Project> projects = [
    Project(
      id: 'first',
      title: 'First',
      category: 'Product',
      description: 'Description',
      techStack: const [],
    ),
    Project(
      id: 'second',
      title: 'Second',
      category: 'Product',
      description: 'Description',
      techStack: const [],
    ),
  ];

  @override
  Future<void> updateProject(Project project) async {
    if (failure != null) throw failure!;
    savedProject = project;
  }

  @override
  Future<void> updateJob(JobPosting job) async {
    if (failure != null) throw failure!;
    savedJob = job;
  }

  @override
  Future<void> updateSettings(PortfolioSettings value) async {
    if (failure != null) throw failure!;
    savedSettings = value;
  }

  @override
  Future<PortfolioSettings> getSettings() async => settings;
  @override
  Future<List<Project>> getAllProjects() async => projects;
  @override
  Future<List<Experience>> getAllExperience() async => [];
  @override
  Future<bool> isSlugAvailable(String slug, {String? excludeId}) async => true;
  @override
  Stream<List<Project>> watchProjects() => Stream.value(projects);
  @override
  Future<void> deleteProject(String id) async {
    if (failure != null) throw failure!;
  }
}

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is AdminTextField && widget.label == label,
  ),
  matching: find.byType(TextFormField),
);

Future<void> _openEditor(
  WidgetTester tester,
  _PortfolioFake service,
  Widget editor,
) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    Provider<PortfolioService>.value(
      value: service,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () =>
                  showDialog<void>(context: context, builder: (_) => editor),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

Future<void> _expand(WidgetTester tester, String title) async {
  await tester.ensureVisible(find.text(title));
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = _field(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

void main() {
  testWidgets(
    'homepage selection reorders, removes archived references, and falls back to all published',
    (tester) async {
      var selection = ['one', 'two'];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: OrderedContentPicker(
                  label: 'Projects',
                  choices: const [
                    ContentChoice(id: 'one', label: 'First'),
                    ContentChoice(id: 'two', label: 'Second', isActive: false),
                  ],
                  selected: selection,
                  emptyMeansAll: true,
                  onChanged: (values) => setState(() => selection = values),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Move First down'));
      await tester.pump();
      expect(selection, ['two', 'one']);
      await tester.tap(find.byTooltip('Remove Second'));
      await tester.pump();
      expect(selection, ['one']);
      await tester.tap(find.text('Use all published items'));
      await tester.pump();
      expect(selection, isEmpty);
      expect(
        find.text('All published items will appear in their display order.'),
        findsOneWidget,
      );
      expect(find.text('Second'), findsNothing);
    },
  );

  testWidgets(
    'structured list editing preserves edited values through reorder and removal',
    (tester) async {
      var values = <String>['Dart', 'Java'];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StringListEditor(
                initialValues: values,
                itemLabel: 'Skill',
                onChanged: (next) => values = next,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'TypeScript');
      await tester.tap(find.byTooltip('Move Skill 1 down'));
      await tester.pump();
      expect(values, ['Java', 'TypeScript']);
      expect(find.widgetWithText(TextFormField, 'TypeScript'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove Skill 1'));
      await tester.pump();
      expect(values, ['TypeScript']);
    },
  );

  testWidgets(
    'project editor clears optional URLs and normalizes a bare source URL',
    (tester) async {
      final service = _PortfolioFake();
      final project = service.projects.first.copyWith(
        link: 'https://old.example.com',
        imageUrl: 'https://old.example.com/image.png',
      );
      await _openEditor(tester, service, ProjectFormDialog(project: project));
      await _expand(tester, 'Links and image');
      await _enter(tester, 'Live project URL', '');
      await _enter(tester, 'Image URL', '');
      await _enter(tester, 'Source code URL', 'github.com/owner/project');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(service.savedProject?.link, isNull);
      expect(service.savedProject?.imageUrl, isNull);
      expect(
        service.savedProject?.sourceUrl,
        'https://github.com/owner/project',
      );
      expect(find.byType(ProjectFormDialog), findsNothing);
    },
  );

  testWidgets('invalid project URL cannot be saved', (tester) async {
    final service = _PortfolioFake();
    await _openEditor(
      tester,
      service,
      ProjectFormDialog(project: service.projects.first),
    );
    await _expand(tester, 'Links and image');
    await _enter(tester, 'Live project URL', 'javascript:alert(1)');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(service.savedProject, isNull);
    expect(find.text('Check the marked fields before saving.'), findsOneWidget);
  });

  testWidgets('save failure preserves form changes and allows retry', (
    tester,
  ) async {
    final service = _PortfolioFake()
      ..failure = StateError('Please retry this save.');
    await _openEditor(
      tester,
      service,
      ProjectFormDialog(project: service.projects.first),
    );
    await _enter(tester, 'Title', 'Revised title');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Please retry this save.'), findsOneWidget);
    service.failure = null;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(service.savedProject?.title, 'Revised title');
  });

  testWidgets(
    'editing an expired link opens date picker and clears expiry and overrides',
    (tester) async {
      final service = _PortfolioFake();
      final job = JobPosting(
        id: 'job',
        slug: 'example-job',
        title: 'Engineer',
        company: 'Example',
        expiresAt: DateTime(2001),
        customTagline: 'Old tagline',
        customAbout: 'Old summary',
      );
      await _openEditor(tester, service, JobFormDialog(job: job));
      await tester.ensureVisible(find.text('Set expiry'));
      await tester.tap(find.text('Set expiry'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Clear expiry'));
      await tester.tap(find.text('Clear expiry'));
      await _enter(tester, 'Custom introduction', '');
      await _enter(tester, 'Custom summary', '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(service.savedJob?.expiresAt, isNull);
      expect(service.savedJob?.customTagline, isNull);
      expect(service.savedJob?.customAbout, isNull);
      expect(service.savedJob, isNotNull);
    },
  );

  testWidgets(
    'homepage editor saves ordering without overwriting the latest profile',
    (tester) async {
      final service = _PortfolioFake();
      final old = service.settings.copyWith(
        defaultProjectIds: ['first', 'second'],
      );
      await _openEditor(tester, service, DefaultsFormDialog(settings: old));
      await tester.tap(find.byTooltip('Move First down'));
      await tester.pump();
      service.settings = service.settings.copyWith(name: 'Updated elsewhere');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(service.savedSettings?.defaultProjectIds, ['second', 'first']);
      expect(service.savedSettings?.name, 'Updated elsewhere');
    },
  );

  testWidgets(
    'profile editor saves certifications and availability and clears a social link',
    (tester) async {
      final service = _PortfolioFake();
      final settings = service.settings.copyWith(
        github: 'https://github.com/old-profile',
        certifications: [
          Certification(
            name: 'Existing credential',
            issuer: 'Issuer',
            year: '2024',
          ),
        ],
      );
      await _openEditor(
        tester,
        service,
        SettingsFormDialog(settings: settings),
      );
      await _enter(tester, 'Availability', 'Open to collaboration');
      await _expand(tester, 'Contact and links');
      await _enter(tester, 'GitHub URL', '');
      await _expand(tester, 'Certifications');
      await _enter(tester, 'Certification name', 'Updated credential');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(service.savedSettings?.availability, 'Open to collaboration');
      expect(service.savedSettings?.github, isNull);
      expect(
        service.savedSettings?.certifications.single.name,
        'Updated credential',
      );
    },
  );

  testWidgets(
    'reordering quiz options keeps the correct answer attached to its value',
    (tester) async {
      final service = _PortfolioFake();
      final settings = service.settings.copyWith(
        quiz: [
          QuizQuestion(
            q: 'Choose the answer',
            options: ['Correct', 'Other'],
            answer: 0,
          ),
        ],
      );
      await _openEditor(
        tester,
        service,
        SettingsFormDialog(settings: settings),
      );
      await _expand(tester, 'Quiz');
      await tester.ensureVisible(find.byTooltip('Move Option 1 down'));
      await tester.tap(find.byTooltip('Move Option 1 down'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final question = service.savedSettings!.quiz.single;
      expect(question.options, ['Other', 'Correct']);
      expect(question.answer, 1);
      expect(question.options[question.answer], 'Correct');
    },
  );

  testWidgets(
    'project library fits a narrow screen and archive is confirmed with recoverable errors',
    (tester) async {
      final service = _PortfolioFake()
        ..failure = StateError('Archive failed. Retry.');
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        Provider<PortfolioService>.value(
          value: service,
          child: const MaterialApp(home: Scaffold(body: ProjectsTab())),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Archive').first);
      await tester.pumpAndSettle();
      expect(find.text('Archive content?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
      await tester.pumpAndSettle();
      expect(find.text('Archive failed. Retry.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
