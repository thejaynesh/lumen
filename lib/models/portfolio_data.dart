import 'package:cloud_firestore/cloud_firestore.dart';

// Tolerant reads preserve older documents; writes validate before publication.
const _unchanged = Object();
String _text(Object? value) => value is String ? value : '';
String? _optionalText(Object? value) =>
    value is String && value.isNotEmpty ? value : null;
int _integer(Object? value, [int fallback = 0]) =>
    value is int ? value : fallback;
bool _active(Object? value) => value is bool ? value : false;
List<String> _strings(Object? value) =>
    value is List ? value.whereType<String>().toList() : <String>[];
DateTime? _date(Object? value) => value is Timestamp
    ? value.toDate()
    : value is DateTime
    ? value
    : null;
final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
List<T> _objects<T>(Object? value, T Function(Map<String, dynamic>) decode) =>
    value is List
    ? value
          .whereType<Map>()
          .map(
            (item) => decode(
              Map<String, dynamic>.fromEntries(
                item.entries
                    .where((entry) => entry.key is String)
                    .map((entry) => MapEntry(entry.key as String, entry.value)),
              ),
            ),
          )
          .toList()
    : <T>[];

class Highlight {
  final String label;
  final String value;
  final String note;
  Highlight({required this.label, required this.value, this.note = ''});
  factory Highlight.fromMap(Map<String, dynamic> m) => Highlight(
    label: _text(m['label']),
    value: _text(m['value']),
    note: _text(m['note']),
  );
  Map<String, dynamic> toMap() => {
    'label': label,
    'value': value,
    'note': note,
  };
}

class SkillGroup {
  final String category;
  final List<String> items;
  SkillGroup({required this.category, this.items = const []});
  factory SkillGroup.fromMap(Map<String, dynamic> m) =>
      SkillGroup(category: _text(m['category']), items: _strings(m['items']));
  Map<String, dynamic> toMap() => {'category': category, 'items': items};
}

class EducationEntry {
  final String when;
  final String where;
  final String what;
  EducationEntry({required this.when, required this.where, required this.what});
  factory EducationEntry.fromMap(Map<String, dynamic> m) => EducationEntry(
    when: _text(m['when']),
    where: _text(m['where']),
    what: _text(m['what']),
  );
  Map<String, dynamic> toMap() => {'when': when, 'where': where, 'what': what};
}

class QuizQuestion {
  final String q;
  final List<String> options;
  final int answer;
  final String funFact;
  QuizQuestion({
    required this.q,
    required this.options,
    required this.answer,
    this.funFact = '',
  });
  factory QuizQuestion.fromMap(Map<String, dynamic> m) => QuizQuestion(
    q: _text(m['q']),
    options: _strings(m['options']),
    answer: _integer(m['answer']),
    funFact: _text(m['funFact']),
  );
  Map<String, dynamic> toMap() => {
    'q': q,
    'options': options,
    'answer': answer,
    'funFact': funFact,
  };
}

class PersonalityItem {
  final String label;
  final String value;
  PersonalityItem({required this.label, required this.value});
  factory PersonalityItem.fromMap(Map<String, dynamic> m) =>
      PersonalityItem(label: _text(m['label']), value: _text(m['value']));
  Map<String, dynamic> toMap() => {'label': label, 'value': value};
}

