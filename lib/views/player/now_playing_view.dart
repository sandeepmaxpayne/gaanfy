import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../../core/enums/playback_source.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../services/playback_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/song_experience_panel.dart';

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
        final isDesktop = AppLayout.isDesktop(context);
        final isApple = AppLayout.isApple(context);
        final heroAccent = Theme.of(context).brightness == Brightness.light
            ? palette.primary
            : accentColor;

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: AppBackground(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : 20,
              vertical: isApple ? 10 : 0,
            ),
            child: song == null
                ? Center(
                    child: Text(
                      'Nothing queued yet.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final useTwoColumns = constraints.maxWidth >= 980;

                      final hero = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isApple) ...[
                            Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                margin: const EdgeInsets.only(top: 6, bottom: 16),
                                decoration: BoxDecoration(
                                  color: palette.textMuted.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 20),
                          SongExperiencePanel(
                            song: song,
                            accentColor: accentColor,
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
                          if (song.sourceLabel != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _MetaChip(
                                  label: song.sourceLabel!,
                                  accentColor: heroAccent,
                                ),
                                if (song.backupStreamUrls.isNotEmpty)
                                  _MetaChip(
                                    label:
                                        '${song.backupStreamUrls.length} backup links',
                                    accentColor: palette.secondary,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      );

                      final controls = Column(
                        children: [
                          _PlayerCard(
                            child: Column(
                              children: [
                                ProgressBar(
                                  progress: playback.position,
                                  buffered: playback.position,
                                  total: playback.duration,
                                  baseBarColor: palette.secondary.withValues(
                                    alpha: 0.12,
                                  ),
                                  progressBarColor: heroAccent,
                                  thumbColor: heroAccent,
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
                          _PlayerCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton.filledTonal(
                                  onPressed: playback.toggleShuffle,
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    color: playback.shuffleEnabled
                                        ? heroAccent
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
                                    backgroundColor: heroAccent,
                                    foregroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: EdgeInsets.all(
                                      isApple ? 26 : 24,
                                    ),
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
                                IconButton.filledTonal(
                                  onPressed: null,
                                  icon: const Icon(Icons.open_in_new_rounded),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _PlayerCard(
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
                                ...playback.queue.asMap().entries.take(4).map(
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
                        ],
                      );

                      if (useTwoColumns) {
                        return SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: hero),
                              const SizedBox(width: 24),
                              Expanded(flex: 4, child: controls),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hero,
                            const SizedBox(height: 22),
                            controls,
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AppLayout.isApple(context);

    return Container(
      padding: EdgeInsets.all(isApple ? 20 : 18),
      decoration: BoxDecoration(
        color: palette.surface.withValues(
          alpha: isDark ? (isApple ? 0.9 : 0.94) : (isApple ? 0.82 : 0.9),
        ),
        borderRadius: BorderRadius.circular(isApple ? 30 : 26),
        border: Border.all(
          color: palette.glow.withValues(alpha: isDark ? 0.08 : 0.44),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
            blurRadius: isDark ? 26 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
