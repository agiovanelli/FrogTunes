import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Text('Le tue canzoni preferite',
                    style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            // Bottone per accedere alla schermata delle canzoni preferite
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LikedSongsScreen()),
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
                  children: const [
                    Icon(Icons.add_circle_outline_sharp, color: Colors.white, size: 50.0),
                    SizedBox(height: 10),
                    Text(
                      "Canzoni preferite",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Text('I tuoi artisti preferiti',
                    style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            // Bottone per accedere alla schermata degli artisti preferiti
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FollowedArtistsScreen()),
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
                  children: const [
                    Icon(Icons.music_note_outlined, color: Colors.white, size: 50.0),
                    SizedBox(height: 10),
                    Text(
                      "Artisti preferiti",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Text('I tuoi podcast preferiti',
                    style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const ListTile(
            leading: Icon(Icons.contactless, color: Colors.white),
            title: Text('Daily Cogito', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.contactless, color: Colors.white),
            title: Text('Grandi Linee', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}

// Classe per visualizzare le canzoni preferite dell'utente
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      appBar: AppBar(
        title: const Text("Brani che ti piacciono", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Recupera le canzoni preferite dell'utente dal Firestore
        stream: FirebaseFirestore.instance
            .collection('utenti')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('likedSongs')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final songs = snapshot.data!.docs;

          // Se non ci sono canzoni preferite, mostra un messaggio
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                "Non hai ancora messo mi piace a nessuna canzone",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final List<String> artistIds = List<String>.from(song['artistId'] ?? []);

              // Recupera i nomi degli artisti dato un elenco di ID
              return FutureBuilder<List<String>>(
                future: fetchArtistName(artistIds),
                builder: (context, snapshot) {
                  final artistNames = snapshot.data ?? ["Artista sconosciuto"];

                // Costruisce la lista delle canzoni preferite
                return ListTile(
                  leading: Image.network(
                    song['cover'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(song['titolo'], style: const TextStyle(color: Colors.white)),
                  subtitle: Wrap(
                    alignment: WrapAlignment.start,
                    children: List.generate(artistNames.length, (index) {
                      final nome = artistNames[index];

                      return GestureDetector(
                        // Bottone per accedere al player della canzone
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerScreen(
                                songId: song.id,
                                titolo: song['titolo'],
                                artistId: artistIds,
                                cover: song['cover'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          // Mostra i nomi degli artisti separati da una virgola se ce ne sono più di uno
                          child: Text(
                            index < artistNames.length - 1 ? "$nome, " : nome,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
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
    );
  }
}

// Classe per visualizzare gli artisti seguiti dall'utente
class FollowedArtistsScreen extends StatelessWidget {
  const FollowedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Artisti seguiti"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Recupera gli artisti seguiti dall'utente dal Firestore
        stream: FirebaseFirestore.instance
            .collection('utenti')
            .doc(uid)
            .collection('followedArtists')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se non ci sono artisti seguiti, mostra un messaggio
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Non segui ancora nessun artista",
                  style: TextStyle(color: Colors.white)),
            );
          }

          final artists = snapshot.data!.docs;

          // Costruisce la lista degli artisti seguiti
          return ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              final cover = artist['cover'] ?? 'https://via.placeholder.com/150';
              final nome = artist['nome'] ?? 'Artista sconosciuto';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(cover),
                ),
                title: Text(nome, style: const TextStyle(color: Colors.white)),
                // Bottone per accedere alla schermata dell'artista
                onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistScreen(
                                artistId: artist['uid'],
                                nomeArtista: nome,
                              ),
                            ),
                          );
                        },
              );
            },
          );
        },
      ),
    );
  }
}
