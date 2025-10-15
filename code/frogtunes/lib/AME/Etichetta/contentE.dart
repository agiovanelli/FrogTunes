// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';

class HomeEContent extends StatelessWidget {
  const HomeEContent({super.key});

  // Recupera i nomi degli artisti dato una lista di artistIds
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


  // Recupera tutti i manager che lavorano per l'etichetta e per ciascun manager tutti gli artisti gestiti
  // Ottimizzata: recupera manager e artisti in parallelo
  Future<List<Map<String, dynamic>>> fetchManagersWithArtists() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final subcollection = await FirebaseFirestore.instance
      .collection('etichette')
      .doc(userId)
      .collection('managers')
      .orderBy('addedAt', descending: true)
      .get();

    final managerFutures = subcollection.docs.map((doc) async {
      final managerId = doc.data()['uid'];
      final managerDoc = await FirebaseFirestore.instance.collection('manager').doc(managerId).get();
      if (!managerDoc.exists) return null;
      final managerData = managerDoc.data() ?? {};
      // Recupera artisti gestiti da questo manager in parallelo
      final managedArtistsSnap = await FirebaseFirestore.instance
        .collection('manager')
        .doc(managerId)
        .collection('managedArtists')
        .orderBy('addedAt', descending: true)
        .get();
      final artistFutures = managedArtistsSnap.docs.map((artistDoc) async {
        final artistId = artistDoc.data()['uid'];
        final artistDataDoc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
        if (!artistDataDoc.exists) return null;
        final artistData = artistDataDoc.data() ?? {};
        return {
          'nome': artistData['nome'] ?? 'Artista sconosciuto',
          'addedAt': artistDoc.data()['addedAt'],
          'uid': artistId,
        };
      });
      final managedArtists = (await Future.wait(artistFutures)).whereType<Map<String, dynamic>>().toList();
      return {
        'nome': managerData['nome'] ?? 'Manager sconosciuto',
        'addedAt': doc.data()['addedAt'],
        'uid': managerId,
        'artists': managedArtists,
      };
    });
    final managers = (await Future.wait(managerFutures)).whereType<Map<String, dynamic>>().toList();
    return managers;
  }

  // Recupera tutti gli artisti gestiti da tutti i manager dell'etichetta
  Future<List<Map<String, dynamic>>> fetchAllManagedArtists() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final subcollection = await FirebaseFirestore.instance
      .collection('etichette')
      .doc(userId)
      .collection('managers')
      .orderBy('addedAt', descending: true)
      .get();

    final artists = <Map<String, dynamic>>[];
    for (var doc in subcollection.docs) {
      final managerId = doc.data()['uid'];
      final managedArtistsSnap = await FirebaseFirestore.instance
        .collection('manager')
        .doc(managerId)
        .collection('managedArtists')
        .orderBy('addedAt', descending: true)
        .get();
      for (var artistDoc in managedArtistsSnap.docs) {
        final artistId = artistDoc.data()['uid'];
        final artistDataDoc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
        if (artistDataDoc.exists) {
          final artistData = artistDataDoc.data() ?? {};
          artists.add({
            'nome': artistData['nome'] ?? 'Artista sconosciuto',
            'addedAt': artistDoc.data()['addedAt'],
            'uid': artistId,
            'managerId': managerId,
          });
        }
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
                child: const Center(
                  child: Text('I tuoi manager e i loro artisti',
                    style: TextStyle(fontSize: 26, color: Colors.white)),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchManagersWithArtists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nessun manager trovato", style: TextStyle(color: Colors.white)));
                  }
                  final managers = snapshot.data!;
                  return Column(
                    children: [
                      for (final manager in managers)
                        _ManagerCard(manager: manager)
                    ],
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

// Widget per card manager che si espande per mostrare gli artisti gestiti
class _ManagerCard extends StatefulWidget {
  final Map<String, dynamic> manager;
  const _ManagerCard({required this.manager});

  @override
  State<_ManagerCard> createState() => _ManagerCardState();
}

class _ManagerCardState extends State<_ManagerCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: expanded ? null : 65,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Card(
        color: Colors.green[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.manager['nome'] ?? 'Manager sconosciuto',
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: (widget.manager['artists'] as List).isEmpty
                      ? const Text('Nessun artista gestito', style: TextStyle(color: Colors.white70))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Artisti gestiti:', style: TextStyle(fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            ...((widget.manager['artists'] as List).map((artist) => Padding(
                              padding: const EdgeInsets.only(left: 12.0, bottom: 2.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistScreen(
                                        artistId: artist['uid'],
                                        nomeArtista: artist['nome'] ?? 'Artista sconosciuto',
                                        type: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  artist['nome'] ?? 'Artista sconosciuto',
                                  style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16),
                                ),
                              ),
                            )))
                          ],
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
