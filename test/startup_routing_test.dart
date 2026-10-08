import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen/config/app_environment.dart';
import 'package:lumen/main.dart';

void main() {
  for (final initialLocation in ['/login', '/?job=research-role']) {
    testWidgets('delayed startup preserves $initialLocation', (tester) async {
      final harness = _StartupHarness(tester, initialLocation);
      final initialization = Completer<AppEnvironment>();

      await tester.pumpWidget(
        AppBootstrap(
          initialize: () => initialization.future,
          appBuilder: harness.buildApp,
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Navigator), findsNothing);
      expect(harness.navigationCalls, isEmpty);
      expect(harness.router, isNull);

      initialization.complete(AppEnvironment.fromValues());
      await tester.pumpAndSettle();

      expect(
        harness.router!.routeInformationProvider.value.uri.toString(),
        initialLocation,
      );
      expect(find.text('Location: $initialLocation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('startup failure and retry preserve the tailored link', (
    tester,
  ) async {
    const initialLocation = '/?job=research-role';
    final harness = _StartupHarness(tester, initialLocation);
    final firstAttempt = Completer<AppEnvironment>();
    final retryAttempt = Completer<AppEnvironment>();
    var attempts = 0;

    await tester.pumpWidget(
      AppBootstrap(
        initialize: () =>
            ++attempts == 1 ? firstAttempt.future : retryAttempt.future,
        appBuilder: harness.buildApp,
      ),
    );
    firstAttempt.completeError(StateError('Initialization failed'));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(Navigator), findsNothing);
    expect(harness.navigationCalls, isEmpty);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(attempts, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Navigator), findsNothing);
    expect(harness.navigationCalls, isEmpty);

    retryAttempt.complete(AppEnvironment.fromValues());
    await tester.pumpAndSettle();

    expect(
      harness.router!.routeInformationProvider.value.uri.toString(),
      initialLocation,
    );
    expect(find.text('Location: $initialLocation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _StartupHarness {
  _StartupHarness(WidgetTester tester, String initialLocation) {
    tester.platformDispatcher.defaultRouteNameTestValue = initialLocation;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.navigation, (call) async {
      navigationCalls.add(call);
      return null;
    });
    addTearDown(() {
      tester.platformDispatcher.clearDefaultRouteNameTestValue();
      messenger.setMockMethodCallHandler(SystemChannels.navigation, null);
      router?.dispose();
    });
  }

  final navigationCalls = <MethodCall>[];
  GoRouter? router;

  Widget buildApp(AppEnvironment environment) {
    // Construct routing only after startup, as LumenApp does in production.
    router ??= GoRouter(
      routes: [
        for (final path in ['/', '/login'])
          GoRoute(
            path: path,
            builder: (context, state) =>
                Scaffold(body: Text('Location: ${state.uri}')),
          ),
      ],
    );
    return MaterialApp.router(routerConfig: router!);
  }
}
