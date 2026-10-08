import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading || !_form.currentState!.validate()) return;
    final success = await auth.signIn(_email.text.trim(), _password.text);
    if (success && mounted) context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'LUMEN / STUDIO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to manage your portfolio.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 36),
                  AutofillGroup(
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _email,
                            enabled: !auth.isLoading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value?.trim() ?? '')
                                ? null
                                : 'Enter a valid email address.',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _password,
                            enabled: !auth.isLoading,
                            obscureText: _obscure,
                            enableSuggestions: false,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscure
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your password.'
                                : null,
                          ),
                          if (auth.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  auth.error!,
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: auth.isLoading || !auth.isInitialized
                                ? null
                                : _login,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: auth.isLoading || !auth.isInitialized
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        semanticsLabel: 'Signing in',
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to portfolio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
