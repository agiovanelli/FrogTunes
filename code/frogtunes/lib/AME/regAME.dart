import 'package:flutter/material.dart';
import 'package:frogtunes/AME/loginAME.dart';

class RegistrazioneAMEView extends StatefulWidget {
  const RegistrazioneAMEView({super.key});

  @override
  _RegistrazioneAMEViewState createState() => _RegistrazioneAMEViewState();
}

class _RegistrazioneAMEViewState extends State<RegistrazioneAMEView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender; // Variabile per gestire il valore selezionato

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            const Text(
              'Registrazione',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: emailController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                labelText: 'Inserisci la tua email',
                labelStyle: TextStyle(color: Colors.green),
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
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                labelText: 'Crea una password',
                labelStyle: TextStyle(color: Colors.green),
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
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleziona tipologia account:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            RadioListTile<String>(
              title:
                  const Text('Artista', style: TextStyle(color: Colors.white)),
              value: 'Artista',
              groupValue: selectedGender,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            RadioListTile<String>(
              title:
                  const Text('Manager', style: TextStyle(color: Colors.white)),
              value: 'Manager',
              groupValue: selectedGender,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Etichetta',
                  style: TextStyle(color: Colors.white)),
              value: 'Etichetta',
              groupValue: selectedGender,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 40), // Larghezza massima e altezza di 50
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginAMEView()),
                );
              },
              child: const Text(
                'Registrati',
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 40), // Larghezza massima e altezza di 50
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginAMEView()),
                );
              },
              child: const Text(
                'Hai già un account?',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
