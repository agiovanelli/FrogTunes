// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frogtunes/AME/statistics.dart';

class ProfileEView extends StatefulWidget {
  const ProfileEView({super.key});

  @override
  ProfileEViewState createState() => ProfileEViewState();
}

class ProfileEViewState extends State<ProfileEView> {
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
    final doc = await FirebaseFirestore.instance.collection('etichette').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
      setState(() {
        userName = data['nome']?.toString().trim().isNotEmpty == true
            ? data['nome']
            : 'Etichetta';

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
            const SizedBox(height: 40),
            // Widget Guadagni
            WidgetGuadagni(etichettaId: user!.uid),
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
    if (mounted) {
      final confirm =
      await showDialog<bool>(
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
            .collection('etichette')
            .doc(user.uid)
            .update({'cover': url});
        if (!mounted) return;
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
                      .collection('etichette')
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

class WidgetGuadagni extends StatefulWidget {
  final String etichettaId;
  const WidgetGuadagni({super.key, required this.etichettaId});

  @override
  State<WidgetGuadagni> createState() => _WidgetGuadagniState();
}

class _WidgetGuadagniState extends State<WidgetGuadagni> {
  double totalEarnings = 0;
  bool loading = false;
  bool requested = false;

  Future<void> _calculateTotalEarnings() async {
    setState(() { loading = true; });
    final managerSnap = await FirebaseFirestore.instance
      .collection('etichette')
      .doc(widget.etichettaId)
      .collection('managers')
      .get();

    final managerIds = managerSnap.docs.map((doc) => doc.data()['uid'] as String).where((id) => id.isNotEmpty).toList();
    double sum = 0;
    for (final managerId in managerIds) {
      final managedSnap = await FirebaseFirestore.instance
        .collection('manager')
        .doc(managerId)
        .collection('managedArtists')
        .get();

      final artistIds = managedSnap.docs.map((doc) => doc.data()['uid'] as String).where((id) => id.isNotEmpty).toList();
      for (final artistId in artistIds) {
        final songsSnap = await FirebaseFirestore.instance
          .collection('canzoni')
          .where('artistId', arrayContains: artistId)
          .get();

        for (final songDoc in songsSnap.docs) {
          try {
            final song = await Song(songId: songDoc.id).fetchSongDetails();
            sum += song.earnings;
          } catch (_) {}
        }
      }
    }
    setState(() {
      totalEarnings = sum;
      loading = false;
    });
  }

  // Logica per inviare la richiesta a FrogTunes
  Future<void> _requestPayout() async {
    setState(() { requested = true; });
    
    await FirebaseFirestore.instance.collection('payoutRequests').add({
      'etichettaId': widget.etichettaId,
      'amount': totalEarnings,
      'timestamp': Timestamp.now(),
    });
    // Conferma
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Richiesta inviata a FrogTunes!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateTotalEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: loading || requested ? null : _requestPayout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Incassa', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          loading
            ? const CircularProgressIndicator()
            : Text('Totale guadagni: €${totalEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (requested)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Richiesta inviata! Riceverai il pagamento da FrogTunes.', 
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center
              ),
            ),
        ],
      ),
    );
  }
}