import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/experience_provider.dart';
import 'screens/mode_selector/mode_selector_screen.dart';
import 'screens/manual/manual_page.dart';
import 'screens/automated/automated_mode.dart';
import 'screens/lucky/lucky_mode.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';

String? portfolioSlug(Uri uri) =>
    uri.queryParameters['job'] ?? uri.queryParameters['jobId'];
String? adminRedirect({
  required bool initialized,
  required bool loggedIn,
  required bool authorized,
  required String location,
}) {
  if (!initialized) return null;
  if (location == '/login' && authorized) return '/admin';
  if (location.startsWith('/admin')) {
    if (!loggedIn) return '/login';
    if (!authorized) return '/access-denied';
  }
  if (location == '/access-denied' && authorized) return '/admin';
  return null;
}

GoRouter createAppRouter(AuthProvider auth) => GoRouter(
  refreshListenable: auth,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, state) => ManualPage(jobId: portfolioSlug(state.uri)),
    ),
    GoRoute(
      path: '/portfolio',
      builder: (_, state) => ManualPage(jobId: portfolioSlug(state.uri)),
    ),
    GoRoute(
      path: '/modes',
      builder: (context, state) {
        final experience = context.watch<ExperienceProvider>();
        if (!experience.hasSelectedMode) return const ModeSelectorScreen();
        return switch (experience.mode) {
          ExperienceMode.automated => AutomatedMode(
            jobId: portfolioSlug(state.uri),
          ),
          ExperienceMode.lucky => const LuckyMode(),
          ExperienceMode.manual => ManualPage(jobId: portfolioSlug(state.uri)),
        };
      },
    ),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: '/admin',
      builder: (context, _) => ListenableBuilder(
        listenable: auth,
        builder: (_, _) => !auth.isInitialized
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Restoring your session',
                  ),
                ),
              )
            : auth.isAdmin
            ? const AdminDashboard()
            : const SizedBox.shrink(),
      ),
    ),
    GoRoute(
      path: '/access-denied',
      builder: (context, _) => _RouteMessage(
        title: 'Administrator access required',
        message: auth.error ?? 'This account cannot manage the portfolio.',
        action: TextButton(
          onPressed: () async {
            await auth.signOut();
            if (context.mounted) context.go('/login');
          },
          child: const Text('Sign in with another account'),
        ),
      ),
    ),
  ],
  redirect: (_, state) => adminRedirect(
    initialized: auth.isInitialized,
    loggedIn: auth.isLoggedIn,
    authorized: auth.isAdmin,
    location: state.matchedLocation,
  ),
  errorBuilder: (context, _) => _RouteMessage(
    title: 'Page not found',
    message: 'The page you requested is not available.',
    action: TextButton(
      onPressed: () => context.go('/'),
      child: const Text('Back to portfolio'),
    ),
  ),
);

class _RouteMessage extends StatelessWidget {
  final String title;
  final String message;
  final Widget action;
  const _RouteMessage({
    required this.title,
    required this.message,
    required this.action,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            action,
          ],
        ),
      ),
    ),
  );
}
