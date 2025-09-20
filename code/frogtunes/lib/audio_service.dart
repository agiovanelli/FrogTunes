import 'package:just_audio/just_audio.dart';

class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Getter per identificare lo stato attuale
  bool get isPlaying => _player.playing;
  bool get isShuffle => _player.shuffleModeEnabled;
  bool get isLoop => _player.loopMode == LoopMode.one;

  // Stream per UI reattiva
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  // Controlli base
  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  // Navigazione tracce (se hai playlist)
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();

  // Modalità shuffle/loop
  Future<void> toggleShuffle() =>
      _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);

  Future<void> toggleLoop() =>
      _player.setLoopMode(isLoop ? LoopMode.off : LoopMode.one);

  // Playlist opzionale
  Future<void> setPlaylist(List<String> urls) async {
    final playlist = urls
        .map((url) => AudioSource.uri(Uri.parse(url)))
        .toList();
    await _player.setAudioSource(ConcatenatingAudioSource(children: playlist));
  }

  // Pulizia
  Future<void> dispose() => _player.dispose();
}
