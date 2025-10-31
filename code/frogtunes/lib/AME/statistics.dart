import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/player_screen.dart';

// Dummy data models
class Song {
  final String songId;
  final String title;
  final List<String> artistNames;
  final int totalPlays;
  final int playsLast24h;
  final String cover;

  Song({
    required this.songId,
    this.title = '',
    this.artistNames = const [],
    this.totalPlays = 0,
    this.playsLast24h = 0,
    this.cover = '',
  });

  Future<Song> fetchSongDetails() async {
    final songDoc = await FirebaseFirestore.instance
        .collection('canzoni')
        .doc(songId)
        .get();

    if (!songDoc.exists) {
      throw Exception("Canzone non trovata");
    }

    final songData = songDoc.data()!;
    final totalPlays = songData['ascoltiTotali'] ?? 0;
    final artistId = (songData['artistId'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final cover = songData['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d';

    // Calcolo ascolti ultime 24 ore
    final last24h = DateTime.now().subtract(const Duration(hours: 24));
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('eventiAscolto')
        .where('cid', isEqualTo: songId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(last24h))
        .get();

    final playsLast24h = eventsSnapshot.docs.length;

    final artistNames = await fetchArtistName((artistId as List<dynamic>? ?? []).map((e) => e.toString()).toList());

    return Song(
      songId: songId,
      title: songData['titolo'] ?? 'Senza titolo',
      artistNames: artistNames,
      totalPlays: totalPlays,
      playsLast24h: playsLast24h,
      cover: cover,
    );
  }

  double get earnings => totalPlays * 0.005; // esempio: 0.005€ per stream
}

class Artist {
  final String artistName;
  final String artistId;
  
  Artist({
    required this.artistName,
    required this.artistId,
  });

  Future<List<Song>> fetchArtistSongs() async {
    if (artistId.isEmpty) return [];
    final songsSnap = await FirebaseFirestore.instance
      .collection('canzoni')
      .where('artistId', arrayContains: artistId)
      .get();

    final songList = <Song>[];
    for (final doc in songsSnap.docs) {
      final songId = doc.id;
      if (songId.trim().isEmpty) continue; // Salta songId null/vuoti
      try {
        final song = await Song(songId: songId).fetchSongDetails();
        songList.add(song);
      } catch (e) {
        continue;
      }
    }

    return songList;
  }

  // double get totalEarnings =>
  //     songs.fold(0, (sum, song) => sum + song.earnings);
}

class Manager {
  final String managerId;

  Manager({
    required this.managerId
    });

  Future<Map<String, dynamic>> fetchManagerData() async {
    final managerDoc = await FirebaseFirestore.instance.collection('manager').doc(managerId).get();
    if (!managerDoc.exists) throw Exception('Manager non trovato');
    final managerData = managerDoc.data()!;
    final nome = managerData['nome'] ?? 'Manager sconosciuto';
    final profileImageUrl = managerData['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d';
    // Prendi tutti gli artisti gestiti
    final managedSnap = await FirebaseFirestore.instance
      .collection('manager')
      .doc(managerId)
      .collection('managedArtists')
      .get();
    final artistIds = managedSnap.docs.map((doc) => doc.data()['uid'] as String).where((id) => id.isNotEmpty).toList();
    // Prendi tutte le canzoni degli artisti gestiti
    final songFutures = artistIds.map((artistId) async {
      final songsSnap = await FirebaseFirestore.instance
        .collection('canzoni')
        .where('artistId', arrayContains: artistId)
        .get();
      return songsSnap.docs.map((doc) => Song(songId: doc.id)).toList();
    });
    final songLists = await Future.wait(songFutures);
    final allSongs = songLists.expand((list) => list).toList();
    // Calcola guadagno totale
    double totalEarnings = 0;
    for (final song in allSongs) {
      try {
        final details = await song.fetchSongDetails();
        totalEarnings += details.earnings;
      } catch (_) {}
    }
    // Prendi dati artisti
    final artistFutures = artistIds.map((artistId) async {
      final artistDoc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
      if (!artistDoc.exists) return null;
      final artistData = artistDoc.data()!;
      return {
        'artistId': artistId,
        'nome': artistData['nome'] ?? 'Artista sconosciuto',
        'profileImageUrl': artistData['profileImageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/covers%2Fdefault.jpg?alt=media&token=8c008540-b5b4-4290-8512-b7085474321d',
      };
    });
    final artists = (await Future.wait(artistFutures)).whereType<Map<String, dynamic>>().toList();
    return {
      'nome': nome,
      'profileImageUrl': profileImageUrl,
      'totalEarnings': totalEarnings,
      'artists': artists,
    };
  }
}

class StatisticsPage extends StatefulWidget {
  final String artistName;
  final String artistId;
  final String managerId;
  final String songId;

  const StatisticsPage({
    super.key,
    this.artistName = '',
    this.artistId = '',
    this.managerId = '',
    this.songId = '',
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

enum StatView { song, artist, manager }

class _StatisticsPageState extends State<StatisticsPage> {
  StatView selectedView = StatView.song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        title: Text('Statistiche'),
        backgroundColor: const Color.fromARGB(255, 24, 96, 26),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder (
              builder: (context) {
                if(widget.songId.isNotEmpty){
                  return SongListView(
                      songId: widget.songId,
                    );
                }else if(widget.artistId.isNotEmpty && widget.artistName.isNotEmpty){
                  return ArtistListView(
                      artistId: widget.artistId,
                      artistName: widget.artistName,
                    );
                }else{
                  return ManagerListView(
                      managerId: widget.managerId,
                    );
                }
              },
            ),
          ),
        ]
      ),
    );
  }
}

// Song view
class SongListView extends StatelessWidget {
  final String songId;

  const SongListView({
    super.key,
    required this.songId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Song>(
      future: Song(songId: songId).fetchSongDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Canzone non trovata'));
        }
        final song = snapshot.data!;
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Image.network(song.cover, width: 160, height: 160)),
                      const SizedBox(height: 24),
                      Text('Titolo: ${song.title}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Artista: ${song.artistNames.join(', ')}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 12),
                      Text('Stream totali: ${song.totalPlays}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Stream 24h: ${song.playsLast24h}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Guadagno: €${song.earnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            //),
          ],
        );
      },
    );
  }
}

// Artist view
class ArtistListView extends StatelessWidget {
  final String artistId;
  final String artistName;

