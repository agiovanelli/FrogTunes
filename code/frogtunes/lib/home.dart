import 'package:flutter/material.dart';
import 'playlist.dart';
import 'package:frogtunes/login.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('FrogTunes', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Container(
            height: 50,
            color: Colors.teal[700],
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                },
                child: const Text(
                  'Clicca qui per cambiare account',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ]),
          SizedBox(
            height: 360,
            child: PlaylistView(),
          ),
        ],
      ),
    );
  }
}
