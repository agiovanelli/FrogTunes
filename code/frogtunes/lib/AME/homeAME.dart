import 'package:flutter/material.dart';
import 'package:frogtunes/AME/settingsAME.dart';
import 'package:frogtunes/AME/loginAME.dart';
import 'package:frogtunes/AME/Artista/analytic.dart';
import 'package:frogtunes/AME/Artista/contentA.dart';
import 'package:frogtunes/AME/Artista/profile.dart';
import 'package:frogtunes/AME/Manager/contentM.dart';
import 'package:frogtunes/AME/Manager/analyticM.dart';
import 'package:frogtunes/AME/Manager/profileM.dart';
import 'package:frogtunes/AME/Etichetta/contentE.dart';
import 'package:frogtunes/AME/Etichetta/analyticE.dart';
import 'package:frogtunes/AME/Etichetta/profileE.dart';

class HomeAMEView extends StatefulWidget {
  const HomeAMEView({super.key, required this.selectedRole});
  final String selectedRole; // Accetta il valore passato

  @override
  _HomeAMEViewState createState() => _HomeAMEViewState();
}

class _HomeAMEViewState extends State<HomeAMEView> {
  int _selectedIndex = 1; // Home di default

  // Pagine associate ai BottomNavigationBarItem

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      if (widget.selectedRole == 'Artista') ...[
        const AnalyticView(),
        const HomeAContent(),
        const ProfileView(),
      ],
      if (widget.selectedRole == 'Manager') ...[
        const AnalyticMView(),
        const HomeMContent(),
        const ProfileMView(),
      ],
      if (widget.selectedRole == 'Etichetta') ...[
        const AnalyticEView(),
        const HomeEContent(),
        const ProfileEView(),
      ],
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Text('Ciao ${widget.selectedRole}',
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsAMEPage(
                        selectedRole: widget.selectedRole /*?? 'Artista'*/)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginAMEView()),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex], // Mostra la pagina selezionata
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
