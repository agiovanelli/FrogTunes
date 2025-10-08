import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:frogtunes/player_screen.dart';

class SongInsightPage extends StatefulWidget {
  final String songId;

  const SongInsightPage({super.key, required this.songId});

  @override
  State<SongInsightPage> createState() => _SongInsightPageState();
}

class _SongInsightPageState extends State<SongInsightPage> {
  final audio = AudioService();
  
  // Recupera tutti i dettagli e le statistiche della canzone
  Future<SongDetails> fetchSongDetails() async {
    final songDoc = await FirebaseFirestore.instance
        .collection('canzoni')
        .doc(widget.songId)
        .get();

    if (!songDoc.exists) {
      throw Exception("Canzone non trovata");
    }

    final songData = songDoc.data()!;
    final totalPlays = songData['ascoltiTotali'] ?? 0;
    final artistId = (songData['artistId'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final cover = songData['cover'] ?? 'https://via.placeholder.com/150';
    final audioUrl = songData['audioUrl'] ?? '';

    // Calcolo ascolti ultime 24 ore
    final last24h = DateTime.now().subtract(const Duration(hours: 24));
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('eventiAscolto')
        // .where('cid', isEqualTo: widget.songId) TODO: fixare indici firestore 
        .where('timestamp', isGreaterThan: Timestamp.fromDate(last24h))
        .get();

    final playsLast24h = eventsSnapshot.docs.length;

    // Calcolo paesi che hanno streammato di più la canzone
    // Legge le statistiche aggregate salvate nel documento della canzone
    final Map<String, dynamic> statPaese =
        (songData['statPaese'] ?? {}) as Map<String, dynamic>;

    // Ordina i paesi per numero di ascolti
    final topCountries = statPaese.entries
        .map((e) => CountryPlays(name: e.key, plays: e.value))
        .toList()
      ..sort((a, b) => b.plays.compareTo(a.plays));

    // Mostra solo i primi 5 paesi (puoi cambiare il numero)
    final top5 = topCountries.take(5).toList();

    // Parsing crediti: gestisce il caso di una singola mappa con 3 campi stringa
    List<Credits> credits = [];
    final rawCrediti = songData['crediti'];
    if (rawCrediti is Map<String, dynamic>) {
      credits = [
        Credits(
          autore: rawCrediti['Autore']?.toString() ?? '',
          compositore: rawCrediti['Compositore']?.toString() ?? '',
          producer: rawCrediti['Producer']?.toString() ?? '',
        )
      ];
    } else if (rawCrediti is List) {
      credits = rawCrediti.map((value) {
        if (value is Map<String, dynamic>) {
          return Credits(
            autore: value['autore']?.toString() ?? '',
            compositore: value['compositore']?.toString() ?? '',
            producer: value['producer']?.toString() ?? '',
          );
        } else {
          return Credits(autore: '', compositore: '', producer: '');
        }
      }).toList();
    }

    final artistNames = await fetchArtistName((songData['artistId'] as List<dynamic>? ?? []).map((e) => e.toString()).toList());

    return SongDetails(
      title: songData['titolo'] ?? 'Senza titolo',
      artistId: artistId,
      artistNames: artistNames,
      credits: credits,
      totalPlays: totalPlays,
      playsLast24h: playsLast24h,
      topCountries: top5,
      cover: cover,
      audioUrl: audioUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        title: const Text('Dettagli'),
        backgroundColor: const Color.fromARGB(255, 24, 96, 26),
      ),
      body: FutureBuilder<SongDetails>(
        future: fetchSongDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nessun dato trovato'));
          }

          final song = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(song.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Artisti: ${song.artistNames.join(", ")}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                const Divider(height: 32),
                Text("Ascolti",
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.headphones),
                  title: const Text('Ascolti totali'),
                  trailing: Text('${song.totalPlays}'),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Ascolti ultime 24 ore'),
                  trailing: Text('${song.playsLast24h}'),
                ),
                const Divider(height: 32),
                Text('Territori',
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...song.topCountries.map(
                  (country) => ListTile(
                    leading: const Icon(Icons.flag),
                    title: Text(country.name),
                    trailing: Text('${country.plays}'),
                  ),
                ),
                const Divider(height: 32),
                Text('Crediti',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (song.credits.isEmpty)
                  const Text('Nessun credito disponibile')
                else ...[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Autore'),
                    trailing: Text(song.credits.map((c) => c.autore.trim().isNotEmpty ? c.autore : 'Non disponibile').join(', ')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('Compositore'),
                    trailing: Text(song.credits.map((c) => c.compositore.trim().isNotEmpty ? c.compositore : 'Non disponibile').join(', ')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Producer'),
                    trailing: Text(song.credits.map((c) => c.producer.trim().isNotEmpty ? c.producer : 'Non disponibile').join(', ')),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Ascolta'),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          songId: widget.songId,
                          titolo: song.title,
                          artistId: song.artistId,
                          cover: song.cover,
                        ),
                      ),
                    );

                    if (song.audioUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio non disponibile')),
                      );
                      return;
                    }
                    
                    await audio.playSong(
                      songId: widget.songId,
                      url: song.audioUrl,
                      title: song.title,
                      artist: song.artistId.join(", "),
                      artistId: song.artistId,
                      cover: song.cover,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SongDetails {
  final String title;
  final List<String> artistId;
  final List<Credits> credits;
  final int totalPlays;
  final int playsLast24h;
  final List<CountryPlays> topCountries;
  final String cover;
  final String audioUrl;
  final List<String> artistNames;
  SongDetails({
    required this.title,
    required this.artistId,
    required this.artistNames,
    required this.credits,
    required this.totalPlays,
    required this.playsLast24h,
    required this.topCountries,
    required this.cover,
    required this.audioUrl,
  });
}

class CountryPlays {
  final String name;
  final int plays;

  CountryPlays({required this.name, required this.plays});
}

class Credits {
  final String autore;
  final String compositore;
  final String producer;

  Credits({required this.autore, required this.compositore, required this.producer});
}