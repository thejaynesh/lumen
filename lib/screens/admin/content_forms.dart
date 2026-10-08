import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../services/portfolio_service.dart';
import '../../utils/external_links.dart';
import 'editor_fields.dart';

class _Draft {
  final Map<String, TextEditingController> fields;
  List<String> items;
  int answer;
  _Draft(Map<String, String> values, {this.items = const [], this.answer = 0})
    : fields = values.map(
        (key, value) => MapEntry(key, TextEditingController(text: value)),
      );
  TextEditingController operator [](String key) => fields[key]!;
  String text(String key) => fields[key]!.text.trim();
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
  }
}

String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

bool _safeRelativeUrl(String value) {
  final uri = Uri.tryParse(value);
  return value.startsWith('/') &&
      !value.startsWith('//') &&
      !value.contains('\\') &&
      !RegExp(r'\s').hasMatch(value) &&
      uri != null &&
      !uri.hasScheme &&
      !uri.hasAuthority &&
      !uri.pathSegments.contains('..');
}

String? _canonicalUrl(String value, {bool allowRelative = false}) {
  final text = value.trim();
  if (text.isEmpty) return null;
  if (allowRelative && _safeRelativeUrl(text)) return text;
  return normalizeExternalUrl(text);
}

String? _webUrlError(String? value, {bool allowRelative = false}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  if (allowRelative && _safeRelativeUrl(text)) return null;
  final uri = Uri.tryParse(normalizeExternalUrl(text));
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty) {
    return allowRelative
        ? 'Enter an https URL or a site path beginning with /.'
        : 'Enter a website URL, such as https://example.com.';
  }
  return null;
}

String? _orderError(String? value) {
  final number = int.tryParse(value?.trim() ?? '');
  return number == null || number < 0 || number > 100000
      ? 'Enter a whole number from 0 to 100,000.'
      : null;
}

