import '../enums/app_enums.dart';

class AuthController {
  AuthState authState = AuthState.loggedOut;

  bool login(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      authState = AuthState.loggedIn;
      return true;
    }

    return false;
  }

  void logout() {
    authState = AuthState.loggedOut;
  }
}