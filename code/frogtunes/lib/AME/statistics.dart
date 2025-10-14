import 'package:flutter/material.dart';

// Dummy data models
class Song {
  final String coverUrl;
  final String title;
  final String artist;
  final int totalStreams;
  final int streams24h;
  Song({
    required this.coverUrl,
    required this.title,
    required this.artist,
    required this.totalStreams,
    required this.streams24h,
  });

  double get earnings => totalStreams * 0.005; // Example multiplier
}

class Artist {
  final String name;
  final List<Song> songs;
  Artist({required this.name, required this.songs});

  double get totalEarnings =>
      songs.fold(0, (sum, song) => sum + song.earnings);
}

class Manager {
  final String name;
  final List<Artist> artists;
  Manager({required this.name, required this.artists});
}

// Dummy data
final songs = [
  Song(
    coverUrl: 'https://via.placeholder.com/100',
    title: 'Song One',
    artist: 'Artist A',
    totalStreams: 10000,
    streams24h: 500,
  ),
  Song(
    coverUrl: 'https://via.placeholder.com/100',
    title: 'Song Two',
    artist: 'Artist A',
    totalStreams: 8000,
    streams24h: 300,
  ),
  Song(
    coverUrl: 'https://via.placeholder.com/100',
    title: 'Song Three',
    artist: 'Artist B',
    totalStreams: 12000,
    streams24h: 700,
  ),
];

final artists = [
  Artist(name: 'Artist A', songs: songs.where((s) => s.artist == 'Artist A').toList()),
  Artist(name: 'Artist B', songs: songs.where((s) => s.artist == 'Artist B').toList()),
];

final managers = [
  Manager(name: 'Manager X', artists: artists),
];

// Main page
class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

enum StatView { song, artist, manager }

class _StatisticsPageState extends State<StatisticsPage> {
  StatView selectedView = StatView.song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                selectedView == StatView.song,
                selectedView == StatView.artist,
                selectedView == StatView.manager,
              ],
              onPressed: (index) {
                setState(() {
                  selectedView = StatView.values[index];
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Canzone'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Artista'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Manager'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                switch (selectedView) {
                  case StatView.song:
                    return SongListView(songs: songs);
                  case StatView.artist:
                    return ArtistListView(artists: artists);
                  case StatView.manager:
                    return ManagerListView(managers: managers);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Song view
class SongListView extends StatelessWidget {
  final List<Song> songs;
  const SongListView({required this.songs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, idx) {
        final song = songs[idx];
        return ListTile(
          leading: Image.network(song.coverUrl, width: 50, height: 50),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(song.title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(song.coverUrl, width: 100, height: 100),
                  SizedBox(height: 8),
                  Text('Artista: ${song.artist}'),
                  Text('Stream totali: ${song.totalStreams}'),
                  Text('Stream 24h: ${song.streams24h}'),
                  Text('Guadagno: €${song.earnings.toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Chiudi'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Artist view
class ArtistListView extends StatelessWidget {
  final List<Artist> artists;
  const ArtistListView({required this.artists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, idx) {
        final artist = artists[idx];
        return ExpansionTile(
          leading: CircleAvatar(child: Text(artist.name[0])),
          title: Text(artist.name),
          subtitle: Text('Guadagno totale: €${artist.totalEarnings.toStringAsFixed(2)}'),
          children: artist.songs.map((song) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Image.network(song.coverUrl, width: 40, height: 40),
                title: Text(song.title),
                subtitle: Text('Guadagno: €${song.earnings.toStringAsFixed(2)}'),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(song.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(song.coverUrl, width: 100, height: 100),
                        SizedBox(height: 8),
                        Text('Artista: ${song.artist}'),
                        Text('Stream totali: ${song.totalStreams}'),
                        Text('Stream 24h: ${song.streams24h}'),
                        Text('Guadagno: €${song.earnings.toStringAsFixed(2)}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('Chiudi'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Manager view
class ManagerListView extends StatelessWidget {
  final List<Manager> managers;
  const ManagerListView({required this.managers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: managers.length,
      itemBuilder: (context, idx) {
        final manager = managers[idx];
        return ExpansionTile(
          leading: CircleAvatar(child: Text(manager.name[0])),
          title: Text(manager.name),
          subtitle: Text('Artisti gestiti: ${manager.artists.length}'),
          children: manager.artists.map((artist) {
            return ExpansionTile(
              leading: CircleAvatar(child: Text(artist.name[0])),
              title: Text(artist.name),
              subtitle: Text('Guadagno totale: €${artist.totalEarnings.toStringAsFixed(2)}'),
              children: artist.songs.map((song) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Image.network(song.coverUrl, width: 40, height: 40),
                    title: Text(song.title),
                    subtitle: Text('Guadagno: €${song.earnings.toStringAsFixed(2)}'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(song.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(song.coverUrl, width: 100, height: 100),
                            SizedBox(height: 8),
                            Text('Artista: ${song.artist}'),
                            Text('Stream totali: ${song.totalStreams}'),
                            Text('Stream 24h: ${song.streams24h}'),
                            Text('Guadagno: €${song.earnings.toStringAsFixed(2)}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text('Chiudi'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}