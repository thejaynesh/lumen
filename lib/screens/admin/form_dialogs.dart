import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';

// ============== SHARED FIELDS ==============

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  const _LabeledTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
      ),
    );
  }
}

/// Tag input: comma- or enter-separated string entries shown as Material chips.
class _ChipField extends StatefulWidget {
  final List<String> values;
  final String label;
  final ValueChanged<List<String>> onChanged;
  const _ChipField({
    required this.values,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_ChipField> createState() => _ChipFieldState();
}

class _ChipFieldState extends State<_ChipField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    final next = [...widget.values, t];
    widget.onChanged(next);
    _controller.clear();
  }

  void _remove(int i) {
    final next = [...widget.values]..removeAt(i);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: AppTheme.darkTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.values.asMap().entries.map(
                (e) => Chip(
                  label: Text(e.value),
                  onDeleted: () => _remove(e.key),
                  deleteIconColor: AppTheme.darkTextSecondary,
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type and press Enter',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _add,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============== PROJECT FORM ==============

class ProjectFormDialog extends StatefulWidget {
  final Project? project;
  const ProjectFormDialog({super.key, this.project});

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _link;
  late final TextEditingController _imageUrl;
  late final TextEditingController _colorHex;
  late final TextEditingController _order;
  late final TextEditingController _tag;
  late final TextEditingController _kpi;
  late List<String> _techStack;
  late List<String> _tags;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = TextEditingController(text: p?.title ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _link = TextEditingController(text: p?.link ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _colorHex = TextEditingController(
      text:
          '#${(p?.colorHex ?? 0xFFFF6B35).toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );
    _order = TextEditingController(text: (p?.order ?? 0).toString());
    _tag = TextEditingController(text: p?.tag ?? '');
    _kpi = TextEditingController(text: p?.kpi ?? '');
    _techStack = List.of(p?.techStack ?? const []);
    _tags = List.of(p?.tags ?? const []);
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _description.dispose();
    _link.dispose();
    _imageUrl.dispose();
    _colorHex.dispose();
    _order.dispose();
    _tag.dispose();
    _kpi.dispose();
    super.dispose();
  }

  int _parseHex(String input) {
    var s = input.replaceAll('#', '').trim();
    if (s.length == 6) s = 'FF$s';
    return int.tryParse(s, radix: 16) ?? 0xFFFF6B35;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final svc = context.read<PortfolioService>();
    try {
      final fields = {
        'title': _title.text.trim(),
        'category': _category.text.trim(),
        'description': _description.text.trim(),
        'techStack': _techStack,
        'link': _link.text.trim().isEmpty ? null : _link.text.trim(),
        'imageUrl':
            _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        'colorHex': _parseHex(_colorHex.text),
        'tags': _tags,
        'tag': _tag.text.trim(),
        'kpi': _kpi.text.trim(),
        'order': int.tryParse(_order.text) ?? 0,
        'isActive': _isActive,
      };

      if (widget.project == null) {
        await svc.addProject(
          Project(
            id: '',
            title: fields['title'] as String,
            category: fields['category'] as String,
            description: fields['description'] as String,
            techStack: fields['techStack'] as List<String>,
            link: fields['link'] as String?,
            imageUrl: fields['imageUrl'] as String?,
            colorHex: fields['colorHex'] as int,
            tags: fields['tags'] as List<String>,
            tag: fields['tag'] as String,
            kpi: fields['kpi'] as String,
            order: fields['order'] as int,
            isActive: fields['isActive'] as bool,
          ),
        );
      } else {
        await svc.updateProject(
          widget.project!.copyWith(
            title: fields['title'] as String,
            category: fields['category'] as String,
            description: fields['description'] as String,
            techStack: fields['techStack'] as List<String>,
            link: fields['link'] as String?,
            imageUrl: fields['imageUrl'] as String?,
            colorHex: fields['colorHex'] as int,
            tags: fields['tags'] as List<String>,
            tag: fields['tag'] as String,
            kpi: fields['kpi'] as String,
            order: fields['order'] as int,
            isActive: fields['isActive'] as bool,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledTextField(
                  controller: _title,
                  label: 'Title',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _category,
                  label: 'Category',
                  hint: 'WEB APPLICATION',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _description,
                  label: 'Description',
                  required: true,
                  maxLines: 3,
                ),
                _ChipField(
                  values: _techStack,
                  label: 'Tech Stack',
                  onChanged: (v) => setState(() => _techStack = v),
                ),
                _ChipField(
                  values: _tags,
                  label: 'Tags (lowercase, e.g. flutter, web)',
                  onChanged: (v) => setState(() => _tags = v),
                ),
                _LabeledTextField(
                  controller: _tag,
                  label: 'Badge label (e.g. "Hackathon · 2024")',
                  hint: 'Hackathon · 2024',
                ),
                _LabeledTextField(
                  controller: _kpi,
                  label: 'KPI line (e.g. "2nd of ~40 teams")',
                  hint: '2nd of ~40 teams',
                ),
                _LabeledTextField(
                  controller: _link,
                  label: 'Link / URL (optional)',
                ),
                _LabeledTextField(
                  controller: _imageUrl,
                  label: 'Image URL (optional)',
                ),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledTextField(
                        controller: _colorHex,
                        label: 'Color (hex)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledTextField(
                        controller: _order,
                        label: 'Order',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ============== EXPERIENCE FORM ==============

class ExperienceFormDialog extends StatefulWidget {
  final Experience? experience;
  const ExperienceFormDialog({super.key, this.experience});

  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _role;
  late final TextEditingController _company;
  late final TextEditingController _period;
  late final TextEditingController _description;
  late final TextEditingController _order;
  late final TextEditingController _city;
  late List<String> _highlights;
  late List<String> _tags;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.experience;
    _role = TextEditingController(text: e?.role ?? '');
    _company = TextEditingController(text: e?.company ?? '');
    _period = TextEditingController(text: e?.period ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _order = TextEditingController(text: (e?.order ?? 0).toString());
    _city = TextEditingController(text: e?.city ?? '');
    _highlights = List.of(e?.highlights ?? const []);
    _tags = List.of(e?.tags ?? const []);
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _role.dispose();
    _company.dispose();
    _period.dispose();
    _description.dispose();
    _order.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final svc = context.read<PortfolioService>();
    try {
      if (widget.experience == null) {
        await svc.addExperience(
          Experience(
            id: '',
            role: _role.text.trim(),
            company: _company.text.trim(),
            period: _period.text.trim(),
            description: _description.text.trim(),
            highlights: _highlights,
            tags: _tags,
            city: _city.text.trim(),
            order: int.tryParse(_order.text) ?? 0,
            isActive: _isActive,
          ),
        );
      } else {
        await svc.updateExperience(
          widget.experience!.copyWith(
            role: _role.text.trim(),
            company: _company.text.trim(),
            period: _period.text.trim(),
            description: _description.text.trim(),
            highlights: _highlights,
            tags: _tags,
            city: _city.text.trim(),
            order: int.tryParse(_order.text) ?? 0,
            isActive: _isActive,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.experience == null ? 'Add Experience' : 'Edit Experience',
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledTextField(
                  controller: _role,
                  label: 'Role',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _company,
                  label: 'Company',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _period,
                  label: 'Period',
                  hint: '2023 - Present',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _city,
                  label: 'City (e.g. Mumbai, India)',
                  hint: 'Mumbai, India',
                ),
                _LabeledTextField(
                  controller: _description,
                  label: 'Description',
                  required: true,
                  maxLines: 4,
                ),
                _ChipField(
                  values: _highlights,
                  label: 'Highlights / Skills',
                  onChanged: (v) => setState(() => _highlights = v),
                ),
                _ChipField(
                  values: _tags,
                  label: 'Tags',
                  onChanged: (v) => setState(() => _tags = v),
                ),
                _LabeledTextField(
                  controller: _order,
                  label: 'Order',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ============== JOB FORM ==============

class JobFormDialog extends StatefulWidget {
  final JobPosting? job;
  const JobFormDialog({super.key, this.job});

  @override
  State<JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends State<JobFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _slug;
  late final TextEditingController _title;
  late final TextEditingController _company;
  late final TextEditingController _description;
  late final TextEditingController _customTagline;
  late final TextEditingController _customAbout;
  late Set<String> _projectIds;
  late Set<String> _experienceIds;
  late bool _isActive;
  DateTime? _expiresAt;
  bool _saving = false;
  String? _slugError;

  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _slug = TextEditingController(text: j?.slug ?? '');
    _title = TextEditingController(text: j?.title ?? '');
    _company = TextEditingController(text: j?.company ?? '');
    _description = TextEditingController(text: j?.description ?? '');
    _customTagline = TextEditingController(text: j?.customTagline ?? '');
    _customAbout = TextEditingController(text: j?.customAbout ?? '');
    _projectIds = Set.of(j?.projectIds ?? const []);
    _experienceIds = Set.of(j?.experienceIds ?? const []);
    _isActive = j?.isActive ?? true;
    _expiresAt = j?.expiresAt;
  }

  @override
  void dispose() {
    _slug.dispose();
    _title.dispose();
    _company.dispose();
    _description.dispose();
    _customTagline.dispose();
    _customAbout.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _slugError = null;
    });
    final svc = context.read<PortfolioService>();
    try {
      final slug = _slug.text.trim().toLowerCase();
      final available = await svc.isSlugAvailable(
        slug,
        excludeId: widget.job?.id,
      );
      if (!available) {
        setState(() {
          _slugError = 'Slug already in use';
          _saving = false;
        });
        return;
      }

      if (widget.job == null) {
        await svc.addJob(
          JobPosting(
            id: '',
            slug: slug,
            title: _title.text.trim(),
            company: _company.text.trim(),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            projectIds: _projectIds.toList(),
            experienceIds: _experienceIds.toList(),
            customTagline: _customTagline.text.trim().isEmpty
                ? null
                : _customTagline.text.trim(),
            customAbout: _customAbout.text.trim().isEmpty
                ? null
                : _customAbout.text.trim(),
            isActive: _isActive,
            expiresAt: _expiresAt,
          ),
        );
      } else {
        await svc.updateJob(
          widget.job!.copyWith(
            slug: slug,
            title: _title.text.trim(),
            company: _company.text.trim(),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            projectIds: _projectIds.toList(),
            experienceIds: _experienceIds.toList(),
            customTagline: _customTagline.text.trim().isEmpty
                ? null
                : _customTagline.text.trim(),
            customAbout: _customAbout.text.trim().isEmpty
                ? null
                : _customAbout.text.trim(),
            isActive: _isActive,
            expiresAt: _expiresAt,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<PortfolioService>();
    return AlertDialog(
      title: Text(widget.job == null ? 'Add Job Posting' : 'Edit Job Posting'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _slug,
                    decoration: InputDecoration(
                      labelText: 'Slug (URL-safe id, lowercase)',
                      hintText: 'pa-7k2f or google-swe-2026',
                      errorText: _slugError,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!RegExp(r'^[a-z0-9][a-z0-9\-]*$').hasMatch(v.trim())) {
                        return 'Lowercase letters, digits, hyphens only';
                      }
                      return null;
                    },
                  ),
                ),
                _LabeledTextField(
                  controller: _title,
                  label: 'Job title',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _company,
                  label: 'Company',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _description,
                  label: 'Description / notes (optional)',
                  maxLines: 2,
                ),
                _LabeledTextField(
                  controller: _customTagline,
                  label: 'Custom hero tagline (optional)',
                ),
                _LabeledTextField(
                  controller: _customAbout,
                  label: 'Custom about / bio (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Featured Projects',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                _MultiSelectStream<Project>(
                  stream: svc.watchProjects(),
                  selected: _projectIds,
                  labelOf: (p) => '${p.title}  ·  ${p.category}',
                  idOf: (p) => p.id,
                  onChanged: (s) => setState(() => _projectIds = s),
                ),
                const SizedBox(height: 16),
                Text(
                  'Featured Experience',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                _MultiSelectStream<Experience>(
                  stream: svc.watchExperience(),
                  selected: _experienceIds,
                  labelOf: (e) => '${e.role} @ ${e.company}',
                  idOf: (e) => e.id,
                  onChanged: (s) => setState(() => _experienceIds = s),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'No expiry'
                            : 'Expires: ${_expiresAt!.toIso8601String().split("T").first}',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickExpiry,
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('Set expiry'),
                    ),
                    if (_expiresAt != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _expiresAt = null),
                      ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _MultiSelectStream<T> extends StatelessWidget {
  final Stream<List<T>> stream;
  final Set<String> selected;
  final String Function(T) labelOf;
  final String Function(T) idOf;
  final ValueChanged<Set<String>> onChanged;

  const _MultiSelectStream({
    required this.stream,
    required this.selected,
    required this.labelOf,
    required this.idOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Text(
            '(Nothing to select — add some first)',
            style: TextStyle(color: AppTheme.darkTextSecondary),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items
                .map(
                  (it) => CheckboxListTile(
                    dense: true,
                    title: Text(labelOf(it)),
                    value: selected.contains(idOf(it)),
                    activeColor: AppTheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      final next = Set<String>.of(selected);
                      if (v == true) {
                        next.add(idOf(it));
                      } else {
                        next.remove(idOf(it));
                      }
                      onChanged(next);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

// ============== SETTINGS FORM ==============

class SettingsFormDialog extends StatefulWidget {
  final PortfolioSettings settings;
  const SettingsFormDialog({super.key, required this.settings});

  @override
  State<SettingsFormDialog> createState() => _SettingsFormDialogState();
}

class _SettingsFormDialogState extends State<SettingsFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Basic profile fields
  late final TextEditingController _name;
  late final TextEditingController _initials;
  late final TextEditingController _role;
  late final TextEditingController _tagline;
  late final TextEditingController _location;
  late final TextEditingController _about;
  late final TextEditingController _summary;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _github;
  late final TextEditingController _linkedin;
  late final TextEditingController _twitter;
  late final TextEditingController _instagram;
  late final TextEditingController _resumeUrl;

  // List fields as structured text
  // highlights: one per line "label | value | note"
  late final TextEditingController _highlights;
  // skillGroups: one group per line "Category: item1, item2, item3"
  late final TextEditingController _skillGroups;
  // awards: one per line
  late final TextEditingController _awards;
  // education: one per line "when | where | what"
  late final TextEditingController _education;

  // JSON fields
  // quiz: JSON array of {q, options[], answer, funFact}
  late final TextEditingController _quiz;
  // personality: JSON array of {label, value}
  late final TextEditingController _personality;

  bool _saving = false;

  // Helper to pretty-print a list of toMap objects as JSON
  String _toJson(List<Map<String, dynamic>> items) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(items);
  }

  @override
  void initState() {
    super.initState();
    final s = widget.settings;

    _name = TextEditingController(text: s.name);
    _initials = TextEditingController(text: s.initials);
    _role = TextEditingController(text: s.role);
    _tagline = TextEditingController(text: s.tagline);
    _location = TextEditingController(text: s.location);
    _about = TextEditingController(text: s.about);
    _summary = TextEditingController(text: s.summary);
    _email = TextEditingController(text: s.email);
    _phone = TextEditingController(text: s.phone);
    _github = TextEditingController(text: s.github ?? '');
    _linkedin = TextEditingController(text: s.linkedin ?? '');
    _twitter = TextEditingController(text: s.twitter ?? '');
    _instagram = TextEditingController(text: s.instagram ?? '');
    _resumeUrl = TextEditingController(text: s.resumeUrl ?? '');

    // highlights → "label | value | note" per line
    _highlights = TextEditingController(
      text: s.highlights
          .map((h) => '${h.label} | ${h.value} | ${h.note}')
          .join('\n'),
    );

    // skillGroups → "Category: item1, item2" per line
    _skillGroups = TextEditingController(
      text: s.skillGroups
          .map((sg) => '${sg.category}: ${sg.items.join(', ')}')
          .join('\n'),
    );

    // awards → one per line
    _awards = TextEditingController(text: s.awards.join('\n'));

    // education → "when | where | what" per line
    _education = TextEditingController(
      text: s.education
          .map((e) => '${e.when} | ${e.where} | ${e.what}')
          .join('\n'),
    );

    // quiz and personality as JSON
    _quiz = TextEditingController(
      text: _toJson(s.quiz.map((q) => q.toMap()).toList()),
    );
    _personality = TextEditingController(
      text: _toJson(s.personality.map((p) => p.toMap()).toList()),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _initials.dispose();
    _role.dispose();
    _tagline.dispose();
    _location.dispose();
    _about.dispose();
    _summary.dispose();
    _email.dispose();
    _phone.dispose();
    _github.dispose();
    _linkedin.dispose();
    _twitter.dispose();
    _instagram.dispose();
    _resumeUrl.dispose();
    _highlights.dispose();
    _skillGroups.dispose();
    _awards.dispose();
    _education.dispose();
    _quiz.dispose();
    _personality.dispose();
    super.dispose();
  }

  // Parse "label | value | note" lines into Highlight list
  List<Highlight> _parseHighlights(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          final parts = line.split('|').map((p) => p.trim()).toList();
          return Highlight(
            label: parts.isNotEmpty ? parts[0] : '',
            value: parts.length > 1 ? parts[1] : '',
            note: parts.length > 2 ? parts[2] : '',
          );
        })
        .toList();
  }

  // Parse "Category: item1, item2" lines into SkillGroup list
  List<SkillGroup> _parseSkillGroups(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          final colonIdx = line.indexOf(':');
          if (colonIdx == -1) {
            return SkillGroup(category: line, items: const []);
          }
          final category = line.substring(0, colonIdx).trim();
          final itemsStr = line.substring(colonIdx + 1).trim();
          final items = itemsStr.isEmpty
              ? <String>[]
              : itemsStr.split(',').map((i) => i.trim()).where((i) => i.isNotEmpty).toList();
          return SkillGroup(category: category, items: items);
        })
        .toList();
  }

  // Parse one-per-line into String list
  List<String> _parseLines(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // Parse "when | where | what" lines into EducationEntry list
  List<EducationEntry> _parseEducation(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          final parts = line.split('|').map((p) => p.trim()).toList();
          return EducationEntry(
            when: parts.isNotEmpty ? parts[0] : '',
            where: parts.length > 1 ? parts[1] : '',
            what: parts.length > 2 ? parts[2] : '',
          );
        })
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse JSON fields before saving — show SnackBar on error
    List<QuizQuestion> quizList;
    List<PersonalityItem> personalityList;
    try {
      final quizRaw = jsonDecode(_quiz.text.trim().isEmpty ? '[]' : _quiz.text.trim());
      quizList = (quizRaw as List<dynamic>)
          .map((e) => QuizQuestion.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz JSON is invalid — fix and retry.')),
        );
      }
      return;
    }
    try {
      final pRaw = jsonDecode(_personality.text.trim().isEmpty ? '[]' : _personality.text.trim());
      personalityList = (pRaw as List<dynamic>)
          .map((e) => PersonalityItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personality JSON is invalid — fix and retry.')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    final svc = context.read<PortfolioService>();
    try {
      await svc.updateSettings(
        widget.settings.copyWith(
          name: _name.text.trim(),
          initials: _initials.text.trim(),
          role: _role.text.trim(),
          tagline: _tagline.text.trim(),
          location: _location.text.trim(),
          about: _about.text.trim(),
          summary: _summary.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          github: _github.text.trim().isEmpty ? null : _github.text.trim(),
          linkedin: _linkedin.text.trim().isEmpty ? null : _linkedin.text.trim(),
          twitter: _twitter.text.trim().isEmpty ? null : _twitter.text.trim(),
          instagram: _instagram.text.trim().isEmpty ? null : _instagram.text.trim(),
          resumeUrl: _resumeUrl.text.trim().isEmpty ? null : _resumeUrl.text.trim(),
          highlights: _parseHighlights(_highlights.text),
          skillGroups: _parseSkillGroups(_skillGroups.text),
          awards: _parseLines(_awards.text),
          education: _parseEducation(_education.text),
          quiz: quizList,
          personality: personalityList,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile Settings'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Identity'),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LabeledTextField(
                        controller: _name,
                        label: 'Name',
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _LabeledTextField(
                        controller: _initials,
                        label: 'Initials',
                        hint: 'JB',
                      ),
                    ),
                  ],
                ),
                _LabeledTextField(
                  controller: _role,
                  label: 'Role / headline (e.g. "Software Engineer")',
                  hint: 'Software Engineer',
                ),
                _LabeledTextField(
                  controller: _tagline,
                  label: 'Tagline',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _location,
                  label: 'Location (e.g. "Boston, MA")',
                  hint: 'Boston, MA',
                ),
                _sectionHeader('Bio'),
                _LabeledTextField(
                  controller: _about,
                  label: 'About (legacy / job fallback)',
                  maxLines: 3,
                ),
                _LabeledTextField(
                  controller: _summary,
                  label: 'Summary',
                  maxLines: 3,
                ),
                _sectionHeader('Contact'),
                _LabeledTextField(
                  controller: _email,
                  label: 'Email',
                  required: true,
                ),
                _LabeledTextField(
                  controller: _phone,
                  label: 'Phone (optional)',
                ),
                _LabeledTextField(
                  controller: _github,
                  label: 'GitHub URL (optional)',
                ),
                _LabeledTextField(
                  controller: _linkedin,
                  label: 'LinkedIn URL (optional)',
                ),
                _LabeledTextField(
                  controller: _twitter,
                  label: 'Twitter URL (optional)',
                ),
                _LabeledTextField(
                  controller: _instagram,
                  label: 'Instagram URL (optional)',
                ),
                _LabeledTextField(
                  controller: _resumeUrl,
                  label: 'Resume URL (optional)',
                ),
                _sectionHeader('Highlights'),
                _LabeledTextField(
                  controller: _highlights,
                  label: 'Highlights (one per line: label | value | note)',
                  hint: 'Projects | 20+ | shipped\nYears | 3 | of experience',
                  maxLines: 5,
                ),
                _sectionHeader('Skills'),
                _LabeledTextField(
                  controller: _skillGroups,
                  label: 'Skill Groups (one group per line: Category: item1, item2)',
                  hint: 'Languages: Dart, Python, TypeScript\nFrameworks: Flutter, FastAPI',
                  maxLines: 6,
                ),
                _sectionHeader('Awards'),
                _LabeledTextField(
                  controller: _awards,
                  label: 'Awards (one per line)',
                  hint: '2nd Place — HackMIT 2024\nDean\'s List — Northeastern University',
                  maxLines: 4,
                ),
                _sectionHeader('Education'),
                _LabeledTextField(
                  controller: _education,
                  label: 'Education (one per line: when | where | what)',
                  hint: '2024–2026 | Northeastern University | MS Computer Science',
                  maxLines: 4,
                ),
                _sectionHeader('Quiz (JSON)'),
                _LabeledTextField(
                  controller: _quiz,
                  label: 'Quiz — JSON array of {q, options[], answer, funFact}',
                  maxLines: 8,
                ),
                _sectionHeader('Personality (JSON)'),
                _LabeledTextField(
                  controller: _personality,
                  label: 'Personality — JSON array of {label, value}',
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
