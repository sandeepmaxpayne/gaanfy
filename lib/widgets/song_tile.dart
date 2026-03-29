import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
  });

  final Song song;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: isDark ? 0.88 : 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.glow.withValues(alpha: isDark ? 0.08 : 0.44),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: isDark ? 22 : 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: song.artworkUrl != null
              ? Image.network(
                  song.artworkUrl!,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _FallbackArtwork(song: song),
                )
              : _FallbackArtwork(song: song),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          song.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: palette.textMuted),
        ),
        trailing:
            trailing ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  song.isOffline
                      ? Icons.folder_rounded
                      : Icons.play_circle_fill_rounded,
                  color: song.isOffline
                      ? palette.secondary
                      : (isDark ? palette.accent : palette.primary),
                ),
                if (!song.isOffline && song.sourceLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      song.sourceLabel!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: song.isOffline
              ? [palette.primary, palette.secondary]
              : [palette.accent, palette.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        song.isOffline
            ? Icons.music_note_rounded
            : Icons.wifi_tethering_rounded,
        color: palette.primaryDeep,
      ),
    );
  }
}
