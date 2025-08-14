import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/AME/loginAME.dart';

class RegistrazioneAMEView extends StatefulWidget {
  const RegistrazioneAMEView({super.key});

  @override
  _RegistrazioneAMEViewState createState() => _RegistrazioneAMEViewState();
}

class _RegistrazioneAMEViewState extends State<RegistrazioneAMEView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedAccountType;

  Future<void> registraUtente() async {
    if (selectedAccountType == null) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Seleziona un tipo di account'),
          content: Text('Devi selezionare una tipologia di account per continuare.'),
        ),
      );
      return;
    }

    try {
      // Registrazione Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Salva info su Firestore
        await FirebaseFirestore.instance.collection('utenti_ame').doc(user.uid).set({
          'email': user.email,
          'uid': user.uid,
          'tipologia': selectedAccountType,
          'dataRegistrazione': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginAMEView()),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Errore di registrazione'),
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
    body: SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
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
                  keyboardType: TextInputType.emailAddress,
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
                  obscureText: true,
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
                ),
                const SizedBox(height: 20),
                const Text(
                  'Seleziona tipologia account:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                RadioListTile<String>(
                  title: const Text('Artista', style: TextStyle(color: Colors.white)),
                  value: 'Artista',
                  groupValue: selectedAccountType,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      selectedAccountType = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Manager', style: TextStyle(color: Colors.white)),
                  value: 'Manager',
                  groupValue: selectedAccountType,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      selectedAccountType = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Etichetta', style: TextStyle(color: Colors.white)),
                  value: 'Etichetta',
                  groupValue: selectedAccountType,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      selectedAccountType = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: registraUtente,
                  child: const Text(
                    'Registrati',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginAMEView()),
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
        ),
      ),
    ),
  );
}
}
