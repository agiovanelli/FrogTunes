import 'package:flutter/material.dart';

class PlaylistView extends StatelessWidget {
  final List<String> playlists = List.generate(6, (index) => 'Playlist $index');

  PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Numero di colonne
          crossAxisSpacing: 30.0, // Spazio tra colonne
          mainAxisSpacing: 20.0, // Spazio tra righe
          childAspectRatio: 1.0, // Mantiene i quadrati proporzionati
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlaylistDetailsView(playlistName: playlists[index]),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.green,
              elevation: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    playlists[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}

class PlaylistDetailsView extends StatelessWidget {
  final String playlistName;

  const PlaylistDetailsView({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final List<String> songs =
        List.generate(5, (index) => 'Song $index'); // Lista di brani

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(playlistName),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title:
                Text(songs[index], style: const TextStyle(color: Colors.white)),
          );
        },
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