class Certification {
  final String name;
  final String issuer;
  final String year;
  Certification({required this.name, this.issuer = '', this.year = ''});
  factory Certification.fromMap(Map<String, dynamic> m) => Certification(
    name: _text(m['name']),
    issuer: _text(m['issuer']),
    year: _text(m['year']),
  );
  Map<String, dynamic> toMap() => {
    'name': name,
    'issuer': issuer,
    'year': year,
  };
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
  final String availability;
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
    this.availability = '',
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
        _objects(map[k], f);
    return PortfolioSettings(
      name: _text(map['name']),
      initials: _text(map['initials']),
      role: _text(map['role']),
      tagline: _text(map['tagline']),
      location: _text(map['location']),
      about: _text(map['about']),
      summary: _text(map['summary']),
      email: _text(map['email']),
      phone: _text(map['phone']),
      availability: _text(map['availability']),
      github: _optionalText(map['github']),
      linkedin: _optionalText(map['linkedin']),
      twitter: _optionalText(map['twitter']),
      instagram: _optionalText(map['instagram']),
      resumeUrl: _optionalText(map['resumeUrl']),
      highlights: list('highlights', Highlight.fromMap),
      skillGroups: list('skillGroups', SkillGroup.fromMap),
      awards: _strings(map['awards']),
      education: list('education', EducationEntry.fromMap),
      quiz: list('quiz', QuizQuestion.fromMap),
      personality: list('personality', PersonalityItem.fromMap),
      certifications: list('certifications', Certification.fromMap),
      now: _strings(map['now']),
      defaultProjectIds: _strings(map['defaultProjectIds']),
      defaultExperienceIds: _strings(map['defaultExperienceIds']),
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
    'availability': availability,
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
    String? name,
    String? initials,
    String? role,
    String? tagline,
    String? location,
    String? about,
    String? summary,
    String? email,
    String? phone,
    String? availability,
    Object? github = _unchanged,
    Object? linkedin = _unchanged,
    Object? twitter = _unchanged,
    Object? instagram = _unchanged,
    Object? resumeUrl = _unchanged,
    List<Highlight>? highlights,
    List<SkillGroup>? skillGroups,
    List<String>? awards,
    List<EducationEntry>? education,
    List<QuizQuestion>? quiz,
    List<PersonalityItem>? personality,
    List<Certification>? certifications,
    List<String>? now,
    List<String>? defaultProjectIds,
    List<String>? defaultExperienceIds,
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
      availability: availability ?? this.availability,
      github: identical(github, _unchanged) ? this.github : github as String?,
      linkedin: identical(linkedin, _unchanged)
          ? this.linkedin
          : linkedin as String?,
      twitter: identical(twitter, _unchanged)
          ? this.twitter
          : twitter as String?,
      instagram: identical(instagram, _unchanged)
          ? this.instagram
          : instagram as String?,
      resumeUrl: identical(resumeUrl, _unchanged)
          ? this.resumeUrl
          : resumeUrl as String?,
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

  static PortfolioSettings empty() =>
      PortfolioSettings(name: '', tagline: '', email: '');
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
  final String problem;
  final String contribution;
  final String outcome;
  final String sourceUrl;
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
    this.problem = '',
    this.contribution = '',
    this.outcome = '',
    this.sourceUrl = '',
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
      title: _text(map['title']),
      category: _text(map['category']),
      description: _text(map['description']),
      techStack: _strings(map['techStack']),
      link: _optionalText(map['link']),
      imageUrl: _optionalText(map['imageUrl']),
      colorHex: _integer(map['colorHex'], 0xFFFF6B35),
      tags: _strings(map['tags']),
      tag: _text(map['tag']),
      problem: _text(map['problem']),
      contribution: _text(map['contribution']),
      outcome: _text(map['outcome']),
      sourceUrl: _text(map['sourceUrl']),
      kpi: _text(map['kpi']),
      order: _integer(map['order'], 0),
      isActive: _active(map['isActive']),
      createdAt: _date(map['createdAt']) ?? _epoch,
      updatedAt: _date(map['updatedAt']) ?? _epoch,
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
      'problem': problem,
      'contribution': contribution,
      'outcome': outcome,
      'sourceUrl': sourceUrl,
      'kpi': kpi,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    List<String>? techStack,
    Object? link = _unchanged,
    Object? imageUrl = _unchanged,
    int? colorHex,
    List<String>? tags,
    String? tag,
    String? problem,
    String? contribution,
    String? outcome,
    String? sourceUrl,
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
      link: identical(link, _unchanged) ? this.link : link as String?,
      imageUrl: identical(imageUrl, _unchanged)
          ? this.imageUrl
          : imageUrl as String?,
      colorHex: colorHex ?? this.colorHex,
      tags: tags ?? this.tags,
      tag: tag ?? this.tag,
      problem: problem ?? this.problem,
      contribution: contribution ?? this.contribution,
      outcome: outcome ?? this.outcome,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      kpi: kpi ?? this.kpi,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
      role: _text(map['role']),
      company: _text(map['company']),
      period: _text(map['period']),
      description: _text(map['description']),
      highlights: _strings(map['highlights']),
      tags: _strings(map['tags']),
      city: _text(map['city']),
      order: _integer(map['order'], 0),
      isActive: _active(map['isActive']),
      createdAt: _date(map['createdAt']) ?? _epoch,
      updatedAt: _date(map['updatedAt']) ?? _epoch,
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
      'updatedAt': updatedAt,
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
      updatedAt: updatedAt,
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
      slug: _text(map['slug']),
      title: _text(map['title']),
      company: _text(map['company']),
      description: _optionalText(map['description']),
      projectIds: _strings(map['projectIds']),
      experienceIds: _strings(map['experienceIds']),
      customTagline: _optionalText(map['customTagline']),
      customAbout: _optionalText(map['customAbout']),
      isActive: _active(map['isActive']),
      viewCount: _integer(map['viewCount'], 0),
      createdAt: _date(map['createdAt']) ?? _epoch,
      updatedAt: _date(map['updatedAt']) ?? _epoch,
      expiresAt: map['expiresAt'] == null
          ? null
          : (_date(map['expiresAt']) ?? _epoch),
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
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
    };
  }

  Map<String, dynamic> toPublicMap() => {
    'slug': slug,
    'projectIds': projectIds,
    'experienceIds': experienceIds,
    'customTagline': customTagline,
    'customAbout': customAbout,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'expiresAt': expiresAt,
  };

  factory JobPosting.fromPublicMap(Map<String, dynamic> map, String slug) {
    final decoded = JobPosting.fromMap(map, slug);
    return JobPosting(
      id: slug,
      slug: slug,
      title: '',
      company: '',
      projectIds: decoded.projectIds,
      experienceIds: decoded.experienceIds,
      customTagline: decoded.customTagline,
      customAbout: decoded.customAbout,
      isActive: decoded.isActive,
      createdAt: decoded.createdAt,
      updatedAt: decoded.updatedAt,
      expiresAt: decoded.expiresAt,
    );
  }

  JobPosting copyWith({
    String? id,
    String? slug,
    String? title,
    String? company,
    Object? description = _unchanged,
    List<String>? projectIds,
    List<String>? experienceIds,
    Object? customTagline = _unchanged,
    Object? customAbout = _unchanged,
    bool? isActive,
    int? viewCount,
    Object? expiresAt = _unchanged,
  }) {
    return JobPosting(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      company: company ?? this.company,
      description: identical(description, _unchanged)
          ? this.description
          : description as String?,
      projectIds: projectIds ?? this.projectIds,
      experienceIds: experienceIds ?? this.experienceIds,
      customTagline: identical(customTagline, _unchanged)
          ? this.customTagline
          : customTagline as String?,
      customAbout: identical(customAbout, _unchanged)
          ? this.customAbout
          : customAbout as String?,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: identical(expiresAt, _unchanged)
          ? this.expiresAt
          : expiresAt as DateTime?,
    );
  }

  /// Get the full URL for this job posting
  String getUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    return uri
        .replace(queryParameters: {...uri.queryParameters, 'job': slug})
        .toString();
  }
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
  String get tagline =>
      _optionalText(jobPosting?.customTagline) ?? settings.tagline;

  /// Gets the about text - from job if provided, otherwise from settings
  String get about =>
      _optionalText(jobPosting?.customAbout) ??
      _optionalText(settings.summary) ??
      settings.about;

  /// Whether this is a job-specific view
  bool get isJobView => jobPosting != null;
}
