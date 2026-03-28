import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/online_music_view_model.dart';
import 'now_playing_view.dart';

class OnlineNowPlayingScreen extends StatelessWidget {
  const OnlineNowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<OnlineMusicViewModel>().playback;
    return NowPlayingView(
      title: 'Streaming Player',
      playback: playback,
      accentColor: const Color(0xFF1ED760),
    );
  }
}
