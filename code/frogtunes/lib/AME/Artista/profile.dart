import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String userName = 'Nome Artista';
  String bio =
      'Questa è una breve biografia dell\'artista. Qui puoi scrivere qualcosa su di te!';
  String profileImage =
      'https://www.shutterstock.com/image-vector/cute-frog-cartoon-vector-illustration-600nw-2426110363.jpg';
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
                const SizedBox(width: 40),
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
  void _changeProfileImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          title: const Text('Cambia immagine',
              style: TextStyle(color: Colors.white)),
          content: const Text('Seleziona una nuova immagine profilo.',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                // Logica per selezionare un'immagine (es. ImagePicker)
                Navigator.pop(context);
              },
              child: const Text('Scegli immagine',
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Annulla', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Funzione per cambiare il nome utente
  void _changeUserName() {
    TextEditingController nameController =
        TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          title: const Text('Modifica Nome',
              style: TextStyle(color: Colors.white)),
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
              onPressed: () {
                setState(() {
                  userName = nameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Salva', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Annulla', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Funzione per cambiare la biografia
  void _changeBio() {
    TextEditingController bioController = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          title: const Text('Modifica Biografia',
              style: TextStyle(color: Colors.white)),
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
              onPressed: () {
                setState(() {
                  bio = bioController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Salva', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Annulla', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
