import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  void _performSearch(String query) async{
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = <String>[];

  try {
      // RICERCA su collezione "canzoni"
      final querySnapshot = await FirebaseFirestore.instance
          .collection('canzoni')
          .where('keywords', arrayContains: query.toLowerCase()) // ricerca parziale
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        results.add('${data['titolo']} - ${data['artista']}'); // personalizzabile
      }
      
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Errore nella ricerca: $e');
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Cerca',
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 18),
              filled: true,
              fillColor: Colors.green[700], // Sfondo leggermente più scuro
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // Angoli smussati
                borderSide: BorderSide.none, // Rimuove il bordo predefinito
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            onChanged: _performSearch,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: Text(_searchResults[index],
                style: const TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
