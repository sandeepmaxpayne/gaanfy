enum PlaybackSource { online, offline }

extension PlaybackSourceX on PlaybackSource {
  String get storageKey => name;

  String get label => this == PlaybackSource.online ? 'Online' : 'Offline';
}
