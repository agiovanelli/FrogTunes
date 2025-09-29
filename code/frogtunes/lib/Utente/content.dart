import 'package:flutter/material.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'playlist.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Contenuto della schermata principale dell'utente, mostra le ultime canzoni ascoltate e le playlist
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
                              //da fare più avanti quando introduco possibilità di ascoltare canzoni
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text('bambino indaco', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Narcolessia', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(
                        artistId: '',
                        nomeArtista: 'Narcolessia',
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
                        artistId: '',
                        nomeArtista: 'Marco444',
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
                        artistId: '',
                        nomeArtista: 'Narcolessia',
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
                // Mostra la vista delle playlist
                child: PlaylistView(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
