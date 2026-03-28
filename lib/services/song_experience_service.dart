import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';
import '../models/song_experience.dart';

class SongExperienceService {
  Future<SongExperience> fetchExperience(Song song) async {
    final results = await Future.wait<String?>([
      _fetchLyrics(song),
      _fetchVideoPreview(song),
    ]);

    return SongExperience(
      lyrics: results[0],
      videoPreviewUrl: results[1],
      visualImageUrl: song.artworkUrl,
    );
  }

  Future<String?> _fetchLyrics(Song song) async {
    final uri = Uri.parse(
      'https://api.lyrics.ovh/v1/${Uri.encodeComponent(song.artist)}/${Uri.encodeComponent(song.title)}',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final lyrics = json['lyrics'] as String?;
      if (lyrics == null || lyrics.trim().isEmpty) {
        return null;
      }
      return lyrics.trim();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _fetchVideoPreview(Song song) async {
    if (song.isOffline) {
      return null;
    }

    final uri = Uri.https('itunes.apple.com', '/search', {
      'term': '${song.artist} ${song.title}',
      'media': 'musicVideo',
      'entity': 'musicVideo',
      'limit': '1',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = json['results'] as List<dynamic>? ?? const [];
      if (items.isEmpty) {
        return null;
      }

      final item = items.first as Map<String, dynamic>;
      return item['previewUrl'] as String?;
    } catch (_) {
      return null;
    }
  }
}
