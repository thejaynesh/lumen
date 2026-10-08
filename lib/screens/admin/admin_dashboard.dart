import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_environment.dart';
import '../../models/portfolio_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import 'editor_fields.dart';
import 'form_dialogs.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selected = 0;
  bool _signingOut = false;
  static const _tabs = ['Projects', 'Experience', 'Tailored links', 'Profile'];
  static const _icons = [
    Icons.folder_outlined,
    Icons.work_outline,
    Icons.link,
    Icons.person_outline,
  ];

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await context.read<AuthProvider>().signOut();
      if (mounted) context.go('/login');
    } catch (error) {
      if (mounted) {
        _notify(context, adminErrorMessage(error));
        setState(() => _signingOut = false);
      }
    }
  }

  Widget _navigation(bool drawer) {
    final environment = context.read<AppEnvironment?>();
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lumen', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Portfolio studio',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                if (environment != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Chip(
                      label: Text(environment.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selected: _selected == i,
                      selectedTileColor: colors.primaryContainer,
                      selectedColor: colors.onPrimaryContainer,
                      leading: Icon(_icons[i]),
                      title: Text(_tabs[i]),
                      onTap: () {
                        setState(() => _selected = i);
                        if (drawer) Navigator.pop(context);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _signingOut ? null : _signOut,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(_signingOut ? 'Signing out…' : 'Sign out'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      return Scaffold(
        appBar: AppBar(
          title: Text(_tabs[_selected]),
          actions: [
            IconButton(
              tooltip: 'Switch theme',
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
            IconButton(
              tooltip: 'View portfolio',
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.open_in_new),
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: wide ? null : Drawer(child: _navigation(true)),
        body: Row(
          children: [
            if (wide)
              SizedBox(
                width: 244,
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: _navigation(false),
                ),
              ),
            if (wide) const VerticalDivider(width: 1),
            Expanded(
              child: switch (_selected) {
                0 => const ProjectsTab(),
                1 => const ExperienceTab(),
                2 => const JobsTab(),
                _ => const SettingsTab(),
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _edit(BuildContext context, Widget editor) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => editor,
  );
  if (saved == true && context.mounted) _notify(context, 'Changes saved.');
}

void _notify(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});
  @override
  Widget build(BuildContext context) => _LiveContent<List<Project>>(
    stream: (service) => service.watchProjects(),
    builder: (context, projects) {
      final service = context.read<PortfolioService>();
      return _LibraryList<Project>(
        items: projects,
        title: 'Your work',
        detail:
            'Build a focused collection of projects and the evidence behind them.',
        addLabel: 'Add project',
        empty:
            'Your project library is empty. Add your first project to get started.',
        onAdd: () => _edit(context, const ProjectFormDialog()),
        itemBuilder: (project) => _ContentCard(
          key: ValueKey(project.id),
          title: project.title,
          subtitle: project.category,
          status: project.isActive ? 'Published' : 'Archived',
          onEdit: () => _edit(context, ProjectFormDialog(project: project)),
          toggleLabel: project.isActive ? 'Archive' : 'Publish',
          confirmation: project.isActive
              ? 'Archive “${project.title}”? It will be hidden from public pages. Existing selections are preserved, so you can publish it again later.'
              : null,
          onToggle: () => project.isActive
              ? service.deleteProject(project.id)
              : service.updateProject(project.copyWith(isActive: true)),
        ),
      );
    },
  );
}

class ExperienceTab extends StatelessWidget {
  const ExperienceTab({super.key});
  @override
  Widget build(BuildContext context) => _LiveContent<List<Experience>>(
    stream: (service) => service.watchExperience(),
    builder: (context, items) {
      final service = context.read<PortfolioService>();
      return _LibraryList<Experience>(
        items: items,
        title: 'Experience',
        detail: 'Tell the story of your work, responsibilities and results.',
        addLabel: 'Add experience',
        empty: 'No experience has been added yet.',
        onAdd: () => _edit(context, const ExperienceFormDialog()),
        itemBuilder: (experience) => _ContentCard(
          key: ValueKey(experience.id),
          title: experience.role,
          subtitle: '${experience.company} · ${experience.period}',
          status: experience.isActive ? 'Published' : 'Archived',
          onEdit: () =>
              _edit(context, ExperienceFormDialog(experience: experience)),
          toggleLabel: experience.isActive ? 'Archive' : 'Publish',
          confirmation: experience.isActive
              ? 'Archive this experience? It will be hidden publicly. Existing selections are preserved for later restoration.'
              : null,
          onToggle: () => experience.isActive
              ? service.deleteExperience(experience.id)
              : service.updateExperience(experience.copyWith(isActive: true)),
        ),
      );
    },
  );
}

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});
  @override
  Widget build(BuildContext context) => _LiveContent<List<JobPosting>>(
    stream: (service) => service.watchJobs(),
    builder: (context, jobs) {
      final service = context.read<PortfolioService>();
      return _LibraryList<JobPosting>(
        items: jobs,
        title: 'A portfolio for each opportunity',
        detail:
            'Keep application notes private and share a selection of relevant work.',
        addLabel: 'Create link',
        empty:
            'Create a tailored link when you want to highlight specific projects for an opportunity.',
        onAdd: () => _edit(context, const JobFormDialog()),
        itemBuilder: (job) {
          final expired =
              job.expiresAt != null && job.expiresAt!.isBefore(DateTime.now());
          return _ContentCard(
            key: ValueKey(job.id),
            title: job.title,
            subtitle: job.company,
            status: !job.isActive
                ? 'Archived'
                : expired
                ? 'Expired'
                : 'Published',
            onEdit: () => _edit(context, JobFormDialog(job: job)),
            toggleLabel: job.isActive ? 'Archive' : 'Publish',
            confirmation: job.isActive
                ? 'Archive this tailored link? Visitors will no longer be able to view it until you publish it again.'
                : null,
            onToggle: () async {
              if (!job.isActive && expired) {
                throw StateError(
                  'Update or clear the expiry before publishing this link.',
                );
              }
              await service.updateJob(job.copyWith(isActive: !job.isActive));
            },
            extra: [
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _ShareLinkDialog(job: job),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview & share'),
              ),
            ],
            onDelete: () => service.deleteJob(job.id),
          );
        },
      );
    },
  );
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) => _LiveContent<PortfolioSettings>(
    stream: (service) => service.watchSettings(),
    builder: (context, settings) => ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Your public profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your introduction, contact details, skills and achievements in one place.',
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () =>
                _edit(context, SettingsFormDialog(settings: settings)),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit profile'),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in [
                  ('Name', settings.name),
                  ('Introduction', settings.tagline),
                  ('Availability', settings.availability),
                  ('Email', settings.email),
                  ('Location', settings.location),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$1,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.$2.isEmpty ? 'Not set' : entry.$2,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                Text(
                  '${settings.certifications.length} certifications · ${settings.skillGroups.length} skill groups · ${settings.education.length} education entries',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Homepage selection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose and reorder the work that appears on your main portfolio. An empty selection shows all published items.',
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () =>
                _edit(context, DefaultsFormDialog(settings: settings)),
            icon: const Icon(Icons.reorder),
            label: const Text('Edit homepage selection'),
          ),
        ),
      ],
    ),
  );
}

class _LiveContent<T> extends StatefulWidget {
  final Stream<T> Function(PortfolioService) stream;
  final Widget Function(BuildContext, T) builder;
  const _LiveContent({required this.stream, required this.builder});
  @override
  State<_LiveContent<T>> createState() => _LiveContentState<T>();
}

class _LiveContentState<T> extends State<_LiveContent<T>> {
  late Stream<T> _stream;
  @override
  void initState() {
    super.initState();
    _stream = widget.stream(context.read<PortfolioService>());
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    stream: _stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 32),
                const SizedBox(height: 16),
                Text(
                  adminErrorMessage(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => setState(
                    () => _stream = widget.stream(
                      context.read<PortfolioService>(),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Loading portfolio content',
          ),
        );
      }
      return widget.builder(context, snapshot.data as T);
    },
  );
}

