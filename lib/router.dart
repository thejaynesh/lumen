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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Mode selector / main entry
    GoRoute(
      path: '/',
      builder: (context, state) {
        final experienceProvider = context.watch<ExperienceProvider>();

        if (!experienceProvider.hasSelectedMode) {
          return const ModeSelectorScreen();
        }

        switch (experienceProvider.mode) {
          case ExperienceMode.automated:
            return const AutomatedMode();
          case ExperienceMode.lucky:
            return const LuckyMode();
          case ExperienceMode.manual:
            return ManualPage(jobId: state.uri.queryParameters['job']);
        }
      },
    ),
    // Direct portfolio access (bypasses selector for job-specific links)
    GoRoute(
      path: '/portfolio',
      builder: (context, state) {
        if (!context.read<ExperienceProvider>().hasSelectedMode) {
          context.read<ExperienceProvider>().setMode(ExperienceMode.manual);
        }
        return ManualPage(jobId: state.uri.queryParameters['job']);
      },
    ),
    // Admin login
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // Admin dashboard (protected)
    GoRoute(
      path: '/admin',
      builder: (context, state) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }
        return const AdminDashboard();
      },
    ),
  ],
  // Redirect logic for protected routes
  redirect: (context, state) {
    // Allow public routes
    if (state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/portfolio') {
      return null;
    }
    // Check auth for admin routes
    try {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn &&
          state.matchedLocation.startsWith('/admin')) {
        return '/login';
      }
    } catch (_) {
      // Provider not ready, allow navigation
    }
    return null;
  },
);
