import 'package:flutter/material.dart';
import 'playlist.dart';
import 'package:frogtunes/Utente/login.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: const Text('Ciao Utente', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Text('Le tue canzoni preferite',
                    style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title:
                Text('bambino indaco', style: TextStyle(color: Colors.white)),
            subtitle: Text('Narcolessia', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text('Voragine', style: TextStyle(color: Colors.white)),
            subtitle: Text('Marco444', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text('micixsempre', style: TextStyle(color: Colors.white)),
            subtitle: Text('Narcolessia', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
                child: Text('Le tue playlist',
                    style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 350,
            child: PlaylistView(),
          ),
          BottomNavigationBar(
            selectedItemColor: Colors.white, // Colore dell'elemento selezionato
            unselectedItemColor:
                Colors.white70, // Colore degli elementi non selezionati
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Cerca',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2),
                label: 'Profilo',
              ),
            ],
            backgroundColor: Colors.green[700],
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