class _LibraryList<T> extends StatelessWidget {
  final List<T> items;
  final String title, detail, addLabel, empty;
  final VoidCallback onAdd;
  final Widget Function(T) itemBuilder;
  const _LibraryList({
    required this.items,
    required this.title,
    required this.detail,
    required this.addLabel,
    required this.empty,
    required this.onAdd,
    required this.itemBuilder,
  });
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 500 ? 16 : 28),
    itemCount: items.length + 1,
    itemBuilder: (context, index) {
      if (index > 0) return itemBuilder(items[index - 1]);
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(detail),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(addLabel),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  empty,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _ContentCard extends StatefulWidget {
  final String title, subtitle, status, toggleLabel;
  final String? confirmation;
  final VoidCallback onEdit;
  final Future<void> Function() onToggle;
  final Future<void> Function()? onDelete;
  final List<Widget> extra;
  const _ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.toggleLabel,
    required this.onEdit,
    required this.onToggle,
    this.confirmation,
    this.onDelete,
    this.extra = const [],
  });
  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _busy = false;
  Future<void> _run(
    Future<void> Function() action, {
    String? confirmation,
    bool delete = false,
  }) async {
    if (_busy) return;
    if (confirmation != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            delete ? 'Delete tailored link?' : '${widget.toggleLabel} content?',
          ),
          content: Text(confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(delete ? 'Delete link' : widget.toggleLabel),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(
        SnackBar(content: Text(delete ? 'Link deleted.' : 'Content updated.')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(adminErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                widget.subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Chip(
              label: Text(widget.status),
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(semanticsLabel: 'Saving change'),
            ),
          AbsorbPointer(
            absorbing: _busy,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : widget.onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                ...widget.extra,
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          widget.onToggle,
                          confirmation: widget.confirmation,
                        ),
                  icon: Icon(
                    widget.status == 'Archived'
                        ? Icons.publish_outlined
                        : Icons.archive_outlined,
                    size: 18,
                  ),
                  label: Text(widget.toggleLabel),
                ),
                if (widget.onDelete != null)
                  TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            widget.onDelete!,
                            delete: true,
                            confirmation:
                                'Permanently delete this application record and its public link? The URL will stop working. Your project and experience libraries will be kept.',
                          ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShareLinkDialog extends StatefulWidget {
  final JobPosting job;
  const _ShareLinkDialog({required this.job});
  @override
  State<_ShareLinkDialog> createState() => _ShareLinkDialogState();
}

class _ShareLinkDialogState extends State<_ShareLinkDialog> {
  String? _message;
  late final Uri _uri = Uri.base
      .resolve('/portfolio')
      .replace(queryParameters: {'job': widget.job.slug});
  Future<void> _preview() async {
    try {
      if (!await launchUrl(
        _uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      )) {
        throw StateError(
          'The preview could not open. Allow pop-ups and try again.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _message = adminErrorMessage(error));
    }
  }

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: _uri.toString()));
      if (mounted) setState(() => _message = 'Link copied.');
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Could not copy automatically. Select and copy the link above.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final live =
        job.isActive &&
        (job.expiresAt == null || job.expiresAt!.isAfter(DateTime.now()));
    return AlertDialog(
      title: const Text('Preview & share'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                live
                    ? 'Review the public portfolio before sharing it.'
                    : 'Publish this link and set a future expiry before sharing it.',
              ),
              const SizedBox(height: 16),
              if (job.customTagline?.isNotEmpty == true)
                Text(
                  job.customTagline!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (job.customAbout?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(job.customAbout!),
                ),
              const SizedBox(height: 16),
              Text(
                '${job.projectIds.length} selected projects · ${job.experienceIds.length} selected experience entries',
              ),
              const SizedBox(height: 12),
              SelectableText(_uri.toString()),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Semantics(liveRegion: true, child: Text(_message!)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: live ? _preview : null,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Preview portfolio'),
        ),
        FilledButton.icon(
          onPressed: live ? _copy : null,
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy link'),
        ),
      ],
    );
  }
}
