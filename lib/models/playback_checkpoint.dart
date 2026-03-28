class PlaybackCheckpoint {
  const PlaybackCheckpoint({
    required this.type,
    required this.queueJson,
    required this.currentIndex,
    required this.positionMs,
    required this.isShuffle,
    required this.updatedAt,
  });

  final String type;
  final String queueJson;
  final int currentIndex;
  final int positionMs;
  final bool isShuffle;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'type': type,
      'queue_json': queueJson,
      'current_index': currentIndex,
      'position_ms': positionMs,
      'is_shuffle': isShuffle ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PlaybackCheckpoint.fromMap(Map<String, Object?> map) {
    return PlaybackCheckpoint(
      type: map['type'] as String,
      queueJson: map['queue_json'] as String? ?? '[]',
      currentIndex: map['current_index'] as int? ?? 0,
      positionMs: map['position_ms'] as int? ?? 0,
      isShuffle: (map['is_shuffle'] as int? ?? 0) == 1,
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
