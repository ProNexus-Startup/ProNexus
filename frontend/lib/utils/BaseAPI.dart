import 'dart:convert';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class BaseAPI {
  static String api =
      "happy-reprieve-production.up.railway.app"; //"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"
  Uri userPath = Uri.parse('$api/me');
  Uri loginPath = Uri.parse('$api/login');
  Uri logoutPath = Uri.parse("$api/logout");
  Uri makeOrgPath = Uri.parse("$api/makeorg");
  Uri signupPath = Uri.parse("$api/signup");
  Uri questionnairePath = Uri.parse("$api/user/profile");
  Uri expertsPath = Uri.parse("$api/expert-list");
  Uri makeExpertsPath = Uri.parse("$api/make-expert");
  Uri makeProjectPath = Uri.parse("$api/make-project");
  Uri projectsPath = Uri.parse("$api/projects-list");

  Uri callsPath = Uri.parse("$api/calls-list");
  // more routes
  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8"
  };
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
    try {
      final response = await http.get(_authAPI.userPath,
          headers: {"Authorization": "Bearer ${token}"});
      if (response.statusCode == 200) {
        User user = User.fromJson(response.body);
        return user;
      } else {
        return User.defaultUser();
      }
    } catch (e) {
      return User.defaultUser();
    }
  }

  Future<List<AvailableExpert>> getExperts(String token) async {
    AuthAPI _authAPI = AuthAPI();
    try {
      final response = await http.get(
          _authAPI
              .expertsPath, // Updated path to include query for organizationID
          headers: {"Authorization": "Bearer ${token}"});

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
      final response = await http.get(
          _authAPI
              .callsPath, // Updated path to include query for organizationID
          headers: {"Authorization": "Bearer ${token}"});
      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        List<CallTracker> calls = List.from(decoded)
            .map((callJson) => CallTracker.fromJson(callJson))
            .toList();

        return calls;
      } else {
        // Log or handle the error response properly
        print("Failed to retrieve calls. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Log the exception
      print("Error occurred while fetching calls: $e");
      return []; // Return an empty list as a fallback in case of exceptions
    }
  }

  Future<List<Project>> getProjects(String token) async {
    AuthAPI _authAPI = AuthAPI();
    try {
      final response = await http.get(
          _authAPI
              .projectsPath, // Updated path to include query for organizationID
          headers: {"Authorization": "Bearer ${token}"});
      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        List<Project> projects = List.from(decoded)
            .map((projectJson) => Project.fromJson(projectJson))
            .toList();

        return projects;
      } else {
        // Log or handle the error response properly
        print(
            "Failed to retrieve projects. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Log the exception
      print("Error occurred while fetching projects: $e");
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
