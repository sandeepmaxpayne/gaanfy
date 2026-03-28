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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
          Icon(
            song.isOffline
                ? Icons.folder_rounded
                : Icons.play_circle_fill_rounded,
            color: song.isOffline ? palette.secondary : palette.accent,
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
              : [palette.accent, palette.accentSoft],
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
