import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';

/// Local/offline persistence layer for course data, backed by Hive.
///
/// This class ONLY knows how to read/write the on-device cache — it has no
/// knowledge of the network or HTTP. It stores the course list as a single
/// JSON-encoded string rather than using generated Hive TypeAdapters, which
/// keeps the setup simple (no build_runner / code generation step) while
/// still giving fast, persistent, offline-capable key-value storage.
class CourseLocalService {
  static const String boxName = 'courses_box';
  static const String _coursesKey = 'cached_courses';
  static const String _lastSyncKey = 'last_sync_at';

  /// Call once during app startup, before this service is used.
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Box get _box => Hive.box(boxName);

  /// Persist the given courses as the current offline snapshot, and record
  /// the sync timestamp.
  Future<void> cacheCourses(List<CourseModel> courses) async {
    final jsonList = courses.map((c) => c.toJson()).toList();
    await _box.put(_coursesKey, jsonEncode(jsonList));
    await _box.put(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Read whatever course data was last cached (empty list if none yet).
  List<CourseModel> getCachedCourses() {
    final raw = _box.get(_coursesKey);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw as String) as List<dynamic>;
    return decoded
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// When the cache was last successfully refreshed from the API.
  DateTime? getLastSyncTime() {
    final raw = _box.get(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }

  Future<void> clearCache() async {
    await _box.clear();
  }
}
