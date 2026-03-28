class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.streamUrl,
    required this.isOffline,
    this.artworkUrl,
    this.filePath,
    this.durationMs,
    this.genre,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String streamUrl;
  final String? artworkUrl;
  final String? filePath;
  final int? durationMs;
  final bool isOffline;
  final String? genre;

  Duration get duration =>
      Duration(milliseconds: durationMs == null ? 0 : durationMs!);

  String get subtitle {
    if (album.isEmpty) {
      return artist;
    }
    return '$artist • $album';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'streamUrl': streamUrl,
      'artworkUrl': artworkUrl,
      'filePath': filePath,
      'durationMs': durationMs,
      'isOffline': isOffline,
      'genre': genre,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Unknown Track',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? '',
      streamUrl: map['streamUrl'] as String? ?? '',
      artworkUrl: map['artworkUrl'] as String?,
      filePath: map['filePath'] as String?,
      durationMs: map['durationMs'] as int?,
      isOffline: map['isOffline'] as bool? ?? false,
      genre: map['genre'] as String?,
    );
  }
}
