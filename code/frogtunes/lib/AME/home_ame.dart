import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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

class HomeAMEView extends StatefulWidget {
  const HomeAMEView({super.key, required this.selectedRole});
  final String selectedRole; // Accetta il valore passato

  @override
  _HomeAMEViewState createState() => _HomeAMEViewState();
}

class _HomeAMEViewState extends State<HomeAMEView> {
  int _selectedIndex = 1; // Home di default
  Map<String, dynamic>? userData;
  late String role;

  // Pagine associate ai BottomNavigationBarItem
    @override
  void initState() {
    super.initState();
    role = widget.selectedRole;
    _checkAndShowProfileDialog();
  }

  Future<void> _checkAndShowProfileDialog() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection(role.toLowerCase()).doc(user.uid).get();
    if (!doc.exists){ 
      throw FirebaseAuthException(code: 'user-data-not-found', message: 'Dati utente non trovati.');
    }

    final data = doc.data();
    final hasName = data?['username'] != null && data?['username'] != '';
    final hasPhoto = data?['profileImageUrl'] != null && data?['profileImageUrl'] != '';

    if (!hasName || !hasPhoto) {
      // Attendi un frame per mostrare il dialog (evita errori di context)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileDialog(context, user.uid);
      });
    }

    if (data != null && mounted) {
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
                        debugPrint('📸 Avvio selezione immagine...');
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (pickedFile == null) {
                          debugPrint('❌ Nessuna immagine selezionata.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nessuna immagine selezionata')),
                          );
                          return;
                        }

                        debugPrint('✅ Immagine selezionata: ${pickedFile.path}');
                        final File file = File(pickedFile.path);

                        final exists = await file.exists();
                        debugPrint('📁 File esiste? $exists');

                        if (!exists) {
                          throw PlatformException(
                            code: 'no_valid_image_uri',
                            message: 'Il file selezionato non esiste più o non è accessibile.',
                          );
                        }

                        setState(() {
                          selectedImage = file;
                        });

                        debugPrint('⏫ Inizio upload su Firebase Storage...');
                        final storageRef = FirebaseStorage.instance
                            .ref()
                            .child('profile_pictures/$uid.jpg');

                        try {
                          final UploadTask uploadTask = storageRef.putFile(file);

                          final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

                          if (snapshot.state == TaskState.success) {
                            final imageUrl = await snapshot.ref.getDownloadURL();
                            debugPrint('✅ Upload completato. URL: $imageUrl');

                            setState(() {
                              uploadedPhotoUrl = imageUrl;
                            });
                          } else {
                            debugPrint('❌ Upload fallito. Stato: ${snapshot.state}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Errore nel caricamento dell\'immagine.')),
                            );
                          }
                        } catch (e) {
                          debugPrint('❌ Errore durante l\'upload o il recupero dell\'URL: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Errore nel caricamento dell\'immagine.')),
                          );
                        }

                      } on PlatformException catch (e) {
                        debugPrint('❌ Errore PlatformException: ${e.code} - ${e.message}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: ${e.message}')),
                        );
                      } catch (e, stack) {
                        debugPrint('❌ Errore generico: $e');
                        debugPrint('📜 Stack trace: $stack');
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

                  final docRef = FirebaseFirestore.instance.collection(role.toLowerCase()).doc(uid);
                  final doc = await docRef.get();
                  final currentData = doc.data();
                  final currentPhoto = currentData?['profileImageUrl'];

                  const String defaultPhotoURL = 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
                  final String finalPhotoURL = uploadedPhotoUrl ??
                                              (currentPhoto != null && currentPhoto.isNotEmpty ? currentPhoto : defaultPhotoURL);

                  // Se nessun aggiornamento ma l'utente ha già dati validi, chiudi comunque il dialog
                  if (name.isEmpty && (finalPhotoURL.isEmpty)) {
                    if(mounted) Navigator.of(context).pop(); // chiudi senza fare update
                    return;
                  }


                  // Costruisci mappa degli aggiornamenti
                  final Map<String, dynamic> updates = {};
                  if (name.isNotEmpty) {
                    updates['username'] = name;
                    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
                  }
                  if (finalPhotoURL.isNotEmpty) {
                    updates['profileImageUrl'] = finalPhotoURL;
                    await FirebaseAuth.instance.currentUser?.updatePhotoURL(finalPhotoURL);
                  }

                  // Salva su Firestore
                  if (updates.isNotEmpty) {
                    await docRef.update(updates);

                    setState(() {
                      userData = {
                        'username': updates['username'] ?? currentData?['username'],
                        'profileImageUrl': updates['profileImageUrl'] ?? currentData?['profileImageUrl'],
                      };
                    });
                  }

                  if(mounted) Navigator.of(context).pop(); // Chiudi il dialog
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
