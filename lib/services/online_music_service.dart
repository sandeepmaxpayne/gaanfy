import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/music_section.dart';
import '../models/song.dart';

class OnlineMusicService {
  static const _baseHost = 'itunes.apple.com';

  Future<List<MusicSection>> fetchDiscoverSections() async {
    final sections = await Future.wait([
      _section('Trending Now', 'Global chart samplers', 'top hits 2026'),
      _section(
        'Bollywood Glow',
        'Easy entry for Indian listeners',
        'bollywood romantic',
      ),
      _section('Late Night Lofi', 'Headphones-on mood', 'lofi chill beats'),
    ]);
    return sections;
  }

  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }
    return _search(query, limit: 20);
  }

  Future<MusicSection> _section(
    String title,
    String caption,
    String query,
  ) async {
    final songs = await _search(query, limit: 12);
    return MusicSection(title: title, caption: caption, songs: songs);
  }

  Future<List<Song>> _search(String query, {required int limit}) async {
    final uri = Uri.https(_baseHost, '/search', {
      'term': query,
      'entity': 'song',
      'limit': '$limit',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return const [];
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['results'] as List<dynamic>? ?? const [];

    return items
        .where((item) => (item as Map<String, dynamic>)['previewUrl'] != null)
        .map((item) {
          final map = item as Map<String, dynamic>;
          final artwork = map['artworkUrl100'] as String?;
          return Song(
            id: (map['trackId'] ?? map['collectionId']).toString(),
            title: map['trackName'] as String? ?? 'Unknown Track',
            artist: map['artistName'] as String? ?? 'Unknown Artist',
            album: map['collectionName'] as String? ?? '',
            streamUrl: map['previewUrl'] as String? ?? '',
            artworkUrl: artwork?.replaceAll('100x100bb', '600x600bb'),
            filePath: null,
            durationMs: map['trackTimeMillis'] as int?,
            isOffline: false,
            genre: map['primaryGenreName'] as String?,
          );
        })
        .toList();
  }
}
