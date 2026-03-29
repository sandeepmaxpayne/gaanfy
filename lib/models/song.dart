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
    this.sourceLabel,
    this.backupStreamUrls = const [],
    this.releaseDate,
    this.externalUrl,
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
  final String? sourceLabel;
  final List<String> backupStreamUrls;
  final String? releaseDate;
  final String? externalUrl;

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
      'sourceLabel': sourceLabel,
      'backupStreamUrls': backupStreamUrls,
      'releaseDate': releaseDate,
      'externalUrl': externalUrl,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    final backupUrls = map['backupStreamUrls'];
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
      sourceLabel: map['sourceLabel'] as String?,
      backupStreamUrls: backupUrls is List
          ? backupUrls.whereType<String>().toList()
          : const [],
      releaseDate: map['releaseDate'] as String?,
      externalUrl: map['externalUrl'] as String?,
    );
  }
}
