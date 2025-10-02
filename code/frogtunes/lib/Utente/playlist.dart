import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:frogtunes/mini_player.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class PlaylistSettings {
  static Future<void> creaPlaylist({
    required BuildContext context,
    required String uid,
    required Map<String, dynamic> canzone,
    required void Function(Map<String, String>) onPlaylistCreata,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
      String nuovaPlaylist = "";
        return AlertDialog(
          backgroundColor: const Color(0xFF041F0F),
          title: const Text(
            "Nuova Playlist",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nome playlist",
              hintStyle: TextStyle(color: Colors.white54),
            ),
            onChanged: (val) {
              nuovaPlaylist = val;
            },
          ),
          actions: [
            TextButton(
              child:
                  const Text("Annulla", style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (nuovaPlaylist.isNotEmpty) {
                  // Crea documento playlist
                  final docRef =
                      FirebaseFirestore.instance.collection('playlists').doc();

                  await docRef.set({
                    'pid': docRef.id,
                    'name': nuovaPlaylist,
                    'uid': uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'canzoni': [],
                  });

                  // Aggiungi la canzone subito alla nuova playlist
                  await docRef.collection('canzoni').add({
                    ...canzone,
                    'addedAt': FieldValue.serverTimestamp(),
                  });

                  if(context.mounted){
                    Navigator.pop(context);
                  }
  
                  onPlaylistCreata({
                    'id': docRef.id,
                    'name': nuovaPlaylist,
                  });
                  
                }
              },
              child: const Text("Crea"),
            ),
          ],
        );
      },
    );
  }
}

class _PlaylistViewState extends State<PlaylistView> {
  final audio = AudioService();
  final List<Map<String, String>> playlists = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Variabili per ascoltare i cambiamenti di posizione e durata
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration?> _durationSub;

  // Variabili per posizione e durata
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _caricaPlaylist();