  const ArtistListView({
    super.key,
    required this.artistId,
    required this.artistName,
  });


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: Artist(artistId: artistId, artistName: artistName).fetchArtistSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessuna canzone trovata per questo artista'));
        }
        final songs = snapshot.data!;
        final totalEarnings = songs.fold<double>(0, (somma, song) => somma + song.earnings);
        final cover = songs.first.cover;
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                color: Colors.green[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(cover),
                        radius: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(artistName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Guadagno totale: €${totalEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            ...songs.map((song) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Card(
                color: Colors.green[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: Image.network(song.cover, width: 50, height: 50),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  trailing: Text('€${song.earnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(
                          songId: song.songId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ))
          ],
        );
      },
    );
  }
}

// Manager view
class ManagerListView extends StatelessWidget {
  final String managerId;

  const ManagerListView({
    super.key,
    required this.managerId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Manager(managerId: managerId).fetchManagerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Manager non trovato'));
        }
        final data = snapshot.data!;
        final artists = data['artists'] as List<dynamic>? ?? [];
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                color: Colors.green[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data['profileImageUrl']),
                        radius: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(data['nome'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Guadagno totale: €${data['totalEarnings'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            ...artists.map((artist) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              child: Card(
                color: Colors.green[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: Image.network(artist['profileImageUrl'], width: 50, height: 50),
                  title: Text(artist['nome'], style: const TextStyle(color: Colors.white)),
                  trailing: FutureBuilder<List<Song>>(
                    future: Artist(artistId: artist['artistId'], artistName: artist['nome']).fetchArtistSongs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Calcolo guadagno...', style: TextStyle(color: Colors.white70));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('€0.00', style: TextStyle(color: Colors.greenAccent));
                      }
                      final totalEarnings = snapshot.data!.fold<double>(0, (somma, song) => somma + song.earnings);
                      return Text('€${totalEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent));
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(
                          artistId: artist['artistId'],
                          artistName: artist['nome'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ))
          ],
        );
      },
    );
  }
}