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