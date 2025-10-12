import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frogtunes/AME/home_ame.dart';
import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/AME/reg_ame.dart';

class LoginAMEView extends StatefulWidget {
  const LoginAMEView({super.key});
  @override
  LoginAMEViewState createState() => LoginAMEViewState();
}

class LoginAMEViewState extends State<LoginAMEView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  // Funzione di login con Firebase Authentication
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
      // Effettua il login con email e password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifica se l'utente esiste nel database Firestore
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Utente non trovato.');
      }else{
        // In base al ruolo selezionato, verifica l'esistenza del documento corrispondente
        if(selectedRole == 'Artista'){
          final doc = await FirebaseFirestore.instance.collection('artisti').doc(uid).get();
          if (!doc.exists) {
            throw FirebaseAuthException(code: 'user-data-not-found', message: 'Dati utente non trovati.');
          }
        } else if(selectedRole == 'Manager'){
          final doc = await FirebaseFirestore.instance.collection('manager').doc(uid).get();
          if (!doc.exists) {
            throw FirebaseAuthException(code: 'user-data-not-found', message: 'Dati utente non trovati.');
          }
        } else if(selectedRole == 'Etichetta'){
          final doc = await FirebaseFirestore.instance.collection('etichette').doc(uid).get();
          if (!doc.exists) {
            throw FirebaseAuthException(code: 'user-data-not-found', message: 'Dati utente non trovati.');
          }
          final ruoloRegistrato = doc.data()?['tipologia'];
          if (ruoloRegistrato != selectedRole) {
            // Mostra un messaggio di errore se il ruolo non corrisponde
            if(context.mounted){
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
            }
            return;
          }
        }
      }

      if(context.mounted){
        // Naviga alla schermata principale dopo il login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeAMEView(selectedRole: selectedRole!),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if(context.mounted){
        // Mostra un messaggio di errore in caso di fallimento del login
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
              const SizedBox(height: 60),
              const Text(
                'FrogTunes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Business',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 60),
              // Input email
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
              // Input password
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
              // Selezione ruolo
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
              Row(
                children: [
                  // Pulsante di login
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => loginAME(context),
                      child: const Text('Login', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Pulsante di registrazione
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
                ],
              ),
              const SizedBox(height: 30),
              // Pulsante per tornare al login utente
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                },
                child: const Text('Torna indietro', style: TextStyle(color: Colors.green)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
