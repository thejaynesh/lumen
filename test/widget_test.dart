import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/models/portfolio_data.dart';
import 'package:lumen/providers/experience_provider.dart';
import 'package:lumen/providers/narrator_provider.dart';

void main() {
  group('Broadside model serialization', () {
    test('Highlight round-trips', () {
      final h = Highlight(label: 'Hackathons won', value: '3×', note: 'Roux · Start ×2');
      final r = Highlight.fromMap(h.toMap());
      expect(r.label, h.label);
      expect(r.value, h.value);
      expect(r.note, h.note);
    });

    test('SkillGroup round-trips and preserves order', () {
      final g = SkillGroup(category: 'Languages', items: ['Java', 'Python', 'Dart']);
      final r = SkillGroup.fromMap(g.toMap());
      expect(r.category, 'Languages');
      expect(r.items, ['Java', 'Python', 'Dart']);
    });

    test('EducationEntry round-trips', () {
      final e = EducationEntry(when: '2024–25', where: 'Northeastern University', what: 'M.S. Computer Science');
      final r = EducationEntry.fromMap(e.toMap());
      expect(r.where, 'Northeastern University');
      expect(r.what, 'M.S. Computer Science');
    });

    test('QuizQuestion round-trips', () {
      final q = QuizQuestion(q: 'Go-to language?', options: ['Java', 'Python'], answer: 1, funFact: 'Python.');
      final r = QuizQuestion.fromMap(q.toMap());
      expect(r.options, ['Java', 'Python']);
      expect(r.answer, 1);
    });

    test('PersonalityItem round-trips', () {
      final p = PersonalityItem(label: 'Coffee order', value: 'Black, no sugar');
      final r = PersonalityItem.fromMap(p.toMap());
      expect(r.value, 'Black, no sugar');
    });

    test('PortfolioSettings carries all Broadside fields', () {
      final s = PortfolioSettings(
        name: 'Jaynesh Bhandari', initials: 'JB', role: 'Software Engineer',
        tagline: 'Full-stack developer.', location: 'Portland, Maine',
        email: 'thejaynesh@gmail.com', phone: '+1 207·313·7210',
        linkedin: 'linkedin.com/in/thejaynesh', github: 'github.com/thejaynesh',
        summary: "Master's student in CS.",
        highlights: [Highlight(label: 'Years coding', value: '5+', note: 'since 2018')],
        skillGroups: [SkillGroup(category: 'Languages', items: ['Java'])],
        awards: ['1st Place — Start Summit'],
        education: [EducationEntry(when: '2024–25', where: 'NEU', what: 'M.S. CS')],
        quiz: [QuizQuestion(q: 'Q', options: ['a', 'b'], answer: 0, funFact: 'f')],
        personality: [PersonalityItem(label: 'IDE', value: 'VS Code')],
      );
      final r = PortfolioSettings.fromMap(s.toMap());
      expect(r.name, s.name);
      expect(r.initials, 'JB');
      expect(r.role, 'Software Engineer');
      expect(r.location, 'Portland, Maine');
      expect(r.phone, s.phone);
      expect(r.summary, s.summary);
      expect(r.highlights.first.value, '5+');
      expect(r.skillGroups.first.items, ['Java']);
      expect(r.awards.first, contains('Start Summit'));
      expect(r.education.first.where, 'NEU');
      expect(r.quiz.first.answer, 0);
      expect(r.personality.first.value, 'VS Code');
    });

    test('empty() contains no fabricated data', () {
      final e = PortfolioSettings.empty();
      expect(e.name, isEmpty);
      expect(e.highlights, isEmpty);
      expect(e.skillGroups, isEmpty);
      expect(e.education, isEmpty);
      expect(e.quiz, isEmpty);
      expect(e.personality, isEmpty);
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

    test('Project carries Broadside tag + kpi', () {
      final p = Project(
        id: 'p1', title: 'Inventory System', category: '', description: 'blurb',
        techStack: ['Flutter', 'Dart'], tag: 'Freelance · 2023', kpi: 'End-to-end · solo',
      );
      final r = Project.fromMap(p.toMap(), 'p1');
      expect(r.tag, 'Freelance · 2023');
      expect(r.kpi, 'End-to-end · solo');
      expect(r.techStack, ['Flutter', 'Dart']);
    });

    test('Experience carries city + when/org mapping', () {
      final e = Experience(
        id: 'e1', role: 'Assistant System Engineer', company: 'TCS',
        period: '2022–24', description: 'blurb', city: 'Mumbai, India',
        tags: ['Java', 'API Mocking'],
      );
      final r = Experience.fromMap(e.toMap(), 'e1');
      expect(r.city, 'Mumbai, India');
      expect(r.period, '2022–24');
      expect(r.company, 'TCS');
      expect(r.tags, ['Java', 'API Mocking']);
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
}
