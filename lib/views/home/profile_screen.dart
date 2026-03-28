import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/theme_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ThemeViewModel>(
      builder: (context, auth, themeVm, _) {
        final palette = AppTheme.paletteOf(context);

        return ListView(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    palette.surface,
                    palette.primaryDeep.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: palette.accent.withValues(alpha: 0.2),
                    child: Text(
                      auth.displayName.isEmpty
                          ? 'G'
                          : auth.displayName.characters.first.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: palette.glow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    auth.user?.email ?? 'Demo mode enabled',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.accent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      themeVm.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: palette.primaryDeep,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dark mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Forest-night styling inspired by Color Hunt green palettes and your reference screen.',
                          style: TextStyle(color: palette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: themeVm.isDarkMode,
                    onChanged: themeVm.setDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Firebase status',
              description: auth.isFirebaseReady
                  ? 'Connected. Email auth and Firestore profile sync are available.'
                  : 'Firebase native files are still missing. Add google-services.json and GoogleService-Info.plist to enable real auth.',
            ),
            const SizedBox(height: 14),
            const _InfoCard(
              title: 'Scale path',
              description:
                  'If Gaanfy grows past 50 million users, move profile and session metadata into a dedicated NoSQL layer such as Cassandra while Firebase Auth stays the identity provider.',
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: Text(auth.isGuestMode ? 'Exit demo mode' : 'Sign out'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: palette.textMuted)),
        ],
      ),
    );
  }
}
