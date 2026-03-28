import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/offline_music_view_model.dart';
import 'now_playing_view.dart';

class OfflineNowPlayingScreen extends StatelessWidget {
  const OfflineNowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<OfflineMusicViewModel>().playback;
    return NowPlayingView(
      title: 'Offline Player',
      playback: playback,
      accentColor: const Color(0xFF3BC8FF),
    );
  }
}
