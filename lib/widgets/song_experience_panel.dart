import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../models/song.dart';
import '../models/song_experience.dart';
import '../services/song_experience_service.dart';

class SongExperiencePanel extends StatefulWidget {
  const SongExperiencePanel({
    super.key,
    required this.song,
    required this.accentColor,
  });

  final Song song;
  final Color accentColor;

  @override
  State<SongExperiencePanel> createState() => _SongExperiencePanelState();
}

class _SongExperiencePanelState extends State<SongExperiencePanel> {
  final SongExperienceService _service = SongExperienceService();

  SongExperience? _experience;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExperience());
  }

  @override
  void didUpdateWidget(covariant SongExperiencePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _selectedTab = 0;
      unawaited(_loadExperience());
    }
  }

  Future<void> _loadExperience() async {
    setState(() {
      _isLoading = true;
    });

    await _disposeVideo();
    final experience = await _service.fetchExperience(widget.song);
    if (!mounted) {
      return;
    }

    VideoPlayerController? nextController;
    if (experience.hasVideo) {
      nextController = VideoPlayerController.networkUrl(
        Uri.parse(experience.videoPreviewUrl!),
      );
      await nextController.initialize();
      await nextController.setLooping(true);
      await nextController.setVolume(0);
      await nextController.play();
    }

    if (!mounted) {
      await nextController?.dispose();
      return;
    }

    setState(() {
      _experience = experience;
      _videoController = nextController;
      _isLoading = false;
    });
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    await controller?.dispose();
  }

  @override
  void dispose() {
    unawaited(_disposeVideo());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _PanelTab(
              label: 'Visuals',
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 10),
            _PanelTab(
              label: 'Lyrics',
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _selectedTab == 0
              ? _buildVisualCard(palette)
              : _buildLyricsCard(palette),
        ),
      ],
    );
  }

  Widget _buildVisualCard(AppPalette palette) {
    final imageUrl = _experience?.visualImageUrl ?? widget.song.artworkUrl;
    final hasVideo =
        _videoController != null && _videoController!.value.isInitialized;

    return Container(
      key: const ValueKey('visual'),
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isLoading)
              Container(
                color: palette.surface,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (hasVideo)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _FallbackVisual(accentColor: widget.accentColor),
              )
            else
              _FallbackVisual(accentColor: widget.accentColor),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasVideo ? 'Short Video Preview' : 'Album / Artist Visual',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.song.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Media previews courtesy of iTunes when available.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsCard(AppPalette palette) {
    final lyrics = _experience?.lyrics;

    return Container(
      key: const ValueKey('lyrics'),
      height: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Text(
                lyrics ??
                    'Lyrics are not available for this song right now. You can still enjoy the album art or short preview video in the Visuals tab.',
                style: const TextStyle(
                  height: 1.7,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

class _PanelTab extends StatelessWidget {
  const _PanelTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? palette.accent.withValues(alpha: 0.18)
                : palette.surface.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? palette.accent.withValues(alpha: 0.48)
                  : palette.secondary.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? palette.accentSoft : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackVisual extends StatelessWidget {
  const _FallbackVisual({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.7),
            const Color(0xFF12372A),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq_rounded, size: 88, color: Colors.white),
      ),
    );
  }
}
