import 'dart:async';

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
  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      _searchResults = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 280), () async {
      _isLoading = true;
      notifyListeners();

      final queryAtDispatch = _query;
      final results = await _musicService.searchSongs(value);
      if (queryAtDispatch != _query) {
        if (_query.trim().isEmpty) {
          _isLoading = false;
          notifyListeners();
        }
        return;
      }

      _searchResults = results;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> playFromSection(List<Song> songs, Song selectedSong) async {
    await playback.playSelectedSong(
      selectedSong: selectedSong,
      queueSongs: songs,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    playback.removeListener(notifyListeners);
    playback.dispose();
    super.dispose();
  }
}
