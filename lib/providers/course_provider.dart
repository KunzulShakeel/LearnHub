import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../enums/app_enums.dart';
import '../models/course_model.dart';
import '../repository/course_repository.dart';

/// State management layer for courses (Provider / ChangeNotifier).
///
/// Responsibilities:
/// - Own all UI-facing state: list of courses, load status, error message,
///   offline flag, search query, and which item (if any) has a mutation
///   in flight.
/// - Talk ONLY to [CourseRepository] — never to the API service or local
///   storage directly. This keeps the UI, state, and data-access concerns
///   cleanly separated (UI -> Provider -> Repository -> API/Local).
/// - Implement optimistic UI updates for add/update/delete: the UI is
///   updated immediately, then rolled back if the underlying API call
///   fails.
class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  CourseLoadStatus _status = CourseLoadStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  DateTime? _lastSyncTime;
  String _searchQuery = '';
  int? _mutatingCourseId;

  List<CourseModel> get courses => _filteredCourses;
  CourseLoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get searchQuery => _searchQuery;
  int? get mutatingCourseId => _mutatingCourseId;

  /// Call once when the screen owning this provider is created.
  Future<void> init() async {
    _connectivitySubscription =
        _repository.connectivityChanges.listen(_onConnectivityChanged);
    await loadCourses();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final nowOffline = results.every((r) => r == ConnectivityResult.none);
    // Coming back online after being offline -> re-sync with the API.
    if (_isOffline && !nowOffline) {
      loadCourses(silent: true);
    }
  }

  /// Loads courses via the repository (offline-first). When [silent] is
  /// true, the loading spinner is skipped so a background re-sync doesn't
  /// disrupt whatever the user is currently looking at.
  Future<void> loadCourses({bool silent = false}) async {
    if (!silent) {
      _status = CourseLoadStatus.loading;
      notifyListeners();
    }

    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.isOffline;
      _lastSyncTime = _repository.lastSyncTime;
      _errorMessage = '';
      _status = _courses.isEmpty ? CourseLoadStatus.empty : CourseLoadStatus.success;
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
      _status = CourseLoadStatus.error;
    }

    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredCourses = List.of(_courses);
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredCourses = _courses
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }

  /// Optimistically inserts the new course, then confirms/rolls back based
  /// on the API result.
  Future<bool> addCourse(CourseModel course) async {
    final tempId = -DateTime.now().millisecondsSinceEpoch; // negative = temp
    final optimistic = course.copyWith(id: tempId);

    _courses.insert(0, optimistic);
    _status = CourseLoadStatus.success;
    _applyFilter();
    notifyListeners();

    try {
      final created = await _repository.addCourse(course);
      final index = _courses.indexWhere((c) => c.id == tempId);
      if (index != -1) _courses[index] = created;
      await _repository.persistSnapshot(_courses);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback: remove the optimistic entry.
      _courses.removeWhere((c) => c.id == tempId);
      _errorMessage = 'Failed to add course: $e';
      _status = _courses.isEmpty ? CourseLoadStatus.empty : CourseLoadStatus.success;
      _applyFilter();
      notifyListeners();
      return false;
    }
  }

  /// Optimistically applies the edit, then confirms/rolls back.
  Future<bool> updateCourse(CourseModel updated) async {
    final index = _courses.indexWhere((c) => c.id == updated.id);
    if (index == -1) return false;

    final previous = _courses[index];
    _mutatingCourseId = updated.id;
    _courses[index] = updated;
    _applyFilter();
    notifyListeners();

    try {
      final saved = await _repository.updateCourse(updated);
      _courses[index] = saved;
      await _repository.persistSnapshot(_courses);
      return true;
    } catch (e) {
      // Rollback to the previous value.
      _courses[index] = previous;
      _errorMessage = 'Failed to update course: $e';
      return false;
    } finally {
      _mutatingCourseId = null;
      _applyFilter();
      notifyListeners();
    }
  }

  /// Optimistically removes the course, then confirms/rolls back.
  Future<bool> deleteCourse(int id) async {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final removed = _courses[index];
    _mutatingCourseId = id;
    _courses.removeAt(index);
    _applyFilter();
    notifyListeners();

    try {
      await _repository.deleteCourse(id);
      await _repository.persistSnapshot(_courses);
      _mutatingCourseId = null;
      _status = _courses.isEmpty ? CourseLoadStatus.empty : CourseLoadStatus.success;
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback: put the item back where it was.
      _courses.insert(index, removed);
      _errorMessage = 'Failed to delete course: $e';
      _mutatingCourseId = null;
      _applyFilter();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
