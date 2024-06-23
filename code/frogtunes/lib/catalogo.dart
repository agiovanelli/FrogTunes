import 'package:flutter/material.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Il tuo catalogo', style: TextStyle(color: Colors.white)),
      ),
       body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Container(
            height: 50,
            color: Colors.teal[700],
            child: const Center(child: Text('Le tue canzoni preferite', style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text('bambino indaco', style: TextStyle(color: Colors.white)),
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
            height: 50,
            color: Colors.teal[700],
            child: const Center(child: Text('I tuoi artisti preferiti', style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const ListTile(
            leading: Icon(Icons.assignment_ind, color: Colors.white),
            title: Text('Narcolessia', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.assignment_ind, color: Colors.white),
            title: Text('Marco444', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.assignment_ind, color: Colors.white),
            title: Text('Milky Chance', style: TextStyle(color: Colors.white)),
          ),
          Container(
            height: 50,
            color: Colors.teal[700],
            child: const Center(child: Text('I tuoi podcast preferiti', style: TextStyle(fontSize: 26, color: Colors.white))),
          ),
          const ListTile(
            leading: Icon(Icons.contactless, color: Colors.white),
            title: Text('Daily Cogito', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.contactless, color: Colors.white),
            title: Text('Grandi Linee', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}