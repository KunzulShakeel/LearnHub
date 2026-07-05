import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/course_local_service.dart';
import '../models/course_model.dart';
import '../services/course_api_service.dart';

/// Result of a "get courses" operation, including where the data came from.
class CourseFetchResult {
  final List<CourseModel> courses;
  final bool isOffline;

  const CourseFetchResult({required this.courses, required this.isOffline});
}

/// Repository layer: the single source of truth for course data.
///
/// This is the ONLY class that decides whether to hit the network or fall
/// back to the local cache. Everything above it (state management, UI)
/// just asks the repository for data and never talks to [CourseApiService]
/// or [CourseLocalService] directly.
///
/// Flow: UI -> CourseProvider (state) -> CourseRepository -> CourseApiService / CourseLocalService
class CourseRepository {
  final CourseApiService _apiService;
  final CourseLocalService _localService;
  final Connectivity _connectivity;

  CourseRepository({
    CourseApiService? apiService,
    CourseLocalService? localService,
    Connectivity? connectivity,
  })  : _apiService = apiService ?? CourseApiService(),
        _localService = localService ?? CourseLocalService(),
        _connectivity = connectivity ?? Connectivity();

  Future<bool> get _hasConnection async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Fetch courses, offline-first:
  /// 1. If there's no network connection, serve the cache immediately.
  /// 2. If there is a connection, hit the API and refresh the cache.
  /// 3. If the API call fails anyway (server error, timeout, etc.), fall
  ///    back to whatever is cached rather than showing a hard error.
  Future<CourseFetchResult> getCourses() async {
    final online = await _hasConnection;

    if (!online) {
      return CourseFetchResult(
        courses: _localService.getCachedCourses(),
        isOffline: true,
      );
    }

    try {
      final courses = await _apiService.fetchCourses();
      await _localService.cacheCourses(courses);
      return CourseFetchResult(courses: courses, isOffline: false);
    } catch (_) {
      final cached = _localService.getCachedCourses();
      if (cached.isNotEmpty) {
        return CourseFetchResult(courses: cached, isOffline: true);
      }
      rethrow;
    }
  }

  Future<CourseModel> addCourse(CourseModel course) {
    return _apiService.addCourse(course);
  }

  Future<CourseModel> updateCourse(CourseModel course) {
    return _apiService.updateCourse(course);
  }

  Future<void> deleteCourse(int id) {
    return _apiService.deleteCourse(id);
  }

  /// Re-save the current in-memory list to the local cache — called by the
  /// provider after a successful add/update/delete so offline data stays
  /// in sync with the latest known-good state.
  Future<void> persistSnapshot(List<CourseModel> courses) {
    return _localService.cacheCourses(courses);
  }

  DateTime? get lastSyncTime => _localService.getLastSyncTime();

  Stream<List<ConnectivityResult>> get connectivityChanges =>
      _connectivity.onConnectivityChanged;
}
