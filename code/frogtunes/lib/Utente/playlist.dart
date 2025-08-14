import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';  

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final List<Map<String, String>> playlists = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _caricaPlaylist();
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
          'name': doc['name'] as String
        }));
    });
  }

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
            // Pulsante Crea Playlist
            return GestureDetector(
              onTap: _creaPlaylist,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green.withOpacity(0.3),
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
            final playlistId = playlists[index - 1]['id']!;
            final playlistName = playlists[index - 1]['name']!;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PlaylistDetailsView(playlistId: playlistId, playlistName: playlistName),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.green,
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 50.0,
                    ),
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
        title: Text(playlistName),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: playlistRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Playlist non trovata", style: TextStyle(color: Colors.white)));
          }

          final playlistData = snapshot.data!.data() as Map<String, dynamic>;
          final canzoni = List<Map<String, dynamic>>.from(playlistData['canzoni'] ?? []);

          if (canzoni.isEmpty) {
            return const Center(child: Text("Nessuna canzone nella playlist", style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: canzoni.length,
            itemBuilder: (context, index) {
              final canzone = canzoni[index];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: Text(canzone['titolo'] ?? 'Titolo sconosciuto',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(canzone['artista'] ?? 'Artista sconosciuto',
                    style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(
                        canzoni: ['${canzone['titolo'] ?? 'Sconosciuto'}'],
                        nomeArtista: '${canzone['artista'] ?? 'Sconosciuto'}',
                        immagineArtista: 'https://via.placeholder.com/300x300', // URL della copertina
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
