import 'package:flutter/material.dart';
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/aggiungi_pc.dart';
import 'package:algolia/algolia.dart';
import 'package:frogtunes/algolia_service.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  SearchViewState createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final audio = AudioService();

  // Funzione per eseguire la ricerca su Algolia (canzoni + artisti)
  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    List<Map<String, dynamic>> results = [];
    try {
      // Ricerca artisti
      final AlgoliaQuery artistQuery = AlgoliaService.instance
          .index('artisti')
          .query(query)
          .setHitsPerPage(20);
      final AlgoliaQuerySnapshot artistSnap = await artistQuery.getObjects();
      List<Map<String, dynamic>> artistResults = artistSnap.hits.map((hit) {
        final data = hit.data;
        return {
          'type': 'artist',
          'artistId': data['objectID'] ?? '',
          'nome': data['nome'] ?? '',
          'profileImageUrl': data['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f',
        };
      }).toList();
      results.addAll(artistResults);

      // Ricerca canzoni
      final AlgoliaQuery songQuery = AlgoliaService.instance
          .index('canzoni')
          .query(query)
          .setHitsPerPage(20);

      final AlgoliaQuerySnapshot songSnap = await songQuery.getObjects();
      List<Map<String, dynamic>> songResults = songSnap.hits.map((hit) {
        final data = hit.data;
        final List<String> artistId = List<String>.from(data['artistId'] ?? []);
        // Gestione robusta del campo artista
        var artistaRaw = data['artista'];
        String artista;
        if (artistaRaw is List) {
          artista = artistaRaw.join(', ');
        } else if (artistaRaw is String) {
          artista = artistaRaw;
        } else {
          artista = '';
        }
        return {
          'type': 'song',
          'songId': data['cid'] ?? '',
          'titolo': data['titolo'] ?? '',
          'artistId': artistId,
          'audioUrl': data['audioUrl'] ?? '',
          'cover': data['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d',
          'artista': artista,
        };
      }).toList();
      results.addAll(songResults);

    } catch (e) {
      debugPrint('Errore nella ricerca Algolia: $e');
    }
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Cerca',
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 18),
              filled: true,
              fillColor: Colors.green[700],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                // Bottone per cancellare il testo della ricerca
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            onChanged: _performSearch,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              if (item['type'] == 'artist') {
                final nome = item['nome'] ?? 'Artista sconosciuto';
                final artistId = item['artistId'] ?? '';
                final profileImageUrl = item['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  color: Colors.green[900],
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        profileImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 40, color: Colors.white);
                        },
                      ),
                    ),
                    title: Text(
                      nome,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Vai alla schermata dell'artista al cliccando sul nome
                      builder: (context) => ArtistScreen(
                        artistId: artistId,
                        nomeArtista: nome,
                      ),
                    ),
                  );
                    },
                  ),
                );
              } else {
                final songId = item['songId'] ?? '';
                final titolo = item['titolo'] ?? 'Titolo sconosciuto';
                final artista = item['artista'] ?? 'Artista sconosciuto';
                final cover = item['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d';
                final audioUrl = item['audioUrl'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  color: Colors.green[900],
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    // Bottone per aprire il player e riprodurre la canzone
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            songId: songId,
                            titolo: titolo,
                            artistId: item['artistId'] ?? [],
                            cover: cover,
                          ),
                        ),
                      );

                      if (audioUrl == null || audioUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio non disponibile')),
                        );
                        return;
                      }
                      
                      await audio.playSong(
                        songId: songId,
                        url: audioUrl,
                        title: titolo,
                        artist: artista,
                        artistId: item['artistId'] ?? [],
                        cover: cover,
                      );
                    },
                    // Bottone per mostrare il bottom sheet con opzioni aggiuntive di aggiunta a coda o a playlist
                    onLongPress: () {
                      showSongOptionsBottomSheet(
                        context: context,
                        audioUrl: audioUrl,
                        songId: songId,
                        titolo: titolo,
                        artistId: item['artistId'] ?? [],
                        artist: artista,
                        cover: cover,
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cover,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.music_note, size: 40, color: Colors.white);
                        },
                      ),
                    ),
                    // Rappresentazione del title, artista e bottone di play/pause
                    title: Text(
                      titolo,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      artista,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ValueListenableBuilder<String>(
                      valueListenable: audio.currentSongId,
                      builder: (context, currentId, _) {
                        // Stream per lo stato di riproduzione
                        return StreamBuilder(
                          stream: audio.stateStream,
                          builder: (context, snapshot) {
                            final playing =
                                (snapshot.data != null && snapshot.data is PlayerState)
                                    ? (snapshot.data as PlayerState).playing
                                    : false;

                            final isThisSongPlaying = (currentId == songId) && playing;

                            return IconButton(
                              icon: Icon(
                                isThisSongPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                              // La pressione sul bottone attiva o interrompre la riproduzione della canzone
                              onPressed: () async {
                                if (audioUrl == null || audioUrl.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Audio non disponibile')),
                                  );
                                  return;
                                }
                                // Controlla se la canzone in riproduzione è quella selezionata, se lo è mette in pausa o riprende 
                                if (currentId == songId) {
                                  if (playing) {
                                    await audio.pause();
                                  } else {
                                    await audio.play();
                                  }
                                } else {
                                  // Se è diversa fa partire la riproduzione (imposta playlist da 1)
                                  await audio.playSong(
                                    songId: songId,
                                    url: audioUrl,
                                    title: titolo,
                                    artist: artista,
                                    artistId: item['artistId'] ?? [],
                                    cover: cover,
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
