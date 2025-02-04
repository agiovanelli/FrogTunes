import 'package:flutter/material.dart';
import 'package:frogtunes/login.dart';

class RegistrazioneView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              'Registrazione',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 100),
            TextField(
              controller: emailController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                labelText: 'Inserisci la tua email',
                labelStyle: TextStyle(color: Colors.green), // Colore del label
                border: OutlineInputBorder(
                  // Bordo di default
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  // Bordo quando non è in focus
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  // Bordo quando è in focus
                  borderSide: BorderSide(
                      color: Colors.green,
                      width: 2), // Puoi cambiare lo spessore
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                labelText: 'Crea una password',
                labelStyle: TextStyle(color: Colors.green), // Colore del label
                border: OutlineInputBorder(
                  // Bordo di default
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  // Bordo quando non è in focus
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  // Bordo quando è in focus
                  borderSide: BorderSide(
                      color: Colors.green,
                      width: 2), // Puoi cambiare lo spessore
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 40),
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
                    'Registrati',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ]),
            const SizedBox(height: 20),
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
                    'Hai già un account?',
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
