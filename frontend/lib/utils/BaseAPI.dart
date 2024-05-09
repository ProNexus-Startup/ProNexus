import 'dart:convert';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class BaseAPI {
  static String api =
      "http://localhost:8080"; //"pronexus-production.up.railway.app"; //"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"
  Uri userPath = Uri.parse('$api/me');
  Uri usersPath = Uri.parse('$api/users');
  Uri loginPath = Uri.parse('$api/login');
  Uri logoutPath = Uri.parse("$api/logout");
  Uri makeOrgPath = Uri.parse("$api/makeorg");
  Uri signupPath = Uri.parse("$api/signup");
  Uri questionnairePath = Uri.parse("$api/user/profile");
  Uri expertsPath = Uri.parse("$api/expert-list");
  Uri makeExpertPath = Uri.parse("$api/manually-make-expert");
  Uri makeCallPath = Uri.parse("$api/manually-make-call");
  Uri makeProjectPath = Uri.parse("$api/make-project");
  Uri projectsPath = Uri.parse("$api/projects-list");
  Uri callsPath = Uri.parse("$api/calls-list");

  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8"
  };
}

class AuthAPI extends BaseAPI {
  Future<http.Response> signup(User user) async {
    var body = jsonEncode({
      'fullName': user.fullName,
      'email': user.email,
      'password': user.password,
      'organizationID': user.organizationId,
      'admin': user.admin,
    });
    http.Response response =
        await http.post(super.signupPath, headers: super.headers, body: body);
    return response;
  }

  Future<http.Response> makeOrg(String orgName) async {
    print(orgName);
    var body = jsonEncode({'name': orgName});
    var headers = {
      'Content-Type': 'application/json',
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
    try {
      final response = await http
          .get(userPath, headers: {"Authorization": "Bearer ${token}"});
      if (response.statusCode == 200) {
        User user = User.fromJson(json.decode(response.body));
        return user;
      } else {
        return User.defaultUser();
      }
    } catch (e) {
      return User.defaultUser();
    }
  }

  Future<List<User>> getUsers(String token) async {
    try {
      final response = await http
          .get(usersPath, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        List<User> users = (json.decode(response.body) as List)
            .map((data) => User.fromJson(data))
            .toList();

        return users;
      } else {
        print("Error: ${response.body}");
        return [User.defaultUser()];
      }
    } catch (e) {
      print("Exception caught: $e");
      return [User.defaultUser()];
    }
  }

  Future<List<AvailableExpert>> getExperts(String token) async {
    try {
      final response = await http
          .get(expertsPath, // Updated path to include query for organizationID
              headers: {"Authorization": "Bearer ${token}"});

      if (response.statusCode == 200) {
        // Decode the JSON response
        var decoded = json.decode(response.body);
        List<AvailableExpert> experts = List.from(decoded)
            .map((expertJson) => AvailableExpert.fromJson(expertJson))
            .toList();

        return experts;
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
    try {
      final response = await http
          .get(callsPath, // Updated path to include query for organizationID
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
    try {
      final response = await http
          .get(projectsPath, // Updated path to include query for organizationID
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

  Future<void> postExpert(String token, AvailableExpert expert) async {
    final response = await http.post(
      makeExpertPath,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
      body: jsonEncode({
        "expertId": "123",
        "name": "John Doe",
        "project": "Project 1",
        "favorite": false,
        "title": "Senior Engineer",
        "company": "Tech Solutions",
        "yearsAtCompany": "5",
        "description": "Expert in renewable energy systems",
        "geography": "USA",
        "angle": "Technical",
        "status": "Active",
        "AIAssessment": 85,
        "comments": "Highly recommended for technical insights",
        "availability": "Monday to Friday",
        "expertNetworkName": "Global Tech Leaders",
        "cost": 200.0,
        "screeningQuestions": [
          "What is your experience with renewable energy?",
          "Can you provide examples of projects you've led?"
        ],
      }),
    );

    if (response.statusCode == 200) {
      // Handle the response body if the call was successful
      print('Success: ${response.body}');
    } else {
      // Handle the error
      print(
          'Failed to post available expert. StatusCode: ${response.statusCode}');
    }
  }

  Future<void> makeCall(String token, CallTracker callTracker) async {
    // Encode the callTracker data into JSON
    var body = jsonEncode({
      'organizationID': callTracker.organizationID,
      'callTracker': callTracker.callTracker
          .map((ct) => {
                'expertId': ct.ID,
                'name': ct.Name,
                'projectId': ct.ProjectID,
                'favorite': ct.Favorite,
                'title': ct.Title,
                'company': ct.Company,
                'companyType': ct.CompanyType,
                'yearsAtCompany': ct.YearsAtCompany,
                'description': ct.Description,
                'geography': ct.Geography,
                'angle': ct.Angle,
                'status': ct.Status,
                'AIAssessment': ct.AIAssessment,
                'comments': ct.Comments,
                'availability': ct.Availability,
                'expertNetworkName': ct.ExpertNetworkName,
                'cost': ct.Cost,
                'screeningQuestions': ct.ScreeningQuestions,
                'addedExpertBy': ct.AddedExpertBy,
                'dateAddedExpert': ct.DateAddedExpert.toIso8601String(),
                'addedCallBy': ct.AddedCallBy,
                'dateAddedCall': ct.DateAddedCall.toIso8601String(),
                'inviteSent': ct.InviteSent,
                'meetingStartDate': ct.MeetingStartDate.toIso8601String(),
                'meetingEndDate': ct.MeetingEndDate.toIso8601String(),
                'paidStatus': ct.PaidStatus,
                'rating': ct.Rating,
              })
          .toList()
    });

    try {
      // Set up the request headers
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Send the POST request
      var response =
          await http.post(makeCallPath, headers: headers, body: body);

      // Check the response status
      if (response.statusCode == 200) {
        print('Call tracker created successfully.');
      } else {
        print(
            'Failed to create call tracker. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending request: $e');
    }
  }

  Future<void> postProject(String token, String name, DateTime startDate,
      String target, String status) async {
    final response = await http.post(
      makeProjectPath,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
      body: jsonEncode({
        'projectId': '', // This is a unique identifier for the project
        'name': name, // Name of the project
        'startDate': startDate
            .toUtc()
            .toIso8601String(), //startDate, // Start date in ISO 8601 format
        'target': target, // The target goal of the project
        'callsCompleted':
            0, // Number of calls or actions completed towards the project
        'status': status, // The current status of the project
      }),
    );

    if (response.statusCode == 200) {
      // Handle the response body if the call was successful
      print('Success: ${response.body}');
    } else {
      // Handle the error
      print('Failed to post project. StatusCode: ${response.statusCode}');
    }
  }

  Future<http.Response> logout(String token) async {
    final response = await http.post(
      logoutPath,
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
