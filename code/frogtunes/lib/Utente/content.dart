import 'package:flutter/material.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'playlist.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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
                      child: Text('Ultime canzoni ascoltate',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text('bambino indaco', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Narcolessia', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(
                        canzoni: ['bambino indaco'],
                        nomeArtista: 'Narcolessia',
                        immagineArtista: 'https://via.placeholder.com/300x300', // URL della copertina
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text('Voragine', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Marco444', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(
                        canzoni: ['Voragine'],
                        nomeArtista: 'Marco444',
                        immagineArtista: 'https://via.placeholder.com/300x300', // URL della copertina
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.music_note, color: Colors.white),
                title:
                    Text('micixsempre', style: TextStyle(color: Colors.white)),
                subtitle:
                    Text('Narcolessia', style: TextStyle(color: Colors.grey)),
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(
                        canzoni: ['micixsempre'],
                        nomeArtista: 'Narcolessia',
                        immagineArtista: 'https://via.placeholder.com/300x300', // URL della copertina
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Le tue playlist',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              const SizedBox(height: 5),
              SizedBox(
                height: 365,
                child: PlaylistView(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
