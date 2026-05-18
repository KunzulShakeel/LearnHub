import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const NovaBankApp());
}

class NovaBankApp extends StatelessWidget {
  const NovaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnHub',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginScreen(),
    );
  }
}