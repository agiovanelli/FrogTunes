import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SongInsightPage extends StatefulWidget {
  final String songId;

  const SongInsightPage({super.key, required this.songId});

  @override
  State<SongInsightPage> createState() => _SongInsightPageState();
}

class _SongInsightPageState extends State<SongInsightPage> {
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
    final credits = songData['crediti'] ?? '';
    final artistIds = List<String>.from(songData['artistId'] ?? []);

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

    return SongDetails(
      title: songData['titolo'] ?? 'Senza titolo',
      artists: artistIds,
      credits: credits,
      totalPlays: totalPlays,
      playsLast24h: playsLast24h,
      topCountries: top5,
    );
  }

  // Riproduzione canzone da collegare con audio_service.dart
  void _playSong() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Canzone')),
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
                Text('Artisti: ${song.artists.join(", ")}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Crediti: ${song.credits}',
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic)),
                const Divider(height: 32),
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
                Text('Top paesi:',
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...song.topCountries.map(
                  (country) => ListTile(
                    leading: const Icon(Icons.flag),
                    title: Text(country.name),
                    trailing: Text('${country.plays}'),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Ascolta la canzone'),
                  onPressed: _playSong,
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
  final List<String> artists;
  final String credits;
  final int totalPlays;
  final int playsLast24h;
  final List<CountryPlays> topCountries;

  SongDetails({
    required this.title,
    required this.artists,
    required this.credits,
    required this.totalPlays,
    required this.playsLast24h,
    required this.topCountries,
  });
}

class CountryPlays {
  final String name;
  final int plays;

  CountryPlays({required this.name, required this.plays});
}
