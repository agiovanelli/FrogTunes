// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeAContent extends StatelessWidget {
  Future<List<String>> fetchArtistNames(List<dynamic> artistIds) async {
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
  const HomeAContent({super.key});

  Future<List<Map<String, dynamic>>> _fetchReleaseData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final query = await FirebaseFirestore.instance
    .collection('canzoni')
    .where('artistId', arrayContains: userId)
    .orderBy('addedAt', descending: true)
    .get();

    final canzoni = query.docs.map((doc) => doc.data()).toList();
    return canzoni;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchReleaseData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: const Center(
                                  child: Text('Singoli', style: TextStyle(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('0', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: const Center(
                                  child: Text('Album', style: TextStyle(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('0', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  final canzoni = snapshot.data!;
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  int singoliCount = canzoni.where((c) => (c['artistId'] as List).contains(userId)).length;
                  final albumMap = <String, int>{};
                  for (var c in canzoni) {
                    final albumName = (c['album'] ?? '').toString().trim();
                    if (albumName.isNotEmpty) {
                      albumMap[albumName] = (albumMap[albumName] ?? 0) + 1;
                    }
                  }
                  int albumCount = albumMap.values.where((count) => count >= 2).length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: const Center(
                                child: Text('Singoli', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(singoliCount.toString(), style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: const Center(
                                child: Text('Album', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(albumCount.toString(), style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Center(
                  child: Text('Le tue ultime release',
                    style: TextStyle(fontSize: 26, color: Colors.white)),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchReleaseData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nessuna release trovata", style: TextStyle(color: Colors.white)));
                  }
                  final canzoni = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: canzoni.length,
                    itemBuilder: (context, index) {
                      final canzone = canzoni[index];
                      return FutureBuilder<List<String>>(
                        future: fetchArtistNames(canzone['artistId']),
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
            ],
          ),
        ),
      ],
    );
  }
}