    // Ascolta i cambiamenti di posizione e durata da qualsiasi punto
    _positionSub = audio.positionStream.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _durationSub = audio.durationStream.listen((d) {
      if (mounted && d != null) setState(() => duration = d);
    });
  }

  // Funzione per caricare le playlist
  Future<void> _caricaPlaylist() async {
    // Recupera le playlist che hanno lo stesso id dell'utente
    final snapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('uid', isEqualTo: uid)
        .get();

    setState(() {
      playlists.clear();
      playlists.addAll(snapshot.docs.map((doc) => {
          'id': doc.id, // ID documento Firestore
          'name': doc['name'] as String,
        }));
    });
  }

  // Funzione di creazione playlist
  Future<void> _creaPlaylist() async {
    showDialog(
      context: context,
      builder: (context) {
        String nuovaPlaylist = "";
        return AlertDialog(
          backgroundColor: const Color(0xFF041F0F),
          title: const Text(
            "Nuova Playlist",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nome playlist",
              hintStyle: TextStyle(color: Colors.white54),
            ),
            onChanged: (val) {
              nuovaPlaylist = val;
            },
          ),
          actions: [
            TextButton(
              child:
                  const Text("Annulla", style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (nuovaPlaylist.isNotEmpty) {
                  // Crea documento vuoto per ottenere l'ID
                  final docRef = FirebaseFirestore.instance.collection('playlists').doc();

                  // Salva dati con pid = doc.id
                  await docRef.set({
                    'pid': docRef.id,
                    'name': nuovaPlaylist,
                    'uid': uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // Aggiorna lista locale
                  setState(() {
                    playlists.add({'id': docRef.id, 'name': nuovaPlaylist});
                  });

                  if(context.mounted){
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Crea"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 20.0,
          childAspectRatio: 1.0,
        ),
        itemCount: playlists.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Crea Playlist
            return GestureDetector(
              onTap: _creaPlaylist,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green.withValues(alpha: 1),
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 50.0),
                    SizedBox(height: 10),
                    Text(
                      "Crea playlist",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Visualizzazione delle singole playlist
            final playlist = playlists[index - 1];
            final playlistId = playlist['id'] ?? '';
            final playlistName = playlist['name'] ?? 'Senza nome';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailsView(
                      playlistId: playlistId,
                      playlistName: playlistName,
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF041F0F),
                    title: const Text(
                      "Elimina playlist",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      "Sei sicuro di voler eliminare la playlist \"$playlistName\"?",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Annulla", style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('playlists')
                              .doc(playlistId)
                              .delete();
                          setState(() {
                            playlists.removeAt(index - 1);
                          });
                          if(context.mounted){
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Playlist eliminata")),
                            );
                          }
                        },
                        child: const Text("Elimina"),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green.withValues(alpha: 0.3),
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.queue_music, color: Colors.white, size: 40.0),
                    const SizedBox(height: 10),
                    Text(
                      playlistName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _durationSub.cancel();
    super.dispose();
  }
}

// Classe di visualizzazione interna della playlist
class PlaylistDetailsView extends StatelessWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistDetailsView({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();
    final playlistRef = FirebaseFirestore.instance.collection('playlists').doc(playlistId);
    
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: StreamBuilder<DocumentSnapshot>(
          stream: playlistRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("...");
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Text(data['name'] ?? 'Playlist');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            // Bottone per far partire tutte le canzoni presenti nella playlist
            onPressed: () async {
              final playlistSnapshot = await playlistRef.collection('canzoni').get();
              if (context.mounted) {
                if (playlistSnapshot.docs.isNotEmpty) {
                  // Recupera i nomi degli artisti per ogni canzone
                  final playlistUrls = <Map<String, dynamic>>[];
                  for (final doc in playlistSnapshot.docs) {
                    final artistIds = List<String>.from(doc['artistId'] ?? []);
                    final artistNames = await fetchArtistName(artistIds);
                    playlistUrls.add({
                      'songId': doc['cid'] ?? '',
                      'url': doc['url'] ?? '',
                      'title': doc['titolo'] ?? '',
                      'artistId': artistIds,
                      'artist': artistNames.join(', '),
                      'cover': doc['cover'] ?? '',
                    });
                  }
                  final filteredUrls = playlistUrls.where((track) => (track['url'] as String).isNotEmpty).toList();
                  if (filteredUrls.isNotEmpty) {
                    await audio.setPlaylist(filteredUrls);
                    await audio.play();
                  } else {
                    // Altrimenti comunica che è vuota
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("La playlist è vuota")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("La playlist è vuota")),
                  );
                }
              }
            },
          ),
          ValueListenableBuilder<LoopMode>(
            valueListenable: audio.loopModeNotifier,
            builder: (context, loopMode, _) {
              final isLoopActive = loopMode == LoopMode.all;
              return IconButton(
                icon: Icon(
                  isLoopActive ? Icons.repeat_one : Icons.repeat,
                  color: Colors.white,
                ),
                tooltip: isLoopActive ? 'Loop playlist attivo' : 'Loop playlist',
                onPressed: () async {
                  await audio.player.setLoopMode(
                    isLoopActive ? LoopMode.off : LoopMode.all
                  );
                  // Mostra un messaggio di conferma in fase di testing si tiene 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isLoopActive
                          ? "Loop playlist disattivato"
                          : "Loop playlist attivo: la playlist si ripete all'infinito"
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            // Bottone per modificare il nome della playlist
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String nuovoNome = playlistName;
                  return AlertDialog(
                    backgroundColor: const Color(0xFF041F0F),
                    title: const Text(
                      "Modifica nome",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Nome playlist",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      controller: TextEditingController(text: playlistName),
                      onChanged: (val) {
                        nuovoNome = val;
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Annulla", style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          if (nuovoNome.isNotEmpty) {
                            await playlistRef.update({'name': nuovoNome});
                            if(context.mounted){
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Nome playlist aggiornato")),
                              );
                            }
                          }
                        },
                        child: const Text("Salva"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: playlistRef.collection('canzoni').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Nessuna canzone nella playlist", style: TextStyle(color: Colors.white)));
              }

            final canzoni = snapshot.data!.docs.map((doc) {
              return doc.data() as Map<String, dynamic>;
            }).toList();
          return ListView.builder(
            itemCount: canzoni.length,
            itemBuilder: (context, index) {
              final canzone = canzoni[index];
              final List<String> artistIds = List<String>.from(canzone['artistId'] ?? []);

              return FutureBuilder<List<String>>(
                future: fetchArtistName(artistIds),
                builder: (context, snapshot) {
                  final artistNames = snapshot.data ?? ["Artista sconosciuto"];

                  return ListTile(
                    leading: Image.network(
                      canzone['cover'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(canzone['titolo'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: Wrap(
                      alignment: WrapAlignment.start,
                      children: List.generate(artistNames.length, (i) {
                        final nome = artistNames[i];
                        return GestureDetector(
                          onTap: () {
                            // Vai allo screen dell'artista
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistScreen(
                                  artistId: artistIds[i],
                                  nomeArtista: nome,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              i < artistNames.length - 1 ? "$nome, " : nome,
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ),
                        );
                      }),
                    ),
                    onTap: () async {
                      final playlistSnapshot = await playlistRef.collection('canzoni').get();

                      if (context.mounted) {
                        if (playlistSnapshot.docs.isNotEmpty) {
                          // Recupera i dati per ogni canzone
                          final playlistUrls = <Map<String, dynamic>>[];
                          for (final doc in playlistSnapshot.docs) {
                            final artistIds = List<String>.from(doc['artistId'] ?? []);
                            final artistNames = await fetchArtistName(artistIds);
                            playlistUrls.add({
                              'songId': doc['cid'] ?? '',
                              'url': doc['url'] ?? '',
                              'title': doc['titolo'] ?? '',
                              'artistId': artistIds,
                              'artist': artistNames.join(', '),
                              'cover': doc['cover'] ?? '',
                            });
                          }
                          final filteredUrls = playlistUrls.where((track) => (track['url'] as String).isNotEmpty).toList();
                          if (filteredUrls.isNotEmpty) {
                            // Trova l'indice della canzone selezionata nella lista filtrata
                            final selectedSongId = canzone['cid'] ?? '';
                            final selectedIndex = filteredUrls.indexWhere((track) => track['songId'] == selectedSongId);
                            int indexToPlay = 0;
                            if (selectedIndex != -1) {
                              indexToPlay = selectedIndex;
                            }
                            // Apri subito il PlayerScreen, poi avvia la riproduzione
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerScreen(
                                    songId: filteredUrls[indexToPlay]['songId'],
                                    titolo: filteredUrls[indexToPlay]['title'],
                                    artistId: List<String>.from(filteredUrls[indexToPlay]['artistId']),
                                    cover: filteredUrls[indexToPlay]['cover'],
                                  ),
                                ),
                              );
                            }
                            await audio.setPlaylist(filteredUrls, initialIndex: indexToPlay);
                            await audio.play();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("La playlist è vuota")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("La playlist è vuota")),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
          const Align(
                alignment: Alignment.bottomCenter,
                child: MiniPlayer(),
          ),
        ]
      ), 
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
