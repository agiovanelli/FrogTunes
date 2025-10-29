import 'package:flutter/material.dart';
import 'package:frogtunes/AME/home_ame.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsAMEPage extends StatefulWidget {
  const SettingsAMEPage({super.key, required this.selectedRole});
  final String selectedRole; // Accetta il valore passato

  @override
  SettingsAMEPageState createState() => SettingsAMEPageState();
}

class SettingsAMEPageState extends State<SettingsAMEPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newPassword = _passwordController.text.trim();

    try {
    // Riautenticazione se vogliamo cambiare email o password
    if (newPassword.isNotEmpty) {
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
                MaterialPageRoute(
                    builder: (context) =>
                        HomeAMEView(selectedRole: widget.selectedRole)),
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
              title: const Text(
                "Credenziali",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Nuova password',
                    labelStyle:
                        TextStyle(color: Colors.green), // Colore del label
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                          color: Colors.green,
                          width: 3), // Puoi cambiare lo spessore
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text(
                    "Salva",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ExpansionTile(
              title: const Text(
                "Notifiche",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              iconColor: Colors.white,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                SwitchListTile(
                  title: const Text("Abilita notifiche"),
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green[900],
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red[900],
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
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
            const SizedBox(
              height: 20,
            ),
            const ExpansionTile(
              title: Text(
                "Informazioni",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color.fromARGB(255, 4, 35, 5)),
              ),
              children: [
                ListTile(
                  title: Text("Versione: 1.0.0"),
                ),
                ListTile(
                  title: Text("Sviluppatore: Alessio Giovanelli"),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
