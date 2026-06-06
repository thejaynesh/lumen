// Data models for the portfolio with Firestore serialization

class Highlight {
  final String label;
  final String value;
  final String note;
  Highlight({required this.label, required this.value, this.note = ''});
  factory Highlight.fromMap(Map<String, dynamic> m) =>
      Highlight(label: m['label'] ?? '', value: m['value'] ?? '', note: m['note'] ?? '');
  Map<String, dynamic> toMap() => {'label': label, 'value': value, 'note': note};
}

class SkillGroup {
  final String category;
  final List<String> items;
  SkillGroup({required this.category, this.items = const []});
  factory SkillGroup.fromMap(Map<String, dynamic> m) =>
      SkillGroup(category: m['category'] ?? '', items: List<String>.from(m['items'] ?? []));
  Map<String, dynamic> toMap() => {'category': category, 'items': items};
}

class EducationEntry {
  final String when;
  final String where;
  final String what;
  EducationEntry({required this.when, required this.where, required this.what});
  factory EducationEntry.fromMap(Map<String, dynamic> m) =>
      EducationEntry(when: m['when'] ?? '', where: m['where'] ?? '', what: m['what'] ?? '');
  Map<String, dynamic> toMap() => {'when': when, 'where': where, 'what': what};
}

class QuizQuestion {
  final String q;
  final List<String> options;
  final int answer;
  final String funFact;
  QuizQuestion({required this.q, required this.options, required this.answer, this.funFact = ''});
  factory QuizQuestion.fromMap(Map<String, dynamic> m) => QuizQuestion(
        q: m['q'] ?? '',
        options: List<String>.from(m['options'] ?? []),
        answer: (m['answer'] ?? 0) as int,
        funFact: m['funFact'] ?? '',
      );
  Map<String, dynamic> toMap() => {'q': q, 'options': options, 'answer': answer, 'funFact': funFact};
}

class PersonalityItem {
  final String label;
  final String value;
  PersonalityItem({required this.label, required this.value});
  factory PersonalityItem.fromMap(Map<String, dynamic> m) =>
      PersonalityItem(label: m['label'] ?? '', value: m['value'] ?? '');
  Map<String, dynamic> toMap() => {'label': label, 'value': value};
}

class Certification {
  final String name;
  final String issuer;
  final String year;
  Certification({required this.name, this.issuer = '', this.year = ''});
  factory Certification.fromMap(Map<String, dynamic> m) => Certification(
        name: m['name'] ?? '',
        issuer: m['issuer'] ?? '',
        year: m['year'] ?? '',
      );
  Map<String, dynamic> toMap() =>
      {'name': name, 'issuer': issuer, 'year': year};
}

class PortfolioSettings {
  final String name;
  final String initials;
  final String role;
  final String tagline;
  final String location;
  final String about; // legacy; kept for JobPosting customAbout fallback
  final String summary;
  final String email;
  final String phone;
  final String? github;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? resumeUrl;
  final List<Highlight> highlights;
  final List<SkillGroup> skillGroups;
  final List<String> awards;
  final List<EducationEntry> education;
  final List<QuizQuestion> quiz;
  final List<PersonalityItem> personality;
  final List<Certification> certifications;
  final List<String> now;
  final List<String> defaultProjectIds;
  final List<String> defaultExperienceIds;

  PortfolioSettings({
    required this.name,
    this.initials = '',
    this.role = '',
    required this.tagline,
    this.location = '',
    this.about = '',
    this.summary = '',
    required this.email,
    this.phone = '',
    this.github,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.resumeUrl,
    this.highlights = const [],
    this.skillGroups = const [],
    this.awards = const [],
    this.education = const [],
    this.quiz = const [],
    this.personality = const [],
    this.certifications = const [],
    this.now = const [],
    this.defaultProjectIds = const [],
    this.defaultExperienceIds = const [],
  });

