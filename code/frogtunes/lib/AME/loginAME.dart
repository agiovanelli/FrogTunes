import 'package:flutter/material.dart';
import 'package:frogtunes/AME/homeAME.dart';
import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/AME/regAME.dart';

class LoginAMEView extends StatefulWidget {
  const LoginAMEView({super.key});
  @override
  _LoginAMEViewState createState() => _LoginAMEViewState();
}

class _LoginAMEViewState extends State<LoginAMEView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender; // Variabile per gestire il valore selezionato

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            const Text(
              'FrogTunes',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Business',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 100),
            TextField(
              controller: emailController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                labelText: 'Username / Email',
                labelStyle: TextStyle(color: Colors.green), // Colore del label
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
                      width: 2), // Puoi cambiare lo spessore
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              cursorColor: Colors.green, // Colore del cursore lampeggiante
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.green), // Colore del label
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
                      width: 2), // Puoi cambiare lo spessore
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Per centrare gli elementi
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title:
                        const Text('A', style: TextStyle(color: Colors.white)),
                    value: 'Artista',
                    groupValue: selectedGender,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title:
                        const Text('M', style: TextStyle(color: Colors.white)),
                    value: 'Manager',
                    groupValue: selectedGender,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title:
                        const Text('E', style: TextStyle(color: Colors.white)),
                    value: 'Etichetta',
                    groupValue: selectedGender,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedGender != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeAMEView(selectedRole: selectedGender!),
                        ),
                      );
                    } else {
                      // Mostra un messaggio se non è stata selezionata alcuna opzione
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Seleziona un'opzione prima di procedere"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrazioneAMEView()),
                    );
                  },
                  child: const Text('Registrazione',
                      style: TextStyle(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 5),
            ]),
            const SizedBox(height: 50),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  },
                  child: const Text(
                    'Torna indietro',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
