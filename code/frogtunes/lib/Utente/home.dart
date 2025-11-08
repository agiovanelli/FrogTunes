import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/Utente/content.dart';
import 'package:frogtunes/Utente/search.dart';
import 'package:frogtunes/Utente/settings.dart';
import 'package:frogtunes/Utente/catalogo.dart';
import '../mini_player.dart';
import 'package:frogtunes/audio_service.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  final bool showAppBar;
  
  const HomeView({
    this.initialIndex = 1, // Indice di default è 1 quindi allo start ci mostra sempre la Home
    this.showAppBar = true, // Appbar di default visibile
    super.key,
  });

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _selectedIndex = 1;
  Map<String, dynamic>? userData; // Dati utente caricati da Firestore

  // Pagine per la navigazione
  final List<Widget> _pages = [
    const SearchView(),
    const HomeContent(),
    const LibraryView(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAndShowProfileDialog();
  }

  // Funzione per controllare se mostrare il dialog di completamento profilo in caso fosse il suo primo accesso
  Future<void> _checkAndShowProfileDialog() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
      setState(() {  
        final hasName = data['username']?.toString().trim().isNotEmpty == true
              ? data['username']
              : 'Utente';
        final hasPhoto = data['profileImageUrl']?.toString().trim().isNotEmpty == true
              ? data['profileImageUrl']
              : 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';

        userData = {
          'username': hasName,
          'profileImageUrl': hasPhoto,
          'tipologia': data['tipologiaAccount'] ?? 0,
        };

        // Mostra il dialog SOLO se mancano sia username che foto personalizzata
        if (hasName == 'Utente' &&
            hasPhoto == 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showProfileDialog(context, user.uid);
          });
        }
      });
    }
  }
}

  // Funzione per mostrare il dialog di completamento profilo (username e foto profilo)
  void _showProfileDialog(BuildContext context, String uid) async {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String uploadedPhotoUrl = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Completa il tuo profilo',
                style: TextStyle(color: Colors.white)
              ),
              backgroundColor: Colors.green[900],
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile == null) return;

                        final file = await pickedFile.readAsBytes();
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('profile_pictures')
                            .child('$uid.jpg');

                        final uploadTask = await ref.putData(file);
                        final url = await uploadTask.ref.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection('utenti')
                            .doc(uid)
                            .update({'profileImageUrl': url});
                        setState(() {
                          uploadedPhotoUrl = url;
                        });
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: uploadedPhotoUrl.startsWith('http')
                          ? NetworkImage(uploadedPhotoUrl)
                          : AssetImage(uploadedPhotoUrl) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00FF00)),
                      ),
                    ),
                      cursorColor: Color(0xFF00FF00),
                      style: TextStyle(color: Colors.white)
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final docRef = FirebaseFirestore.instance.collection('utenti').doc(uid);
                    final doc = await docRef.get();
                    if (!context.mounted) return;
                    final currentData = doc.data();
                    
                    const String defaultPhotoURL = 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
                    final String finalPhotoURL = uploadedPhotoUrl.isNotEmpty
                      ? uploadedPhotoUrl
                      : (currentData?['profileImageUrl'] ?? defaultPhotoURL);
                    
                    // Se nessun aggiornamento ma l'utente ha già dati validi, chiudi comunque il dialog
                    if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inserisci un nome utente.'),
                      ),
                    );
                    return;
                  }

                  // Aggiornamento Firebase Auth + Firestore
                  await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
                  await FirebaseAuth.instance.currentUser
                      ?.updatePhotoURL(finalPhotoURL);

                  await docRef.set({
                    'username': name,
                    'profileImageUrl': finalPhotoURL,
                  }, SetOptions(merge: true));

                  if (context.mounted) {
                    setState(() {
                      userData = {
                        'username': name,
                        'profileImageUrl': finalPhotoURL,
                      };
                    });

                    Navigator.of(context).pop();
                  }

                    // // Costruisci mappa degli aggiornamenti
                    // final Map<String, dynamic> updates = {};
                    // if (name.isNotEmpty) {
                    //   updates['username'] = name;
                    //   await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
                    //   if (!context.mounted) return;
                    // }
                    // if (finalPhotoURL.isNotEmpty) {
                    //   updates['profileImageUrl'] = finalPhotoURL;
                    //   await FirebaseAuth.instance.currentUser?.updatePhotoURL(finalPhotoURL);
                    //   if (!context.mounted) return;
                    // }
                    // // Salva su Firestore
                    // if (updates.isNotEmpty) {
                    //   await docRef.update(updates);
                    // }
 
                    // if(context.mounted) {
                    //   // Aggiorna userData subito dopo il salvataggio
                    //   setState(() {
                    //     userData = {
                    //       'username': name.isNotEmpty ? name : currentData?['username'] ?? 'Utente',
                    //       'profileImageUrl': finalPhotoURL.isNotEmpty ? finalPhotoURL : currentData?['profileImageUrl'] ?? defaultPhotoURL,
                    //     };
                    //   });
                    //   Navigator.of(context).pop();
                    // }
                    // Dopo la chiusura del dialog aggiorna la UI
                    await _checkAndShowProfileDialog();
                  },
                  child: const Text('Salva', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Costruzione UI Appbar e BottomNavigationBar
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: 
      widget.showAppBar
        ? AppBar(
            backgroundColor: const Color.fromARGB(255, 4, 35, 5),
            title: Row(
              children:[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: userData?['profileImageUrl'] != null && userData!['profileImageUrl'] != ''
                      ? NetworkImage(userData!['profileImageUrl'])
                      : user?.photoURL != null && user?.photoURL != ''
                          ? NetworkImage(user!.photoURL!)
                          : const NetworkImage('https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f'),
                ),
                const SizedBox(width: 10),
                Expanded(child:
                  Text(
                    'Ciao ${userData?['username'] ?? 'Utente'}',
                    style: const TextStyle(color: Colors.white),
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
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await AudioService().resetPlayerState();
                  if (context.mounted){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  }
                },
              ),
            ],
          )
        : null,
      body: Stack(
        children: [ _pages[_selectedIndex],
        // Aggiungi il MiniPlayer in basso se c'è una canzone in riproduzione
        const Align(
                alignment: Alignment.bottomCenter,
                child: MiniPlayer(),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[700],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
