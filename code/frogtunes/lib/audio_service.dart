import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Info della traccia corrente (usati dal MiniPlayer)
  final ValueNotifier<String> currentSongId = ValueNotifier('');
  final ValueNotifier<String> currentTitle = ValueNotifier('');
  final ValueNotifier<List<String>> currentArtistId = ValueNotifier([]);
  final ValueNotifier<String> currentArtist = ValueNotifier('');
  final ValueNotifier<String> currentCover = ValueNotifier('');

  // Getter per identificare lo stato attuale
  bool get isPlaying => _player.playing;
  bool get isShuffle => _player.shuffleModeEnabled;
  bool get isLoop => _player.loopMode == LoopMode.one;

  // Stream per UI reattiva
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  // Avvia una canzone e aggiorna i metadati
  Future<void> playSong({
    required String songId,
    required String url,
    required String title,
    required List<String> artistId,
    required String artist,
    required String cover,
  }) async {
  // Se è la stessa canzone, fai solo resume
  if (currentSongId.value == songId && _player.playing == false) {
    await _player.play();
    return;
  }
  // Se è una canzone diversa, parte dall'inizio
    currentSongId.value = songId;
    currentTitle.value = title;
    currentArtistId.value = artistId;
    currentArtist.value = artist;
    currentCover.value = cover;

    await _player.setUrl(url);
    await _player.play();
  }

  // Controlli base
  Future<void> setUrl(String url) async => _player.setUrl(url);
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