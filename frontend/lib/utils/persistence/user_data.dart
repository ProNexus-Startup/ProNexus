import 'dart:convert';
import 'package:admin/utils/cards/available_expert_card.dart';
import 'package:admin/utils/cards/call_tracker_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../BaseAPI.dart';
import 'package:http/http.dart' as http;

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

class AuthAPI extends BaseAPI {
  Future<http.Response> signup(String fullName, String email, String password,
      String organizationID) async {
    var body = jsonEncode({
      'fullName': fullName,
      'email': email,
      'password': password,
      'organizationID': organizationID
    });
    http.Response response =
        await http.post(super.signupPath, headers: super.headers, body: body);
    return response;
  }

  Future<http.Response> makeOrg(String orgName) async {
    var body = jsonEncode({'name': orgName});
    var headers = {
      'Content-Type': 'application/json',
      // Add any other necessary headers here, like authorization tokens
    };

    try {
      http.Response response = await http.post(
        makeOrgPath, // Make sure this is the correct endpoint
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Success
        print("Organization created successfully.");
      } else {
        // Handle server errors or invalid responses
        print(
            "Failed to create organization. Status code: ${response.statusCode}");
      }
      return response;
    } catch (e) {
      // Handle any errors that occur during the request
      print("Error making the request: $e");
      throw Exception("Failed to make request");
    }
  }

  Future<http.Response> login(String email, String password) async {
    var headers = {
      'Content-Type': 'application/json',
      // Add any other necessary headers here, like authorization tokens
    };
    var body = jsonEncode({'email': email, 'password': password});

    http.Response response =
        await http.post(super.loginPath, headers: headers, body: body);

    return response;
  }

  Future<User> getUser(String token) async {
    AuthAPI _authAPI = AuthAPI();
    print("trying");
    try {
      final response = await http.get(_authAPI.userPath,
          headers: {"Authorization": "Bearer ${token}"});
      if (response.statusCode == 200) {
        User user = User.fromJson(response.body);
        return user;
      } else {
        print("bruh moment");
        print(response.statusCode);
        return User.defaultUser();
      }
    } catch (e) {
      print("username not received");
      return User.defaultUser();
    }
  }

  Future<List<AvailableExpert>> getExperts(String token) async {
    AuthAPI _authAPI = AuthAPI();
    try {
      print("didnyt work");
      // Retrieve the current user
      User user = await getUser(token);
      String organizationID = user.organizationID;

      // Assuming you want to use the organizationID in the request
      final response = await http.get(
        _authAPI
            .expertsPath, // Updated path to include query for organizationID
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Organization-ID': organizationID, // Custom header for organizationID
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Decode the JSON response
        var decoded = json.decode(response.body);

        // Assuming the decoded response is a List of maps, we need to iterate over them
        // and convert each item to an AvailableExpert instance
        List<AvailableExpert> experts = List.from(decoded)
            .map((expertJson) => AvailableExpert.fromJson(expertJson))
            .toList();

        return experts; // Return the list of experts
      } else {
        // Log or handle the error response properly
        print(
            "Failed to retrieve experts. Status code: ${response.statusCode}");
        return []; // Return an empty list indicating no experts found or an error occurred
      }
    } catch (e) {
      // Log the exception
      print("Error occurred while fetching experts: $e");
      return []; // Return an empty list as a fallback in case of exceptions
    }
  }

  Future<List<CallTracker>> getCalls(String token) async {
    AuthAPI _authAPI = AuthAPI();
    try {
      // Retrieve the current user
      User user = await getUser(token);
      String organizationID = user.organizationID;

      // Assuming you want to use the organizationID in the request
      final response = await http.get(
        _authAPI.callsPath, // Updated path to include query for organizationID
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Organization-ID': organizationID, // Custom header for organizationID
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Decode the JSON response
        var decoded = json.decode(response.body);

        List<CallTracker> calls = List.from(decoded)
            .map((callJson) => CallTracker.fromJson(callJson))
            .toList();

        return calls; // Return the list of calls
      } else {
        // Log or handle the error response properly
        print("Failed to retrieve calls. Status code: ${response.statusCode}");
        return []; // Return an empty list indicating no calls found or an error occurred
      }
    } catch (e) {
      // Log the exception
      print("Error occurred while fetching calls: $e");
      return []; // Return an empty list as a fallback in case of exceptions
    }
  }

  Future<http.Response> logout(String token) async {
    AuthAPI _authAPI = AuthAPI();
    final response = await http.post(
      _authAPI.logoutPath,
      headers: {
        'Authorization': token,
      },
    );
    return response;
  }
}

class UserCubit extends Cubit<User?> {
  UserCubit(User state) : super(state);

  void login(User user) => emit(user);

  void logout() => emit(null);
}
