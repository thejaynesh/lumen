import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import 'form_dialogs.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Projects', 'Experience', 'Jobs', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Lumen',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Navigation
          ..._tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            final isSelected = _selectedIndex == index;
            final icons = [
              Icons.folder_outlined,
              Icons.work_outline,
              Icons.link,
              Icons.settings_outlined,
            ];
            return _buildNavItem(
              title,
              icons[index],
              isSelected,
              () => setState(() => _selectedIndex = index),
            );
          }),
          const Spacer(),
          // Sign out
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sign Out'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.darkTextSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildNavItem(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.darkTextSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.darkTextSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Text(
            _tabs[_selectedIndex],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Portfolio'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const ProjectsTab();
      case 1:
        return const ExperienceTab();
      case 2:
        return const JobsTab();
      case 3:
        return const SettingsTab();
      default:
        return const SizedBox();
    }
  }
}

// ============== PROJECTS TAB ==============
class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<PortfolioService>();
    return StreamBuilder(
      stream: service.watchProjects(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final projects = snapshot.data!;
        return _buildListWithAdd(
          context: context,
          items: projects,
          emptyMessage: 'No projects yet',
          onAdd: () => _showProjectDialog(context),
          itemBuilder: (project) => _AdminCard(
            title: project.title,
            subtitle: project.category,
            trailing: Switch(
              value: project.isActive,
              onChanged: (v) =>
                  service.updateProject(project.copyWith(isActive: v)),
              activeColor: AppTheme.primary,
            ),
            onTap: () => _showProjectDialog(context, project: project),
            onDelete: () => service.deleteProject(project.id),
          ),
        );
      },
    );
  }

  void _showProjectDialog(BuildContext context, {Project? project}) {
    showDialog(
      context: context,
      builder: (_) => ProjectFormDialog(project: project),
    );
  }
}

// ============== EXPERIENCE TAB ==============
class ExperienceTab extends StatelessWidget {
  const ExperienceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<PortfolioService>();
    return StreamBuilder(
      stream: service.watchExperience(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final experiences = snapshot.data!;
        return _buildListWithAdd(
          context: context,
          items: experiences,
          emptyMessage: 'No experience yet',
          onAdd: () => _showExpDialog(context),
          itemBuilder: (exp) => _AdminCard(
            title: exp.role,
            subtitle: '${exp.company} • ${exp.period}',
            trailing: Switch(
              value: exp.isActive,
              onChanged: (v) =>
                  service.updateExperience(exp.copyWith(isActive: v)),
              activeColor: AppTheme.primary,
            ),
            onTap: () => _showExpDialog(context, experience: exp),
            onDelete: () => service.deleteExperience(exp.id),
          ),
        );
      },
    );
  }

  void _showExpDialog(BuildContext context, {Experience? experience}) {
    showDialog(
      context: context,
      builder: (_) => ExperienceFormDialog(experience: experience),
    );
  }
}

// ============== JOBS TAB ==============
class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<PortfolioService>();
    return StreamBuilder(
      stream: service.watchJobs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final jobs = snapshot.data!;
        return _buildListWithAdd(
          context: context,
          items: jobs,
          emptyMessage: 'No job postings yet',
          onAdd: () => _showJobDialog(context),
          itemBuilder: (job) => _AdminCard(
            title: job.title,
            subtitle: '${job.company} • Views: ${job.viewCount}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyJobUrl(context, job.slug),
                  tooltip: 'Copy URL',
                ),
                Switch(
                  value: job.isActive,
                  onChanged: (v) =>
                      service.updateJob(job.copyWith(isActive: v)),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
            onTap: () => _showJobDialog(context, job: job),
            onDelete: () => service.deleteJob(job.id),
          ),
        );
      },
    );
  }

  void _showJobDialog(BuildContext context, {JobPosting? job}) {
    showDialog(
      context: context,
      builder: (_) => JobFormDialog(job: job),
    );
  }

  Future<void> _copyJobUrl(BuildContext context, String slug) async {
    final url = '${Uri.base.origin}/portfolio?job=$slug';
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied: $url')),
      );
    }
  }
}

// ============== SETTINGS TAB ==============
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<PortfolioService>();
    return StreamBuilder(
      stream: service.watchSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final settings = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _SettingsCard(settings: settings),
              const SizedBox(height: 32),
              Text(
                'Default Homepage Content',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Select which projects and experience to show on the generic homepage.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showDefaultsDialog(context, settings),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Defaults'),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => service.seedInitialData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Seed Sample Data'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.darkTextSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultsDialog(BuildContext context, dynamic settings) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Defaults editor coming soon!')),
    );
  }
}

// ============== HELPER WIDGETS ==============
Widget _buildListWithAdd<T>({
  required BuildContext context,
  required List<T> items,
  required String emptyMessage,
  required VoidCallback onAdd,
  required Widget Function(T) itemBuilder,
}) {
  return Stack(
    children: [
      if (items.isEmpty)
        Center(
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
      else
        ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (_, i) => itemBuilder(items[i]),
        ),
      Positioned(
        right: 24,
        bottom: 24,
        child: FloatingActionButton.extended(
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Add New', style: TextStyle(color: Colors.black)),
          backgroundColor: AppTheme.primary,
        ),
      ),
    ],
  );
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppTheme.darkTextSecondary),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final dynamic settings;
  const _SettingsCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Name', settings.name),
            _row('Tagline', settings.tagline),
            _row('Email', settings.email),
            _row('GitHub', settings.github ?? 'Not set'),
            _row('LinkedIn', settings.linkedin ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.darkTextSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== FORM DIALOGS ==============
class ProjectFormDialog extends StatelessWidget {
  final dynamic project;
  const ProjectFormDialog({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(project == null ? 'Add Project' : 'Edit Project'),
      content: const SizedBox(
        width: 400,
        child: Text('Project form coming in next update'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class ExperienceFormDialog extends StatelessWidget {
  final dynamic experience;
  const ExperienceFormDialog({super.key, this.experience});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(experience == null ? 'Add Experience' : 'Edit Experience'),
      content: const SizedBox(
        width: 400,
        child: Text('Experience form coming in next update'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class JobFormDialog extends StatelessWidget {
  final dynamic job;
  const JobFormDialog({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(job == null ? 'Add Job Posting' : 'Edit Job Posting'),
      content: const SizedBox(
        width: 400,
        child: Text('Job form coming in next update'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
