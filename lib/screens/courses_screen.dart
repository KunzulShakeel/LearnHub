import 'package:flutter/material.dart';
import '../enums/app_enums.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import 'course_form_screen.dart';

/// Displays the list of courses fetched from the JSONPlaceholder API and
/// lets the user Add / Edit / Delete courses (full CRUD).
///
/// UI state (loading / success / error) is tracked via [ApiStatus].
/// All network calls are delegated to [CourseService] — this widget only
/// deals with presentation and user interaction.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService _courseService = CourseService();

  ApiStatus _status = ApiStatus.loading;
  List<CourseModel> _courses = [];
  String _errorMessage = '';

  // Tracks which course id currently has an action (update/delete) in
  // flight, so we can show an inline spinner on just that item.
  int? _mutatingCourseId;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _status = ApiStatus.loading;
      _errorMessage = '';
    });

    try {
      final courses = await _courseService.fetchCourses();
      setState(() {
        _courses = courses;
        _status = ApiStatus.success;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _status = ApiStatus.error;
      });
    }
  }

  Future<void> _goToAddCourse() async {
    final newCourse = await Navigator.push<CourseModel>(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );

    if (newCourse == null) return;

    try {
      final created = await _courseService.addCourse(newCourse);
      setState(() {
        _courses.insert(0, created);
      });
      _showSnackBar("Course added successfully");
    } catch (e) {
      _showSnackBar("Failed to add course: $e", isError: true);
    }
  }

  Future<void> _goToEditCourse(CourseModel course) async {
    final updated = await Navigator.push<CourseModel>(
      context,
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );

    if (updated == null) return;

    setState(() => _mutatingCourseId = course.id);
    try {
      final saved = await _courseService.updateCourse(updated);
      setState(() {
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index != -1) _courses[index] = saved;
      });
      _showSnackBar("Course updated successfully");
    } catch (e) {
      _showSnackBar("Failed to update course: $e", isError: true);
    } finally {
      setState(() => _mutatingCourseId = null);
    }
  }

  Future<void> _confirmAndDelete(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Course"),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true || course.id == null) return;

    setState(() => _mutatingCourseId = course.id);
    try {
      await _courseService.deleteCourse(course.id!);
      setState(() {
        _courses.removeWhere((c) => c.id == course.id);
      });
      _showSnackBar("Course deleted successfully");
    } catch (e) {
      _showSnackBar("Failed to delete course: $e", isError: true);
    } finally {
      setState(() => _mutatingCourseId = null);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case ApiStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ApiStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 12),
                const Text(
                  "Failed to load courses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadCourses,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        );

      case ApiStatus.success:
        if (_courses.isEmpty) {
          return const Center(child: Text("No courses yet. Tap + to add one."));
        }
        return RefreshIndicator(
          onRefresh: _loadCourses,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              final isMutating = _mutatingCourseId == course.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      "${course.id ?? '?'}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: isMutating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _goToEditCourse(course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmAndDelete(course),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses (Live API)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _status == ApiStatus.loading ? null : _loadCourses,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddCourse,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
