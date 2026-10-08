import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/models/portfolio_validation.dart';

void main() {
  group('Explicitly clearing optional content', () {
    test('social and resume links distinguish omission from null', () {
      final profile = PortfolioSettings(
        name: 'Name',
        tagline: 'Hello',
        email: 'me@example.com',
        github: 'https://github.com/example',
        resumeUrl: '/resume.pdf',
      );
      expect(profile.copyWith().github, profile.github);
      expect(profile.copyWith(github: null).github, isNull);
      expect(profile.copyWith(resumeUrl: null).resumeUrl, isNull);
    });

    test('project link and image can both be removed', () {
      final project = Project(
        id: 'project',
        title: 'Title',
        category: '',
        description: '',
        techStack: [],
        link: 'https://example.com',
        imageUrl: 'https://example.com/image.png',
      );
      final cleared = project.copyWith(link: null, imageUrl: null);
      expect(cleared.link, isNull);
      expect(cleared.imageUrl, isNull);
      expect(project.copyWith().link, project.link);
    });

    test(
      'job expiry and overrides can be removed without changing creation time',
      () {
        final job = JobPosting(
          id: 'job',
          slug: 'example',
          title: 'Title',
          company: 'Company',
          description: 'Private',
          customTagline: 'Special',
          customAbout: 'Custom',
          expiresAt: DateTime.utc(2030),
        );
        final cleared = job.copyWith(
          description: null,
          customTagline: null,
          customAbout: null,
          expiresAt: null,
        );
        expect(cleared.description, isNull);
        expect(cleared.customTagline, isNull);
        expect(cleared.customAbout, isNull);
        expect(cleared.expiresAt, isNull);
        expect(job.copyWith().expiresAt, job.expiresAt);
        expect(cleared.createdAt, job.createdAt);
        expect(cleared.updatedAt, job.updatedAt);
      },
    );
  });

  group('Defensive document reads', () {
    test('known timestamps round trip for every model', () {
      final now = DateTime.utc(2026, 9, 30);
      for (final value in [now, Timestamp.fromDate(now)]) {
        final job = JobPosting.fromMap({
          'createdAt': value,
          'updatedAt': value,
          'expiresAt': value,
        }, 'id');
        expect(job.createdAt.isAtSameMomentAs(now), isTrue);
        expect(job.updatedAt.isAtSameMomentAs(now), isTrue);
        expect(job.expiresAt!.isAtSameMomentAs(now), isTrue);
        expect(
          JobPosting.fromMap(job.toMap(), 'id').createdAt.isAtSameMomentAs(now),
          isTrue,
        );
        expect(
          Project.fromMap({
            'createdAt': value,
          }, 'id').createdAt.isAtSameMomentAs(now),
          isTrue,
        );
        expect(
          Experience.fromMap({
            'createdAt': value,
          }, 'id').createdAt.isAtSameMomentAs(now),
          isTrue,
        );
      }
    });

    test('malformed fields do not crash the entire portfolio', () {
      final settings = PortfolioSettings.fromMap({
        'name': 42,
        'email': [],
        'github': {},
        'skillGroups': 'broken',
        'highlights': [
          null,
          7,
          {'label': false, 'value': 4},
        ],
        'awards': [1, 'Award'],
      });
      expect(settings.name, '');
      expect(settings.github, isNull);
      expect(settings.awards, ['Award']);
      expect(settings.highlights.single.label, '');
      final job = JobPosting.fromMap({
        'isActive': 'true',
        'expiresAt': 'bad',
        'createdAt': 123,
      }, 'id');
      expect(job.isActive, isFalse);
      expect(job.expiresAt!.isBefore(DateTime.utc(2020)), isTrue);
      expect(
        Project.fromMap({'order': 3.2, 'techStack': false}, 'id').order,
        0,
      );
    });

    test(
      'older documents default the optional case-study and availability fields',
      () {
        final project = Project.fromMap({'title': 'Legacy'}, 'id');
        expect(
          [
            project.problem,
            project.contribution,
            project.outcome,
            project.sourceUrl,
          ],
          ['', '', '', ''],
        );
        expect(PortfolioSettings.fromMap({}).availability, '');
      },
    );
  });

  test(
    'public projections never serialize private application information',
    () {
      final job = JobPosting(
        id: 'private-id',
        slug: 'share',
        title: 'Private role',
        company: 'Private company',
        description: 'Sensitive notes',
        viewCount: 91,
        projectIds: ['project'],
      );
      expect(job.toPublicMap().keys.toSet(), {
        'slug',
        'projectIds',
        'experienceIds',
        'customTagline',
        'customAbout',
        'isActive',
        'createdAt',
        'updatedAt',
        'expiresAt',
      });
      expect(job.toPublicMap().values, isNot(contains('Sensitive notes')));
      final public = JobPosting.fromPublicMap(job.toMap(), 'share');
      expect(public.title, '');
      expect(public.company, '');
      expect(public.description, isNull);
      expect(public.viewCount, 0);
      expect(public.id, 'share');
    },
  );

  test('job URL preserves existing query parameters and encodes its value', () {
    final job = JobPosting(
      id: 'id',
      slug: 'a-b',
      title: 'Title',
      company: 'Company',
    );
    final uri = Uri.parse(
      job.getUrl('https://example.com/portfolio?theme=dark#work'),
    );
    expect(uri.queryParameters, {'theme': 'dark', 'job': 'a-b'});
    expect(uri.fragment, 'work');
  });

  test(
    'custom bio resolves over the modern summary and legacy about fallback',
    () {
      final settings = PortfolioSettings(
        name: 'Name',
        tagline: 'Default',
        email: 'me@example.com',
        summary: 'Summary',
        about: 'Legacy',
      );
      final job = JobPosting(
        id: 'id',
        slug: 'share',
        title: 'Title',
        company: 'Company',
        customAbout: 'Tailored',
      );
      PortfolioViewData view(JobPosting? j) => PortfolioViewData(
        settings: settings,
        projects: [],
        experiences: [],
        jobPosting: j,
      );
      expect(view(null).about, 'Summary');
      expect(view(job).about, 'Tailored');
      expect(view(job.copyWith(customAbout: null)).about, 'Summary');
    },
  );

  group('Publication validation', () {
    test('blocks invalid answer indices and unsafe links', () {
      final settings = PortfolioSettings(
        name: 'Name',
        tagline: 'Hello',
        email: 'me@example.com',
      );
      expect(
        () => validateSettings(
          settings.copyWith(
            quiz: [
              QuizQuestion(q: 'Q', options: ['A', 'B'], answer: 2),
            ],
          ),
        ),
        throwsFormatException,
      );
      expect(
        () =>
            validateSettings(settings.copyWith(github: 'javascript:alert(1)')),
        throwsFormatException,
      );
      expect(
        () => validateSettings(settings.copyWith(resumeUrl: '/resume.pdf')),
        returnsNormally,
      );
      expect(
        () => validateSettings(
          settings.copyWith(resumeUrl: '//untrusted.example'),
        ),
        throwsFormatException,
      );
    });
    test(
      'supports chunkable selections but rejects duplicate or invalid IDs',
      () {
        expect(
          () => validateDocumentIds(
            List.generate(65, (i) => 'project-$i'),
            'Projects',
          ),
          returnsNormally,
        );
        expect(
          () => validateDocumentIds(['same', 'same'], 'Projects'),
          throwsFormatException,
        );
        expect(
          () => validateDocumentIds(['../secret'], 'Projects'),
          throwsFormatException,
        );
        expect(
          () =>
              validateDocumentIds(List.generate(101, (i) => 'p$i'), 'Projects'),
          throwsFormatException,
        );
      },
    );
  });
}