String? _emailError(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address.';

class ProjectFormDialog extends StatefulWidget {
  final Project? project;
  const ProjectFormDialog({super.key, this.project});
  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  late final _Draft _draft;
  late List<String> _techStack;
  late List<String> _tags;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _draft = _Draft({
      'title': p?.title ?? '',
      'category': p?.category ?? '',
      'description': p?.description ?? '',
      'link': p?.link ?? '',
      'imageUrl': p?.imageUrl ?? '',
      'sourceUrl': p?.sourceUrl ?? '',
      'problem': p?.problem ?? '',
      'contribution': p?.contribution ?? '',
      'outcome': p?.outcome ?? '',
      'tag': p?.tag ?? '',
      'kpi': p?.kpi ?? '',
      'order': (p?.order ?? 0).toString(),
      'color':
          '#${(p?.colorHex ?? 0xFFB64D31).toRadixString(16).padLeft(8, '0').toUpperCase()}',
    });
    _techStack = [...?p?.techStack];
    _tags = [...?p?.tags];
    _active = p?.isActive ?? false;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = context.read<PortfolioService>();
    var hex = _draft.text('color').replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final base =
        widget.project ??
        Project(
          id: '',
          title: '',
          category: '',
          description: '',
          techStack: const [],
        );
    final project = base.copyWith(
      title: _draft.text('title'),
      category: _draft.text('category'),
      description: _draft.text('description'),
      techStack: _techStack,
      tags: _tags,
      tag: _draft.text('tag'),
      kpi: _draft.text('kpi'),
      problem: _draft.text('problem'),
      contribution: _draft.text('contribution'),
      outcome: _draft.text('outcome'),
      sourceUrl: _canonicalUrl(_draft.text('sourceUrl')) ?? '',
      link: _canonicalUrl(_draft.text('link')),
      imageUrl: _canonicalUrl(_draft.text('imageUrl'), allowRelative: true),
      colorHex: int.parse(hex, radix: 16),
      order: int.parse(_draft.text('order')),
      isActive: _active,
    );
    if (widget.project == null) {
      await service.addProject(project);
    } else {
      await service.updateProject(project);
    }
  }

  @override
  Widget build(BuildContext context) => AdminEditorDialog(
    title: widget.project == null ? 'Add project' : 'Edit project',
    introduction:
        'Describe the work and its evidence. Leave optional details empty until they are ready.',
    onSave: _save,
    fields: [
      AdminTextField(
        controller: _draft['title'],
        label: 'Title',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['category'],
        label: 'Category',
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['description'],
        label: 'Description',
        required: true,
        maxLines: 4,
        maxLength: 10000,
      ),
      AdminTextField(
        controller: _draft['tag'],
        label: 'Project context',
        helper: 'For example, your role or the project year.',
        maxLength: 300,
      ),
      AdminTextField(
        controller: _draft['kpi'],
        label: 'Key result',
        helper: 'Use a result you can substantiate.',
        maxLength: 1000,
      ),
      EditorSection(
        title: 'Case study',
        child: Column(
          children: [
            AdminTextField(
              controller: _draft['problem'],
              label: 'Problem',
              maxLines: 3,
              maxLength: 10000,
            ),
            AdminTextField(
              controller: _draft['contribution'],
              label: 'Your contribution',
              maxLines: 3,
              maxLength: 10000,
            ),
            AdminTextField(
              controller: _draft['outcome'],
              label: 'Outcome',
              maxLines: 3,
              maxLength: 10000,
            ),
          ],
        ),
      ),
      EditorSection(
        title: 'Technologies',
        child: StringListEditor(
          initialValues: _techStack,
          itemLabel: 'Technology',
          itemMaxLength: 200,
          onChanged: (values) => _techStack = values,
        ),
      ),
      EditorSection(
        title: 'Tags',
        child: StringListEditor(
          initialValues: _tags,
          itemLabel: 'Tag',
          itemMaxLength: 200,
          onChanged: (values) => _tags = values,
        ),
      ),
      EditorSection(
        title: 'Links and image',
        child: Column(
          children: [
            AdminTextField(
              controller: _draft['link'],
              label: 'Live project URL',
              validator: _webUrlError,
              keyboardType: TextInputType.url,
            ),
            AdminTextField(
              controller: _draft['sourceUrl'],
              label: 'Source code URL',
              validator: _webUrlError,
              keyboardType: TextInputType.url,
            ),
            AdminTextField(
              controller: _draft['imageUrl'],
              label: 'Image URL',
              validator: (value) => _webUrlError(value, allowRelative: true),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
      AdminTextField(
        controller: _draft['order'],
        label: 'Display order',
        validator: _orderError,
        keyboardType: TextInputType.number,
      ),
      AdminTextField(
        controller: _draft['color'],
        label: 'Accent color',
        helper: '#RRGGBB or #AARRGGBB',
        validator: (value) =>
            RegExp(
              r'^#?(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
            ).hasMatch(value?.trim() ?? '')
            ? null
            : 'Enter a six- or eight-digit hex color.',
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Published'),
        subtitle: const Text(
          'Archived projects are hidden from all public pages.',
        ),
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class ExperienceFormDialog extends StatefulWidget {
  final Experience? experience;
  const ExperienceFormDialog({super.key, this.experience});
  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  late final _Draft _draft;
  late List<String> _highlights;
  late List<String> _tags;
  late bool _active;
  @override
  void initState() {
    super.initState();
    final e = widget.experience;
    _draft = _Draft({
      'role': e?.role ?? '',
      'company': e?.company ?? '',
      'period': e?.period ?? '',
      'city': e?.city ?? '',
      'description': e?.description ?? '',
      'order': (e?.order ?? 0).toString(),
    });
    _highlights = [...?e?.highlights];
    _tags = [...?e?.tags];
    _active = e?.isActive ?? false;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = context.read<PortfolioService>();
    final base =
        widget.experience ??
        Experience(id: '', role: '', company: '', period: '', description: '');
    final experience = base.copyWith(
      role: _draft.text('role'),
      company: _draft.text('company'),
      period: _draft.text('period'),
      city: _draft.text('city'),
      description: _draft.text('description'),
      order: int.parse(_draft.text('order')),
      highlights: _highlights,
      tags: _tags,
      isActive: _active,
    );
    if (widget.experience == null) {
      await service.addExperience(experience);
    } else {
      await service.updateExperience(experience);
    }
  }

  @override
  Widget build(BuildContext context) => AdminEditorDialog(
    title: widget.experience == null ? 'Add experience' : 'Edit experience',
    onSave: _save,
    fields: [
      AdminTextField(
        controller: _draft['role'],
        label: 'Role',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['company'],
        label: 'Organization',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['period'],
        label: 'Period',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['city'],
        label: 'Location',
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['description'],
        label: 'Description',
        required: true,
        maxLines: 4,
        maxLength: 10000,
      ),
      EditorSection(
        title: 'Highlights',
        child: StringListEditor(
          initialValues: _highlights,
          itemLabel: 'Highlight',
          onChanged: (values) => _highlights = values,
        ),
      ),
      EditorSection(
        title: 'Tags',
        child: StringListEditor(
          initialValues: _tags,
          itemLabel: 'Tag',
          itemMaxLength: 200,
          onChanged: (values) => _tags = values,
        ),
      ),
      AdminTextField(
        controller: _draft['order'],
        label: 'Display order',
        validator: _orderError,
        keyboardType: TextInputType.number,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Published'),
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class JobFormDialog extends StatefulWidget {
  final JobPosting? job;
  const JobFormDialog({super.key, this.job});
  @override
  State<JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends State<JobFormDialog> {
  late final _Draft _draft;
  late List<String> _projects;
  late List<String> _experience;
  late bool _active;
  DateTime? _expiry;
  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _draft = _Draft({
      'slug': job?.slug ?? '',
      'title': job?.title ?? '',
      'company': job?.company ?? '',
      'notes': job?.description ?? '',
      'tagline': job?.customTagline ?? '',
      'about': job?.customAbout ?? '',
    });
    _projects = [...?job?.projectIds];
    _experience = [...?job?.experienceIds];
    _active = job?.isActive ?? false;
    _expiry = job?.expiresAt;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final candidate = _expiry?.toLocal() ?? today.add(const Duration(days: 90));
    final initial = candidate.isBefore(today) ? today : candidate;
    final last = DateTime(today.year + 10, 12, 31);
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      initialDate: initial.isAfter(last) ? last : initial,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(
        () => _expiry = DateTime(
          picked.year,
          picked.month,
          picked.day + 1,
        ).subtract(const Duration(milliseconds: 1)),
      );
    }
  }

  Future<void> _save() async {
    final service = context.read<PortfolioService>();
    final slug = _draft.text('slug').toLowerCase();
    if (!await service.isSlugAvailable(slug, excludeId: widget.job?.id)) {
      throw StateError('That slug is already in use. Choose another.');
    }
    final base =
        widget.job ?? JobPosting(id: '', slug: '', title: '', company: '');
    final job = base.copyWith(
      slug: slug,
      title: _draft.text('title'),
      company: _draft.text('company'),
      description: _optional(_draft.text('notes')),
      customTagline: _optional(_draft.text('tagline')),
      customAbout: _optional(_draft.text('about')),
      projectIds: _projects,
      experienceIds: _experience,
      isActive: _active,
      expiresAt: _expiry,
    );
    if (widget.job == null) {
      await service.addJob(job);
    } else {
      await service.updateJob(job);
    }
  }

  @override
  Widget build(BuildContext context) => AdminEditorDialog(
    title: widget.job == null ? 'Create tailored link' : 'Edit tailored link',
    onSave: _save,
    introduction:
        'The title, organization and notes stay private. Only the selected work and custom introduction are published.',
    fields: [
      AdminTextField(
        controller: _draft['slug'],
        label: 'Link slug',
        required: true,
        maxLength: 100,
        helper:
            'Letters, numbers and hyphens. Use an unguessable slug if you prefer an unlisted link.',
        validator: (value) =>
            RegExp(
              r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
            ).hasMatch((value ?? '').trim().toLowerCase())
            ? null
            : 'Use letters and numbers separated by single hyphens.',
      ),
      AdminTextField(
        controller: _draft['title'],
        label: 'Job title',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['company'],
        label: 'Organization',
        required: true,
        maxLength: 200,
      ),
      AdminTextField(
        controller: _draft['notes'],
        label: 'Private application notes',
        maxLines: 3,
        maxLength: 10000,
      ),
      AdminTextField(
        controller: _draft['tagline'],
        label: 'Custom introduction',
        maxLines: 2,
        maxLength: 1000,
      ),
      AdminTextField(
        controller: _draft['about'],
        label: 'Custom summary',
        maxLines: 4,
        maxLength: 10000,
      ),
      _LibrarySelectors(
        projects: _projects,
        experience: _experience,
        onProjects: (ids) => setState(() => _projects = ids),
        onExperience: (ids) => setState(() => _experience = ids),
      ),
      const SizedBox(height: 20),
      Text(
        _expiry == null
            ? 'This link has no expiry.'
            : 'Expires at the end of ${MaterialLocalizations.of(context).formatMediumDate(_expiry!.toLocal())} (your local time).',
      ),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _pickExpiry,
            icon: const Icon(Icons.calendar_month),
            label: const Text('Set expiry'),
          ),
          if (_expiry != null)
            TextButton(
              onPressed: () => setState(() => _expiry = null),
              child: const Text('Clear expiry'),
            ),
        ],
      ),
      if (_expiry != null && _expiry!.isBefore(DateTime.now()))
        Text(
          'This link has expired. Set a future date or clear the expiry to share it.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Published'),
        subtitle: const Text('An archived link cannot be viewed publicly.'),
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class DefaultsFormDialog extends StatefulWidget {
  final PortfolioSettings settings;
  const DefaultsFormDialog({super.key, required this.settings});
  @override
  State<DefaultsFormDialog> createState() => _DefaultsFormDialogState();
}

class _DefaultsFormDialogState extends State<DefaultsFormDialog> {
  late List<String> _projects = [...widget.settings.defaultProjectIds];
  late List<String> _experience = [...widget.settings.defaultExperienceIds];
  @override
  Widget build(BuildContext context) => AdminEditorDialog(
    title: 'Homepage selection',
    introduction:
        'Choose featured content and its order. An empty selection uses all published items.',
    onSave: () async {
      final service = context.read<PortfolioService>();
      final latest = await service.getSettings();
      await service.updateSettings(
        latest.copyWith(
          defaultProjectIds: _projects,
          defaultExperienceIds: _experience,
        ),
      );
    },
    fields: [
      _LibrarySelectors(
        projects: _projects,
        experience: _experience,
        onProjects: (ids) => setState(() => _projects = ids),
        onExperience: (ids) => setState(() => _experience = ids),
        emptyMeansAll: true,
      ),
    ],
  );
}

class _LibrarySelectors extends StatefulWidget {
  final List<String> projects;
  final List<String> experience;
  final ValueChanged<List<String>> onProjects;
  final ValueChanged<List<String>> onExperience;
  final bool emptyMeansAll;
  const _LibrarySelectors({
    required this.projects,
    required this.experience,
    required this.onProjects,
    required this.onExperience,
    this.emptyMeansAll = false,
  });
  @override
  State<_LibrarySelectors> createState() => _LibrarySelectorsState();
}

class _LibrarySelectorsState extends State<_LibrarySelectors> {
  late Future<(List<Project>, List<Experience>)> _future;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Project>, List<Experience>)> _load() async {
    final service = context.read<PortfolioService>();
    final results = await Future.wait<Object>([
      service.getAllProjects(),
      service.getAllExperience(),
    ]);
    return (results[0] as List<Project>, results[1] as List<Experience>);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<(List<Project>, List<Experience>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              children: [
                Text(adminErrorMessage(snapshot.error!)),
                TextButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: const Text('Retry loading content'),
                ),
              ],
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: LinearProgressIndicator(semanticsLabel: 'Loading content'),
            );
          }
          final (projects, experience) = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderedContentPicker(
                label: 'Featured projects',
                choices: projects
                    .map(
                      (p) => ContentChoice(
                        id: p.id,
                        label: p.title,
                        isActive: p.isActive,
                      ),
                    )
                    .toList(),
                selected: widget.projects,
                onChanged: widget.onProjects,
                emptyMeansAll: widget.emptyMeansAll,
              ),
              const SizedBox(height: 24),
              OrderedContentPicker(
                label: 'Featured experience',
                choices: experience
                    .map(
                      (e) => ContentChoice(
                        id: e.id,
                        label: '${e.role} · ${e.company}',
                        isActive: e.isActive,
                      ),
                    )
                    .toList(),
                selected: widget.experience,
                onChanged: widget.onExperience,
                emptyMeansAll: widget.emptyMeansAll,
              ),
            ],
          );
        },
      );
}

class SettingsFormDialog extends StatefulWidget {
  final PortfolioSettings settings;
  const SettingsFormDialog({super.key, required this.settings});
  @override
  State<SettingsFormDialog> createState() => _SettingsFormDialogState();
}

class _SettingsFormDialogState extends State<SettingsFormDialog> {
  late final _Draft _profile;
  late final List<_Draft> _highlights;
  late final List<_Draft> _skills;
  late final List<_Draft> _education;
  late final List<_Draft> _certifications;
  late final List<_Draft> _quiz;
  late final List<_Draft> _personality;
  final List<_Draft> _retired = [];
  late List<String> _awards;
  late List<String> _now;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _profile = _Draft({
      'name': s.name,
      'initials': s.initials,
      'role': s.role,
      'tagline': s.tagline,
      'location': s.location,
      'about': s.about,
      'summary': s.summary,
      'email': s.email,
      'phone': s.phone,
      'github': s.github ?? '',
      'linkedin': s.linkedin ?? '',
      'twitter': s.twitter ?? '',
      'instagram': s.instagram ?? '',
      'resumeUrl': s.resumeUrl ?? '',
      'availability': s.availability,
    });
    _highlights = s.highlights
        .map(
          (h) => _Draft({'label': h.label, 'value': h.value, 'note': h.note}),
        )
        .toList();
    _skills = s.skillGroups
        .map((g) => _Draft({'category': g.category}, items: [...g.items]))
        .toList();
    _education = s.education
        .map((e) => _Draft({'when': e.when, 'where': e.where, 'what': e.what}))
        .toList();
    _certifications = s.certifications
        .map(
          (c) => _Draft({'name': c.name, 'issuer': c.issuer, 'year': c.year}),
        )
        .toList();
    _quiz = s.quiz
        .map(
          (q) => _Draft(
            {'question': q.q, 'fact': q.funFact},
            items: [...q.options],
            answer: q.answer,
          ),
        )
        .toList();
    _personality = s.personality
        .map((p) => _Draft({'label': p.label, 'value': p.value}))
        .toList();
    _awards = [...s.awards];
    _now = [...s.now];
  }

  @override
  void dispose() {
    for (final draft in [
      _profile,
      ..._highlights,
      ..._skills,
      ..._education,
      ..._certifications,
      ..._quiz,
      ..._personality,
      ..._retired,
    ]) {
      draft.dispose();
    }
    super.dispose();
  }

  Widget _rows(
    List<_Draft> rows,
    String label,
    _Draft Function() create,
    Widget Function(_Draft, int) builder,
  ) => EditableRows<_Draft>(
    rows: rows,
    itemLabel: label,
    onAdd: () => setState(() => rows.add(create())),
    onRemove: (index) => setState(() => _retired.add(rows.removeAt(index))),
    onMove: (from, to) => setState(() => rows.insert(to, rows.removeAt(from))),
    builder: builder,
  );

  Future<void> _save() async {
    for (final question in _quiz) {
      if (question.items.length < 2 ||
          question.answer < 0 ||
          question.answer >= question.items.length) {
        throw const FormatException(
          'Each quiz question needs at least two options and a correct answer.',
        );
      }
      if (question.items.toSet().length != question.items.length) {
        throw const FormatException('Quiz answers must be distinct.');
      }
    }
    for (final group in _skills) {
      if (group.items.isEmpty) {
        throw const FormatException(
          'Add at least one skill to each skill group, or remove the group.',
        );
      }
    }
    final service = context.read<PortfolioService>();
    final latest = await service.getSettings();
    await service.updateSettings(
      latest.copyWith(
        name: _profile.text('name'),
        initials: _profile.text('initials'),
        role: _profile.text('role'),
        tagline: _profile.text('tagline'),
        location: _profile.text('location'),
        about: _profile.text('about'),
        summary: _profile.text('summary'),
        email: _profile.text('email'),
        phone: _profile.text('phone'),
        availability: _profile.text('availability'),
        github: _canonicalUrl(_profile.text('github')),
        linkedin: _canonicalUrl(_profile.text('linkedin')),
        twitter: _canonicalUrl(_profile.text('twitter')),
        instagram: _canonicalUrl(_profile.text('instagram')),
        resumeUrl: _canonicalUrl(
          _profile.text('resumeUrl'),
          allowRelative: true,
        ),
        highlights: _highlights
            .map(
              (d) => Highlight(
                label: d.text('label'),
                value: d.text('value'),
                note: d.text('note'),
              ),
            )
            .toList(),
        skillGroups: _skills
            .map(
              (d) => SkillGroup(category: d.text('category'), items: d.items),
            )
            .toList(),
        education: _education
            .map(
              (d) => EducationEntry(
                when: d.text('when'),
                where: d.text('where'),
                what: d.text('what'),
              ),
            )
            .toList(),
        certifications: _certifications
            .map(
              (d) => Certification(
                name: d.text('name'),
                issuer: d.text('issuer'),
                year: d.text('year'),
              ),
            )
            .toList(),
        quiz: _quiz
            .map(
              (d) => QuizQuestion(
                q: d.text('question'),
                options: d.items,
                answer: d.answer,
                funFact: d.text('fact'),
              ),
            )
            .toList(),
        personality: _personality
            .map(
              (d) => PersonalityItem(
                label: d.text('label'),
                value: d.text('value'),
              ),
            )
            .toList(),
        awards: _awards,
        now: _now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AdminEditorDialog(
    title: 'Edit profile',
    onSave: _save,
    introduction:
        'Profile details are public. Add only information you want visitors to see.',
    fields: [
      EditorSection(
        title: 'Identity and introduction',
        initiallyExpanded: true,
        child: Column(
          children: [
            AdminTextField(
              controller: _profile['name'],
              label: 'Name',
              required: true,
              maxLength: 200,
            ),
            AdminTextField(
              controller: _profile['initials'],
              label: 'Initials',
              maxLength: 20,
            ),
            AdminTextField(
              controller: _profile['role'],
              label: 'Role',
              maxLength: 200,
            ),
            AdminTextField(
              controller: _profile['tagline'],
              label: 'Introduction',
              required: true,
              maxLines: 2,
              maxLength: 1000,
            ),
            AdminTextField(
              controller: _profile['location'],
              label: 'Location',
              maxLength: 200,
            ),
            AdminTextField(
              controller: _profile['availability'],
              label: 'Availability',
              helper: 'Leave blank to hide the availability message.',
              maxLength: 300,
            ),
            AdminTextField(
              controller: _profile['summary'],
              label: 'Summary',
              maxLines: 4,
              maxLength: 10000,
            ),
            AdminTextField(
              controller: _profile['about'],
              label: 'Additional bio',
              maxLines: 3,
              maxLength: 10000,
            ),
          ],
        ),
      ),
      EditorSection(
        title: 'Contact and links',
        child: Column(
          children: [
            AdminTextField(
              controller: _profile['email'],
              label: 'Email',
              required: true,
              maxLength: 320,
              validator: _emailError,
              keyboardType: TextInputType.emailAddress,
            ),
            AdminTextField(
              controller: _profile['phone'],
              label: 'Phone',
              keyboardType: TextInputType.phone,
              maxLength: 50,
            ),
            for (final field in [
              ('github', 'GitHub URL'),
              ('linkedin', 'LinkedIn URL'),
              ('twitter', 'X / Twitter URL'),
              ('instagram', 'Instagram URL'),
            ])
              AdminTextField(
                controller: _profile[field.$1],
                label: field.$2,
                validator: _webUrlError,
                keyboardType: TextInputType.url,
              ),
            AdminTextField(
              controller: _profile['resumeUrl'],
              label: 'Résumé URL',
              helper: 'Leave blank to use the résumé bundled with the website.',
              validator: (value) => _webUrlError(value, allowRelative: true),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
      EditorSection(
        title: 'Highlights',
        child: _rows(
          _highlights,
          'Highlight',
          () => _Draft({'label': '', 'value': '', 'note': ''}),
          (d, _) => Column(
            children: [
              AdminTextField(
                controller: d['label'],
                label: 'Label',
                required: true,
                maxLength: 200,
              ),
              AdminTextField(
                controller: d['value'],
                label: 'Value',
                required: true,
                maxLength: 200,
              ),
              AdminTextField(
                controller: d['note'],
                label: 'Supporting detail',
                maxLength: 1000,
              ),
            ],
          ),
        ),
      ),
      EditorSection(
        title: 'Skills',
        child: _rows(
          _skills,
          'Skill group',
          () => _Draft({'category': ''}, items: []),
          (d, _) => Column(
            children: [
              AdminTextField(
                controller: d['category'],
                label: 'Category',
                required: true,
                maxLength: 200,
              ),
              StringListEditor(
                initialValues: d.items,
                itemLabel: 'Skill',
                maxItems: 30,
                itemMaxLength: 200,
                onChanged: (values) => d.items = values,
              ),
            ],
          ),
        ),
      ),
      EditorSection(
        title: 'Education',
        child: _rows(
          _education,
          'Education',
          () => _Draft({'when': '', 'where': '', 'what': ''}),
          (d, _) => Column(
            children: [
              AdminTextField(
                controller: d['where'],
                label: 'Institution',
                required: true,
                maxLength: 500,
              ),
              AdminTextField(
                controller: d['what'],
                label: 'Qualification',
                required: true,
                maxLength: 1000,
              ),
              AdminTextField(
                controller: d['when'],
                label: 'Period',
                maxLength: 200,
              ),
            ],
          ),
        ),
      ),
      EditorSection(
        title: 'Certifications',
        child: _rows(
          _certifications,
          'Certification',
          () => _Draft({'name': '', 'issuer': '', 'year': ''}),
          (d, _) => Column(
            children: [
              AdminTextField(
                controller: d['name'],
                label: 'Certification name',
                required: true,
                maxLength: 500,
              ),
              AdminTextField(
                controller: d['issuer'],
                label: 'Issuer',
                maxLength: 300,
              ),
              AdminTextField(
                controller: d['year'],
                label: 'Year',
                maxLength: 4,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null ||
                        value.trim().isEmpty ||
                        RegExp(r'^\d{4}$').hasMatch(value.trim())
                    ? null
                    : 'Enter a four-digit year or leave blank.',
              ),
            ],
          ),
        ),
      ),
      EditorSection(
        title: 'Awards',
        child: StringListEditor(
          initialValues: _awards,
          itemLabel: 'Award',
          onChanged: (values) => _awards = values,
        ),
      ),
      EditorSection(
        title: 'Current focus',
        child: StringListEditor(
          initialValues: _now,
          itemLabel: 'Current focus',
          onChanged: (values) => _now = values,
        ),
      ),
      EditorSection(
        title: 'Personality',
        child: _rows(
          _personality,
          'Personality detail',
          () => _Draft({'label': '', 'value': ''}),
          (d, _) => Column(
            children: [
              AdminTextField(
                controller: d['label'],
                label: 'Prompt',
                required: true,
                maxLength: 200,
              ),
              AdminTextField(
                controller: d['value'],
                label: 'Answer',
                required: true,
                maxLength: 1000,
              ),
            ],
          ),
        ),
      ),
      EditorSection(
        title: 'Quiz',
        child: _rows(
          _quiz,
          'Question',
          () => _Draft({'question': '', 'fact': ''}, items: ['', '']),
          (d, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminTextField(
                controller: d['question'],
                label: 'Question',
                required: true,
                maxLength: 1000,
              ),
              StringListEditor(
                initialValues: d.items,
                itemLabel: 'Option',
                maxItems: 8,
                itemMaxLength: 500,
                onRemove: (index) {
                  if (d.answer == index) {
                    d.answer = -1;
                  } else if (d.answer > index) {
                    d.answer--;
                  }
                },
                onMove: (from, to) {
                  if (d.answer == from) {
                    d.answer = to;
                  } else if (d.answer == to) {
                    d.answer = from;
                  }
                },
                onChanged: (values) => setState(() => d.items = values),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey('answer-$index-${d.items.length}-${d.answer}'),
                initialValue:
                    d.items.isEmpty ||
                        d.answer < 0 ||
                        d.answer >= d.items.length
                    ? null
                    : d.answer,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Correct answer',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (var i = 0; i < d.items.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        '${i + 1}. ${d.items[i]}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => d.answer = value);
                },
                validator: (value) =>
                    d.items.length < 2 ||
                        value == null ||
                        value >= d.items.length
                    ? 'Add at least two options and choose an answer.'
                    : null,
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: d['fact'],
                label: 'Explanation',
                maxLines: 2,
                maxLength: 2000,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
