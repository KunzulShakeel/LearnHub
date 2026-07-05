import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../enums/app_enums.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart';

/// Displays courses fetched offline-first (API when online, cache when
/// offline) and lets the user Add / Edit / Delete with optimistic UI
/// updates. All state comes from [CourseProvider]; this widget contains
/// no business logic of its own.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CourseProvider>(
      create: (_) => CourseProvider()..init(),
      child: const _CoursesView(),
    );
  }
}

class _CoursesView extends StatefulWidget {
  const _CoursesView();

  @override
  State<_CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<_CoursesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToAddCourse(BuildContext context) async {
    final provider = context.read<CourseProvider>();
    final newCourse = await Navigator.push<CourseModel>(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );
    if (newCourse == null) return;

    final ok = await provider.addCourse(newCourse);
    _showSnackBar(
      context,
      ok ? "Course added successfully" : provider.errorMessage,
      isError: !ok,
    );
  }

  Future<void> _goToEditCourse(BuildContext context, CourseModel course) async {
    final provider = context.read<CourseProvider>();
    final updated = await Navigator.push<CourseModel>(
      context,
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );
    if (updated == null) return;

    final ok = await provider.updateCourse(updated);
    _showSnackBar(
      context,
      ok ? "Course updated successfully" : provider.errorMessage,
      isError: !ok,
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, CourseModel course) async {
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

    if (confirmed != true || course.id == null || !context.mounted) return;

    final provider = context.read<CourseProvider>();
    final ok = await provider.deleteCourse(course.id!);
    if (!context.mounted) return;
    _showSnackBar(
      context,
      ok ? "Course deleted successfully" : provider.errorMessage,
      isError: !ok,
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _offlineBanner(CourseProvider provider) {
    if (!provider.isOffline) return const SizedBox.shrink();

    final syncText = provider.lastSyncTime != null
        ? "Last synced ${TimeOfDay.fromDateTime(provider.lastSyncTime!).format(context)}"
        : "No previous sync";

    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline — showing cached courses. $syncText.",
              style: const TextStyle(color: Colors.deepOrange, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => context.read<CourseProvider>().search(value),
        decoration: InputDecoration(
          hintText: "Search courses...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CourseProvider>().search('');
                  },
                ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CourseProvider provider) {
    switch (provider.status) {
      case CourseLoadStatus.initial:
      case CourseLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CourseLoadStatus.error:
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
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadCourses(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        );

      case CourseLoadStatus.empty:
        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: provider.loadCourses,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No courses yet",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap + to add your first course.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

      case CourseLoadStatus.success:
        if (provider.courses.isEmpty) {
          // Success overall, but the current search query matched nothing.
          return const Center(child: Text("No courses match your search."));
        }
        return RefreshIndicator(
          onRefresh: provider.loadCourses,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: provider.courses.length,
            itemBuilder: (context, index) {
              final course = provider.courses[index];
              final isMutating = provider.mutatingCourseId == course.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              onPressed: () => _goToEditCourse(context, course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmAndDelete(context, course),
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
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses (Offline-First)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.status == CourseLoadStatus.loading
                ? null
                : () => provider.loadCourses(),
          ),
        ],
      ),
      body: Column(
        children: [
          _offlineBanner(provider),
          _searchBar(),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddCourse(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
