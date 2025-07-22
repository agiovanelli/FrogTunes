import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/Utente/home.dart';
import 'package:frogtunes/AME/loginAME.dart';
import 'package:frogtunes/Utente/reg.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginView({super.key});

  Future<void> loginUtente(BuildContext context) async {
    try {
      // Tentativo di login con Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Se login riuscito, vai alla Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } on FirebaseAuthException catch (e) {
      // Mostra un messaggio di errore
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Errore di login'),
          content: Text(e.message ?? 'Errore sconosciuto'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(30.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 100),
        const Text(
          'FrogTunes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 80),
        TextField(
          controller: emailController,
          cursorColor: Colors.green,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
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
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          decoration: const InputDecoration(
            labelText: 'Password',
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
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => loginUtente(context),
                child: const Text('Login', style: TextStyle(color: Colors.green)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrazioneView()),
                  );
                },
                child: const Text('Registrazione', style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        const Text(
          'Sei un artista, un manager o un\'etichetta?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginAMEView()),
            );
          },
          child: const Text(
            'Clicca qui per cambiare account',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    ),
  ),
),

    );
  }
}
