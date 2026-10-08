import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/providers/auth_provider.dart';
import 'package:lumen/services/portfolio_service.dart';

class _Token extends Fake implements IdTokenResult {
  @override
  final Map<String, dynamic> claims;
  _Token(this.claims);
}

class _User extends Fake implements User {
  @override
  final String uid;
  final Future<IdTokenResult> token;
  _User(this.token, {this.uid = 'owner'});
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) => token;
}

class _Service extends PortfolioService {
  final controller = StreamController<User?>.broadcast(sync: true);
  @override
  Stream<User?> get authStateChanges => controller.stream;
  @override
  Future<void> signOut() async => controller.add(null);
}

void main() {
  late _Service service;
  late AuthProvider provider;
  setUp(() {
    service = _Service();
    provider = AuthProvider(service);
  });
  tearDown(() async {
    provider.dispose();
    await service.controller.close();
  });

  test(
    'restoration waits for token claims before granting admin access',
    () async {
      final token = Completer<IdTokenResult>();
      service.controller.add(_User(token.future));
      expect(provider.isInitialized, isFalse);
      expect(provider.isAdmin, isFalse);
      token.complete(_Token({'email': adminEmail, 'email_verified': true}));
      await Future<void>.delayed(Duration.zero);
      expect(provider.isInitialized, isTrue);
      expect(provider.isAdmin, isTrue);
    },
  );

  test('late successful token cannot restore access after sign-out', () async {
    final token = Completer<IdTokenResult>();
    service.controller.add(_User(token.future));
    await provider.signOut();
    token.complete(_Token({'admin': true}));
    await Future<void>.delayed(Duration.zero);
    expect(provider.isLoggedIn, isFalse);
    expect(provider.isInitialized, isTrue);
    expect(provider.isAdmin, isFalse);
  });

  test(
    'token refresh preserves admin state until new claims revoke access',
    () async {
      service.controller.add(_User(Future.value(_Token({'admin': true}))));
      await Future<void>.delayed(Duration.zero);
      final refreshed = Completer<IdTokenResult>();
      service.controller.add(_User(refreshed.future));
      expect(provider.isInitialized, isTrue);
      expect(provider.isAdmin, isTrue);
      refreshed.complete(_Token({'admin': false}));
      await Future<void>.delayed(Duration.zero);
      expect(provider.isInitialized, isTrue);
      expect(provider.isAdmin, isFalse);
    },
  );

  test('token failure never leaves the route waiting indefinitely', () async {
    service.controller.add(
      _User(Future<IdTokenResult>.error(StateError('Offline'))),
    );
    await Future<void>.delayed(Duration.zero);
    expect(provider.isInitialized, isTrue);
    expect(provider.isAdmin, isFalse);
    expect(provider.error, contains('verify your access'));
    service.controller.add(null);
    expect(provider.error, isNull);
  });

  test('switching accounts clears prior authorization immediately', () async {
    service.controller.add(_User(Future.value(_Token({'admin': true}))));
    await Future<void>.delayed(Duration.zero);
    final other = Completer<IdTokenResult>();
    service.controller.add(_User(other.future, uid: 'different-account'));
    expect(provider.isAdmin, isFalse);
    expect(provider.isInitialized, isFalse);
    other.complete(_Token({}));
    await Future<void>.delayed(Duration.zero);
    expect(provider.isAdmin, isFalse);
    expect(provider.isInitialized, isTrue);
  });

  test('disposing unsubscribes and ignores pending token completion', () async {
    final token = Completer<IdTokenResult>();
    final localService = _Service();
    final localProvider = AuthProvider(localService);
    var notifications = 0;
    localProvider.addListener(() => notifications++);
    localService.controller.add(_User(token.future));
    localProvider.dispose();
    final before = notifications;
    expect(localService.controller.hasListener, isFalse);
    token.complete(_Token({'admin': true}));
    await Future<void>.delayed(Duration.zero);
    expect(notifications, before);
    await localService.controller.close();
  });
}
