import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../core/enums/playback_source.dart';
import '../models/playback_checkpoint.dart';
import '../models/song.dart';
import 'local_database_service.dart';

class PlaybackService extends ChangeNotifier {
  PlaybackService({
    required PlaybackSource source,
    required LocalDatabaseService databaseService,
  }) : _source = source,
       _databaseService = databaseService,
       _player = AudioPlayer();

  final PlaybackSource _source;
  final LocalDatabaseService _databaseService;
  final AudioPlayer _player;

  final List<Song> _queue = [];
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  int _lastPersistedSecond = -1;

  List<Song> get queue => List.unmodifiable(_queue);
  PlaybackSource get source => _source;
  Song? get currentSong {
    if (_queue.isEmpty) {
      return null;
    }
    final index = _player.currentIndex ?? 0;
    if (index < 0 || index >= _queue.length) {
      return _queue.first;
    }
    return _queue[index];
  }

  int get currentIndex => _player.currentIndex ?? 0;
  bool get isPlaying => _player.playing;
  bool get hasQueue => _queue.isNotEmpty;
  bool get hasNext => currentIndex < _queue.length - 1;
  bool get hasPrevious => currentIndex > 0;
  bool get shuffleEnabled => _player.shuffleModeEnabled;
  Duration get position => _player.position;
  Duration get duration =>
      _player.duration ?? currentSong?.duration ?? Duration.zero;

  Future<void> initialize() async {
    _positionSubscription ??= _player.positionStream.listen((position) {
      final currentSecond = position.inSeconds;
      if (currentSecond % 5 == 0 && currentSecond != _lastPersistedSecond) {
        _lastPersistedSecond = currentSecond;
        unawaited(_persistCheckpoint());
      }
      notifyListeners();
    });

    _indexSubscription ??= _player.currentIndexStream.listen((_) {
      unawaited(_persistCheckpoint());
      notifyListeners();
    });

    _stateSubscription ??= _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && hasNext) {
        unawaited(playNext());
      }
      unawaited(_persistCheckpoint());
      notifyListeners();
    });

    await _restoreCheckpoint();
  }

  Future<void> playSongs(
    List<Song> songs, {
    int startIndex = 0,
    bool autoPlay = true,
  }) async {
    _queue
      ..clear()
      ..addAll(songs);

    await _player.setAudioSources(
      songs.map(_toAudioSource).toList(),
      initialIndex: startIndex,
      initialPosition: Duration.zero,
    );

    if (autoPlay) {
      await _player.play();
    }
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (!hasQueue) {
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> playNext() async {
    if (!hasNext) {
      return;
    }
    await _player.seekToNext();
    await _player.play();
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) {
      return;
    }
    await _player.seekToPrevious();
    await _player.play();
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> seek(Duration nextPosition) async {
    await _player.seek(nextPosition);
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    final nextState = !_player.shuffleModeEnabled;
    if (nextState) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(nextState);
    await _persistCheckpoint();
    notifyListeners();
  }

  Future<void> _restoreCheckpoint() async {
    final checkpoint = await _databaseService.loadCheckpoint(
      _source.storageKey,
    );
    if (checkpoint == null) {
      return;
    }

    final decoded = jsonDecode(checkpoint.queueJson) as List<dynamic>;
    final restoredQueue = decoded
        .map((item) => Song.fromMap(item as Map<String, dynamic>))
        .where((song) => song.streamUrl.isNotEmpty)
        .toList();

    if (restoredQueue.isEmpty) {
      return;
    }

    _queue
      ..clear()
      ..addAll(restoredQueue);

    await _player.setAudioSources(
      restoredQueue.map(_toAudioSource).toList(),
      initialIndex: checkpoint.currentIndex.clamp(0, restoredQueue.length - 1),
      initialPosition: Duration(milliseconds: checkpoint.positionMs),
    );

    if (checkpoint.isShuffle) {
      await _player.shuffle();
      await _player.setShuffleModeEnabled(true);
    }
    notifyListeners();
  }

  Future<void> _persistCheckpoint() async {
    if (_queue.isEmpty) {
      return;
    }

    await _databaseService.saveCheckpoint(
      PlaybackCheckpoint(
        type: _source.storageKey,
        queueJson: jsonEncode(_queue.map((song) => song.toMap()).toList()),
        currentIndex: _player.currentIndex ?? 0,
        positionMs: _player.position.inMilliseconds,
        isShuffle: _player.shuffleModeEnabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  AudioSource _toAudioSource(Song song) {
    if (song.isOffline && song.filePath != null) {
      return AudioSource.file(song.filePath!, tag: song);
    }
    return AudioSource.uri(Uri.parse(song.streamUrl), tag: song);
  }

  @override
  void dispose() {
    unawaited(_persistCheckpoint());
    _positionSubscription?.cancel();
    _indexSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
