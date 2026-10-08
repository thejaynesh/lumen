import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/portfolio_service.dart';

const adminEmail = 'thejaynesh@gmail.com';
bool isAuthorizedAdmin({
  required String? email,
  required bool emailVerified,
  Map<String, dynamic>? claims,
}) => claims?['admin'] == true || (email == adminEmail && emailVerified);

class AuthProvider extends ChangeNotifier {
  final PortfolioService _service;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  bool _isInitialized = false;
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _disposed = false;
  int _revision = 0;
  String? _error;

  AuthProvider(this._service) {
    _subscription = _service.authStateChanges.listen(
      (user) => unawaited(_applyUser(user)),
      onError: (Object error) {
        _revision++;
        _user = null;
        _isAdmin = false;
        _isInitialized = true;
        _error = 'Your session could not be restored. Please sign in again.';
        _notify();
      },
    );
  }
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _isInitialized && _isAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> _applyUser(User? user) async {
    final revision = ++_revision;
    final refreshingAdmin =
        user != null && _user?.uid == user.uid && _isInitialized && _isAdmin;
    _user = user;
    if (!refreshingAdmin) {
      _isAdmin = false;
      _isInitialized = false;
      _notify();
    }
    var authorized = false;
    try {
      if (user != null) {
        final token = await user.getIdTokenResult();
        authorized = isAuthorizedAdmin(
          email: token.claims?['email'] is String
              ? token.claims!['email'] as String
              : null,
          emailVerified: token.claims?['email_verified'] == true,
          claims: token.claims,
        );
      }
      if (_disposed || revision != _revision) return authorized;
      _isAdmin = authorized;
      _error = user != null && !authorized
          ? 'This account is not authorized to manage the portfolio.'
          : null;
    } catch (_) {
      if (_disposed || revision != _revision) return false;
      _isAdmin = false;
      _error = 'We could not verify your access. Please sign in again.';
    }
    if (!_disposed && revision == _revision) {
      _isInitialized = true;
      _notify();
    }
    return authorized;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      final credential = await _service.signIn(email.trim(), password);
      return await _applyUser(credential.user);
    } on FirebaseAuthException catch (e) {
      _error = switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Check your connection and try again.',
        _ => 'Unable to sign in. Check your email and password.',
      };
      return false;
    } catch (_) {
      _error = 'Unable to sign in. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    await _applyUser(null);
  }

  void clearError() {
    _error = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
