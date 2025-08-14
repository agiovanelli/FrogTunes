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
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;
    final username = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      // 1. Aggiorna email
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.updateEmail(newEmail);
      }

      // 2. Aggiorna password
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      // 3. Aggiorna username su Firestore
      if (username.isNotEmpty) {
        await FirebaseFirestore.instance.collection('utenti').doc(uid).update({
          'username': username,
        });
      }

      // 4. Carica immagine profilo se presente
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impostazioni aggiornate con successo!")),
      );
    } catch (e) {
      print("Errore nel salvataggio delle impostazioni: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: ${e.toString()}")),
      );
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
                TextField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Cambia nome utente'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Nuova email'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Nuova password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text("Salva",
                      style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text("Notifiche",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              iconColor: Colors.white,
              children: [
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
