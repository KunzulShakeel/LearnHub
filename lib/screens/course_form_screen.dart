import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../validators/app_validator.dart';

/// Shared Add/Edit form for a Course.
///
/// If [course] is passed in, the form is pre-filled and acts as an
/// "edit" screen (PUT). Otherwise it acts as an "add" screen (POST).
/// This screen only collects/validates input — it does not talk to the
/// API itself. It returns the resulting [CourseModel] via
/// `Navigator.pop(context, course)`, and the caller (CoursesScreen) is
/// responsible for calling the service layer.
class CourseFormScreen extends StatefulWidget {
  final CourseModel? course;

  const CourseFormScreen({super.key, this.course});

  bool get isEditing => course != null;

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.course?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.course?.description ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final result = CourseModel(
      id: widget.course?.id,
      userId: widget.course?.userId ?? 1,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Course" : "Add Course"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Course Title",
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    AppValidator.validateEmpty(value ?? '', "Title"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Course Description",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    AppValidator.validateEmpty(value ?? '', "Description"),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(widget.isEditing ? Icons.save : Icons.add),
                label: Text(widget.isEditing ? "Save Changes" : "Add Course"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
