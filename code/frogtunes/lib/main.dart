import 'package:flutter/material.dart';
import 'package:frogtunes/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrogTunes',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: LoginView(),
    );
  }
}