  factory PortfolioSettings.fromMap(Map<String, dynamic> map) {
    List<T> list<T>(String k, T Function(Map<String, dynamic>) f) =>
        (map[k] as List<dynamic>?)?.map((e) => f(Map<String, dynamic>.from(e))).toList() ?? <T>[];
    return PortfolioSettings(
      name: map['name'] ?? '',
      initials: map['initials'] ?? '',
      role: map['role'] ?? '',
      tagline: map['tagline'] ?? '',
      location: map['location'] ?? '',
      about: map['about'] ?? '',
      summary: map['summary'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      github: map['github'],
      linkedin: map['linkedin'],
      twitter: map['twitter'],
      instagram: map['instagram'],
      resumeUrl: map['resumeUrl'],
      highlights: list('highlights', Highlight.fromMap),
      skillGroups: list('skillGroups', SkillGroup.fromMap),
      awards: List<String>.from(map['awards'] ?? []),
      education: list('education', EducationEntry.fromMap),
      quiz: list('quiz', QuizQuestion.fromMap),
      personality: list('personality', PersonalityItem.fromMap),
      certifications: list('certifications', Certification.fromMap),
      now: List<String>.from(map['now'] ?? []),
      defaultProjectIds: List<String>.from(map['defaultProjectIds'] ?? []),
      defaultExperienceIds: List<String>.from(map['defaultExperienceIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'initials': initials,
        'role': role,
        'tagline': tagline,
        'location': location,
        'about': about,
        'summary': summary,
        'email': email,
        'phone': phone,
        'github': github,
        'linkedin': linkedin,
        'twitter': twitter,
        'instagram': instagram,
        'resumeUrl': resumeUrl,
        'highlights': highlights.map((e) => e.toMap()).toList(),
        'skillGroups': skillGroups.map((e) => e.toMap()).toList(),
        'awards': awards,
        'education': education.map((e) => e.toMap()).toList(),
        'quiz': quiz.map((e) => e.toMap()).toList(),
        'personality': personality.map((e) => e.toMap()).toList(),
        'certifications': certifications.map((e) => e.toMap()).toList(),
        'now': now,
        'defaultProjectIds': defaultProjectIds,
        'defaultExperienceIds': defaultExperienceIds,
      };

  PortfolioSettings copyWith({
    String? name, String? initials, String? role, String? tagline, String? location,
    String? about, String? summary, String? email, String? phone,
    String? github, String? linkedin, String? twitter, String? instagram, String? resumeUrl,
    List<Highlight>? highlights, List<SkillGroup>? skillGroups, List<String>? awards,
    List<EducationEntry>? education, List<QuizQuestion>? quiz, List<PersonalityItem>? personality,
    List<Certification>? certifications, List<String>? now,
    List<String>? defaultProjectIds, List<String>? defaultExperienceIds,
  }) {
    return PortfolioSettings(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      role: role ?? this.role,
      tagline: tagline ?? this.tagline,
      location: location ?? this.location,
      about: about ?? this.about,
      summary: summary ?? this.summary,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      highlights: highlights ?? this.highlights,
      skillGroups: skillGroups ?? this.skillGroups,
      awards: awards ?? this.awards,
      education: education ?? this.education,
      quiz: quiz ?? this.quiz,
      personality: personality ?? this.personality,
      certifications: certifications ?? this.certifications,
      now: now ?? this.now,
      defaultProjectIds: defaultProjectIds ?? this.defaultProjectIds,
      defaultExperienceIds: defaultExperienceIds ?? this.defaultExperienceIds,
    );
  }

  static PortfolioSettings empty() => PortfolioSettings(name: '', tagline: '', email: '');
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
  final String tag; // Broadside badge label (e.g. "Hackathon · 2024")
  final String kpi; // Broadside KPI line (e.g. "2nd of ~40 teams")
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
    this.tag = '',
    this.kpi = '',
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
      tag: map['tag'] ?? '',
      kpi: map['kpi'] ?? '',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is DateTime ? map['createdAt'] as DateTime : (map['createdAt']?.toDate() ?? DateTime.now()),
      updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] as DateTime : (map['updatedAt']?.toDate() ?? DateTime.now()),
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
      'tag': tag,
      'kpi': kpi,
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
    String? tag,
    String? kpi,
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
      tag: tag ?? this.tag,
      kpi: kpi ?? this.kpi,
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
  final String city; // Broadside location (e.g. "Mumbai, India")
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
    this.city = '',
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
      city: map['city'] ?? '',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is DateTime ? map['createdAt'] as DateTime : (map['createdAt']?.toDate() ?? DateTime.now()),
      updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] as DateTime : (map['updatedAt']?.toDate() ?? DateTime.now()),
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
      'city': city,
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
    String? city,
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
      city: city ?? this.city,
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
