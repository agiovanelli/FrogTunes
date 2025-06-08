import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
  int _selectedIndex = 1;
  Map<String, dynamic>? userData;

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

  Future<void> _checkAndShowProfileDialog() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    final data = doc.data();

    final hasName = data?['displayName'] != null && data?['displayName'] != '';
    final hasPhoto = data?['photoURL'] != null && data?['photoURL'] != '';

    if (!hasName || !hasPhoto) {
      // Attendi un frame per mostrare il dialog (evita errori di context)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileDialog(context, user.uid);
      });
    }

    if (data != null) {
      setState(() {
        userData = data;
      });
    }

  }
}

void _showProfileDialog(BuildContext context, String uid) {
  final TextEditingController nameController = TextEditingController();
  File? selectedImage;
  String? uploadedPhotoUrl;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Completa il tuo profilo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (pickedFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nessuna immagine selezionata')),
                          );
                          return;
                        }

                        final File file = File(pickedFile.path);

                        if (!await file.exists()) {
                          throw PlatformException(
                            code: 'no_valid_image_uri',
                            message: 'Il file selezionato non esiste più o non è accessibile.',
                          );
                        }

                        setState(() {
                          selectedImage = file;
                        });

                        // Upload to Firebase
                        final storageRef = FirebaseStorage.instance
                            .ref()
                            .child('profile_pictures/$uid.jpg');
                        await storageRef.putFile(file);
                        final imageUrl = await storageRef.getDownloadURL();

                        setState(() {
                          uploadedPhotoUrl = imageUrl;
                        });

                      } on PlatformException catch (e) {
                        debugPrint('Errore Piattaforma: ${e.message}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: ${e.message}')),
                        );
                      } catch (e) {
                        debugPrint('Errore Generico: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Errore sconosciuto nel caricamento.')),
                        );
                      }
                    },

                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : null,
                      child: selectedImage == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Username'),
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
                  final currentData = doc.data();
                  final currentPhoto = currentData?['photoURL'];

                  // Usa la foto già esistente se non ne è stata caricata una nuova
                  final String finalPhotoURL = uploadedPhotoUrl ?? currentPhoto;

                  // Se entrambi sono nulli o vuoti, non fare nulla
                  if (name.isEmpty && (finalPhotoURL == null || finalPhotoURL.isEmpty)) return;

                  // Costruisci mappa degli aggiornamenti
                  final Map<String, dynamic> updates = {};
                  if (name.isNotEmpty) {
                    updates['displayName'] = name;
                    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
                  }
                  if (finalPhotoURL != null && finalPhotoURL.isNotEmpty) {
                    updates['photoURL'] = finalPhotoURL;
                    await FirebaseAuth.instance.currentUser?.updatePhotoURL(finalPhotoURL);
                  }

                  // Salva su Firestore
                  if (updates.isNotEmpty) {
                    await docRef.update(updates);

                    setState(() {
                      userData = {
                        'displayName': updates['displayName'] ?? currentData?['displayName'],
                        'photoURL': updates['photoURL'] ?? currentData?['photoURL'],
                      };
                    });
                  }

                  Navigator.of(context).pop(); // Chiudi il dialog
                },


                child: const Text('Salva'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: Text(
          'Ciao ${userData?['displayName'] ?? user?.displayName ?? 'Utente'}',
          style: const TextStyle(color: Colors.white),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
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
