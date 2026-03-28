import 'song.dart';

class MusicSection {
  const MusicSection({
    required this.title,
    required this.caption,
    required this.songs,
  });

  final String title;
  final String caption;
  final List<Song> songs;
}
