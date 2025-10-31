import 'package:flutter/material.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/algolia_service.dart';
import 'package:algolia/algolia.dart';
import 'package:frogtunes/AME/insight.dart';
import 'package:frogtunes/AME/aggiungi_itv.dart';


class AnalyticView extends StatefulWidget {
  const AnalyticView({super.key});

  @override
  AnalyticViewState createState() => AnalyticViewState();
}

class AnalyticViewState extends State<AnalyticView> {
  final TextEditingController _analyticController = TextEditingController();
  List<Map<String, dynamic>> _analyticResults = [];
  final audio = AudioService();

  // Funzione per eseguire la ricerca su Algolia
  void _performAnalytic(String query) async {
    if (query.isEmpty) {
      setState(() {
        _analyticResults = [];
      });
      return;
    }

    // Recupera tramite query su Algolia in modo dinamico
    try {
      final AlgoliaQuery algoliaQuery = AlgoliaService.instance
          .index('canzoni')
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
          'audioUrl': data['audioUrl'] ?? '',
          'cover': data['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d',
        };
      }).toList();

      // Per ogni risultato, recupera i nomi degli artisti in parallelo
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

      setState(() {
        _analyticResults = results;
      });
    } catch (e) {
      // Stampa l'errore in console (meglio gestire anche con UI)
      debugPrint('Errore nella ricerca Algolia: $e');
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
            controller: _analyticController,
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
                  _analyticController.clear();
                  setState(() {
                    _analyticResults = [];
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            onChanged: _performAnalytic,
          ),
        ),
      ),
      body: ListView.builder(
            itemCount: _analyticResults.length,
            itemBuilder: (context, index) {
              final item = _analyticResults[index];
              final songId = item['songId'] ?? '';
              final titolo = item['titolo'] ?? 'Titolo sconosciuto';
              final artista = item['artista'] ?? 'Artista sconosciuto';
              final cover = item['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d';

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
                        builder: (context) => SongInsightPage(
                          songId: songId,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.green[900],
                        title: const Text('Modifica release',
                          style: TextStyle(color: Colors.white)
                        ),
                        content: const Text('Vuoi apportare delle modifiche alla release?'),
                        actions: [
                          TextButton(
                            child: const Text('No',
                              style: TextStyle(color: Colors.white)
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Sì',
                              style: TextStyle(color: Colors.white)
                            ),
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
                  // Rappresentazione del title, artista
                  title: Text(
                    titolo,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    artista,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
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
