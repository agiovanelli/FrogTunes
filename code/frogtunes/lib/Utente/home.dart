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

    final hasName = data?['username'] != null && data?['username'] != '';
    final hasPhoto = data?['profileImageUrl'] != null && data?['profileImageUrl'] != '';

    if (!hasName || !hasPhoto) {
      // Attendi un frame per mostrare il dialog (evita errori di context)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileDialog(context, user.uid);
      });
    }

    if (data != null) {
      if(context.mounted){
        setState(() {
        userData = data;
      });
      }
    }

  }
}

void _showProfileDialog(BuildContext context, String uid) {
  final TextEditingController nameController = TextEditingController();
  File? _selectedImage;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      File? selectedImage;
      String? uploadedPhotoUrl;
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
                        debugPrint('📸 Avvio selezione immagine...');
                        final picker = ImagePicker();
                        final pickedImage =
                            await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

                        if (pickedImage != null) {
                          setState(() {
                            _selectedImage = File(pickedImage.path);
                          });
                        }
                        // final XFile? pickedFile = await picker.pickImage(
                        //   source: ImageSource.gallery,
                        // );

                        if (pickedImage == null) {
                          debugPrint('❌ Nessuna immagine selezionata.');
                          if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nessuna immagine selezionata')),
                          );
                          }
                          return;
                        }

                        debugPrint('✅ Immagine selezionata: ${pickedImage.path}');
                        final file = File(pickedImage.path);

                        final exists = await file.exists();
                        debugPrint('📁 File esiste? $exists');

                        if (!exists) {
                          throw PlatformException(
                            code: 'no_valid_image_uri',
                            message: 'Il file selezionato non esiste più o non è accessibile.',
                          );
                        }

                        if(context.mounted){
                          setState(() {
                            selectedImage = file;
                          });
                        }

                        try {
                          debugPrint('⏫ Inizio upload su Firebase Storage...');
                            final ref = FirebaseStorage.instance
                                .ref()
                                .child('profile_pictures')
                                .child('$uid.jpg');
                            await ref.putFile(_selectedImage!);
                            final imageUrl = await ref.getDownloadURL();

                            await FirebaseFirestore.instance.collection('utenti').doc(uid).update({
                              'profileImageUrl': imageUrl,
                            });

                          // final storageRef = FirebaseStorage.instance
                          //   .ref()
                          //   .child('profile_pictures/$uid.jpg');
                          
                          final UploadTask uploadTask = ref.putFile(file);
                          final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

                          if (snapshot.state == TaskState.success) {
                            final imageUrl = await snapshot.ref.getDownloadURL();
                            debugPrint('✅ Upload completato. URL: $imageUrl');

                            if(context.mounted){
                            setState(() {
                              uploadedPhotoUrl = imageUrl;
                            });
                            }
                          } else {
                            debugPrint('❌ Upload fallito. Stato: ${snapshot.state}');
                            if(context.mounted){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Errore nel caricamento dell\'immagine.')),
                            );
                            }
                          }
                        } catch (e) {
                          debugPrint('❌ Errore durante l\'upload o il recupero dell\'URL: $e');
                          if(context.mounted){ 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Errore nel caricamento dell\'immagine.')),
                          );
                          }
                        }

                      } on PlatformException catch (e) {
                        debugPrint('❌ Errore PlatformException: ${e.code} - ${e.message}');
                        if(context.mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: ${e.message}')),
                        );
                        }
                      } catch (e, stack) {
                        debugPrint('❌ Errore generico: $e');
                        debugPrint('📜 Stack trace: $stack');
                        if(context.mounted){ 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Errore sconosciuto nel caricamento.')),
                        );
                        }
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

                  if (!context.mounted) return;

                  final currentData = doc.data();
                  final currentPhoto = currentData?['profileImageUrl'];

                  const String defaultPhotoURL = 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
                  final String finalPhotoURL = uploadedPhotoUrl ??
                                              (currentPhoto != null && currentPhoto.isNotEmpty ? currentPhoto : defaultPhotoURL);

                  // Se nessun aggiornamento ma l'utente ha già dati validi, chiudi comunque il dialog
                  if (name.isEmpty && (finalPhotoURL == null || finalPhotoURL.isEmpty)) {
                    if(mounted) Navigator.of(context).pop(); // chiudi senza fare update
                    return;
                  }


                  // Costruisci mappa degli aggiornamenti
                  final Map<String, dynamic> updates = {};
                  if (name.isNotEmpty) {
                    updates['username'] = name;
                    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
                    if (!context.mounted) return;
                  }

                  if (finalPhotoURL != null && finalPhotoURL.isNotEmpty) {
                    updates['profileImageUrl'] = finalPhotoURL;
                    await FirebaseAuth.instance.currentUser?.updatePhotoURL(finalPhotoURL);
                    if (!context.mounted) return;
                  }

                  // Salva su Firestore
                  if (updates.isNotEmpty) {
                    await docRef.update(updates);

                    if(context.mounted){
                    setState(() {
                      userData = {
                        'username': updates['username'] ?? currentData?['username'],
                        'profileImageUrl': updates['profileImageUrl'] ?? currentData?['profileImageUrl'],
                      };
                    });
                    }
                    if (!context.mounted) return;
                  }

                  if(context.mounted) Navigator.of(context).pop(); // Chiudi il dialog
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
                'Ciao ${userData?['username'] ?? user?.displayName ?? 'Utente'}',
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
