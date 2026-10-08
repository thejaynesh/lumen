import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/services/portfolio_service.dart';

class _PortfolioServiceFixture extends PortfolioService {
  _PortfolioServiceFixture({super.recordProfileView});

  PortfolioSettings settings = PortfolioSettings(
    name: 'Name',
    tagline: 'Tagline',
    email: 'me@example.com',
  );
  JobPosting? profile;
  final requests = <String>[];
  bool failContent = false;

  @override
  Future<PortfolioSettings> getSettings() async => settings;
  @override
  Future<JobPosting?> getJobBySlug(String slug) async => profile;
  @override
  Future<List<Project>> getActiveProjects() async {
    requests.add('active projects');
    return [];
  }

  @override
  Future<List<Experience>> getActiveExperience() async {
    requests.add('active experience');
    return [];
  }

  @override
  Future<List<Project>> getProjectsByIds(List<String> ids) async {
    requests.add('projects:${ids.join(',')}');
    if (failContent) throw StateError('Offline');
    return [];
  }

  @override
  Future<List<Experience>> getExperienceByIds(List<String> ids) async {
    requests.add('experience:${ids.join(',')}');
    return [];
  }
}

void main() {
  test(
    'curated defaults use their explicit order and empty defaults use active content',
    () async {
      final service = _PortfolioServiceFixture();
      service.settings = service.settings.copyWith(
        defaultProjectIds: ['second', 'first'],
      );
      final data = await service.getPortfolioViewData(null);
      expect(data.isJobView, isFalse);
      expect(service.requests, ['projects:second,first', 'active experience']);
    },
  );

  test(
    'missing or expired public link falls back to defaults without tracking',
    () async {
      final tracked = <String>[];
      final service = _PortfolioServiceFixture(
        recordProfileView: (slug) async => tracked.add(slug),
      );
      final data = await service.getPortfolioViewData('unavailable');
      expect(data.isJobView, isFalse);
      expect(service.requests, ['active projects', 'active experience']);
      expect(tracked, isEmpty);
    },
  );

  test(
    'loaded profile uses only its selections and slow analytics cannot block rendering',
    () async {
      final tracking = Completer<void>();
      final tracked = <String>[];
      final service = _PortfolioServiceFixture(
        recordProfileView: (slug) async {
          tracked.add(slug);
          await tracking.future;
        },
      );
      service.profile = JobPosting(
        id: 'share',
        slug: 'share',
        title: '',
        company: '',
        projectIds: ['one'],
      );
      final data = await service
          .getPortfolioViewData('share')
          .timeout(const Duration(seconds: 1));
      expect(data.isJobView, isTrue);
      expect(service.requests, ['projects:one', 'experience:']);
      expect(tracked, ['share']);
      await service.getPortfolioViewData('share');
      expect(tracked, ['share']);
      tracking.complete();
    },
  );

  test('failed content retrieval does not count a successful view', () async {
    final tracked = <String>[];
    final service = _PortfolioServiceFixture(
      recordProfileView: (slug) async => tracked.add(slug),
    );
    service.profile = JobPosting(
      id: 'share',
      slug: 'share',
      title: '',
      company: '',
    );
    service.failContent = true;
    await expectLater(service.getPortfolioViewData('share'), throwsStateError);
    expect(tracked, isEmpty);
  });
}
