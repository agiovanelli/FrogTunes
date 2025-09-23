import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:frogtunes/mini_player.dart';
import 'dart:async';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class PlaylistSettings{
  static Future<void> creaPlaylist() async{
    // Funzione vuota per evitare errori di riferimento
  }
}

class _PlaylistViewState extends State<PlaylistView> {
  final audio = AudioService();
  final List<Map<String, String>> playlists = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration?> _durationSub;

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

  Future<void> _caricaPlaylist() async {
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

  Future<void> creaPlaylist() async {
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
                    'canzoni': [],
                  });

                  // Aggiorna lista locale
                  setState(() {
                    playlists.add({'id': docRef.id, 'name': nuovaPlaylist});
                  });

                  Navigator.pop(context);
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
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('playlists')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('Nessuna playlist', style: TextStyle(color: Colors.white)),
          );
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 20.0,
            childAspectRatio: 1.0,
          ),
          // +1 per il pulsante "Crea playlist"
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Crea Playlist
              return GestureDetector(
                onTap: creaPlaylist,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.green.withOpacity(1),
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
              // Singola playlist
              final doc = docs[index - 1];
              final playlistId = doc.id;
              final playlistName = doc['name'] ?? 'Senza nome';

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

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Playlist eliminata")),
                          );
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
                    color: Colors.green.withOpacity(0.3),
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
          );
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
            onPressed: () async {
              final playlistSnapshot = await playlistRef.collection('canzoni').get();

              if (playlistSnapshot.docs.isNotEmpty) {
                final playlistUrls = playlistSnapshot.docs.map((doc) {
                  final data = doc.data();
                  return data['url'] as String? ?? '';
                }).where((url) => url.isNotEmpty).toList();

                if (playlistUrls.isNotEmpty) {
                  final audio = AudioService();
                  await audio.setPlaylist(playlistUrls);
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
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
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
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Nome playlist aggiornato")),
                            );
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
      body:Stack(
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
                    children: List.generate(artistNames.length, (index) {
                      final nome = artistNames[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerScreen(
                                songId: canzone['cid'],
                                titolo: canzone['titolo'],
                                artistId: artistIds,
                                cover: canzone['cover'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            index < artistNames.length - 1 ? "$nome, " : nome,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
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
