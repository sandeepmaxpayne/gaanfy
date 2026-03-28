import 'package:flutter/material.dart';

import '../core/enums/playback_source.dart';
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
            color: const Color(0xFF171A20),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        song.isOffline
                            ? const Color(0xFF3BC8FF)
                            : const Color(0xFF1ED760),
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
                                  ? const [Color(0xFF245D9B), Color(0xFF2DC7FF)]
                                  : const [
                                      Color(0xFF0F7A35),
                                      Color(0xFF1ED760),
                                    ],
                            ),
                          ),
                          child: Icon(
                            song.isOffline
                                ? Icons.offline_bolt_rounded
                                : Icons.graphic_eq_rounded,
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
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
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
                            size: 34,
                            color: song.isOffline
                                ? const Color(0xFF3BC8FF)
                                : const Color(0xFF1ED760),
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
