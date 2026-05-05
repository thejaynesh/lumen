import '../../../models/portfolio_data.dart';

/// Provides mock portfolio data for development and fallback purposes
class MockPortfolioData {
  static PortfolioViewData getMockData() {
    final mockSettings = PortfolioSettings(
      name: 'Your Name',
      tagline: 'SOFTWARE DEVELOPER',
      about: 'A passionate developer creating amazing experiences.',
      email: 'your.email@example.com',
      skills: [
        Skill(name: 'Flutter', level: 0.90),
        Skill(name: 'Dart', level: 0.85),
        Skill(name: 'Firebase', level: 0.80),
        Skill(name: 'UI/UX Design', level: 0.75),
        Skill(name: 'React', level: 0.70),
        Skill(name: 'Python', level: 0.85),
      ],
      stats: [],
      github: 'https://github.com/yourusername',
      linkedin: 'https://linkedin.com/in/yourusername',
      resumeUrl: 'https://example.com/resume.pdf',
    );

    final mockProjects = [
      Project(
        id: '1',
        title: 'Project Alpha',
        description:
            'A revolutionary mobile application that transforms how users interact with technology.',
        category: 'Mobile Development',
        techStack: ['Flutter', 'Firebase', 'REST API'],
      ),
      Project(
        id: '2',
        title: 'Project Beta',
        description:
            'An innovative web platform designed to streamline workflows and boost productivity.',
        category: 'Web Development',
        techStack: ['React', 'Node.js', 'MongoDB'],
      ),
      Project(
        id: '3',
        title: 'Project Gamma',
        description:
            'A cutting-edge data visualization tool that makes complex information accessible.',
        category: 'Data Science',
        techStack: ['Python', 'D3.js', 'PostgreSQL'],
      ),
    ];

    final mockExperiences = [
      Experience(
        id: '1',
        company: 'Tech Company Inc.',
        role: 'Senior Developer',
        period: '2022 - Present',
        description:
            'Leading development of cutting-edge applications and mentoring junior developers.',
        highlights: ['Flutter', 'Firebase', 'AWS'],
      ),
      Experience(
        id: '2',
        company: 'Startup XYZ',
        role: 'Full Stack Developer',
        period: '2020 - 2022',
        description:
            'Built scalable web applications and implemented CI/CD pipelines.',
        highlights: ['React', 'Node.js', 'Docker'],
      ),
    ];

    return PortfolioViewData(
      settings: mockSettings,
      projects: mockProjects,
      experiences: mockExperiences,
      jobPosting: null,
    );
  }
}
