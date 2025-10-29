import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frogtunes/Utente/home.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _notificationsEnabled = true;
  String selectedImage = '';

  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
      setState(() {
        selectedImage = data['profileImageUrl']?.toString().trim().isNotEmpty == true
            ? data['profileImageUrl']
            : 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
      });
    }
  }
}

  // Funzione per selezionare un'immagine dal dispositivo
  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // Conferma prima di salvare
    if(mounted){
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
            .collection('utenti')
            .doc(user.uid)
            .update({'profileImageUrl': url});
        setState(() {
          selectedImage = url;
        });
      }
    }
  }

  // Funzione di dialog per chiedere la password corrente
Future<String?> _askCurrentPassword() async {
  String? password;
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Password attuale richiesta"),
      content: TextField(
        obscureText: true,
        onChanged: (val) => password = val,
        decoration: const InputDecoration(
          labelText: "Password attuale",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Annulla"),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
  return password;
}

  // Funzione per salvare le impostazioni
  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;
    final username = _usernameController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
    // Riautenticazione se vogliamo cambiare password
    if(newPassword.isNotEmpty){
      
      // Chiedi all'utente di inserire la password attuale
      final currentPassword = await _askCurrentPassword();

      if (currentPassword != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
      } else {
        // L'utente ha annullato l'inserimento della password
        return;
      }
    }

      // Aggiorna password
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      // Aggiorna username su Firestore
      if (username.isNotEmpty) {
        await FirebaseFirestore.instance.collection('utenti').doc(uid).update({
          'username': username,
        });
      }

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impostazioni aggiornate con successo!")),
        );
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nel salvataggio delle impostazioni: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        title: const Text("Impostazioni e privacy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_backspace_rounded,
                color: Colors.white),
            // Bottone che riporta alla homeView
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text("Credenziali",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                // Cambio di immagine profilo
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipOval(
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[800],
            child: selectedImage.isNotEmpty
              ? (selectedImage.startsWith('http')
                ? Image.network(
                  selectedImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 60, color: Colors.white70),
                )
                : Image.asset(selectedImage, fit: BoxFit.cover))
              : const Center(
                child: Icon(Icons.person, size: 60, color: Colors.white70),
              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Cambio username
                TextField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Cambia nome utente'),
                ),
                const SizedBox(height: 20),
                // Cambio password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Nuova password'),
                ),
                const SizedBox(height: 20),
                // Bottone per salvare le modifiche
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text("Salva",
                      style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sezione notifiche
            ExpansionTile(
              title: const Text("Notifiche",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                // Abilitare o meno le notifiche (fittizio)
                SwitchListTile(
                  title: const Text("Abilita notifiche"),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green[900],
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red[900],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Sezione privacy REINDIRIZZERA' SUL FILE REALI
            ExpansionTile(
              title: const Text(
                "Privacy",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                ListTile(
                  title: const Text("Politica sulla privacy"),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("Termini di servizio"),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sezione informazioni
            ExpansionTile(
              title: const Text("Informazioni",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                ListTile(title: Text("Versione: 1.0.0")),
                ListTile(title: Text("Sviluppatore: Alessio Giovanelli")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.green),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Colors.green),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Colors.green, width: 3),
      ),
    );
  }
}
