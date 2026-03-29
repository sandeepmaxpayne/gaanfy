import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/music_section.dart';
import '../models/song.dart';

class OnlineMusicService {
  OnlineMusicService({
    http.Client? client,
    String? spotifyClientId,
    String? spotifyClientSecret,
    String? jamendoClientId,
    String? audiomackConsumerKey,
    String? audiomackConsumerSecret,
    String? tasteDiveApiKey,
  }) : _client = client ?? http.Client(),
       _spotifyClientId =
           spotifyClientId ?? const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
       _spotifyClientSecret =
           spotifyClientSecret ??
           const String.fromEnvironment('SPOTIFY_CLIENT_SECRET'),
       _jamendoClientId =
           jamendoClientId ?? const String.fromEnvironment('JAMENDO_CLIENT_ID'),
       _audiomackConsumerKey =
           audiomackConsumerKey ??
           const String.fromEnvironment('AUDIOMACK_CONSUMER_KEY'),
       _audiomackConsumerSecret =
           audiomackConsumerSecret ??
           const String.fromEnvironment('AUDIOMACK_CONSUMER_SECRET'),
       _tasteDiveApiKey =
           tasteDiveApiKey ??
           const String.fromEnvironment('TASTEDIVE_API_KEY');

  final http.Client _client;
  final String _spotifyClientId;
  final String _spotifyClientSecret;
  final String _jamendoClientId;
  final String _audiomackConsumerKey;
  final String _audiomackConsumerSecret;
  final String _tasteDiveApiKey;

  static const _itunesHost = 'itunes.apple.com';
  static const _audiomackBaseUrl = 'https://api.audiomack.com';
  static const _audiusBaseUrl = 'https://api.audius.co/v1';
  static const _jamendoHost = 'api.jamendo.com';
  static const _tasteDiveHost = 'tastedive.com';
  static const _requestTimeout = Duration(seconds: 6);
  static const _sourceWeights = <String, double>{
    'Audiomack Full': 1.14,
    'iTunes Preview': 1.0,
    'Audius': 0.9,
    'Jamendo': 0.82,
  };

  String? _spotifyAccessToken;
  DateTime? _spotifyTokenExpiry;

