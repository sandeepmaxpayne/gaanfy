import 'package:flutter/material.dart';

import '../core/enums/playback_source.dart';
import '../core/theme/app_layout.dart';
import '../core/theme/app_theme.dart';
import '../services/playback_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.playback, required this.onTap});

  final PlaybackService playback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final song = playback.currentSong;
        final palette = AppTheme.paletteOf(context);
        final isApple = AppLayout.isApple(context);
        final isWide = AppLayout.isTablet(context);
        if (song == null) {
          return const SizedBox.shrink();
        }

        final progress = playback.duration.inMilliseconds == 0
            ? 0.0
            : playback.position.inMilliseconds /
                playback.duration.inMilliseconds;

        return Container(
          margin: EdgeInsets.fromLTRB(isWide ? 0 : 16, 0, isWide ? 0 : 16, 12),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: isApple ? 0.42 : 0.36),
            borderRadius: BorderRadius.circular(isApple ? 28 : 22),
            border: Border.all(
              color: palette.glow.withValues(alpha: 0.44),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(isApple ? 28 : 22),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(isApple ? 18 : 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: palette.secondary.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        song.isOffline ? palette.secondary : palette.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: song.isOffline
                                  ? [palette.primary, palette.secondary]
                                  : [palette.accent, palette.primary],
                            ),
                          ),
                          child: Icon(
                            song.isOffline
                                ? Icons.offline_bolt_rounded
                                : Icons.graphic_eq_rounded,
                            color: palette.primaryDeep,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${song.artist} - ${playback.source.label}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: palette.textMuted),
                              ),
                              if (song.sourceLabel != null &&
                                  playback.source == PlaybackSource.online)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Primary source: ${song.sourceLabel}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: palette.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: playback.togglePlayPause,
                          icon: Icon(
                            playback.isPlaying
                                ? Icons.pause_circle_rounded
                                : Icons.play_circle_rounded,
                            size: isApple ? 36 : 34,
                            color: song.isOffline
                                ? palette.secondary
                                : palette.primary,
                          ),
                        ),
                      ],
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
