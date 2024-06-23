import 'package:flutter/material.dart';

class PlaylistView extends StatelessWidget {
  final List<String> playlists = List.generate(5, (index) => 'Playlist $index');

  PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.teal[700],
        title: const Center(child:Text('Le tue playlist', style: TextStyle(fontSize: 26, color: Colors.white))),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Numero di colonne
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0, // Rapporto di aspetto 1:1 per creare cubi
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailsView(playlistName: playlists[index]),
                ),
              );
            },
            child: Card(
              color: Colors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 50.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      playlists[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlaylistDetailsView extends StatelessWidget {
  final String playlistName;

  const PlaylistDetailsView({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final List<String> songs = List.generate(5, (index) => 'Song $index'); // Lista di brani

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(playlistName),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: Text(songs[index], style: const TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}