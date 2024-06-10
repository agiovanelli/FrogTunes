import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  void _performSearch(String query) {
    // Questo è solo un esempio. Qui dovresti implementare la tua logica di ricerca.
    setState(() {
      _searchResults = query.isEmpty
          ? []
          : List.generate(10, (index) => 'Result $index for "$query"');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.teal,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cerca',
            hintStyle: TextStyle(color: Colors.white70, fontSize: 25),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white, fontSize: 25),
          onChanged: _performSearch,
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text(_searchResults[index], style: TextStyle(color: Colors.white)),
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