import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../../core/enums/playback_source.dart';
import '../../core/theme/app_theme.dart';
import '../../services/playback_service.dart';
import '../../widgets/app_background.dart';

class NowPlayingView extends StatelessWidget {
  const NowPlayingView({
    super.key,
    required this.title,
    required this.playback,
    required this.accentColor,
  });

  final String title;
  final PlaybackService playback;
  final Color accentColor;

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final palette = AppTheme.paletteOf(context);
        final song = playback.currentSong;

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: AppBackground(
            child: song == null
                ? Center(
                    child: Text(
                      'Nothing queued yet.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          height: 330,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            gradient: LinearGradient(
                              colors: [
                                accentColor,
                                accentColor.withValues(alpha: 0.45),
                                palette.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.16),
                                blurRadius: 28,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: const Icon(
                                Icons.graphic_eq_rounded,
                                size: 86,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          song.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: palette.textMuted),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: palette.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            children: [
                              ProgressBar(
                                progress: playback.position,
                                buffered: playback.position,
                                total: playback.duration,
                                baseBarColor: palette.secondary.withValues(
                                  alpha: 0.12,
                                ),
                                progressBarColor: accentColor,
                                thumbColor: accentColor,
                                onSeek: playback.seek,
                                timeLabelTextStyle: TextStyle(
                                  color: palette.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_format(playback.position)),
                                  Text(_format(playback.duration)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton.filledTonal(
                              onPressed: playback.toggleShuffle,
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: playback.shuffleEnabled
                                    ? accentColor
                                    : palette.textMuted,
                              ),
                            ),
                            IconButton(
                              onPressed: playback.hasPrevious
                                  ? playback.playPrevious
                                  : null,
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 36,
                            ),
                            FilledButton(
                              onPressed: playback.togglePlayPause,
                              style: FilledButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(24),
                              ),
                              child: Icon(
                                playback.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: playback.hasNext
                                  ? playback.playNext
                                  : null,
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 36,
                            ),
                            const IconButton.filledTonal(
                              onPressed: null,
                              icon: Icon(Icons.data_object_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: palette.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Checkpoint status',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Queue position, progress and shuffle mode are stored locally in SQLite for ${playback.source.label.toLowerCase()} playback.',
                                style: TextStyle(color: palette.textMuted),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Up next',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              ...playback.queue
                                  .asMap()
                                  .entries
                                  .take(4)
                                  .map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '${entry.key == playback.currentIndex ? 'Now' : '#${entry.key + 1}'}  ${entry.value.title} - ${entry.value.artist}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
