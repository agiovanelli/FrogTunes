// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/algolia_service.dart';
import 'package:algolia/algolia.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/AME/statistics.dart';

class AnalyticEView extends StatefulWidget {
  const AnalyticEView({super.key});

  @override
  AnalyticEViewState createState() => AnalyticEViewState();
}

class AnalyticEViewState extends State<AnalyticEView> {
  String _searchType = 'Canzoni'; // Valore di default
  final TextEditingController _analyticController = TextEditingController();
  List<Map<String, dynamic>> _analyticResults = [];
  final audio = AudioService();

  // Funzione per eseguire la ricerca su Algolia o Firestore in base al tipo selezionato
  void _performAnalytic(String query) async {
    if (_searchType == 'Artisti') {
      await _searchArtists(query);
    } else if(_searchType == 'Canzoni') {
      await _searchSongs(query);
    }else{
      await _searchManagers(query);
    }
  }

  // Funzione per cercare gli artisti su Firestore (da portare su algolia?)
  // Cerca solo artisti gestiti dai manager che gestisco
  Future<void> _searchArtists(String query) async {
    if (query.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    final etichettaId = FirebaseAuth.instance.currentUser?.uid;
    if (etichettaId == null) return;
    // Prendi manager gestiti da questa etichetta
    final managerSnap = await FirebaseFirestore.instance
      .collection('etichette')
      .doc(etichettaId)
      .collection('managers')
      .get();
    final managerIds = managerSnap.docs.map((doc) => doc.data()['uid']).toList();
    if (managerIds.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    // Prendi tutti gli artisti gestiti da questi manager
    final artistIdSet = <String>{};
    for (final managerId in managerIds) {
      final managedSnap = await FirebaseFirestore.instance
        .collection('manager')
        .doc(managerId)
        .collection('managedArtists')
        .get();
      for (final doc in managedSnap.docs) {
        final artistId = doc.data()['uid'];
        if (artistId != null) artistIdSet.add(artistId);
      }
    }
    if (artistIdSet.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    // Cerca solo tra questi artisti
    final snapshot = await FirebaseFirestore.instance
      .collection('artisti')
      .where('nome', isGreaterThanOrEqualTo: query)
      .where('nome', isLessThanOrEqualTo: query + '\uf8ff')
      .limit(20)
      .get();
    final results = snapshot.docs.where((doc) => artistIdSet.contains(doc.id)).map((doc) {
      final data = doc.data();
      return {
        'artistId': doc.id,
        'nome': data['nome'] ?? '',
        'profileImageUrl': data['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f',
      };
    }).toList();
    setState(() { _analyticResults = results; });
  }

  // Funzione per cercare le canzoni su Algolia filtrando per artisti gestiti dai manager che gestisci
  Future<void> _searchSongs(String query) async {
    if (query.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    try {
      final etichettaId = FirebaseAuth.instance.currentUser?.uid;
      if (etichettaId == null) return;
      // Prendi manager gestiti da questa etichetta
      final managerSnap = await FirebaseFirestore.instance
        .collection('etichette')
        .doc(etichettaId)
        .collection('managers')
        .get();
      final managerIds = managerSnap.docs.map((doc) => doc.data()['uid']).toList();
      if (managerIds.isEmpty) {
        setState(() { _analyticResults = []; });
        return;
      }
      // Prendi tutti gli artisti gestiti da questi manager
      final artistIdSet = <String>{};
      for (final managerId in managerIds) {
        final managedSnap = await FirebaseFirestore.instance
          .collection('manager')
          .doc(managerId)
          .collection('managedArtists')
          .get();
        for (final doc in managedSnap.docs) {
          final artistId = doc.data()['uid'];
          if (artistId != null) artistIdSet.add(artistId);
        }
      }
      if (artistIdSet.isEmpty) {
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
          'cover': data['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d',
        };
      }).where((song) {
        final songArtistIds = song['artistId'] as List<String>;
        return songArtistIds.any((id) => artistIdSet.contains(id));
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

  // Funzione per cercare i manager su Firestore (da portare su algolia?)
  // Cerca solo i manager con cui lavoro (nella subcollection managers)
  Future<void> _searchManagers(String query) async {
    if (query.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    final etichettaId = FirebaseAuth.instance.currentUser?.uid;
    if (etichettaId == null) return;
    final managerSnap = await FirebaseFirestore.instance
      .collection('etichette')
      .doc(etichettaId)
      .collection('managers')
      .get();
    final managerIds = managerSnap.docs.map((doc) => doc.data()['uid']).toList();
    if (managerIds.isEmpty) {
      setState(() { _analyticResults = []; });
      return;
    }
    // Cerca solo tra questi manager
    final snapshot = await FirebaseFirestore.instance
      .collection('manager')
      .where('nome', isGreaterThanOrEqualTo: query)
      .where('nome', isLessThanOrEqualTo: query + '\uf8ff')
      .limit(20)
      .get();
    final results = snapshot.docs.where((doc) => managerIds.contains(doc.id)).map((doc) {
      final data = doc.data();
      return {
        'managerId': doc.id,
        'nome': data['nome'] ?? '',
        'profileImageUrl': data['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f',
      };
    }).toList();
    setState(() { _analyticResults = results; });
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
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Manager', style: TextStyle(color: Colors.white)),
                  selected: _searchType == 'Manager',
                  selectedColor: Colors.green[700],
                  onSelected: (selected) {
                    setState(() { _searchType = 'Manager'; _analyticResults = []; _analyticController.clear(); });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _analyticController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: _searchType == 'Artisti' ? 'Cerca artista...' : _searchType == 'Canzoni' ? 'Cerca canzone...' : 'Cerca manager...',
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
                      builder: (context) => StatisticsPage(
                        artistId: item['artistId'] ?? '',
                        artistName: nome,
                      ),
                    ),
                  );
              },
              ),
            );
          } else if(_searchType == 'Canzoni') {
            final songId = item['songId'] ?? '';
            final titolo = item['titolo'] ?? 'Titolo sconosciuto';
            final artista = item['artista'] ?? 'Artista sconosciuto';
            final cover = item['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d';
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
                      builder: (context) => StatisticsPage(
                        songId: songId,
                      ),
                    ),
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
          }else{
            final nome = item['nome'] ?? 'Manager sconosciuto';
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
                      builder: (context) => StatisticsPage(
                        managerId: item['managerId'] ?? '',
                      ),
                    ),
                  );
              },
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
