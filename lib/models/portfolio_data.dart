/// Data models for the portfolio with Firestore serialization

class PortfolioSettings {
  final String name;
  final String tagline;
  final String about;
  final String email;
  final String? github;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? resumeUrl;
  final List<String> defaultProjectIds; // Projects shown on generic homepage
  final List<String>
  defaultExperienceIds; // Experience shown on generic homepage
  final List<Skill> skills;
  final List<Stat> stats;

  PortfolioSettings({
    required this.name,
    required this.tagline,
    required this.about,
    required this.email,
    this.github,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.resumeUrl,
    this.defaultProjectIds = const [],
    this.defaultExperienceIds = const [],
    this.skills = const [],
    this.stats = const [],
  });

  factory PortfolioSettings.fromMap(Map<String, dynamic> map) {
    return PortfolioSettings(
      name: map['name'] ?? '',
      tagline: map['tagline'] ?? '',
      about: map['about'] ?? '',
      email: map['email'] ?? '',
      github: map['github'],
      linkedin: map['linkedin'],
      twitter: map['twitter'],
      instagram: map['instagram'],
      resumeUrl: map['resumeUrl'],
      defaultProjectIds: List<String>.from(map['defaultProjectIds'] ?? []),
      defaultExperienceIds: List<String>.from(
        map['defaultExperienceIds'] ?? [],
      ),
      skills:
          (map['skills'] as List<dynamic>?)
              ?.map((s) => Skill.fromMap(s))
              .toList() ??
          [],
      stats:
          (map['stats'] as List<dynamic>?)
              ?.map((s) => Stat.fromMap(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagline': tagline,
      'about': about,
      'email': email,
      'github': github,
      'linkedin': linkedin,
      'twitter': twitter,
      'instagram': instagram,
      'resumeUrl': resumeUrl,
      'defaultProjectIds': defaultProjectIds,
      'defaultExperienceIds': defaultExperienceIds,
      'skills': skills.map((s) => s.toMap()).toList(),
      'stats': stats.map((s) => s.toMap()).toList(),
    };
  }

  PortfolioSettings copyWith({
    String? name,
    String? tagline,
    String? about,
    String? email,
    String? github,
    String? linkedin,
    String? twitter,
    String? instagram,
    String? resumeUrl,
    List<String>? defaultProjectIds,
    List<String>? defaultExperienceIds,
    List<Skill>? skills,
    List<Stat>? stats,
  }) {
    return PortfolioSettings(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      about: about ?? this.about,
      email: email ?? this.email,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      defaultProjectIds: defaultProjectIds ?? this.defaultProjectIds,
      defaultExperienceIds: defaultExperienceIds ?? this.defaultExperienceIds,
      skills: skills ?? this.skills,
      stats: stats ?? this.stats,
    );
  }

  /// Non-null placeholder used only when Firestore has no `settings/main`
  /// doc yet. Contains NO fake data — real content lives in Firestore and is
  /// loaded via the seed script or admin dashboard. Empty fields render as
  /// blank/loading rather than shipping fabricated identity.
  static PortfolioSettings empty() {
    return PortfolioSettings(
      name: '',
      tagline: '',
      about: '',
      email: '',
    );
  }
}

class Skill {
  final String name;
  final double level;

  Skill({required this.name, required this.level});

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      level: (map['level'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'level': level};
}

class Stat {
  final String value;
  final String label;

  Stat({required this.value, required this.label});

  factory Stat.fromMap(Map<String, dynamic> map) {
    return Stat(value: map['value'] ?? '', label: map['label'] ?? '');
  }

  Map<String, dynamic> toMap() => {'value': value, 'label': label};
}

class Project {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> techStack;
  final String? link;
  final String? imageUrl;
  final int colorHex; // Accent color for the card
  final List<String>
  tags; // Tags for filtering (e.g., 'flutter', 'web', 'mobile', 'ai')
  final int order; // Display order
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.techStack,
    this.link,
    this.imageUrl,
    this.colorHex = 0xFFFF6B35,
    this.tags = const [],
    this.order = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      techStack: List<String>.from(map['techStack'] ?? []),
      link: map['link'],
      imageUrl: map['imageUrl'],
      colorHex: map['colorHex'] ?? 0xFFFF6B35,
      tags: List<String>.from(map['tags'] ?? []),
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'techStack': techStack,
      'link': link,
      'imageUrl': imageUrl,
      'colorHex': colorHex,
      'tags': tags,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    List<String>? techStack,
    String? link,
    String? imageUrl,
    int? colorHex,
    List<String>? tags,
    int? order,
    bool? isActive,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      colorHex: colorHex ?? this.colorHex,
      tags: tags ?? this.tags,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

class Experience {
  final String id;
  final String role;
  final String company;
  final String period;
  final String description;
  final List<String> highlights; // Skills/tech used
  final List<String> tags; // Tags for filtering
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Experience({
    required this.id,
    required this.role,
    required this.company,
    required this.period,
    required this.description,
    this.highlights = const [],
    this.tags = const [],
    this.order = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Experience.fromMap(Map<String, dynamic> map, String id) {
    return Experience(
      id: id,
      role: map['role'] ?? '',
      company: map['company'] ?? '',
      period: map['period'] ?? '',
      description: map['description'] ?? '',
      highlights: List<String>.from(map['highlights'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'company': company,
      'period': period,
      'description': description,
      'highlights': highlights,
      'tags': tags,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  Experience copyWith({
    String? id,
    String? role,
    String? company,
    String? period,
    String? description,
    List<String>? highlights,
    List<String>? tags,
    int? order,
    bool? isActive,
  }) {
    return Experience(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      period: period ?? this.period,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      tags: tags ?? this.tags,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

class JobPosting {
  final String id;
  final String slug; // URL-friendly ID (e.g., 'google-swe-2025')
  final String title; // Job title (e.g., 'Senior Software Engineer at Google')
  final String company;
  final String? description; // Optional notes about the application
  final List<String> projectIds; // Projects to show for this job
  final List<String> experienceIds; // Experience to show
  final String? customTagline; // Override tagline for this job
  final String? customAbout; // Override about section for this job
  final bool isActive;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  JobPosting({
    required this.id,
    required this.slug,
    required this.title,
    required this.company,
    this.description,
    this.projectIds = const [],
    this.experienceIds = const [],
    this.customTagline,
    this.customAbout,
    this.isActive = true,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory JobPosting.fromMap(Map<String, dynamic> map, String id) {
    return JobPosting(
      id: id,
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      description: map['description'],
      projectIds: List<String>.from(map['projectIds'] ?? []),
      experienceIds: List<String>.from(map['experienceIds'] ?? []),
      customTagline: map['customTagline'],
      customAbout: map['customAbout'],
      isActive: map['isActive'] ?? true,
      viewCount: map['viewCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      expiresAt: map['expiresAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'title': title,
      'company': company,
      'description': description,
      'projectIds': projectIds,
      'experienceIds': experienceIds,
      'customTagline': customTagline,
      'customAbout': customAbout,
      'isActive': isActive,
      'viewCount': viewCount,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
      'expiresAt': expiresAt,
    };
  }

  JobPosting copyWith({
    String? id,
    String? slug,
    String? title,
    String? company,
    String? description,
    List<String>? projectIds,
    List<String>? experienceIds,
    String? customTagline,
    String? customAbout,
    bool? isActive,
    int? viewCount,
    DateTime? expiresAt,
  }) {
    return JobPosting(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      projectIds: projectIds ?? this.projectIds,
      experienceIds: experienceIds ?? this.experienceIds,
      customTagline: customTagline ?? this.customTagline,
      customAbout: customAbout ?? this.customAbout,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Get the full URL for this job posting
  String getUrl(String baseUrl) => '$baseUrl?job=$slug';
}

/// Data container for the public portfolio view
class PortfolioViewData {
  final PortfolioSettings settings;
  final List<Project> projects;
  final List<Experience> experiences;
  final JobPosting? jobPosting; // null for generic homepage

  PortfolioViewData({
    required this.settings,
    required this.projects,
    required this.experiences,
    this.jobPosting,
  });

  /// Gets the tagline - from job if provided, otherwise from settings
  String get tagline => jobPosting?.customTagline ?? settings.tagline;

  /// Gets the about text - from job if provided, otherwise from settings
  String get about => jobPosting?.customAbout ?? settings.about;

  /// Whether this is a job-specific view
  bool get isJobView => jobPosting != null;
}
