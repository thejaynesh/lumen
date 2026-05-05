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
import 'providers/narrator_provider.dart';

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
        ChangeNotifierProvider<NarratorProvider>(
          create: (_) => NarratorProvider(),
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
          );
        },
      ),
    );
  }
}
