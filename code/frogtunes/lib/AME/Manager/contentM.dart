import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
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

  // Recupera gli artisti gestiti dall'utente manager
  Future<List<Map<String, dynamic>>> _fetchManagedArtists() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final subcollection = await FirebaseFirestore.instance
      .collection('manager')
      .doc(userId)
      .collection('managedArtists')
      .orderBy('addedAt', descending: true)
      .get();

    final artists = <Map<String, dynamic>>[];
    for (var doc in subcollection.docs) {
      final artistId = doc.data()['uid'];
      final artistDoc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
      if (artistDoc.exists) {
        final artistData = artistDoc.data() ?? {};
        artists.add({
          'nome': artistData['nome'] ?? 'Artista sconosciuto',
          'addedAt': doc.data()['addedAt'],
          'uid': artistId,
        });
      }
    }
    return artists;
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text('I tuoi artisti',
                        style: TextStyle(fontSize: 26, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchManagedArtists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nessun artista gestito', style: TextStyle(color: Colors.white)));
                  }
                  final artists = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return ListTile(
                        leading: const Icon(Icons.person_2_sharp, color: Colors.white),
                        title: Text(artist['nome'], style: const TextStyle(color: Colors.white)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistScreen(
                                artistId: artist['uid'],
                                nomeArtista: artist['nome'],
                                control: true,
                              ),
                            ),
                          );
                          setState(() {}); // Refresh dopo ritorno
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 50),
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
