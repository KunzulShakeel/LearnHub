import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class DetailScreen extends StatelessWidget {
  final SubjectModel subject;

  const DetailScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.school,
                size: 90,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              subject.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Course Description",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              subject.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            const Text(
              "Schedule",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule, color: Colors.deepPurple),
                title: Text(subject.schedule),
              ),
            ),
          ],
        ),
      ),
    );
  }
}