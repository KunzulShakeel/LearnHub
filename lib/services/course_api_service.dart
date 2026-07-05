import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

/// Thin service layer that talks to the JSONPlaceholder REST API and
/// converts responses into [CourseModel] objects.
///
/// This class ONLY performs HTTP requests and JSON (de)serialization —
/// it has no knowledge of local storage, caching, or app state. Deciding
/// when to use the network vs. local data is the CourseRepository's job;
/// deciding how that affects UI state is CourseProvider's job.
///
/// API used: JSONPlaceholder (https://jsonplaceholder.typicode.com)
/// Docs followed: https://jsonplaceholder.typicode.com/guide
class CourseApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _resource = '/posts';

  /// GET /posts — fetch the list of courses.
  /// `_limit=10` keeps the list short since JSONPlaceholder always returns
  /// the full 100-post dataset otherwise.
  Future<List<CourseModel>> fetchCourses() async {
    final uri = Uri.parse('$_baseUrl$_resource?_limit=10');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load courses (status ${response.statusCode})');
  }

  /// POST /posts — create a new course.
  ///
  /// Note: JSONPlaceholder is a fake/mock API. It does not actually persist
  /// new records; it always responds with `id: 101` and echoes back the
  /// posted body. We merge that response with a locally generated id so the
  /// new course can still be tracked in the UI's in-memory list.
  Future<CourseModel> addCourse(CourseModel course) async {
    final uri = Uri.parse('$_baseUrl$_resource');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return CourseModel.fromJson({
        ...course.toJson(),
        ...json,
        'id': DateTime.now().millisecondsSinceEpoch, // guarantees a unique id
      });
    }

    throw Exception('Failed to add course (status ${response.statusCode})');
  }

  /// PUT /posts/:id — update an existing course.
  Future<CourseModel> updateCourse(CourseModel course) async {
    final uri = Uri.parse('$_baseUrl$_resource/${course.id}');
    final response = await http.put(
      uri,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      // Keep the original id: JSONPlaceholder's mock response for ids > 100
      // (locally generated ones) would otherwise be dropped/altered.
      return CourseModel.fromJson({...course.toJson(), ...json, 'id': course.id});
    }

    throw Exception('Failed to update course (status ${response.statusCode})');
  }

  /// DELETE /posts/:id — delete a course.
  Future<void> deleteCourse(int id) async {
    final uri = Uri.parse('$_baseUrl$_resource/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete course (status ${response.statusCode})');
    }
  }
}
