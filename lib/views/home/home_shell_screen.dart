import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/playback_source.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../models/song.dart';
import '../../services/playback_service.dart';
import '../../viewmodels/offline_music_view_model.dart';
import '../../viewmodels/online_music_view_model.dart';
import '../../widgets/app_background.dart';
import '../../widgets/mini_player.dart';
import 'discover_screen.dart';
import 'offline_library_screen.dart';
import 'profile_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  static const _tabStorageKey = 'home_tab_index';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _restoreTab();
  }

  Future<void> _restoreTab() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_tabStorageKey) ?? 0;
    if (mounted) {
      setState(() => _selectedIndex = savedIndex);
    }
  }

  Future<void> _selectTab(int index) async {
    setState(() => _selectedIndex = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tabStorageKey, index);
  }

  PlaybackService? _activePlayback({
    required OnlineMusicViewModel online,
    required OfflineMusicViewModel offline,
  }) {
    if (_selectedIndex == 1 && offline.playback.hasQueue) {
      return offline.playback;
    }
    if (_selectedIndex == 0 && online.playback.hasQueue) {
      return online.playback;
    }
    if (online.playback.hasQueue) {
      return online.playback;
    }
    if (offline.playback.hasQueue) {
      return offline.playback;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<OnlineMusicViewModel>();
    final offline = context.watch<OfflineMusicViewModel>();
    final playback = _activePlayback(online: online, offline: offline);
    final isDesktop = AppLayout.isDesktop(context);
    final isApple = AppLayout.isApple(context);

    final pages = const [
      DiscoverScreen(),
      OfflineLibraryScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 22 : 18,
          vertical: isApple ? 10 : 0,
        ),
        child: isDesktop
            ? _DesktopShell(
                selectedIndex: _selectedIndex,
                onSelect: _selectTab,
                pages: pages,
                playback: playback,
              )
            : Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: pages,
                    ),
                  ),
                  if (playback != null)
                    MiniPlayer(
                      playback: playback,
                      onTap: () => context.push(
                        playback.source == PlaybackSource.online
                            ? '/online-player'
                            : '/offline-player',
                      ),
                    ),
                  NavigationBar(
                    height: isApple ? 74 : null,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectTab,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: 'Discover',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.folder_outlined),
                        selectedIcon: Icon(Icons.folder_rounded),
                        label: 'Offline',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.selectedIndex,
    required this.onSelect,
    required this.pages,
    required this.playback,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<Widget> pages;
  final PlaybackService? playback;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Row(
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: palette.glow.withValues(alpha: 0.44)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gaanfy',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: palette.glow,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Designed for a bright glassmorphism library with a docked player and floating controls.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: NavigationRail(
                  extended: true,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelect,
                  useIndicator: true,
                  minExtendedWidth: 214,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded),
                      label: Text('Discover'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder_rounded),
                      label: Text('Offline'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
              ),
              _DesktopMoodCard(playback: playback),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: palette.glow.withValues(alpha: 0.44)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: IndexedStack(index: selectedIndex, children: pages),
            ),
          ),
        ),
        if (playback != null) ...[
          const SizedBox(width: 18),
          SizedBox(
            width: 328,
            child: Column(
              children: [
                _DesktopNowPlayingCard(playback: playback!),
                const SizedBox(height: 12),
                MiniPlayer(
                  playback: playback!,
                  onTap: () => context.push(
                    playback!.source == PlaybackSource.online
                        ? '/online-player'
                        : '/offline-player',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DesktopMoodCard extends StatelessWidget {
  const _DesktopMoodCard({required this.playback});

  final PlaybackService? playback;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final song = playback?.currentSong;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.accent.withValues(alpha: 0.86),
            palette.primary.withValues(alpha: 0.86),
            palette.accentSoft.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spotlight',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.primaryDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song?.title ?? 'Wide-screen listening room',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: palette.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            song == null
                ? 'Browse with layered playlist surfaces while the player stays docked and visible.'
                : 'Current focus: ${song.artist}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.primaryDeep.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNowPlayingCard extends StatelessWidget {
  const _DesktopNowPlayingCard({required this.playback});

  final PlaybackService playback;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final song = playback.currentSong;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: palette.glow.withValues(alpha: 0.44)),
      ),
      child: song == null
          ? Text(
              'Start a song to pin playback controls here.',
              style: TextStyle(color: palette.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now playing',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: song.artworkUrl == null
                        ? _DesktopArtFallback(song: song)
                        : Image.network(
                            song.artworkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _DesktopArtFallback(song: song),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textMuted),
                ),
                if (song.sourceLabel != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Source: ${song.sourceLabel}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _DesktopArtFallback extends StatelessWidget {
  const _DesktopArtFallback({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: song.isOffline
              ? [palette.primary, palette.secondary]
              : [palette.accent, palette.accentSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        song.isOffline ? Icons.offline_bolt_rounded : Icons.music_note_rounded,
        color: palette.primaryDeep,
        size: 54,
      ),
    );
  }
}
