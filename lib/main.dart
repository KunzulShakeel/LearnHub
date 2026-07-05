import 'package:flutter/material.dart';
import 'local/course_local_service.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Hive must be initialized before any screen tries to read/write the
  // offline course cache.
  WidgetsFlutterBinding.ensureInitialized();
  await CourseLocalService.init();

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
