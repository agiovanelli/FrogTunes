import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    // ascolta lo stato del player per aggiornare isPlayingNotifier
    _player.playerStateStream.listen((state) {
    isPlayingNotifier.value = state.playing;
    });

    _player.currentIndexStream.listen((index) {
      if (index == null) return;

      final source = _player.sequence[index];
      if (source.tag == null) return;

      final tag = source.tag as Map<String, dynamic>;
      currentSongId.value = tag['songId'] ?? '';
      currentTitle.value = tag['title'] ?? '';
      currentArtist.value = tag['artist'] ?? '';
      currentArtistId.value = List<String>.from(tag['artistId'] ?? []);
      currentCover.value = tag['cover'] ?? '';
    });
  }

  final AudioPlayer _player = AudioPlayer();

  // Info della traccia corrente (usati dal MiniPlayer)
  final ValueNotifier<String> currentSongId = ValueNotifier('');
  final ValueNotifier<String> currentTitle = ValueNotifier('');
  final ValueNotifier<List<String>> currentArtistId = ValueNotifier([]);
  final ValueNotifier<String> currentArtist = ValueNotifier('');
  final ValueNotifier<String> currentCover = ValueNotifier('');

  // Notifier per stato di riproduzione
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  // Getter per identificare lo stato attuale
  bool get isPlaying => _player.playing;
  bool get isShuffle => _player.shuffleModeEnabled;
  bool get isLoop => _player.loopMode == LoopMode.one;

  // Stream per UI reattiva
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  // --- playSong: sempre imposta una "playlist" anche per 1 brano ---
  Future<void> playSong({
    required String songId,
    required String url,
    required String title,
    required List<String> artistId,
    required String artist,
    required String cover,
  }) async {
    // Se è la stessa canzone e il player è in pausa, fai resume
    if (currentSongId.value == songId && !_player.playing) {
      await _player.play();
      return;
    }

    // Aggiorna i metadati
    currentSongId.value = songId;
    currentTitle.value = title;
    currentArtistId.value = artistId;
    currentArtist.value = artist;
    currentCover.value = cover;

    // Crea sempre una lista di AudioSource (playlist) anche con 1 elemento
    final sources = <AudioSource>[
      AudioSource.uri(
        Uri.parse(url),
        tag: {
          'songId': songId,
          'title': title,
          'artist': artist,
          'artistId': artistId,
          'cover': cover,
        },
      ),
    ];

    // Imposta la playlist
    await _player.setAudioSources(sources);
    await _player.play();
  }

  // Per riprodurre una lista di URL (playlist vera)
  Future<void> setPlaylist(List<Map<String, dynamic>> tracks) async {
    final sources = tracks.map((track) {
      return AudioSource.uri(
        Uri.parse(track['url'] ?? ''),
        tag: {
          'songId': track['songId'] ?? '',
          'title': track['title'] ?? '',
          'artist': track['artist'] ?? '',
          'artistId': track['artistId'] ?? [],
          'cover': track['cover'] ?? '',
        },
      );
    }).toList();

    await _player.setAudioSources(sources);
  }

  // Pulizia
  Future<void> dispose() => _player.dispose();

  // Controlli base
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  // Navigazione tracce (usa hasNext/hasPrevious per sicurezza)
  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }
  Future<void> previous() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  // Modalità shuffle/loop
  Future<void> toggleShuffle() =>
      _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
  Future<void> toggleLoop() =>
      _player.setLoopMode(isLoop ? LoopMode.off : LoopMode.one);
}
