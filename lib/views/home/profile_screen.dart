import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
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
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(
                      0xFF1ED760,
                    ).withValues(alpha: 0.18),
                    child: Text(
                      auth.displayName.isEmpty
                          ? 'G'
                          : auth.displayName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.66),
                    ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
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
          Text(description),
        ],
      ),
    );
  }
}
