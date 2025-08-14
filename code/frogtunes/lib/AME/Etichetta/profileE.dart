import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileEView extends StatefulWidget {
  const ProfileEView({super.key});

  @override
  _ProfileEViewState createState() => _ProfileEViewState();
}

class _ProfileEViewState extends State<ProfileEView> {
  Map<String, dynamic>? userData;

  String userName = '';
  String bio = '';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('utenti_ame').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
      setState(() {
        userName = data['username']?.toString().trim().isNotEmpty == true
            ? data['username']
            : 'Etichetta';

        bio = data['bio']?.toString().trim().isNotEmpty == true
            ? data['bio']
            : 'Questa è una breve biografia dell\'artista. Qui puoi scrivere qualcosa su di te!';

        profileImage = data['profileImageUrl']?.toString().trim().isNotEmpty == true
            ? data['profileImageUrl']
            : 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sezione Profilo (Foto + Nome)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto profilo con bottone per modificarla
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(profileImage),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 35,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 30),
                        onPressed: () => _changeProfileImage(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                // Nome Utente con bottone per modificarlo
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _changeUserName(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Biografia con bottone per modificarla
            Container(
              padding: const EdgeInsets.all(12),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bio,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _changeBio(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Bottone per aggiungere un nuovo brano
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Azione per aggiungere un nuovo brano
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi un nuovo brano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }

  // Funzione per cambiare la foto profilo
  Future<void> _changeProfileImage() async {
  final user = FirebaseAuth.instance.currentUser;
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null || user == null) return;

  final file = pickedFile.readAsBytes();
  final ref = FirebaseStorage.instance
      .ref()
      .child('profile_pictures')
      .child('${user.uid}.jpg');

  final uploadTask = await ref.putData(await file);
  final url = await uploadTask.ref.getDownloadURL();

  await FirebaseFirestore.instance
      .collection('utenti_ame')
      .doc(user.uid)
      .update({'profileImageUrl': url});

  setState(() {
    profileImage = url;
  });
}


  // Funzione per cambiare il nome utente
  void _changeUserName() {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController nameController = TextEditingController(text: userName);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.green[900],
        title: const Text('Modifica Nome', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Utente',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green,
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (user != null && newName.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('utenti_ame')
                    .doc(user.uid)
                    .update({'username': newName});
                setState(() {
                  userName = newName;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
  // Funzione per cambiare la biografia
  void _changeBio() {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController bioController = TextEditingController(text: bio);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.green[900],
        title: const Text('Modifica Biografia', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Biografia',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green,
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newBio = bioController.text.trim();
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('utenti_ame')
                    .doc(user.uid)
                    .update({'bio': newBio});
                setState(() {
                  bio = newBio;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
}
