import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/AME/settings_ame.dart';
import 'package:frogtunes/AME/login_ame.dart';
import 'package:frogtunes/AME/Artista/analytic.dart';
import 'package:frogtunes/AME/Artista/contentA.dart';
import 'package:frogtunes/AME/Artista/profile.dart';
import 'package:frogtunes/AME/Manager/contentM.dart';
import 'package:frogtunes/AME/Manager/analyticM.dart';
import 'package:frogtunes/AME/Manager/profileM.dart';
import 'package:frogtunes/AME/Etichetta/contentE.dart';
import 'package:frogtunes/AME/Etichetta/analyticE.dart';
import 'package:frogtunes/AME/Etichetta/profileE.dart';
import 'package:frogtunes/audio_service.dart';

class HomeAMEView extends StatefulWidget {
  const HomeAMEView({super.key, required this.selectedRole});
  final String selectedRole; // Accetta il valore passato

  @override
  HomeAMEViewState createState() => HomeAMEViewState();
}

class HomeAMEViewState extends State<HomeAMEView> {
  int _selectedIndex = 1; // Home di default
  Map<String, dynamic>? userData;
  late String role;

  // Pagine associate ai BottomNavigationBarItem
  @override
  void initState() {
    super.initState();
  role = widget.selectedRole;
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final List<Widget> pages = [
      if (widget.selectedRole == "Artista") ...[
        const AnalyticView(),
        const HomeAContent(),
        const ProfileView(),
      ] else if (widget.selectedRole == "Manager") ...[
        const AnalyticMView(),
        const HomeMContent(),
        const ProfileMView(),
      ] else if (widget.selectedRole == "Etichetta") ...[
        const AnalyticEView(),
        const HomeEContent(),
        const ProfileEView(),
      ] else ...[
        const Center(child: Text('Ruolo non riconosciuto', style: TextStyle(color: Colors.white))),
      ]
    ];
    final int safeIndex = pages.isNotEmpty && _selectedIndex < pages.length ? _selectedIndex : 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Row(
          children:[
            const SizedBox(width: 10),
            Expanded(child:
              Text('Ciao ${userData?['username'] ?? user?.displayName ?? 'Artista'}',
                  style: const TextStyle(color: Colors.white)
                  ),
            ),
          ],
        ),
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await AudioService().resetPlayerState();
              if(context.mounted){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginAMEView()),
                );
              }
            },
          ),
        ],
      ),
      body: pages[safeIndex], // Mostra la pagina selezionata
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[700],
        currentIndex: safeIndex, // Evidenzia l'elemento selezionato
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
