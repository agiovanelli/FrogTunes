import 'package:flutter/material.dart';

class AnalyticMView extends StatefulWidget {
  const AnalyticMView({super.key});

  @override
  _AnalyticMViewState createState() => _AnalyticMViewState();
}

class _AnalyticMViewState extends State<AnalyticMView> {
  final TextEditingController _analyticController = TextEditingController();
  List<String> _analyticResults = [];

  void _performAnalytic(String query) {
    // Questo è solo un esempio. Qui dovresti implementare la tua logica di ricerca.
    setState(() {
      _analyticResults = query.isEmpty
          ? []
          : List.generate(10, (index) => 'Result $index for "$query"');
    });
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
            controller: _analyticController,
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
            onChanged: _performAnalytic,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _analyticResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: Text(_analyticResults[index],
                style: const TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _analyticController.dispose();
    super.dispose();
  }
}
