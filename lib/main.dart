import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'services/portfolio_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/experience_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs (no hash)
  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LumenApp());
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = PortfolioService();

    return MultiProvider(
      providers: [
        Provider<PortfolioService>(create: (_) => portfolioService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(portfolioService),
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ExperienceProvider>(
          create: (_) => ExperienceProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Lumen Portfolio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
            // Hide scrollbars globally (Broadside design has none); scrolling
            // via wheel/drag still works.
            scrollBehavior: const _NoScrollbarBehavior(),
            // Every Broadside screen returns a bare Container (no Scaffold), so
            // wrap each route in a transparent Material to provide the required
            // Material ancestor for text — without it Flutter paints debug
            // yellow underlines under all text.
            builder: (context, child) => Material(
              type: MaterialType.transparency,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

/// Removes scrollbars app-wide while keeping wheel/drag scrolling, matching the
/// Broadside design (which hides scrollbars).
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
