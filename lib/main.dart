import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config/app_environment.dart';
import 'config/firebase_emulator_defaults.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'services/portfolio_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/experience_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.initialize, this.appBuilder});

  final Future<AppEnvironment> Function()? initialize;
  final Widget Function(AppEnvironment environment)? appBuilder;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<AppEnvironment> _initialization;
  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<AppEnvironment> _initialize() async {
    if (widget.initialize != null) {
      return widget.initialize!();
    }
    final environment = AppEnvironment.fromDefines();
    await configureFirebaseEmulatorDefaults(environment);
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: environment.firebaseOptions);
    }
    if (environment.usesEmulators && !kIsWeb) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        environment.emulatorHost,
        environment.firestorePort,
      );
      await firebase_auth.FirebaseAuth.instance.useAuthEmulator(
        environment.emulatorHost,
        environment.authPort,
      );
    }
    return environment;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppEnvironment>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return widget.appBuilder?.call(snapshot.data!) ??
            LumenApp(environment: snapshot.data!);
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // A temporary Navigator would consume the browser's initial deep link.
        builder: (context, child) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child:
                  snapshot.hasError &&
                      snapshot.connectionState == ConnectionState.done
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Jaynesh Bhandari',
                          style: TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The portfolio could not start. Please try again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => setState(() {
                            _initialization = _initialize();
                          }),
                          child: const Text('Try again'),
                        ),
                        TextButton(
                          onPressed: () => launchUrl(
                            Uri.parse('mailto:thejaynesh@gmail.com'),
                          ),
                          child: const Text('Email Jaynesh'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(
                      semanticsLabel: 'Loading portfolio',
                    ),
            ),
          ),
        ),
      );
    },
  );
}

class LumenApp extends StatefulWidget {
  final AppEnvironment environment;
  final PortfolioService? service;
  const LumenApp({super.key, required this.environment, this.service});
  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  late final PortfolioService _service;
  late final AuthProvider _auth;
  late final GoRouter _router;
  @override
  void initState() {
    super.initState();
    _service =
        widget.service ??
        PortfolioService(
          recordProfileView: widget.environment.isProduction
              ? (_) => FirebaseAnalytics.instance.logEvent(
                  name: 'portfolio_profile_view',
                )
              : null,
        );
    _auth = AuthProvider(_service);
    _router = createAppRouter(_auth);
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<AppEnvironment>.value(value: widget.environment),
      Provider<PortfolioService>.value(value: _service),
      ChangeNotifierProvider<AuthProvider>.value(value: _auth),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<ExperienceProvider>(
        create: (_) => ExperienceProvider(),
      ),
    ],
    child: Consumer<ThemeProvider>(
      builder: (context, theme, _) => MaterialApp.router(
        title: 'Jaynesh Bhandari · Software Engineer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme.themeMode,
        routerConfig: _router,
        builder: (context, child) => Scaffold(
          body: SelectionArea(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ),
  );
}
