import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';

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

  // Recupera gli artisti gestiti dall'utente manager
  Future<List<Map<String, dynamic>>> _fetchManagedArtists() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final subcollection = await FirebaseFirestore.instance
      .collection('manager')
      .doc(userId)
      .collection('managedArtists')
      .orderBy('addedAt', descending: true)
      .get();

    final artists = <Map<String, dynamic>>[];
    for (var doc in subcollection.docs) {
      final artistId = doc.data()['uid'];
      final artistDoc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
      if (artistDoc.exists) {
        final artistData = artistDoc.data() ?? {};
        artists.add({
          'nome': artistData['nome'] ?? 'Artista sconosciuto',
          'addedAt': doc.data()['addedAt'],
          'uid': artistId,
        });
      }
    }
    return artists;
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
            Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text('I tuoi artisti',
                        style: TextStyle(fontSize: 26, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchManagedArtists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nessun artista gestito', style: TextStyle(color: Colors.white)));
                  }
                  final artists = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return ListTile(
                        leading: const Icon(Icons.person_2_sharp, color: Colors.white),
                        title: Text(artist['nome'], style: const TextStyle(color: Colors.white)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistScreen(
                                artistId: artist['uid'],
                                nomeArtista: artist['nome'],
                                control: true,
                              ),
                            ),
                          );
                          setState(() {}); // Refresh dopo ritorno
                        },
                      );
                    },
                  );
                },
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
    if(mounted){
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
          cursorColor: Color(0xFF00FF00),
          decoration: const InputDecoration(
            labelText: 'Nome',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.green,
            border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
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