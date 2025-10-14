import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/AME/aggiungi_itv.dart';
import 'package:flutter/material.dart';

class HomeMContent extends StatefulWidget {
  const HomeMContent({Key? key}) : super(key: key);

  @override
  State<HomeMContent> createState() => _HomeMContentState();
}

class _HomeMContentState extends State<HomeMContent> {
  // Recupera i nomi degli artisti dato una lista di artistIds
  Future<List<String>> _fetchArtistNames(List<dynamic> artistIds) async {
    if (artistIds.isEmpty) return [];
    final firestore = FirebaseFirestore.instance;
    final futures = artistIds.map((id) async {
      final doc = await firestore.collection('artisti').doc(id).get();
      if (doc.exists && doc.data() != null && doc.data()!['nome'] != null) {
        return doc.data()!['nome'] as String;
      }
      return 'Artista sconosciuto';
    });
    return Future.wait(futures);
  }

  // Recupera le ultime canzoni rilasciate dagli artisti gestiti
  Future<List<Map<String, dynamic>>> _fetchLatestReleases() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    
    final subcollection = await FirebaseFirestore.instance
      .collection('manager')
      .doc(userId)
      .collection('managedArtists')
      .get();

    final artistIds = subcollection.docs.map((doc) => doc.data()['uid']).toList();
    if (artistIds.isEmpty) return [];

    List<Map<String, dynamic>> allSongs = [];
    final Set<String> seenIds = {};
    for (final id in artistIds) {
      final query = await FirebaseFirestore.instance
        .collection('canzoni')
        .where('artistId', arrayContains: id)
        .orderBy('addedAt', descending: true)
        .limit(10)
        .get();
      for (var doc in query.docs) {
        final data = doc.data();
        final cid = data['cid']?.toString() ?? doc.id;
        if (!seenIds.contains(cid)) {
          seenIds.add(cid);
          allSongs.add(data);
        }
      }
    }
    // Ordina tutte le canzoni per data e prendi le ultime 10
    allSongs.sort((a, b) {
      final aDate = a['addedAt'] is Timestamp ? a['addedAt'].millisecondsSinceEpoch : 0;
      final bDate = b['addedAt'] is Timestamp ? b['addedAt'].millisecondsSinceEpoch : 0;
      return bDate.compareTo(aDate);
    });
    return allSongs.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                  child: Text('Ultime release dei tuoi artisti',
                    style: TextStyle(fontSize: 26, color: Colors.white)),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchLatestReleases(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nessuna release trovata', style: TextStyle(color: Colors.white)));
                  }
                  final releases = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: releases.length,
                    itemBuilder: (context, index) {
                      final canzone = releases[index];
                      // final titolo = canzone['titolo'] ?? '';
                      // final artisti = canzone['artistId'] is List ? canzone['artistId'] : [canzone['artistId']];
                      return FutureBuilder<List<String>>(
                        future: _fetchArtistNames(canzone['artistId']),
                        builder: (context, artistSnapshot) {
                          final artistNames = artistSnapshot.data ?? [];
                          return ListTile(
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
                                    canzone: canzone,
                                    canzoneId: canzone['cid']?.toString() ?? '',
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
                            leading: const Icon(Icons.music_note, color: Colors.white),
                            title: Text(canzone['titolo'] ?? '', style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              artistNames.isNotEmpty
                                  ? artistNames.join(', ')
                                  : 'Artista sconosciuto',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
