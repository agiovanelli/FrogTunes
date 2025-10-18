import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:frogtunes/recensioni.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'audio_service.dart';

class PlayerScreen extends StatefulWidget {
  final String songId;
  final String titolo;
  final List<String> artistId;
  final String cover;
  final bool minimal; 
  final bool managed; // Indica se l'utente è un manager

  const PlayerScreen({
    super.key,
    required this.songId,
    required this.titolo,
    required this.artistId,
    required this.cover,
    this.minimal = false,
    this.managed = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

// Funzione per aggiungere o rimuovere la canzone dai preferiti
Future<void> toggleLikeSong({
  required String audioUrl,
  required String songId,
  required String titolo,
  required List<String> artistId,
  required String cover,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final songRef = FirebaseFirestore.instance
      .collection('utenti')
      .doc(user.uid)
      .collection('likedSongs')
      .doc(songId);

  final doc = await songRef.get();
  if (doc.exists) {
    await songRef.delete();
  } else {
    await songRef.set({
      'audioUrl': audioUrl,
      'cid': songId,
      'titolo': titolo,
      'artistId': artistId,
      'cover': cover,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}

// Funzione per recuperare i nomi degli artisti dato una lista di ID
Future<List<String>> fetchArtistName(List<String> artistId) async {
  if (artistId.isEmpty) return [];
  final doc = await FirebaseFirestore.instance
      .collection('artisti')
      .where(FieldPath.documentId, whereIn: artistId)
      .get();

  final Map<String, String> mappa = {
    for (var d in doc.docs) d.id: d.data()['nome'] as String? ?? 'Artista sconosciuto'
  };

  return artistId.map((id) => mappa[id] ?? 'Artista sconosciuto').toList();
}

// Funzione per recuperare l'URL audio di una canzone dato il suo ID
Future<String> fetchUrl(String songId) async {
  final doc = await FirebaseFirestore.instance
      .collection('canzoni')
      .doc(songId)
      .get();
  return doc.data()?['audioUrl'] ?? '';
}

class _PlayerScreenState extends State<PlayerScreen> {

  // Funzione per recuperare i crediti di una canzone dato il suo ID
  Future<Map<String, List<String>>> _fetchCrediti(String songId) async {
    final doc = await FirebaseFirestore.instance.collection('canzoni').doc(songId).get();
    final data = doc.data();
    final creditiRaw = data != null ? data['crediti'] : null;
    Map<String, List<String>> result = {
      'Autore': [],
      'Compositore': [],
      'Producer': [],
    };
    if (creditiRaw is Map) {
      for (final key in result.keys) {
        final val = creditiRaw[key];
        if (val is List) {
          result[key] = val.map((e) => e.toString()).toList();
        }
      }
    }
    return result;
  }

  void _showCreditiPopup(BuildContext context) async {
    final crediti = await _fetchCrediti(widget.songId);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF041F0F),
          title: const Text('Crediti', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final key in ['Autore', 'Compositore', 'Producer'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(key, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ...crediti[key]!.isNotEmpty
                        ? crediti[key]!.map((c) => Text(c, style: const TextStyle(color: Colors.white70))).toList()
                        : [const Text('-', style: TextStyle(color: Colors.white38))],
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Chiudi', style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  late final AudioService audio;
  List<String> nomiArtisti = [];

  // Variabili per ascoltare i cambiamenti di posizione e durata
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration?> _durationSub;

  // Variabili per posizione e durata
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  // ValueNotifiers per title, cover e artista corrente
  late final ValueNotifier<String> currentTitle;
  late final ValueNotifier<String> currentCover;
  late final ValueNotifier<String> currentArtist;

  @override
  void initState() {
    super.initState();
    audio = AudioService();
    _loadArtisti(widget.artistId); // Carica i nomi degli artisti

    // Inizializza i ValueNotifiers
    currentTitle = audio.currentTitle;
    currentCover = audio.currentCover;
    currentArtist = audio.currentArtist;

    // Ascolta le modifiche per aggiornare la UI
    currentTitle.addListener(() {
      if (mounted) setState(() {});
    });
    
    currentCover.addListener(() {
      if (mounted) setState(() {});
    });

    currentArtist.addListener(() {
      if (mounted) setState(() {});
    });

    // Posizione e durata
    _positionSub = audio.positionStream.listen((p) {
      if (mounted) setState(() => position = p);
    });
    _durationSub = audio.durationStream.listen((d) {
      if (mounted && d != null) setState(() => duration = d);
    });
  }
 
  // Funzione per assegnare i nomi degli artisti in una variabile data una lista di ID
  Future<void> _loadArtisti(List<String> id) async {
    final nomi = await fetchArtistName(id);
    setState(() => nomiArtisti = nomi);
  }

  // Funzione per mostrare la coda reale del player
  void _mostraCoda(BuildContext context, AudioService audio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF041F0F),
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Coda di riproduzione',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<LoopMode>(
                      valueListenable: audio.loopModeNotifier,
                      builder: (context, loopMode, _) {
                        final isLoopActive = loopMode == LoopMode.all;
                        return IconButton(
                          icon: Icon(
                            Icons.repeat,
                            color: isLoopActive ? Colors.green : Colors.white,
                          ),
                          tooltip: isLoopActive ? 'Loop coda attivo' : 'Loop tutta la coda',
                          onPressed: () async {
                            await audio.player.setLoopMode(
                              isLoopActive ? LoopMode.off : LoopMode.all
                            );
                            // Mostra un messaggio di conferma in fase di testing si tiene
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isLoopActive
                                    ? "Loop coda disattivato"
                                    : "Loop coda attivo: la coda si ripete all'infinito"
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'Svuota coda',
                      onPressed: () async {
                        await audio.player.stop();
                        final currentIdx = audio.player.currentIndex;
                        if (currentIdx != null
                            && audio.queue.length > 0
                            && currentIdx >= 0
                            && currentIdx < audio.queue.length) {
                          if (audio.queue.length == 1 && currentIdx == 0 && context.mounted) {
                            Navigator.pop(context);
                            return;
                          }
                          if (audio.queue.children.isNotEmpty && currentIdx >= 0 && currentIdx < audio.queue.children.length) {
                            final currentSource = audio.queue.children[currentIdx];
                            await audio.queue.clear();
                            await audio.queue.add(currentSource);
                            await audio.player.setAudioSource(
                              audio.queue,
                              initialIndex: 0,
                              initialPosition: audio.player.position,
                            );
                            if (audio.player.playing || audio.player.position > Duration.zero) {
                              await audio.player.play();
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: StreamBuilder<List<dynamic>>(
                  stream: audio.player.sequenceStream,
                  builder: (context, snapshot) {
                    final sequence = snapshot.data;
                    if (sequence == null || sequence.isEmpty) {
                      return const Center(
                        child: Text(
                          "La coda è vuota",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: sequence.length,
                      itemBuilder: (context, index) {
                        final audioSource = sequence[index];
                        final tag = audioSource.tag as Map<String, dynamic>?;
                        final isPlaying = audio.player.currentIndex == index;
                        return ListTile(
                          leading: Icon(
                            isPlaying ? Icons.play_arrow : Icons.music_note,
                            color: isPlaying ? Colors.greenAccent : Colors.white,
                          ),
                          title: Text(
                            tag?['title']?.toString() ?? 'Senza titolo',
                            style: TextStyle(
                              color: isPlaying ? Colors.greenAccent : Colors.white,
                              fontWeight:
                                  isPlaying ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            tag?['artist']?.toString() ?? 'Sconosciuto',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            tooltip: 'Rimuovi dalla coda',
                            onPressed: () async {
                              // Rimuovi la traccia dalla coda usando l'istanza _queue
                              if (audio.queue.length > 1 && index >= 0 && index < audio.queue.length) {
                                await audio.queue.removeAt(index);
                              }
                            },
                          ),
                          onTap: () {
                            audio.player.seek(Duration.zero, index: index);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  // Funzione per formattare la durata in minuti e secondi
  String _format(Duration d) =>
      "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  // Mostra il testo della canzone in un bottom sheet trascinabile
  Future<void> _mostraTesto(BuildContext context) async {
    final currentSongId = audio.currentSongId.value.isEmpty ? widget.songId : audio.currentSongId.value;
    try {
      final doc = await FirebaseFirestore.instance.collection('canzoni').doc(currentSongId).get();
      final testo = doc.data()?['testo'] as String? ?? '';

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF041F0F),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Testo - ${widget.titolo}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectableText(
                          testo.isEmpty ? 'Nessun testo disponibile per questa canzone.' : testo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Chiudi', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Errore recupero testo: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore nel recupero del testo')));
    }
  }

  // Mostra il video musicale della canzone
  Future<void> _mostraVideo(BuildContext context) async {
    final currentSongId = audio.currentSongId.value.isEmpty ? widget.songId : audio.currentSongId.value;
    // salva lo stato corrente della riproduzione audio
    final bool audioWasPlaying = audio.isPlaying;
    try {
      final doc = await FirebaseFirestore.instance.collection('canzoni').doc(currentSongId).get();
      final videoUrl = doc.data()?['videoUrl'] as String? ?? '';
      if (videoUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessun video disponibile per questa canzone')));
        return;
      }

      // Metti in pausa l'audio corrente (se sta suonando)
      try {
        await audio.pause();
      } catch (_) {
        // ignore
      }

      // Apri il video in una pagina full-screen dedicata
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullScreenVideoPage(videoUrl: videoUrl),
          fullscreenDialog: true,
        ),
      );

      // Se l'audio era in riproduzione prima dell'apertura del video, riprendi
      if (audioWasPlaying) {
        try {
          await audio.play();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Errore recupero video: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore nel recupero del video')));
    }
  }

  // Widget per il bottone delle canzoni preferite
  Widget _likeButton(String songId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();
    final songRef = FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .collection('likedSongs')
        .doc(songId);

    // Aggiorna l'icona in base allo stato della canzone nei preferiti
    return StreamBuilder<DocumentSnapshot>(
      stream: songRef.snapshots(),
      builder: (context, snapshot) {
        final isLiked = snapshot.data?.exists ?? false;
        return IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.green : Colors.white),
          // Aggiungi o rimuovi la canzone dai preferiti
          onPressed: () async {
            toggleLikeSong(
              audioUrl: await fetchUrl(songId),
              songId: songId,
              titolo: widget.titolo,
              artistId: widget.artistId,
              cover: widget.cover,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('In riproduzione', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (!widget.minimal)
            audio.currentSongId.value.isEmpty ? _likeButton(widget.songId) : _likeButton(audio.currentSongId.value),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.green,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) async {
              final currentSongId = audio.currentSongId.value.isEmpty ? widget.songId : audio.currentSongId.value;
              switch (value) {
                case 'queue':
                  _mostraCoda(context, audio);
                  break;
                case 'video':
                  _mostraVideo(context);
                  break;
                case 'lyrics':
                  _mostraTesto(context);
                  break;
                case 'reviews':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecensioniPage(
                        songId: currentSongId,
                        titolo: widget.titolo,
                        editable: widget.minimal ? !widget.managed ? true : false : false,
                        managed: widget.managed ? true : false,
                      ),
                    ),
                  );
                  break;
                case 'credits':
                  _showCreditiPopup(context);
                  break;
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];
              if (!widget.minimal) {
                items.add(PopupMenuItem(
                  value: 'queue',
                  height: 56,
                  child: Row(children: const [Icon(Icons.queue_music, color: Colors.white), SizedBox(width: 8), Text('Coda', style: TextStyle(color: Colors.white))]),
                ));
              }
              items.add(PopupMenuItem(
                value: 'video',
                height: 56,
                child: Row(children: const [Icon(Icons.music_video, color: Colors.white), SizedBox(width: 8), Text('Video musicale', style: TextStyle(color: Colors.white))]),
              ));
              items.add(PopupMenuItem(
                value: 'lyrics',
                height: 56,
                child: Row(children: const [Icon(Icons.music_note, color: Colors.white), SizedBox(width: 8), Text('Testo', style: TextStyle(color: Colors.white))]),
              ));
              items.add(PopupMenuItem(
                value: 'reviews',
                height: 56,
                child: Row(children: const [Icon(Icons.reviews, color: Colors.white), SizedBox(width: 8), Text('Recensioni', style: TextStyle(color: Colors.white))]),
              ));
              items.add(PopupMenuItem(
                value: 'credits',
                height: 56,
                child: Row(children: const [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 8), Text('Crediti', style: TextStyle(color: Colors.white))]),
              ));
              return items;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                currentCover.value.isEmpty ? widget.cover : currentCover.value,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.music_note, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            // title della canzone aggiornato in tempo reale
            Text(
              currentTitle.value.isEmpty ? widget.titolo : currentTitle.value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Nomi degli artisti aggiornati in tempo reale
            Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(nomiArtisti.length, (index) {
              final nome = nomiArtisti[index];
              final artistId = audio.currentArtist.value.isEmpty ? widget.artistId[index] : audio.currentArtistId.value[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Vai alla schermata dell'artista al cliccando sul nome
                      builder: (_) => ArtistScreen(
                        artistId: artistId,
                        nomeArtista: nome,
                        type: false,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4), 
                  // Riporta la virgola tra i nomi degli artisti se sono più di uno
                  child: Text(
                    index < audio.currentArtistId.value.length - 1 ? "$nome, " : nome,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
              );
            }),
          ),
            const Spacer(),
            // Barra progresso collegata ad AudioService
            Slider(
              value: position.inSeconds.toDouble().clamp(
                    0,
                    duration.inSeconds.toDouble() > 0
                        ? duration.inSeconds.toDouble()
                        : 1,
                  ),
              max: duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
              onChanged: (v) => audio.seek(Duration(seconds: v.toInt())),
              activeColor: Colors.green,
              inactiveColor: Colors.white30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_format(position), style: const TextStyle(color: Colors.white70)),
                Text(_format(duration), style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 20),
            // Bottoni di controllo della riproduzione
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.minimal)
                  IconButton(
                    icon: const Icon(Icons.shuffle, size: 30),
                    color: audio.isShuffle ? Colors.green : Colors.white,
                    onPressed: () async {
                      await audio.toggleShuffle();
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40),
                    onPressed: () => audio.previous(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: Icon(
                      audio.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      size: 60,
                    ),
                    onPressed: () =>
                        audio.isPlaying ? audio.pause() : audio.play(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40),
                    onPressed: () => audio.next(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  if (!widget.minimal)
                  IconButton(
                    icon: Icon(
                      audio.isLoop ? Icons.repeat_one : Icons.repeat,
                      size: 30,
                    ),
                    color: audio.isLoop ? Colors.green : Colors.white,
                    onPressed: () async {
                      await audio.toggleLoop();
                    },
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _durationSub.cancel();
    super.dispose();
  }
}

// Overlay per controlli video
class _VideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoControlsOverlay({required this.controller});

  @override
  State<_VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<_VideoControlsOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
          },
          child: Center(
            child: widget.controller.value.isPlaying
                ? const SizedBox.shrink()
                : const Icon(Icons.play_circle_fill, size: 72, color: Colors.white70),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

// Pagina full-screen per riprodurre il video
class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideoPage({
    super.key,
    required this.videoUrl
    });

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late final VideoPlayerController _controller;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    // hide system overlays for immersive full-screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    // restore system overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _showOverlay = !_controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          onTap: _togglePlay,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio > 0 ? _controller.value.aspectRatio : 16/9,
                    child: VideoPlayer(_controller),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
              if (_showOverlay)
                const Icon(Icons.play_circle_fill, size: 96, color: Colors.white70),
              Positioned(
                top: 24,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
