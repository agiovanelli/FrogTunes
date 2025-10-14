import 'package:flutter/material.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'package:frogtunes/AME/aggiungi_itv.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/algolia_service.dart';
import 'package:algolia/algolia.dart';
import 'package:frogtunes/AME/insight.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticMView extends StatefulWidget {
  const AnalyticMView({super.key});

  @override
  AnalyticMViewState createState() => AnalyticMViewState();
}

class AnalyticMViewState extends State<AnalyticMView> {
  String _searchType = 'Canzoni'; // Valore di default
  final TextEditingController _analyticController = TextEditingController();
  List<Map<String, dynamic>> _analyticResults = [];
  final audio = AudioService();

  // Funzione per eseguire la ricerca su Algolia o Firestore in base al tipo selezionato
  void _performAnalytic(String query) async {
    if (_searchType == 'Artisti') {
      await _searchArtists(query);
    } else {
      await _searchSongs(query);
    }
  }

  // Funzione per cercare gli artisti su Firestore (da portare su algolia?)
  Future<void> _searchArtists(String query) async {
    if (query.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('artisti')
        .where('nome', isGreaterThanOrEqualTo: query)
        .where('nome', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .get();
    final results = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'artistId': doc.id,
        'nome': data['nome'] ?? '',
        'cover': data['cover'] ?? 'https://via.placeholder.com/150',
      };
    }).toList();
    setState(() { _analyticResults = results; });
  }

  // Funzione per cercare le canzoni su Algolia filtrando per artisti gestiti
  Future<void> _searchSongs(String query) async {
    if (query.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    try {
      final managerId = FirebaseAuth.instance.currentUser?.uid;
      if (managerId == null) return;
      final subcollection = await FirebaseFirestore.instance
        .collection('manager')
        .doc(managerId)
        .collection('managedArtists')
        .get();

      final artistIds = subcollection.docs.map((doc) => doc.data()['uid']).toList();
      if (artistIds.isEmpty) {
        setState(() { _analyticResults = []; });
        return;
      }
      final AlgoliaQuery algoliaQuery = AlgoliaService.instance
          .index('canzoni')
          .query(query)
          .setHitsPerPage(20);

      final AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();
      List<Map<String, dynamic>> results = snapshot.hits.map((hit) {
        final data = hit.data;
        final artistIdRaw = data['artistId'];
        final List<String> artistId = artistIdRaw is List ? List<String>.from(artistIdRaw) : [artistIdRaw?.toString() ?? ''];
        return {
          'songId': data['cid'] ?? '',
          'titolo': data['titolo'] ?? '',
          'artistId': artistId,
          'audioUrl': data['audioUrl'] ?? '',
          'cover': data['cover'] ?? 'https://via.placeholder.com/150',
        };
      }).where((song) {
        final songArtistIds = song['artistId'] as List<String>;
        return songArtistIds.any((id) => artistIds.contains(id));
      }).toList();

      for (var item in results) {
        final List<String> artistId = List<String>.from(item['artistId'] ?? []);
        if (artistId.isEmpty) {
          item['artista'] = 'Artista sconosciuto';
          continue;
        }
        final futures = artistId.map((id) =>
            FirebaseFirestore.instance.collection('artisti').doc(id).get());
        final docs = await Future.wait(futures);
        final artistNames = <String>[];
        for (final doc in docs) {
          if (doc.exists) {
            artistNames.add(doc['nome'] ?? 'Sconosciuto');
          }
        }
        item['artista'] =
            artistNames.isNotEmpty ? artistNames.join(', ') : 'Artista sconosciuto';
      }
      setState(() { _analyticResults = results; });
    } catch (e) {
      debugPrint('Errore nella ricerca Algolia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Canzoni', style: TextStyle(color: Colors.white)),
                  selected: _searchType == 'Canzoni',
                  selectedColor: Colors.green[700],
                  onSelected: (selected) {
                    setState(() { _searchType = 'Canzoni'; _analyticResults = []; _analyticController.clear(); });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Artisti', style: TextStyle(color: Colors.white)),
                  selected: _searchType == 'Artisti',
                  selectedColor: Colors.green[700],
                  onSelected: (selected) {
                    setState(() { _searchType = 'Artisti'; _analyticResults = []; _analyticController.clear(); });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _analyticController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: _searchType == 'Artisti' ? 'Cerca artista...' : 'Cerca canzone...',
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
                  onPressed: () {
                    _analyticController.clear();
                    setState(() { _analyticResults = []; });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: _performAnalytic,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _analyticResults.length,
        itemBuilder: (context, index) {
          final item = _analyticResults[index];
          if (_searchType == 'Artisti') {
            final nome = item['nome'] ?? 'Artista sconosciuto';
            final cover = item['cover'] ?? 'https://via.placeholder.com/150';
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
                    cover,
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
                      builder: (context) => ArtistScreen(
                        artistId: item['artistId'],
                        nomeArtista: nome,
                        control: true,
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
            final cover = item['cover'] ?? 'https://via.placeholder.com/150';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: Colors.green[900],
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongInsightPage(
                        songId: songId,
                        managed: true,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Modifica release'),
                        content: const Text('Vuoi apportare delle modifiche alla release?'),
                        actions: [
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Sì'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModificaCanzonePage(
                                    canzone: item,
                                    canzoneId: songId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
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
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _analyticController.dispose();
    super.dispose();
  }
}
