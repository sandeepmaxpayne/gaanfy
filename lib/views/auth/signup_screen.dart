import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/app_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final auth = context.read<AuthViewModel>();
    await auth.sendSignupLink(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your sound ID',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We will email a secure sign-up link. No password needed.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: palette.textMuted),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Full name'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
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
                            : 'Create account with email link',
                      ),
                    ),
                    if (auth.infoMessage != null) ...[
                      const SizedBox(height: 14),
                      _NoticeCard(
                        message: auth.infoMessage!,
                        color: palette.secondary,
                      ),
                    ],
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      _NoticeCard(
                        message: auth.error!,
                        color: palette.accentSoft,
                      ),
                    ],
                    const SizedBox(height: 36),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Already have an account? Log in'),
                      ),
                    ),
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
