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
                  activeColor: AppTheme.primary,
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
                  activeColor: AppTheme.primary,
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
                  activeColor: AppTheme.primary,
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
