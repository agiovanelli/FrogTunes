import 'package:flutter/material.dart';
import 'package:frogtunes/AME/homeAME.dart';

class SettingsAMEPage extends StatefulWidget {
  const SettingsAMEPage({super.key, required this.selectedRole});
  final String selectedRole; // Accetta il valore passato

  @override
  _SettingsAMEPageState createState() => _SettingsAMEPageState();
}

class _SettingsAMEPageState extends State<SettingsAMEPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Logica per salvare le impostazioni
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    print('Salvataggio impostazioni:');
    print("Username: $username");
    print("Email: $email");
    print("Password: $password");
    print("Notifiche abilitate: $_notificationsEnabled");
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
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Cambia nome utente',
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
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Nuova email',
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
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
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
