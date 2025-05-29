import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? selectedRole;

  Future<void> loginAME(BuildContext context) async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty || selectedRole == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Compila tutti i campi e seleziona un ruolo"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    // Login Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'Utente non trovato.');
    }

    // Prendi il ruolo da Firestore
    final doc = await FirebaseFirestore.instance.collection('utenti_ame').doc(uid).get();

    if (!doc.exists) {
      throw FirebaseAuthException(code: 'user-data-not-found', message: 'Dati utente non trovati.');
    }

    final ruoloRegistrato = doc.data()?['tipologia'];
    if (ruoloRegistrato != selectedRole) {
      // Ruolo non corrisponde: blocca accesso
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accesso negato'),
          content: Text('Hai selezionato il ruolo "$selectedRole" ma il tuo account è di tipo "$ruoloRegistrato".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Ruolo corrisponde, vai alla Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeAMEView(selectedRole: selectedRole!),
      ),
    );
  } on FirebaseAuthException catch (e) {
    // Mostra errore di login
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
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 130),
            const Text(
              'FrogTunes',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              'Business',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 100),
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
              obscureText: true,
              cursorColor: Colors.green,
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('A', style: TextStyle(color: Colors.white)),
                    value: 'Artista',
                    groupValue: selectedRole,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('M', style: TextStyle(color: Colors.white)),
                    value: 'Manager',
                    groupValue: selectedRole,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('E', style: TextStyle(color: Colors.white)),
                    value: 'Etichetta',
                    groupValue: selectedRole,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => loginAME(context),
                  child: const Text('Login', style: TextStyle(color: Colors.green)),
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrazioneAMEView()),
                    );
                  },
                  child: const Text('Registrazione', style: TextStyle(color: Colors.green)),
                ),
              ),
            ]),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
              child: const Text('Torna indietro', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}
