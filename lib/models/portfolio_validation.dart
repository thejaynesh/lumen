import 'portfolio_data.dart';

void _text(String value, String field, {int max = 200, bool required = false}) {
  if (value.length > max || (required && value.trim().isEmpty)) {
    throw FormatException(
      '$field ${required ? 'is required and ' : ''}must be at most $max characters.',
    );
  }
}

void _optional(String? value, String field, {int max = 2000}) {
  if (value != null) _text(value, field, max: max);
}

void _url(String? value, String field, {bool relative = false}) {
  if (value == null || value.isEmpty) return;
  _text(value, field, max: 2000);
  if (value.contains(RegExp(r'\s')) || value.contains('\\')) {
    throw FormatException('$field cannot contain whitespace or backslashes.');
  }
  final uri = Uri.tryParse(value);
  final isRelative =
      relative &&
      value.startsWith('/') &&
      !value.startsWith('//') &&
      !value.contains('\\');
  if (uri == null ||
      (!isRelative &&
          (!['https', 'http'].contains(uri.scheme) ||
              uri.host.isEmpty ||
              uri.userInfo.isNotEmpty))) {
    throw FormatException(
      '$field must be an HTTP(S) URL${relative ? ' or a site-relative path' : ''}.',
    );
  }
}

void _list(
  List<String> values,
  String field, {
  int max = 50,
  int itemMax = 2000,
}) {
  if (values.length > max) {
    throw FormatException('$field supports at most $max entries.');
  }
  for (final value in values) {
    _text(value, field, max: itemMax);
    if (value.contains('\n') || value.contains('\r')) {
      throw FormatException('$field entries must each be a single line.');
    }
  }
}

void _objects(Iterable<Object> values, String field) {
  if (values.length > 12) {
    throw FormatException('$field supports at most 12 entries.');
  }
}

void validateDocumentIds(List<String> ids, String field) {
  if (ids.length > 100 ||
      ids.toSet().length != ids.length ||
      ids.any((id) => !RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(id))) {
    throw FormatException(
      '$field must contain at most 100 unique document IDs.',
    );
  }
}

void validateSettings(PortfolioSettings settings) {
  _text(settings.name, 'Name', required: true);
  _text(settings.initials, 'Initials', max: 20);
  _text(settings.role, 'Role');
  _text(settings.location, 'Location');
  _text(settings.tagline, 'Tagline', max: 1000);
  _text(settings.about, 'About', max: 10000);
  _text(settings.summary, 'Summary', max: 10000);
  _text(settings.availability, 'Availability', max: 300);
  _text(settings.email, 'Email', max: 320, required: true);
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(settings.email)) {
    throw const FormatException('Enter a valid email address.');
  }
  _text(settings.phone, 'Phone', max: 50);
  for (final url in [
    settings.github,
    settings.linkedin,
    settings.twitter,
    settings.instagram,
  ]) {
    _url(url, 'Social link');
  }
  _url(settings.resumeUrl, 'Resume URL', relative: true);
  validateDocumentIds(settings.defaultProjectIds, 'Default projects');
  validateDocumentIds(settings.defaultExperienceIds, 'Default experience');
  _list(settings.awards, 'Awards');
  _list(settings.now, 'Currently');
  _objects(settings.highlights, 'Highlights');
  for (final item in settings.highlights) {
    _text(item.label, 'Highlight label');
    _text(item.value, 'Highlight value');
    _text(item.note, 'Highlight note', max: 1000);
  }
  _objects(settings.skillGroups, 'Skill groups');
  for (final item in settings.skillGroups) {
    _text(item.category, 'Skill category', required: true);
    _list(item.items, 'Skills', max: 30, itemMax: 200);
  }
  _objects(settings.education, 'Education');
  for (final item in settings.education) {
    _text(item.when, 'Education period');
    _text(item.where, 'School', max: 500);
    _text(item.what, 'Qualification', max: 1000);
  }
  _objects(settings.quiz, 'Quiz');
  for (final item in settings.quiz) {
    _text(item.q, 'Quiz question', max: 1000, required: true);
    _list(item.options, 'Quiz options', max: 8, itemMax: 500);
    if (item.options.length < 2 ||
        item.answer < 0 ||
        item.answer >= item.options.length) {
      throw const FormatException(
        'Quiz questions need 2–8 options and a valid zero-based answer index.',
      );
    }
    _text(item.funFact, 'Quiz explanation', max: 2000);
  }
  _objects(settings.personality, 'Personality');
  for (final item in settings.personality) {
    _text(item.label, 'Personality label');
    _text(item.value, 'Personality value', max: 1000);
  }
  _objects(settings.certifications, 'Certifications');
  for (final item in settings.certifications) {
    _text(item.name, 'Certification', max: 500, required: true);
    _text(item.issuer, 'Certification issuer', max: 300);
    _text(item.year, 'Certification year', max: 50);
  }
}

void validateProject(Project project) {
  _text(project.title, 'Project title', required: true);
  _text(project.category, 'Project category');
  _text(project.description, 'Project description', max: 10000);
  for (final value in [
    project.problem,
    project.contribution,
    project.outcome,
  ]) {
    _text(value, 'Case study', max: 10000);
  }
  _text(project.tag, 'Project tag', max: 300);
  _text(project.kpi, 'Project result', max: 1000);
  _list(project.techStack, 'Tech stack', itemMax: 200);
  _list(project.tags, 'Project tags', itemMax: 200);
  _url(project.link, 'Project URL');
  _url(project.sourceUrl, 'Source URL');
  _url(project.imageUrl, 'Image URL', relative: true);
  if (project.order < 0 ||
      project.order > 100000 ||
      project.colorHex < 0 ||
      project.colorHex > 0xffffffff) {
    throw const FormatException(
      'Project order or color is outside the supported range.',
    );
  }
}

void validateExperience(Experience experience) {
  _text(experience.role, 'Role', required: true);
  _text(experience.company, 'Company', required: true);
  _text(experience.period, 'Period');
  _text(experience.city, 'City');
  _text(experience.description, 'Description', max: 10000);
  _list(experience.highlights, 'Experience highlights');
  _list(experience.tags, 'Experience tags', itemMax: 200);
  if (experience.order < 0 || experience.order > 100000) {
    throw const FormatException(
      'Experience order must be between 0 and 100000.',
    );
  }
}

void validateJob(JobPosting job) {
  if (!RegExp(r'^[a-z0-9][a-z0-9-]{0,99}$').hasMatch(job.slug)) {
    throw const FormatException(
      'Slug must contain 1–100 lowercase letters, digits or hyphens.',
    );
  }
  _text(job.title, 'Job title', required: true);
  _text(job.company, 'Company', required: true);
  _optional(job.description, 'Application notes', max: 10000);
  _optional(job.customTagline, 'Custom tagline', max: 1000);
  _optional(job.customAbout, 'Custom about', max: 10000);
  validateDocumentIds(job.projectIds, 'Featured projects');
  validateDocumentIds(job.experienceIds, 'Featured experience');
}
