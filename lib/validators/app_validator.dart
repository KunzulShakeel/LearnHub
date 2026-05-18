class AppValidator {
  static String? validateEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return "Invalid email format";
    }

    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < 6) {
      return "Minimum 6 characters required";
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain uppercase letter";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Must contain special character";
    }

    return null;
  }
}