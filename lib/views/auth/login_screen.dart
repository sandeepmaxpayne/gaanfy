import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/app_background.dart';
import '../../widgets/auth_option_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthViewModel>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final palette = AppTheme.paletteOf(context);

        return Scaffold(
          body: AppBackground(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: AnimatedLogo(size: 86, showWordmark: false),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A darker, richer listening space with forest green depth and warm amber highlights.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: palette.textMuted),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'you@example.com',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: auth.isBusy ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: palette.primaryDeep,
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: Text(auth.isBusy ? 'Signing in...' : 'Continue'),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AuthOptionButton(
                      label: 'Continue with phone number',
                      icon: Icons.phone_iphone_rounded,
                      onTap: () => auth.showUnavailableProviderMessage('Phone'),
                    ),
                    const SizedBox(height: 12),
                    AuthOptionButton(
                      label: 'Continue with Google',
                      badgeText: 'G',
                      badgeColor: const Color(0xFFFFB703),
                      onTap: () =>
                          auth.showUnavailableProviderMessage('Google'),
                    ),
                    const SizedBox(height: 12),
                    AuthOptionButton(
                      label: 'Continue with Facebook',
                      icon: Icons.facebook_rounded,
                      onTap: () =>
                          auth.showUnavailableProviderMessage('Facebook'),
                    ),
                    const SizedBox(height: 12),
                    AuthOptionButton(
                      label: 'Continue with Apple',
                      icon: Icons.apple_rounded,
                      onTap: () => auth.showUnavailableProviderMessage('Apple'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await auth.continueAsGuest();
                        if (context.mounted) {
                          context.go('/home');
                        }
                      },
                      child: const Text('Continue in demo mode'),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: palette.accent.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          auth.error!,
                          style: TextStyle(color: palette.accentSoft),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    Center(
                      child: Text(
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
