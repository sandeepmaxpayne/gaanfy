import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/music_section.dart';
import '../../models/song.dart';
import '../../viewmodels/online_music_view_model.dart';
import '../../widgets/song_tile.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineMusicViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          onRefresh: vm.loadDiscover,
          child: ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: [
              Text(
                'Discover',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Free streaming demo from public song previews, plus checkpointed resume when you come back.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
              const SizedBox(height: 18),
              _BlendCard(currentSong: vm.playback.currentSong),
              const SizedBox(height: 18),
              TextField(
                onChanged: vm.search,
                decoration: const InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 18),
              if (vm.isLoading && vm.sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.query.isNotEmpty)
                _SearchResults(results: vm.searchResults)
              else
                ...vm.sections.map(
                  (section) => _SectionBlock(section: section),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BlendCard extends StatelessWidget {
  const _BlendCard({required this.currentSong});

  final Song? currentSong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1ED760), Color(0xFF0B5323), Color(0xFF07140C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Unique Mode',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mood blend',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentSong == null
                ? 'Jump into curated online previews and keep your exact position saved in SQLite.'
                : 'Resume your last stream from ${currentSong!.title} instantly.',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results});

  final List<Song> results;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnlineMusicViewModel>();
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No results yet. Try a different song or artist.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search results',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...results.map(
          (song) => SongTile(
            song: song,
            onTap: () async {
              await vm.playFromSection(results, song);
              if (context.mounted) {
                context.push('/online-player');
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final MusicSection section;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnlineMusicViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            section.caption,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 226,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: section.songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final song = section.songs[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    await vm.playFromSection(section.songs, song);
                    if (context.mounted) {
                      context.push('/online-player');
                    }
                  },
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            song.artworkUrl ?? '',
                            width: 142,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 142,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0F7A35),
                                    Color(0xFF1ED760),
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.music_note_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          song.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.66),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.wifi_tethering_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                song.genre ?? 'Online',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
