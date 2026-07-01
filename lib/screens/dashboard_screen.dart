import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;

  DashboardScreen({
    super.key,
    required this.userName,
  });

  final List<SubjectModel> subjects = [
    SubjectModel(
      name: "Mobile App Development",
      description:
          "This course focuses on building mobile applications using Flutter, Dart, UI design, navigation, and form validation.",
      schedule: "Monday & Wednesday - 10:00 AM to 11:30 AM",
    ),
    SubjectModel(
      name: "Software Re-engineering",
      description:
          "This course covers software maintenance, code restructuring, reverse engineering, and improving existing systems.",
      schedule: "Tuesday - 12:00 PM to 2:00 PM",
    ),
    SubjectModel(
      name: "Management Information Systems (MIS)",
      description:
          "This course explains how information systems support business operations, decision making, and management.",
      schedule: "Thursday - 9:00 AM to 11:00 AM",
    ),
  ];

  Widget subjectCard(BuildContext context, SubjectModel subject) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.book, color: Colors.white),
        ),
        title: Text(subject.name),
        subtitle: const Text("Tap to view details"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(subject: subject),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LearnHub Student Portal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Welcome, $userName",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Student Dashboard",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Subjects",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            for (final subject in subjects) subjectCard(context, subject),
          ],
        ),
      ),
    );
  }
}