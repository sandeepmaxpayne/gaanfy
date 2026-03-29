import 'package:flutter/foundation.dart';

import '../core/enums/playback_source.dart';
import '../models/song.dart';
import '../services/local_database_service.dart';
import '../services/offline_music_service.dart';
import '../services/playback_service.dart';

class OfflineSongGroup {
  const OfflineSongGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.songs,
    required this.isAlbumGroup,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<Song> songs;
  final bool isAlbumGroup;
}

class OfflineMusicViewModel extends ChangeNotifier {
  OfflineMusicViewModel({
    required OfflineMusicService musicService,
    required LocalDatabaseService databaseService,
  }) : _musicService = musicService,
       playback = PlaybackService(
         source: PlaybackSource.offline,
         databaseService: databaseService,
       ) {
    playback.addListener(notifyListeners);
  }

  final OfflineMusicService _musicService;
  final PlaybackService playback;

  List<Song> _songs = const [];
  List<OfflineSongGroup> _groups = const [];
  bool _isLoading = false;
  bool _hasPermission = true;

  List<Song> get songs => _songs;
  List<OfflineSongGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  Future<void> initialize() async {
    await playback.initialize();
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _hasPermission = await _musicService.requestPermission();
    _songs = _hasPermission ? await _musicService.loadDeviceSongs() : const [];
    _groups = _buildGroups(_songs);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    await playback.playSelectedSong(selectedSong: song, queueSongs: _songs);
  }

  Future<void> playGroup(OfflineSongGroup group, {Song? startWith}) async {
    if (group.songs.isEmpty) {
      return;
    }

    if (startWith != null) {
      await playback.playSelectedSong(
        selectedSong: startWith,
        queueSongs: group.songs,
      );
      return;
    }

    await playback.playSongs(group.songs);
  }

  List<OfflineSongGroup> _buildGroups(List<Song> songs) {
    final buckets = <String, List<Song>>{};

    for (final song in songs) {
      final groupKey = _groupKey(song);
      buckets.putIfAbsent(groupKey, () => <Song>[]).add(song);
    }

    final groups = buckets.entries.map((entry) {
      final groupSongs = entry.value.toList()
        ..sort((left, right) => left.title.toLowerCase().compareTo(
              right.title.toLowerCase(),
            ));

      final seed = groupSongs.first;
      final hasAlbum = _hasRealAlbum(seed.album);
      final title = hasAlbum ? seed.album : seed.artist;
      final artistCount = groupSongs.map((song) => song.artist).toSet().length;
      final subtitle = hasAlbum
          ? '${seed.artist} • ${groupSongs.length} songs'
          : artistCount > 1
              ? '$artistCount artists • ${groupSongs.length} songs'
              : '${groupSongs.length} songs';

      return OfflineSongGroup(
        id: entry.key,
        title: title,
        subtitle: subtitle,
        songs: groupSongs,
        isAlbumGroup: hasAlbum,
      );
    }).toList()
      ..sort((left, right) {
        if (left.isAlbumGroup != right.isAlbumGroup) {
          return left.isAlbumGroup ? -1 : 1;
        }
        return left.title.toLowerCase().compareTo(right.title.toLowerCase());
      });

    return groups;
  }

  String _groupKey(Song song) {
    if (_hasRealAlbum(song.album)) {
      return 'album:${_normalize(song.album)}::${_normalize(song.artist)}';
    }
    return 'artist:${_normalize(song.artist)}';
  }

  bool _hasRealAlbum(String album) {
    final normalized = album.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'local library';
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  @override
  void dispose() {
    playback.removeListener(notifyListeners);
    playback.dispose();
    super.dispose();
  }
}