  Future<List<MusicSection>> fetchDiscoverSections() async {
    final now = DateTime.now();
    final weekLabel = _weekRangeLabel(now);
    final freshSongs = await _fetchFreshSongs(limit: 14);
    final indiaSongs = await _aggregateSearch(
      'latest bollywood hindi songs ${now.year}',
      limit: 16,
    );
    final focusSongs = await _aggregateSearch(
      'viral chill electronic remix ${now.year}',
      limit: 16,
    );

    return [
      MusicSection(
        title: 'This Week',
        caption: 'Fast fallback mix updated for $weekLabel.',
        songs: freshSongs.take(10).toList(),
      ),
      MusicSection(
        title: 'Fresh India',
        caption: 'Recent Bollywood and Hindi picks across backup APIs.',
        songs: indiaSongs.take(10).toList(),
      ),
      MusicSection(
        title: 'Instant Play',
        caption: 'Ranked for quick start and resilient playback links.',
        songs: focusSongs.take(10).toList(),
      ),
    ];
  }

  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }
    return _aggregateSearch(query, limit: 24);
  }

  Future<List<Song>> _fetchFreshSongs({required int limit}) async {
    final now = DateTime.now();
    final releases = await Future.wait([
      _fetchAudiomackTrending(limit: limit),
      _fetchAudiusTrending(limit: limit),
      _searchItunes('new music friday ${now.year}', limit: limit),
      _searchItunes('top songs ${now.year}', limit: limit),
      _searchJamendo('new releases', limit: limit),
    ]);

    final combined = releases.expand((songs) => songs).toList();
    final enriched = await _enrichWithSpotifyMetadataIfAvailable(combined);
    return _mergeAndRankSongs(
      enriched,
      query: '${now.year} fresh weekly releases',
      limit: limit,
    );
  }

  Future<List<Song>> _aggregateSearch(String query, {required int limit}) async {
    final expandedQueries = await _buildSearchQueries(query);
    final perQueryLimit = max(6, (limit / max(1, expandedQueries.length)).ceil());
    final providers = await Future.wait(
      expandedQueries.map(
        (term) => _searchAcrossPlayableProviders(term, limit: perQueryLimit),
      ),
    );

    final combined = providers.expand((songs) => songs).toList();
    final enriched = await _enrichWithSpotifyMetadataIfAvailable(combined);
    return _mergeAndRankSongs(enriched, query: query, limit: limit);
  }

  Future<List<Song>> _searchAcrossPlayableProviders(
    String query, {
    required int limit,
  }) async {
    final providers = await Future.wait([
      _searchAudiomack(query, limit: limit),
      _searchItunes(query, limit: limit),
      _searchAudius(query, limit: limit),
      _searchJamendo(query, limit: limit),
    ]);

    return providers.expand((songs) => songs).toList(growable: false);
  }

  Future<List<String>> _buildSearchQueries(String query) async {
    final relatedTerms = await _fetchTasteDiveRelatedTerms(query);
    final terms = <String>[query, ...relatedTerms];
    final unique = <String>[];
    final seen = <String>{};

    for (final term in terms) {
      final normalized = _normalize(term);
      if (normalized.isEmpty || !seen.add(normalized)) {
        continue;
      }
      unique.add(term);
      if (unique.length >= 4) {
        break;
      }
    }

    return unique;
  }

  Future<List<Song>> _searchItunes(String query, {required int limit}) async {
    final uri = Uri.https(_itunesHost, '/search', {
      'term': query,
      'entity': 'song',
      'limit': '$limit',
      'country': 'IN',
    });

    return _guardedRequest(() async {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        return const [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = json['results'] as List<dynamic>? ?? const [];

      return items
          .whereType<Map<String, dynamic>>()
          .where((item) => (item['previewUrl'] as String?)?.isNotEmpty ?? false)
          .map((item) => Song(
                id: 'itunes-${item['trackId'] ?? item['collectionId'] ?? item['previewUrl']}',
                title: item['trackName'] as String? ?? 'Unknown Track',
                artist: item['artistName'] as String? ?? 'Unknown Artist',
                album: item['collectionName'] as String? ?? '',
                streamUrl: item['previewUrl'] as String? ?? '',
                artworkUrl: (item['artworkUrl100'] as String?)
                    ?.replaceAll('100x100bb', '600x600bb'),
                filePath: null,
                durationMs: item['trackTimeMillis'] as int?,
                isOffline: false,
                genre: item['primaryGenreName'] as String?,
                sourceLabel: 'iTunes Preview',
                releaseDate: item['releaseDate'] as String?,
                externalUrl: item['trackViewUrl'] as String?,
              ))
          .toList();
    });
  }

  Future<List<Song>> _searchAudiomack(String query, {required int limit}) async {
    if (!_hasAudiomackCredentials) {
      return const [];
    }

    return _guardedRequest(() async {
      final response = await _signedAudiomackRequest(
        method: 'GET',
        path: '/search',
        queryParameters: {
          'q': query,
          'show': 'songs',
          'limit': '$limit',
        },
      );
      if (response.statusCode != 200) {
        return const [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items =
          (decoded['results'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
      return _hydrateAudiomackSongs(items, limit: limit);
    });
  }

  Future<List<Song>> _fetchAudiomackTrending({required int limit}) async {
    if (!_hasAudiomackCredentials) {
      return const [];
    }

    return _guardedRequest(() async {
      final response = await _signedAudiomackRequest(
        method: 'GET',
        path: '/v1/music/trending',
        queryParameters: {'limit': '$limit'},
      );
      if (response.statusCode != 200) {
        return const [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items =
          (decoded['results'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
      return _hydrateAudiomackSongs(items, limit: limit);
    });
  }

  Future<List<String>> _fetchTasteDiveRelatedTerms(String query) async {
    final apiKey = _tasteDiveApiKey.trim();
    if (apiKey.isEmpty) {
      return const [];
    }

    final uri = Uri.https(_tasteDiveHost, '/api/similar', {
      'q': query,
      'type': 'music',
      'limit': '3',
      'info': '0',
      'k': apiKey,
    });

    final response = await _guardedRawRequest(
      () => _client.get(uri).timeout(_requestTimeout),
    );
    if (response == null || response.statusCode != 200) {
      return const [];
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final similar = decoded['Similar'] as Map<String, dynamic>?;
    final results = (similar?['Results'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    return results
        .map((item) => _stringValue(item['Name']))
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Song>> _fetchAudiusTrending({required int limit}) async {
    final uri = Uri.parse(
      '$_audiusBaseUrl/tracks/trending?app_name=gaanfy&limit=$limit',
    );

    return _guardedRequest(() async {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        return const [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = json['data'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(_mapAudiusSong)
          .whereType<Song>()
          .toList();
    });
  }

  Future<List<Song>> _searchAudius(String query, {required int limit}) async {
    final uri = Uri.parse(
      '$_audiusBaseUrl/tracks/search?query=${Uri.encodeQueryComponent(query)}'
      '&app_name=gaanfy&limit=$limit',
    );

    return _guardedRequest(() async {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        return const [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = json['data'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(_mapAudiusSong)
          .whereType<Song>()
          .toList();
    });
  }

  Song? _mapAudiusSong(Map<String, dynamic> item) {
    final preview = item['preview'] as Map<String, dynamic>?;
    final stream = item['stream'] as Map<String, dynamic>?;
    final artwork = item['artwork'] as Map<String, dynamic>?;
    final user = item['user'] as Map<String, dynamic>?;
    final primaryUrl =
        (preview?['url'] as String?) ??
        (stream?['url'] as String?) ??
        '';

    if (primaryUrl.isEmpty) {
      return null;
    }

    final streamUrl = stream?['url'] as String?;
    final backupUrls = <String>{
      if (streamUrl != null && streamUrl.isNotEmpty && streamUrl != primaryUrl)
        streamUrl,
    }.toList();

    return Song(
      id: 'audius-${item['id'] ?? item['track_id'] ?? primaryUrl}',
      title: item['title'] as String? ?? 'Unknown Track',
      artist:
          user?['name'] as String? ??
          user?['handle'] as String? ??
          'Unknown Artist',
      album: '',
      streamUrl: primaryUrl,
      artworkUrl:
          artwork?['480x480'] as String? ??
          artwork?['150x150'] as String? ??
          artwork?['1000x1000'] as String?,
      filePath: null,
      durationMs: ((item['duration'] as num?)?.toDouble() ?? 0) > 0
          ? (((item['duration'] as num?)?.toDouble() ?? 0) * 1000).round()
          : null,
      isOffline: false,
      genre: item['genre'] as String?,
      sourceLabel: 'Audius',
      backupStreamUrls: backupUrls,
      releaseDate: item['release_date'] as String? ?? item['created_at'] as String?,
      externalUrl: item['permalink'] == null
          ? null
          : 'https://audius.co${item['permalink']}',
    );
  }

  Future<List<Song>> _hydrateAudiomackSongs(
    List<Map<String, dynamic>> items, {
    required int limit,
  }) async {
    final songs = <Song>[];
    for (final item in items.take(limit)) {
      final song = await _mapAudiomackTrack(item);
      if (song != null) {
        songs.add(song);
      }
    }
    return songs;
  }

  Future<Song?> _mapAudiomackTrack(Map<String, dynamic> item) async {
    final id = _stringValue(item['id']);
    if (id == null || id.isEmpty) {
      return null;
    }

    final playResponse = await _signedAudiomackRequest(
      method: 'POST',
      path: '/v1/music/$id/play',
      bodyParameters: const {'hq': 'true'},
    );
    if (playResponse.statusCode != 200) {
      return null;
    }

    final streamUrl = _extractAudiomackStreamUrl(playResponse.body);
    if (streamUrl == null || streamUrl.isEmpty) {
      return null;
    }

    final artistData = item['artist'] as Map<String, dynamic>?;
    final albumData = item['album'] as Map<String, dynamic>?;

    return Song(
      id: 'audiomack-$id',
      title: _stringValue(item['title']) ?? 'Unknown Track',
      artist:
          _stringValue(artistData?['name']) ??
          _stringValue(item['artist']) ??
          'Unknown Artist',
      album:
          _stringValue(albumData?['title']) ??
          _stringValue(item['album']) ??
          '',
      streamUrl: streamUrl,
      artworkUrl: _stringValue(item['image']),
      filePath: null,
      durationMs: _parseDurationMs(item['duration']),
      isOffline: false,
      genre: _stringValue(item['genre']),
      sourceLabel: 'Audiomack Full',
      releaseDate: _audiomackReleaseDate(item),
      externalUrl: _stringValue(item['url']),
    );
  }

  Future<List<Song>> _searchJamendo(String query, {required int limit}) async {
    if (_jamendoClientId.isEmpty) {
      return const [];
    }

    final uri = Uri.https(_jamendoHost, '/v3.0/tracks', {
      'client_id': _jamendoClientId,
      'format': 'json',
      'search': query,
      'limit': '$limit',
      'order': 'popularity_total',
      'include': 'musicinfo',
      'audioformat': 'mp32',
    });

    return _guardedRequest(() async {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        return const [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results =
          (json['results'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>();
      return results
          .where((item) => (item['audio'] as String?)?.isNotEmpty ?? false)
          .map((item) => Song(
                id: 'jamendo-${item['id'] ?? item['audio']}',
                title: item['name'] as String? ?? 'Unknown Track',
                artist: item['artist_name'] as String? ?? 'Unknown Artist',
                album: item['album_name'] as String? ?? '',
                streamUrl: item['audio'] as String? ?? '',
                artworkUrl:
                    item['album_image'] as String? ??
                    item['image'] as String?,
                filePath: null,
                durationMs: ((item['duration'] as num?)?.toDouble() ?? 0) > 0
                    ? (((item['duration'] as num?)?.toDouble() ?? 0) * 1000)
                        .round()
                    : null,
                isOffline: false,
                genre: _jamendoGenre(item),
                sourceLabel: 'Jamendo',
                releaseDate: item['releasedate'] as String?,
                externalUrl: item['shareurl'] as String?,
              ))
          .toList();
    });
  }

  Future<List<Song>> _enrichWithSpotifyMetadataIfAvailable(
    List<Song> songs,
  ) async {
    if (_spotifyClientId.isEmpty || _spotifyClientSecret.isEmpty || songs.isEmpty) {
      return songs;
    }

    final token = await _spotifyToken();
    if (token == null) {
      return songs;
    }

    final sample = songs.take(6).toList();
    final enriched = <String, Song>{};

    for (final song in sample) {
      final spotifySong = await _searchSpotifyMatch(song, token);
      if (spotifySong != null) {
        enriched[_dedupeKey(song)] = _mergeSongPair(song, spotifySong);
      }
    }

    return songs
        .map((song) => enriched[_dedupeKey(song)] ?? song)
        .toList(growable: false);
  }

  Future<String?> _spotifyToken() async {
    final now = DateTime.now();
    if (_spotifyAccessToken != null &&
        _spotifyTokenExpiry != null &&
        now.isBefore(_spotifyTokenExpiry!)) {
      return _spotifyAccessToken;
    }

    final credentials =
        base64Encode(utf8.encode('$_spotifyClientId:$_spotifyClientSecret'));
    final response = await _guardedRawRequest(() {
      return _client
          .post(
            Uri.parse('https://accounts.spotify.com/api/token'),
            headers: {
              'Authorization': 'Basic $credentials',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'grant_type': 'client_credentials'},
          )
          .timeout(_requestTimeout);
    });

    if (response == null || response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _spotifyAccessToken = json['access_token'] as String?;
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    _spotifyTokenExpiry = now.add(Duration(seconds: expiresIn - 60));
    return _spotifyAccessToken;
  }

  Future<Song?> _searchSpotifyMatch(Song song, String token) async {
    final query = '${song.title} ${song.artist}';
    final uri = Uri.https('api.spotify.com', '/v1/search', {
      'q': query,
      'type': 'track',
      'limit': '1',
      'market': 'IN',
    });

    final response = await _guardedRawRequest(() {
      return _client.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_requestTimeout);
    });

    if (response == null || response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items =
        ((json['tracks'] as Map<String, dynamic>?)?['items'] as List<dynamic>? ??
                const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    if (items.isEmpty) {
      return null;
    }

    final item = items.first;
    final artists = (item['artists'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((artist) => artist['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
    final album = item['album'] as Map<String, dynamic>?;
    final images = (album?['images'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Song(
      id: 'spotify-${item['id'] ?? ''}',
      title: item['name'] as String? ?? song.title,
      artist: artists.isEmpty ? song.artist : artists,
      album: album?['name'] as String? ?? song.album,
      streamUrl: song.streamUrl,
      artworkUrl: images.isNotEmpty ? images.first['url'] as String? : song.artworkUrl,
      filePath: null,
      durationMs: item['duration_ms'] as int? ?? song.durationMs,
      isOffline: false,
      genre: song.genre,
      sourceLabel: song.sourceLabel,
      backupStreamUrls: song.backupStreamUrls,
      releaseDate: (album?['release_date'] as String?) ?? song.releaseDate,
      externalUrl: ((item['external_urls'] as Map<String, dynamic>?)?['spotify'])
          as String?,
    );
  }

  List<Song> _mergeAndRankSongs(
    List<Song> songs, {
    required String query,
    required int limit,
  }) {
    final merged = <String, Song>{};

    for (final song in songs.where((song) => song.streamUrl.isNotEmpty)) {
      final key = _dedupeKey(song);
      final existing = merged[key];
      if (existing == null) {
        merged[key] = song;
        continue;
      }
      merged[key] = _pickPreferredSong(existing, song);
    }

    final ranked = merged.values.toList()
      ..sort((left, right) {
        final rightScore = _scoreSong(right, query);
        final leftScore = _scoreSong(left, query);
        return rightScore.compareTo(leftScore);
      });

    return ranked.take(limit).toList(growable: false);
  }

  Song _pickPreferredSong(Song left, Song right) {
    final leftScore = _sourceWeights[left.sourceLabel] ?? 0;
    final rightScore = _sourceWeights[right.sourceLabel] ?? 0;
    final winner = leftScore >= rightScore ? left : right;
    final loser = identical(winner, left) ? right : left;
    return _mergeSongPair(winner, loser);
  }

  Song _mergeSongPair(Song primary, Song secondary) {
    final backups = <String>{
      ...primary.backupStreamUrls,
      ...secondary.backupStreamUrls,
      if (secondary.streamUrl.isNotEmpty && secondary.streamUrl != primary.streamUrl)
        secondary.streamUrl,
    }.toList();

    return Song(
      id: primary.id,
      title: primary.title,
      artist: primary.artist,
      album: primary.album.isNotEmpty ? primary.album : secondary.album,
      streamUrl: primary.streamUrl,
      artworkUrl: primary.artworkUrl ?? secondary.artworkUrl,
      filePath: primary.filePath,
      durationMs: primary.durationMs ?? secondary.durationMs,
      isOffline: primary.isOffline,
      genre: primary.genre ?? secondary.genre,
      sourceLabel: primary.sourceLabel ?? secondary.sourceLabel,
      backupStreamUrls: backups,
      releaseDate: _newerDate(primary.releaseDate, secondary.releaseDate),
      externalUrl: primary.externalUrl ?? secondary.externalUrl,
    );
  }

  double _scoreSong(Song song, String query) {
    final q = query.toLowerCase();
    final title = song.title.toLowerCase();
    final artist = song.artist.toLowerCase();
    final genre = (song.genre ?? '').toLowerCase();
    var score = (_sourceWeights[song.sourceLabel] ?? 0.5) * 100;

    if (title == q || artist == q) {
      score += 40;
    }
    if (title.contains(q)) {
      score += 24;
    }
    if (artist.contains(q)) {
      score += 18;
    }
    if (genre.contains(q)) {
      score += 8;
    }
    if (song.artworkUrl != null) {
      score += 6;
    }
    if (song.backupStreamUrls.isNotEmpty) {
      score += 12;
    }
    if (_isRecent(song.releaseDate)) {
      score += 10;
    }
    final queryTokens = q.split(RegExp(r'\s+')).where((token) => token.isNotEmpty);
    for (final token in queryTokens) {
      if (title.contains(token)) {
        score += 5;
      }
      if (artist.contains(token)) {
        score += 3;
      }
    }
    return score;
  }

  bool _isRecent(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) {
      return false;
    }
    final parsed = DateTime.tryParse(releaseDate);
    if (parsed == null) {
      return false;
    }
    return DateTime.now().difference(parsed).inDays <= 21;
  }

  String _dedupeKey(Song song) {
    final title = _normalize(song.title);
    final artist = _normalize(song.artist);
    return '$title::$artist';
  }

  String _normalize(String value) {
    final withoutFeaturing = value.toLowerCase().replaceAll(
      RegExp(r'\b(feat|ft)\.?\b.*'),
      '',
    );
    return withoutFeaturing.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String? _newerDate(String? left, String? right) {
    if (left == null || left.isEmpty) {
      return right;
    }
    if (right == null || right.isEmpty) {
      return left;
    }

    final leftDate = DateTime.tryParse(left);
    final rightDate = DateTime.tryParse(right);
    if (leftDate == null) {
      return right;
    }
    if (rightDate == null) {
      return left;
    }
    return leftDate.isAfter(rightDate) ? left : right;
  }

  String _weekRangeLabel(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${_monthShort(start.month)} ${start.day}-${end.day}';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String? _jamendoGenre(Map<String, dynamic> item) {
    final musicInfo = item['musicinfo'];
    if (musicInfo is! Map<String, dynamic>) {
      return null;
    }

    final tags = musicInfo['tags'];
    if (tags is! Map<String, dynamic>) {
      return null;
    }

    final genres = tags['genres'];
    if (genres == null) {
      return null;
    }
    return genres.toString();
  }

  String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString().trim().isEmpty ? null : value.toString().trim();
  }

  int? _parseDurationMs(Object? value) {
    if (value == null) {
      return null;
    }
    final raw = num.tryParse(value.toString());
    if (raw == null || raw <= 0) {
      return null;
    }

    if (raw > 10000) {
      return raw.round();
    }
    return (raw * 1000).round();
  }

  bool get _hasAudiomackCredentials =>
      _audiomackConsumerKey.isNotEmpty && _audiomackConsumerSecret.isNotEmpty;

  Future<http.Response> _signedAudiomackRequest({
    required String method,
    required String path,
    Map<String, String> queryParameters = const {},
    Map<String, String> bodyParameters = const {},
  }) async {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final oauthParams = <String, String>{
      'oauth_consumer_key': _audiomackConsumerKey,
      'oauth_nonce': _randomNonce(),
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_version': '1.0',
    };

    final allParams = <String, String>{
      ...queryParameters,
      ...bodyParameters,
      ...oauthParams,
    };

    final uri = Uri.parse('$_audiomackBaseUrl$path').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final signatureBase = _signatureBaseString(method, uri, allParams);
    final signingKey = '${_oauthEncode(_audiomackConsumerSecret)}&';
    final digest = Hmac(
      sha1,
      utf8.encode(signingKey),
    ).convert(utf8.encode(signatureBase));
    oauthParams['oauth_signature'] = base64Encode(digest.bytes);

    final authorization = _oauthAuthorizationHeader(oauthParams);
    final headers = <String, String>{'Authorization': authorization};

    if (method.toUpperCase() == 'POST') {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      return _client
          .post(uri, headers: headers, body: bodyParameters)
          .timeout(_requestTimeout);
    }

    return _client.get(uri, headers: headers).timeout(_requestTimeout);
  }

  String _signatureBaseString(
    String method,
    Uri uri,
    Map<String, String> parameters,
  ) {
    final normalized = parameters.entries.toList()
      ..sort((left, right) {
        final keyCompare = left.key.compareTo(right.key);
        if (keyCompare != 0) {
          return keyCompare;
        }
        return left.value.compareTo(right.value);
      });

    final parameterString = normalized
        .map((entry) => '${_oauthEncode(entry.key)}=${_oauthEncode(entry.value)}')
        .join('&');
    final baseUri = uri.replace(query: '', fragment: '');
    return [
      method.toUpperCase(),
      _oauthEncode(baseUri.toString()),
      _oauthEncode(parameterString),
    ].join('&');
  }

  String _oauthAuthorizationHeader(Map<String, String> oauthParams) {
    final parts = oauthParams.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    return 'OAuth ${parts.map((entry) => '${_oauthEncode(entry.key)}="${_oauthEncode(entry.value)}"').join(', ')}';
  }

  String _oauthEncode(String value) {
    return Uri.encodeQueryComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  String _randomNonce() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      24,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String? _extractAudiomackStreamUrl(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is String) {
        return decoded;
      }
      if (decoded is Map<String, dynamic>) {
        return _stringValue(decoded['url']) ?? _stringValue(decoded['results']);
      }
    } catch (_) {
      if (trimmed.startsWith('http')) {
        return trimmed;
      }
    }

    return null;
  }

  String? _audiomackReleaseDate(Map<String, dynamic> item) {
    final updated = _stringValue(item['updated']);
    if (updated == null) {
      return null;
    }
    final unixSeconds = int.tryParse(updated);
    if (unixSeconds == null) {
      return updated;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    ).toIso8601String();
  }

  Future<List<Song>> _guardedRequest(
    Future<List<Song>> Function() action,
  ) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      debugPrint('Online provider failed: $error\n$stackTrace');
      return const [];
    }
  }

  Future<http.Response?> _guardedRawRequest(
    Future<http.Response> Function() action,
  ) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      debugPrint('Online provider request failed: $error\n$stackTrace');
      return null;
    }
  }
}
