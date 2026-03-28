import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/offline_music_view_model.dart';
import '../../widgets/song_tile.dart';

class OfflineLibraryScreen extends StatelessWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineMusicViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: [
              Text(
                'Offline Library',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan music stored on your device and keep separate offline checkpoints that resume independently from streaming.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3BC8FF).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.offline_bolt_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vm.songs.length} tracks found',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.playback.currentSong == null
                                ? 'Nothing resumed yet'
                                : 'Resume ${vm.playback.currentSong!.title}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.64),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: vm.refresh,
                      icon: const Icon(Icons.sync_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 34),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!vm.hasPermission)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Storage/audio permission is needed to read offline songs from your device.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else if (vm.songs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No offline songs found yet. Add MP3 files to the device and refresh.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else
                ...vm.songs.map(
                  (song) => SongTile(
                    song: song,
                    onTap: () async {
                      await vm.playSong(song);
                      if (context.mounted) {
                        context.push('/offline-player');
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
