import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/aggiungiPC.dart';
import 'package:algolia/algolia.dart';
import 'package:frogtunes/algolia_service.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final AlgoliaQuery algoliaQuery = AlgoliaService.instance
          .index('canzoni') // Nome dell’indice su Algolia
          .query(query)
          .setHitsPerPage(20);

      final AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();

      List<Map<String, dynamic>> results = snapshot.hits.map((hit) {
      final data = hit.data;
      final List<String> artistId = List<String>.from(data['artistId'] ?? []);

      return {
        'songId': data['cid'] ?? '',
        'titolo': data['titolo'] ?? '',
        'artistId': artistId,
        'cover': data['cover'] ?? 'https://via.placeholder.com/150',
      };
    }).toList();

    for (var item in results) {
      List<String> artistId = List<String>.from(item['artistId'] ?? []);
      List<String> artistNames = [];

      for (String id in artistId) {
        final doc = await FirebaseFirestore.instance
            .collection('artisti')
            .doc(id)
            .get();
        if (doc.exists) {
          artistNames.add(doc['nome'] ?? 'Sconosciuto');
        }
      }

      item['artista'] = artistNames.isNotEmpty
          ? artistNames.join(', ')
          : 'Artista sconosciuto';
    }

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Errore nella ricerca Algolia: $e');
    }
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
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            onChanged: _performSearch,
          ),
        ),
      ),
      body: ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final songId = item['songId'] ?? '';
        final titolo = item['titolo'] ?? 'Titolo sconosciuto';
        final artista = item['artista'] ?? 'Artista sconosciuto';
        final cover = item['cover'] ?? 'https://via.placeholder.com/150';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          color: Colors.green[900],
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onTap: () {
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
            },
            // Pressione lunga → aggiungi a playlist o alla coda
            onLongPress: () {
              showSongOptionsBottomSheet(
                context: context,
                titolo: titolo,
                artista: artista,
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
            title: Text(
              titolo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              artista,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
              onPressed: () {
                print('Play: $titolo');
                // Qui in futuro: riproduzione audio
              },
            ),
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _searchController.clear();
          setState(() {
            _searchResults = [];
          });
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.clear, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
