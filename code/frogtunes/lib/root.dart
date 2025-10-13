import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frogtunes/AME/home_ame.dart';
import 'package:frogtunes/Utente/login.dart';
import 'package:frogtunes/Utente/home.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  Future<Widget> _getHomeForUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginView();
    }

    final uid = user.uid;

    final t1 = await FirebaseFirestore.instance.collection('utenti').doc(uid).get();
    final t2 = await FirebaseFirestore.instance.collection('artisti').doc(uid).get();
    final t3 = await FirebaseFirestore.instance.collection('manager').doc(uid).get();
    final t4 = await FirebaseFirestore.instance.collection('etichette').doc(uid).get();

    if (t1.exists) return HomeView();
    if (t2.exists) return HomeAMEView(selectedRole: 'Artista');
    if (t3.exists) return HomeAMEView(selectedRole: 'Manager');
    if (t4.exists) return HomeAMEView(selectedRole: 'Etichetta');

    return LoginView();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getHomeForUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }

        return snapshot.data ?? LoginView();
      },
    );
  }
}
