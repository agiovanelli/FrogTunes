import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/Utente/home.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Se l'utente non è loggato mostra LoginView
    if (user == null) {
      return LoginView();
    }

    // Se l'utente è loggato mostra HomeView
    return const HomeView();
  }
}
