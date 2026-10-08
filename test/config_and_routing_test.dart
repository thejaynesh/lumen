import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/config/app_environment.dart';
import 'package:lumen/providers/auth_provider.dart';
import 'package:lumen/router.dart';
import 'package:lumen/utils/external_links.dart';

void main() {
  test('development cannot accidentally select production', () {
    final local = AppEnvironment.fromValues();
    expect(local.usesEmulators, isTrue);
    expect(local.firebaseOptions.projectId, 'demo-lumen');
    expect(
      () => AppEnvironment.fromValues(projectId: 'lumen-f2e07'),
      throwsArgumentError,
    );
    expect(
      () => AppEnvironment.fromValues(name: 'staging'),
      throwsArgumentError,
    );
    expect(
      () => AppEnvironment.fromValues(
        name: 'staging',
        projectId: 'lumen-f2e07',
        apiKey: 'key',
        appId: 'id',
        senderId: 'sender',
        authDomain: 'domain',
      ),
      throwsArgumentError,
    );
    expect(AppEnvironment.fromValues(name: 'production').isProduction, isTrue);
  });
  test('admin requires verified owner or trusted claim', () {
    expect(isAuthorizedAdmin(email: adminEmail, emailVerified: false), isFalse);
    expect(
      isAuthorizedAdmin(email: 'other@example.com', emailVerified: true),
      isFalse,
    );
    expect(isAuthorizedAdmin(email: adminEmail, emailVerified: true), isTrue);
    expect(
      isAuthorizedAdmin(
        email: null,
        emailVerified: false,
        claims: {'admin': true},
      ),
      isTrue,
    );
    expect(
      isAuthorizedAdmin(
        email: null,
        emailVerified: false,
        claims: {'admin': 'true'},
      ),
      isFalse,
    );
  });
  test('session restoration does not redirect before auth is ready', () {
    expect(
      adminRedirect(
        initialized: false,
        loggedIn: false,
        authorized: false,
        location: '/admin',
      ),
      isNull,
    );
    expect(
      adminRedirect(
        initialized: true,
        loggedIn: false,
        authorized: false,
        location: '/admin',
      ),
      '/login',
    );
    expect(
      adminRedirect(
        initialized: true,
        loggedIn: true,
        authorized: false,
        location: '/admin',
      ),
      '/access-denied',
    );
    expect(
      adminRedirect(
        initialized: true,
        loggedIn: true,
        authorized: true,
        location: '/login',
      ),
      '/admin',
    );
    expect(
      adminRedirect(
        initialized: true,
        loggedIn: true,
        authorized: true,
        location: '/admin',
      ),
      isNull,
    );
  });
  test('both current and documented legacy share links resolve', () {
    expect(portfolioSlug(Uri.parse('/?job=one&jobId=two')), 'one');
    expect(portfolioSlug(Uri.parse('/?jobId=two')), 'two');
  });
  test(
    'external URLs normalize and reject executable or malformed schemes',
    () {
      expect(
        normalizeExternalUrl('github.com/thejaynesh'),
        'https://github.com/thejaynesh',
      );
      expect(
        normalizeExternalUrl('https://github.com/thejaynesh'),
        'https://github.com/thejaynesh',
      );
      for (final value in [
        'javascript:alert(1)',
        'data:text/html,test',
        'https://https://github.com',
        '//attacker.test',
        'https://user:pass@host.test',
        'bad url',
      ]) {
        expect(normalizeExternalUrl(value), '', reason: value);
      }
      expect(
        resolveAssetUrl('/resume.pdf', base: Uri.parse('https://example.com')),
        'https://example.com/resume.pdf',
      );
      expect(resolveAssetUrl('mailto:hello@example.com'), '');
    },
  );
}
