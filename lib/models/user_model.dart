import '../enums/app_enums.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
  });
}