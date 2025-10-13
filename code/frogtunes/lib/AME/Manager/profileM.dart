import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frogtunes/AME/add_release.dart';

class ProfileMView extends StatefulWidget {
  const ProfileMView({super.key});

  @override
  ProfileMViewState createState() => ProfileMViewState();
}

class ProfileMViewState extends State<ProfileMView> {
  Map<String, dynamic>? userData;
  final user = FirebaseAuth.instance.currentUser;

  String userName = '';
  String bio = '';
  String profileImage = '';
  List<String> userId = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('manager').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
      setState(() {
        userName = data['nome']?.toString().trim().isNotEmpty == true
            ? data['nome']
            : 'Manager';

        profileImage = data['cover']?.toString().trim().isNotEmpty == true
            ? data['cover']
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
                      backgroundImage: profileImage.startsWith('http')
                          ? NetworkImage(profileImage)
                          : AssetImage(profileImage) as ImageProvider,
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
                const SizedBox(width: 40),
                // Nome utente con bottone per modificarlo
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
            // Bottone per aggiungere un nuovo brano
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.green[900],
                      title: const Text('Tipo di release', style: TextStyle(color: Colors.white)),
                      content: const Text('Questa è una release singola o fa parte di un album?', style: TextStyle(color: Colors.white)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Singola', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Album', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    if(context.mounted){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReleasePage(
                            artistIds: userId,
                            isSingle: result, // true = singola, false = album
                          ),
                        ),
                      );
                    }
                  }
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
            const SizedBox(height: 50),
            // Bottone per aggiungere un nuovo brano
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.green[900],
                      title: const Text('Tipo di release', style: TextStyle(color: Colors.white)),
                      content: const Text('Questa è una release singola o fa parte di un album?', style: TextStyle(color: Colors.white)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Singola', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Album', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    if(context.mounted){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReleasePage(
                            artistIds: userId,
                            isSingle: result, // true = singola, false = album
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi testo ad un brano'),
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

    // Conferma prima di salvare
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[900],
        title: const Text('Conferma modifica foto', style: TextStyle(color: Colors.white)),
        content: const Text('Vuoi davvero salvare la nuova foto profilo?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (pickedFile == null || user == null) return;

    final file = await pickedFile.readAsBytes();
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');

    final uploadTask = await ref.putData(file);
    final url = await uploadTask.ref.getDownloadURL();

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('manager')
          .doc(user.uid)
          .update({'cover': url});
      setState(() {
        profileImage = url;
      });
    }
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
        title: const Text('Modifica il tuo nome', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome',
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
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.green[900],
                    title: const Text('Conferma modifica nome', style: TextStyle(color: Colors.white)),
                    content: const Text('Vuoi davvero salvare il nuovo nome?', style: TextStyle(color: Colors.white)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Conferma', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseFirestore.instance
                      .collection('manager')
                      .doc(user.uid)
                      .update({'nome': newName});
                  setState(() {
                    userName = newName;
                  });
                }
              }
              if(context.mounted){
                Navigator.pop(context);
              }
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