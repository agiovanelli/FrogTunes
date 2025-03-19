import 'package:flutter/material.dart';
import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/Utente/content.dart';
import 'package:frogtunes/Utente/search.dart';
import 'package:frogtunes/Utente/settings.dart';
import 'package:frogtunes/Utente/catalogo.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 1; // Home di default

  // Pagine associate ai BottomNavigationBarItem
  final List<Widget> _pages = [
    const SearchView(),
    const HomeContent(), // Estratto il contenuto della home in un widget separato
    const LibraryView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: const Text('Ciao Utente', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
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
      body: _pages[_selectedIndex], // Mostra la pagina selezionata
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[700],
        currentIndex: _selectedIndex, // Evidenzia l'elemento selezionato
        onTap: _onItemTapped, // Cambia pagina quando un elemento viene toccato
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
      ),
    );
  }
}
