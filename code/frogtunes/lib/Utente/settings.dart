import 'dart:io';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _notificationsEnabled = true;
  File? _selectedImage;

  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Funzione per selezionare un'immagine dal dispositivo
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Funzione per salvare le impostazioni
  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;
    final username = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      // Aggiorna email
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
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

      // Carica immagine profilo se presente
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$uid.jpg');
        await ref.putFile(_selectedImage!);
        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('utenti').doc(uid).update({
          'profileImageUrl': imageUrl,
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Cambio username
                TextField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Cambia nome utente'),
                ),
                const SizedBox(height: 20),
                // Cambio email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Nuova email'),
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
            const ExpansionTile(
              title: Text("Informazioni",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              iconColor: Colors.white,
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
