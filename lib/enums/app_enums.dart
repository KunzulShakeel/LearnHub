enum Gender {
  male,
  female,
  other,
}

enum AuthState {
  loggedOut,
  loggedIn,
}

/// Represents the state of an async API call (used by the Courses screens
/// to drive loading / success / error UI).
enum ApiStatus {
  loading,
  success,
  error,
}

/// Drives the Courses screen's UI via CourseProvider (state management
/// layer). `empty` is distinct from `success` so the UI can show a
/// dedicated "no courses yet" state instead of a blank list.
enum CourseLoadStatus {
  initial,
  loading,
  success,
  empty,
  error,
}