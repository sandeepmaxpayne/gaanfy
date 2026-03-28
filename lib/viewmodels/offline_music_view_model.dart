import 'package:flutter/foundation.dart';

import '../core/enums/playback_source.dart';
import '../models/song.dart';
import '../services/local_database_service.dart';
import '../services/offline_music_service.dart';
import '../services/playback_service.dart';

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
  bool _isLoading = false;
  bool _hasPermission = true;

  List<Song> get songs => _songs;
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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    final index = _songs.indexWhere((item) => item.id == song.id);
    if (index < 0) {
      return;
    }
    await playback.playSongs(_songs, startIndex: index);
  }

  @override
  void dispose() {
    playback.removeListener(notifyListeners);
    playback.dispose();
    super.dispose();
  }
}
