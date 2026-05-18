import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const NovaBankApp());
}

class NovaBankApp extends StatelessWidget {
  const NovaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaBank',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),
      home: const LoginPage(),
    );
  }
}