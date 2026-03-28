import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song.dart';

class OfflineMusicService {
  OfflineMusicService() : _audioQuery = OnAudioQuery();

  final OnAudioQuery _audioQuery;

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }

    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<List<Song>> loadDeviceSongs() async {
    final allowed = await requestPermission();
    if (!allowed) {
      return const [];
    }

    final songs = await _audioQuery.querySongs();

    return songs
        .where((item) => item.data.isNotEmpty)
        .map(
          (item) => Song(
            id: item.id.toString(),
            title: item.title,
            artist: item.artist ?? 'Unknown Artist',
            album: item.album ?? 'Local Library',
            streamUrl: item.data,
            artworkUrl: null,
            filePath: item.data,
            durationMs: item.duration,
            isOffline: true,
            genre: 'Offline',
          ),
        )
        .toList();
  }
}
