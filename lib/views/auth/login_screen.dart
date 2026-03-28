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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final auth = context.read<AuthViewModel>();
    await auth.sendLoginLink(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final palette = AppTheme.paletteOf(context);

        if (auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/home');
            }
          });
        }

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
                      'Enter your email and we will send a passwordless sign-in link, following the Firebase email-link flow.',
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
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: auth.isBusy ? null : _sendLink,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: palette.primaryDeep,
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: Text(
                        auth.isBusy
                            ? 'Sending link...'
                            : 'Email me a sign-in link',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Open the email on this same device to complete sign-in automatically.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
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
                      onTap: () async {
                        final success = await auth.signInWithGoogle();
                        if (success && context.mounted) {
                          context.go('/home');
                        }
                      },
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
                      onTap: () async {
                        final success = await auth.signInWithApple();
                        if (success && context.mounted) {
                          context.go('/home');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: auth.isBusy
                          ? null
                          : () async {
                              await auth.continueAsGuest();
                              if (context.mounted) {
                                context.go('/home');
                              }
                            },
                      child: const Text('Continue in demo mode'),
                    ),
                    if (auth.infoMessage != null) ...[
                      const SizedBox(height: 10),
                      _NoticeCard(
                        message: auth.infoMessage!,
                        color: palette.secondary,
                      ),
                    ],
                    if (auth.error != null) ...[
                      const SizedBox(height: 10),
                      _NoticeCard(
                        message: auth.error!,
                        color: palette.accentSoft,
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

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}
