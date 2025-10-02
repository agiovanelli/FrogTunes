import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'coda.dart';

class AudioService {
  // Notifier per loopMode
  final ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);
  // Getter pubblico per la coda (ConcatenatingAudioSource)
  ConcatenatingAudioSource get queue => _queue;

  // Getter pubblico per accedere al player
  AudioPlayer get player => _player;
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    // Ascolta lo stato del player per aggiornare isPlayingNotifier
    _player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
    });

    // Aggiorna loopModeNotifier quando cambia
    _player.loopModeStream.listen((mode) {
      loopModeNotifier.value = mode;
    });

    // Ascolta i cambiamenti di traccia per aggiornare i metadati correnti
    _player.currentIndexStream.listen((index) async {
      
      // Se disabilito questa parte, non rimuove la traccia precedente dalla coda
      // // Se si passa alla prossima canzone, rimuovi la precedente dalla coda
      // final prevIndex = index != null ? index - 1 : null;
      // // Evita RangeError: non rimuovere se la coda ha solo una traccia
      // if (_queue.length > 1 && prevIndex != null && prevIndex >= 0 && prevIndex < _queue.length) {
      //   await _queue.removeAt(prevIndex);
      //   // Dopo la rimozione, aggiorna l'indice del player
      //   if (_player.currentIndex != null && _player.currentIndex! > 0) {
      //     await _player.seekToNext();
      //   }
      // }

      if (index == null) return;
      // Evita RangeError: controlla che index sia valido rispetto alla sequence
      if (index < 0 || index >= _player.sequence.length) return;

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
  final ConcatenatingAudioSource _queue = ConcatenatingAudioSource(children: []);

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

  // Funzione per far partire una canzone singola (sostituisce la coda)
  Future<void> playSong({
    required String songId,
    required String url,
    required String title,
    required List<String> artistId,
    required String artist,
    required String cover,
  }) async {
    // Se la canzone è già in riproduzione, non riavviare
    if (currentSongId.value == songId && _player.playing) {
      // Aggiorna solo i metadati se necessario
      currentTitle.value = title;
      currentArtistId.value = artistId;
      currentArtist.value = artist;
      currentCover.value = cover;
      return;
    }

    // Aggiorna i metadati
    currentSongId.value = songId;
    currentTitle.value = title;
    currentArtistId.value = artistId;
    currentArtist.value = artist;
    currentCover.value = cover;

    // Sostituisci la coda con una sola canzone
    _queue.clear();
    await _queue.add(AudioSource.uri(
      Uri.parse(url),
      tag: {
        'songId': songId,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'cover': cover,
      },
    ));
    await _player.stop();
    await _player.setAudioSource(_queue, initialIndex: 0);
    await _player.play();
  }

  // Funzione per aggiungere una canzone in coda senza interrompere la riproduzione
  Future<void> addToQueue(Map<String, dynamic> song) async {
    await _queue.add(AudioSource.uri(
      Uri.parse(song['url'] ?? ''),
      tag: {
        'songId': song['songId'] ?? '',
        'title': song['title'] ?? '',
        'artist': song['artist'] ?? '',
        'artistId': song['artistId'] ?? [],
        'cover': song['cover'] ?? '',
      },
    ));
  }

  // Per riprodurre una lista di URL (playlist vera)
    Future<void> setPlaylist(List<Map<String, dynamic>> tracks, {int initialIndex = 0}) async {
      _queue.clear();
      for (final track in tracks) {
        await _queue.add(AudioSource.uri(
          Uri.parse(track['url'] ?? ''),
          tag: {
            'songId': track['songId'] ?? '',
            'title': track['title'] ?? '',
            'artist': track['artist'] ?? '',
            'artistId': track['artistId'] ?? [],
            'cover': track['cover'] ?? '',
          },
        ));
      }
      Coda.loadPlaylist(tracks);
      await _player.stop();
      await _player.setAudioSource(_queue, initialIndex: initialIndex);
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
