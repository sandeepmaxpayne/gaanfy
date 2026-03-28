import 'package:flutter/foundation.dart';

import '../core/enums/playback_source.dart';
import '../models/music_section.dart';
import '../models/song.dart';
import '../services/local_database_service.dart';
import '../services/online_music_service.dart';
import '../services/playback_service.dart';

class OnlineMusicViewModel extends ChangeNotifier {
  OnlineMusicViewModel({
    required OnlineMusicService musicService,
    required LocalDatabaseService databaseService,
  }) : _musicService = musicService,
       playback = PlaybackService(
         source: PlaybackSource.online,
         databaseService: databaseService,
       ) {
    playback.addListener(notifyListeners);
  }

  final OnlineMusicService _musicService;
  final PlaybackService playback;

  List<MusicSection> _sections = const [];
  List<Song> _searchResults = const [];
  bool _isLoading = false;
  String _query = '';

  List<MusicSection> get sections => _sections;
  List<Song> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get query => _query;

  Future<void> initialize() async {
    await playback.initialize();
    await loadDiscover();
  }

  Future<void> loadDiscover() async {
    _isLoading = true;
    notifyListeners();

    _sections = await _musicService.fetchDiscoverSections();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String value) async {
    _query = value;
    if (value.trim().isEmpty) {
      _searchResults = const [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _searchResults = await _musicService.searchSongs(value);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> playFromSection(List<Song> songs, Song selectedSong) async {
    final index = songs.indexWhere((song) => song.id == selectedSong.id);
    await playback.playSongs(songs, startIndex: index < 0 ? 0 : index);
  }

  @override
  void dispose() {
    playback.removeListener(notifyListeners);
    playback.dispose();
    super.dispose();
  }
}
