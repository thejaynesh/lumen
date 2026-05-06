import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/providers/experience_provider.dart';
import 'package:lumen/providers/narrator_provider.dart';
import 'package:lumen/screens/home/utils/mock_data.dart';

void main() {
  group('PortfolioSettings serialization', () {
    test('defaultSettings round-trips through toMap/fromMap', () {
      final original = PortfolioSettings.defaultSettings();
      final restored = PortfolioSettings.fromMap(original.toMap());
      expect(restored.name, equals(original.name));
      expect(restored.tagline, equals(original.tagline));
      expect(restored.email, equals(original.email));
      expect(restored.stats.length, equals(original.stats.length));
      expect(
        restored.defaultProjectIds,
        equals(original.defaultProjectIds),
      );
    });

    test('Stat serializes and deserializes correctly', () {
      final stat = Stat(value: '10+', label: 'Projects');
      final restored = Stat.fromMap(stat.toMap());
      expect(restored.value, equals('10+'));
      expect(restored.label, equals('Projects'));
    });
  });

  group('Project serialization', () {
    test('copyWith preserves unset fields', () {
      final project = Project(
        id: 'p1',
        title: 'Test Project',
        category: 'Web',
        description: 'A test project',
        techStack: ['Flutter'],
      );
      final updated = project.copyWith(title: 'Updated');
      expect(updated.id, equals('p1'));
      expect(updated.category, equals('Web'));
      expect(updated.title, equals('Updated'));
    });
  });

  group('ExperienceProvider', () {
    test('starts with manual mode and no selection', () {
      final provider = ExperienceProvider();
      expect(provider.mode, equals(ExperienceMode.manual));
      expect(provider.hasSelectedMode, isFalse);
    });

    test('setMode updates mode and marks selection', () {
      final provider = ExperienceProvider();
      provider.setMode(ExperienceMode.narrator);
      expect(provider.mode, equals(ExperienceMode.narrator));
      expect(provider.hasSelectedMode, isTrue);
    });

    test('reset clears hasSelectedMode', () {
      final provider = ExperienceProvider();
      provider.setMode(ExperienceMode.narrator);
      provider.reset();
      expect(provider.hasSelectedMode, isFalse);
    });
  });

  group('NarratorProvider', () {
    test('starts inactive and not playing', () {
      final provider = NarratorProvider();
      expect(provider.isActive, isFalse);
      expect(provider.isPlaying, isFalse);
    });

    test('stop resets all state', () {
      final provider = NarratorProvider();
      provider.stop();
      expect(provider.isActive, isFalse);
      expect(provider.isPlaying, isFalse);
      expect(provider.currentIndex, equals(0));
      expect(provider.sectionProgress, equals(0.0));
    });

    test('totalProgress is 0 when no sections registered', () {
      final provider = NarratorProvider();
      expect(provider.totalProgress, equals(0.0));
    });
  });

  group('MockPortfolioData', () {
    test('returns non-empty projects and experiences', () {
      final data = MockPortfolioData.getMockData();
      expect(data.projects, isNotEmpty);
      expect(data.experiences, isNotEmpty);
      expect(data.settings.name, isNotEmpty);
    });

    test('mock data stats are populated', () {
      final data = MockPortfolioData.getMockData();
      expect(data.settings.stats, isNotEmpty);
    });
  });
}
