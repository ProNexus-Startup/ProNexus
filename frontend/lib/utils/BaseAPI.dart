import 'dart:convert';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/models/user.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class BaseAPI {
  static String api = "https://pronexus-production.up.railway.app";
  Uri userPath = Uri.parse('$api/me');
  Uri usersPath = Uri.parse('$api/users');
  Uri refreshPath = Uri.parse('$api/refresh');
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
  Uri updateUserProjectPath = Uri.parse("$api/update-user-project");
  Uri updateProject = Uri.parse("$api/update-project");

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
      'level': user.level,
    });
    http.Response response =
        await http.post(super.signupPath, headers: super.headers, body: body);
    return response;
  }

  Future<http.Response> makeOrg(String orgName) async {
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

      print(response.body);
      print(response.statusCode);

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
      final response = await http.get(
        expertsPath,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        List<AvailableExpert> experts = List.from(decoded)
            .map((expertJson) => AvailableExpert.fromJson(expertJson))
            .toList();

        return experts;
      } else {
        print(
            "Failed to retrieve experts. Status code: ${response.statusCode}");
        print("Failure: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error occurred while fetching experts: $e");
      return [];
    }
  }

  Future<List<CallTracker>> getCalls(String token) async {
    try {
      final response = await http
          .get(callsPath, headers: {"Authorization": "Bearer ${token}"});
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
      return [];
    }
  }

  Future<List<Project>> getProjects(String token) async {
    try {
      final response = await http.get(
        projectsPath,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body) as List<dynamic>;

        List<Project> projects = decoded
            .map((projectJson) =>
                Project.fromJson(projectJson as Map<String, dynamic>))
            .toList();

        return projects;
      } else {
        print(
            "Failed to retrieve projects. Status code: ${response.statusCode}");
        print("Failure: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error occurred while fetching projects: $e");
      return [];
    }
  }

// Function to make an expert available
  Future<void> makeExpert(AvailableExpert availableExpert, String token) async {
    try {
      // Convert the AvailableExpert object to a JSON string
      String expertData = jsonEncode(availableExpert.toJson());

      // Set up the headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Make the POST request
      http.Response response = await http.post(
        makeExpertPath,
        headers: headers,
        body: expertData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        print("Expert made available successfully.");
      } else {
        print("Failed to make expert available: ${response.body}");
      }
    } catch (e) {
      print("Error making expert available: $e");
    }
  }

  Future<void> createCallTracker(CallTracker callTracker, String token) async {
    try {
      final response = await http.post(
        makeCallPath,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ensure you have a valid token
        },
        body: jsonEncode({
          'isSelected': callTracker.isSelected,
          'name': callTracker.name,
          'projectId': callTracker.projectId,
          'favorite': callTracker.favorite,
          'title': callTracker.profession,
          'company': callTracker.company,
          'companyType': callTracker.companyType,
          'startDate': callTracker.startDate!
                  .toIso8601String()
                  .replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
          'description': callTracker.description,
          'geography': callTracker.geography,
          'angle': callTracker.angle,
          'status': callTracker.status,
          'aiAssessment': callTracker.aiAssessment,
          'comments': callTracker.comments,
          'availability': callTracker.availabilities,
          'expertNetworkName': callTracker.expertNetworkName,
          'cost': callTracker.cost,
          'screeningQuestions': callTracker.screeningQuestionsAndAnswers,
          'addedExpertBy': callTracker.addedExpertBy,
          'dateAddedExpert': callTracker.dateAddedExpert!
                  .toIso8601String()
                  .replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
          'addedCallBy': callTracker.addedCallBy,
          'dateAddedCall': callTracker.dateAddedCall!
                  .toIso8601String()
                  .replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
          'inviteSent': callTracker.inviteSent,
          'meetingStartDate': callTracker.meetingStartDate!
                  .toIso8601String()
                  .replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
          'meetingEndDate': callTracker.meetingEndDate!
                  .toIso8601String()
                  .replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
          'paidStatus': callTracker.paidStatus,
          'rating': callTracker.rating,
        }),
      );

      if (response.statusCode == 200) {
        print('Call Tracker Created Successfully');
      } else {
        print('Failed to create call tracker: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending request: $e');
    }
  }

  Future<void> makeProject(String token, Project project) async {
    Map<String, dynamic> projectJson = project.toJson();
    String projectJsonString = jsonEncode(projectJson);

    print("Sending JSON: $projectJsonString");

    final response = await http.post(
      makeProjectPath,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: projectJsonString, // Directly encode the project data
    );

    if (response.statusCode == 200) {
      print('Project created successfully');
    } else {
      print('Failed to create project: ${response.body}');
    }
  }

  Future<void> updateProjectExpenses(
      String token, String projectId, List<Expense> expenses) async {
    final body = jsonEncode({
      'projectId': projectId,
      'expenses': expenses.map((e) => e.toJson()).toList(),
    });

    final response = await http.post(
      updateProject,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Project updated successfully');
    } else {
      print('Failed to update project: ${response.statusCode}');
    }
  }

  Future<void> updateProjectAngles(
      String token, String projectId, List<Angle> angles) async {
    final body = jsonEncode({
      'projectId': projectId,
      'angle': angles.map((e) => e.toJson()).toList(),
    });

    final response = await http.post(
      updateProject,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Project updated successfully');
    } else {
      print('Failed to update project: ${response.statusCode}');
    }
  }

  Future<void> changeProjects(
      String token, String project, DateTime dateOnboarded) async {
    try {
      // Encode the request body
      var body = jsonEncode({
        'newProject': project,
        'dateOnboarded':
            dateOnboarded.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') +
                'Z',
      });

      // Set up headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Make the POST request
      var response = await http.post(
        updateUserProjectPath,
        headers: headers,
        body: body,
      );

      // Check the response status and body
      if (response.statusCode == 200) {
        print('Successfully changed projects: ${response.body}');
      } else {
        print('Failed to change projects: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> refreshToken(String token) async {
    final response = await http.post(
      refreshPath,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      String newToken = jsonDecode(response.body);
      SecureStorage secureStorage = SecureStorage();

      await secureStorage.write('token', newToken);
    } else {
      // Handle error response
      print('Failed to refresh token: ${response.statusCode}');
      return null;
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
