import 'package:flutter/material.dart';
import 'package:frogtunes/home.dart';

class LoginView extends StatelessWidget {
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
              'FrogTunes',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 100),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Username / Email',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                  labelStyle: TextStyle(color: Colors.green)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green)),
                  labelStyle: TextStyle(color: Colors.green)),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeView()),
                    );
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
                      MaterialPageRoute(builder: (context) => const HomeView()),
                    );
                  },
                  child: const Text('Registrazione',
                      style: TextStyle(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 20),
            ]),
            const SizedBox(height: 200),
            const Text('Sei un artista, un manager o un\'etichetta?',
                style: TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Artista',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Manager',
                      style: TextStyle(color: Colors.green)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Etichetta',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ]),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
