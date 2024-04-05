import 'dart:convert';

class User {
  String id;
  String email;
  String fullName;
  String password;
  String organizationID;

  User(
      {required this.id,
      required this.email,
      required this.fullName,
      required this.password,
      required this.organizationID});

  // Default constructor
  User.defaultUser()
      : id = 'default_id',
        email = 'default@example.com',
        fullName = 'Default',
        password = 'Password1234!',
        organizationID = "Org 1";

  factory User.fromJson(String body) {
    Map<String, dynamic> json = jsonDecode(body);
    return User(
        id: json['id'],
        email: json['email'],
        fullName: json['fullName'],
        password: json['password'],
        organizationID: json['organizationID']);
  }
}
