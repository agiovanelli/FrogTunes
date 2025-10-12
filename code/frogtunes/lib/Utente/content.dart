import 'package:flutter/material.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:frogtunes/aggiungi_pc.dart';
import 'package:frogtunes/player_screen.dart';

import 'playlist.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();
    final recentPlayedRef = FirebaseFirestore.instance.collection('utenti').doc(FirebaseAuth.instance.currentUser!.uid);

    return ListView(
      // Contenuto della schermata principale dell'utente, mostra le ultime canzoni ascoltate e le playlist
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Ultime canzoni ascoltate',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              const SizedBox(height: 5),
              StreamBuilder<QuerySnapshot>(
                stream: recentPlayedRef
                  .collection('recentlyPlayed')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nessuna canzone ascoltata di recente", style: TextStyle(color: Colors.white)));
                }

              final canzoni = snapshot.data!.docs.map((doc) {
                return doc.data() as Map<String, dynamic>;
              }).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                                    type: false,
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
                        final recentPlayedSnapshot = await recentPlayedRef.collection('recentlyPlayed').get();

                        if (context.mounted) {
                          if (recentPlayedSnapshot.docs.isNotEmpty) {
                            // Recupera i dati per ogni canzone
                            final playlistUrls = <Map<String, dynamic>>[];
                            for (final doc in recentPlayedSnapshot.docs) {
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
                            }
                          }
                        }
                      },
                      onLongPress: () {
                        showSongOptionsBottomSheet(
                          context: context,
                          audioUrl: canzone['audioUrl'],
                          songId: canzone['cid'],
                          titolo: canzone['titolo'],
                          artistId: List<String>.from(canzone['artistId'] ?? []),
                          artist: artistNames.join(', '),
                          cover: canzone['cover'] ?? '',
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
              const SizedBox(height: 10),
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Le tue playlist',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              const SizedBox(height: 5),
              SizedBox(
                height: 500,
                // Mostra la vista delle playlist
                child: PlaylistView(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
