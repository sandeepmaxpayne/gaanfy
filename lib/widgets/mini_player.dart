import 'package:flutter/material.dart';

import '../core/enums/playback_source.dart';
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
        if (song == null) {
          return const SizedBox.shrink();
        }

        final progress = playback.duration.inMilliseconds == 0
            ? 0.0
            : playback.position.inMilliseconds /
                  playback.duration.inMilliseconds;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: palette.secondary.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primaryDeep.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: palette.secondary.withValues(
                        alpha: 0.08,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        song.isOffline ? palette.secondary : palette.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: song.isOffline
                                  ? [palette.primary, palette.secondary]
                                  : [palette.accent, palette.accentSoft],
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${song.artist} • ${playback.source.label}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: palette.textMuted),
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
                            size: 34,
                            color: song.isOffline
                                ? palette.secondary
                                : palette.accent,
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
