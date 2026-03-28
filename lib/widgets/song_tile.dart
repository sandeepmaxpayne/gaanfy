import 'package:flutter/material.dart';

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
      ),
      trailing:
          trailing ??
          Icon(
            song.isOffline
                ? Icons.folder_rounded
                : Icons.play_circle_fill_rounded,
            color: song.isOffline
                ? const Color(0xFF3BC8FF)
                : const Color(0xFF1ED760),
          ),
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: song.isOffline
              ? const [Color(0xFF245D9B), Color(0xFF2DC7FF)]
              : const [Color(0xFF0F7A35), Color(0xFF1ED760)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        song.isOffline
            ? Icons.music_note_rounded
            : Icons.wifi_tethering_rounded,
        color: Colors.white,
      ),
    );
  }
}
