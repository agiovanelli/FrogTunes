import 'package:flutter/material.dart';
import 'package:frogtunes/AME/settingsAME.dart';
import 'package:frogtunes/AME/loginAME.dart';
import 'package:frogtunes/AME/analytic.dart';
import 'package:frogtunes/AME/contentA.dart';
import 'package:frogtunes/catalogo.dart';

class HomeAMEView extends StatefulWidget {
  const HomeAMEView({super.key});

  @override
  _HomeAMEViewState createState() => _HomeAMEViewState();
}

class _HomeAMEViewState extends State<HomeAMEView> {
  int _selectedIndex = 1; // Home di default

  // Pagine associate ai BottomNavigationBarItem
  final List<Widget> _pages = [
    const AnalyticView(),
    const HomeAContent(), // Estratto il contenuto della home in un widget separato
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
        title:
            const Text('Ciao Artista', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsAMEPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAMEView()),
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
            icon: Icon(Icons.align_vertical_bottom),
            label: 'Analitica',
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
