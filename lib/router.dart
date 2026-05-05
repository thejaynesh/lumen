import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/experience_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/experience_selector/experience_selector_screen.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Experience selector (landing page)
    GoRoute(
      path: '/',
      builder: (context, state) {
        final experienceProvider = context.watch<ExperienceProvider>();

        // If user hasn't selected a mode, show selector
        if (!experienceProvider.hasSelectedMode) {
          return const ExperienceSelectorScreen();
        }

        // Otherwise show home with selected mode
        final jobSlug = state.uri.queryParameters['job'];
        return HomeScreen(jobId: jobSlug);
      },
    ),
    // Direct portfolio access (bypasses selector for job-specific links)
    GoRoute(
      path: '/portfolio',
      builder: (context, state) {
        final jobSlug = state.uri.queryParameters['job'];
        // Set manual mode if not already set
        final experienceProvider = context.read<ExperienceProvider>();
        if (!experienceProvider.hasSelectedMode) {
          experienceProvider.setMode(ExperienceMode.manual);
        }
        return HomeScreen(jobId: jobSlug);
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
