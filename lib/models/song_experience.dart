class SongExperience {
  const SongExperience({
    this.lyrics,
    this.videoPreviewUrl,
    this.visualImageUrl,
  });

  final String? lyrics;
  final String? videoPreviewUrl;
  final String? visualImageUrl;

  bool get hasLyrics => lyrics != null && lyrics!.trim().isNotEmpty;
  bool get hasVideo => videoPreviewUrl != null && videoPreviewUrl!.isNotEmpty;
}
