import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'package:frogtunes/aggiungi_pc.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:frogtunes/mini_player.dart';

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
    final audio = AudioService();
    final likedSongRef = FirebaseFirestore.instance.collection('utenti').doc(FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      appBar: AppBar(
        title: const Text("Brani che ti piacciono", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            // Bottone per far partire tutte le canzoni presenti nella playlist
            onPressed: () async {
              final likedSongsSnapshot = await likedSongRef.collection('likedSongs').get();
              if (context.mounted) {
                if (likedSongsSnapshot.docs.isNotEmpty) {
                  // Recupera i nomi degli artisti per ogni canzone
                  final songsUrls = <Map<String, dynamic>>[];
                  for (final doc in likedSongsSnapshot.docs) {
                    final artistIds = List<String>.from(doc['artistId'] ?? []);
                    final artistNames = await fetchArtistName(artistIds);
                    songsUrls.add({
                      'songId': doc['cid'] ?? '',
                      'url': doc['audioUrl'] ?? '',
                      'title': doc['titolo'] ?? '',
                      'artistId': artistIds,
                      'artist': artistNames.join(', '),
                      'cover': doc['cover'] ?? '',
                    });
                  }
                  final filteredUrls = songsUrls.where((track) => (track['url'] as String).isNotEmpty).toList();
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
        ],
      ),
      body: Stack(
        children: [
      StreamBuilder<QuerySnapshot>(
        // Recupera le canzoni preferite dell'utente dal Firestore
        stream: FirebaseFirestore.instance
            .collection('utenti')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('likedSongs')
            .orderBy('addedAt', descending: false)
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
                              builder: (context) => ArtistScreen(
                                  artistId: artistIds[index],
                                  nomeArtista: nome,
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
                  onTap: () async {
                      final likedSongsSnapshot = await likedSongRef.collection('likedSongs').get();

                      if (context.mounted) {
                        if (likedSongsSnapshot.docs.isNotEmpty) {
                          // Recupera i dati per ogni canzone
                          final playlistUrls = <Map<String, dynamic>>[];
                          for (final doc in likedSongsSnapshot.docs) {
                            final artistIds = List<String>.from(doc['artistId'] ?? []);
                            final artistNames = await fetchArtistName(artistIds);
                            playlistUrls.add({
                              'songId': doc['cid'] ?? '',
                              'url': doc['audioUrl'] ?? '',
                              'title': doc['titolo'] ?? '',
                              'artistId': artistIds,
                              'artist': artistNames.join(', '),
                              'cover': doc['cover'] ?? '',
                            });
                          }
                          final filteredUrls = playlistUrls.where((track) => (track['url'] as String).isNotEmpty).toList();
                          if (filteredUrls.isNotEmpty) {
                            // Trova l'indice della canzone selezionata nella lista filtrata
                            final selectedSongId = song['cid'] ?? '';
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
                          }
                        }
                      }
                  },
                        onLongPress: () {
                          showSongOptionsBottomSheet(
                            context: context,
                            audioUrl: song['audioUrl'],
                            songId: song['cid'],
                            titolo: song['titolo'],
                            artistId: List<String>.from(song['artistId'] ?? []),
                            artist: artistNames.join(', '),
                            cover: song['cover'] ?? '',
                          );
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
        ],
      )
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
      body: Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
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
          const Align(
                  alignment: Alignment.bottomCenter,
                  child: MiniPlayer(),
            ),
        ],
      ) 
    );
  }
}
