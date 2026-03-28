import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/playback_source.dart';
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

    final pages = const [
      DiscoverScreen(),
      OfflineLibraryScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: pages),
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
