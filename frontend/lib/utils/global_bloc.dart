import 'dart:convert';

import 'package:admin/utils/cards/call_tracker_card.dart';
import 'package:flutter/material.dart';
import './persistence/user_data.dart';
import "cards/available_expert_card.dart";

class GlobalBloc with ChangeNotifier {
  static final GlobalBloc _singleton = GlobalBloc._internal();

  factory GlobalBloc() {
    return _singleton;
  }

  GlobalBloc._internal() {
    expertList = [];
    callList = [];
    currentUser =
        User(id: "", fullName: "", email: "", password: "", organizationID: "");
  }

  late List<AvailableExpert> expertList;
  late List<CallTracker> callList;
  late User currentUser;

  // Getters to expose the data
  List<AvailableExpert> get expertListStream => expertList;

  // This method is now public and correctly named for clarity
  Future<void> createSampleAvailableExperts() async {
    print("Sample list made");
    this.expertList = [
// Sample AvailableExpert 1
      AvailableExpert(
        expertId: "1",
        name: "Alice Johnson",
        favorite: true,
        title: "Senior Flutter Developer",
        company: "Tech Innovations Inc",
        yearsAtCompany: "5",
        description:
            "Alice is a seasoned Flutter developer with a passion for creating seamless mobile applications. She has contributed to over 20 apps in the finance and healthcare sectors.",
        geography: "North America",
        angle: "Application Development",
        status: "Active",
        AIAssessment: 99,
        comments:
            "Great understanding of Flutter best practices and architecture.",
        availability: "Monday to Friday, 9am to 5pm EST",
        expertNetworkName: "Flutter AvailableExperts Hub",
        cost: 19999,
        screeningQuestions:
            "Please describe your project's main objectives and your specific needs from a Flutter development perspective.",
      ),

// Sample AvailableExpert 2
      AvailableExpert(
        expertId: "2",
        name: "Bob Smith",
        favorite: false,
        title: "Flutter UI/UX Specialist",
        company: "DesignWorld",
        yearsAtCompany: "3",
        description:
            "Bob specializes in crafting intuitive and engaging user interfaces for Flutter apps. His work emphasizes accessibility and user experience.",
        geography: "Europe",
        angle: "UI/UX Design",
        status: "Active",
        AIAssessment: 50,
        comments:
            "Exceptional skills in UI design patterns and user testing methodologies.",
        availability: "Flexible",
        expertNetworkName: "Global Tech Artists",
        cost: 100,
        screeningQuestions:
            "Can you provide examples of UI/UX challenges you've faced in Flutter apps and how you resolved them?",
      ),

// Sample AvailableExpert 3
      AvailableExpert(
        expertId: "3",
        name: "Christina Lee",
        favorite: true,
        title: "Mobile Tech Analyst",
        company: "Big Bank",
        yearsAtCompany: "7",
        description:
            "With a deep understanding of the mobile tech industry, Christina offers invaluable insights into market trends and Flutter's place within it.",
        geography: "Asia",
        angle: "Market Analysis",
        status: "Consulting",
        AIAssessment: 1,
        comments:
            "Provides thorough and actionable market analysis tailored to Flutter's ecosystem.",
        availability: "By appointment",
        expertNetworkName: "Tech Insights Network",
        cost: 300,
        screeningQuestions:
            "What specific market trends are you interested in exploring?",
      ),
    ];
  }

  Future<void> onUserLogin(String token) async {
    // Create an instance of AuthAPI
    AuthAPI _authAPI = AuthAPI();

    // Use the instance to call getExperts
    List<AvailableExpert> fetchedExperts = await _authAPI.getExperts(token);

    if (fetchedExperts.isNotEmpty) {
      // If experts were successfully fetched, assign them to the expertList
      this.expertList = fetchedExperts;
    } else {
      // If the list is empty (indicating an error or no data), use the sample list
      await createSampleAvailableExperts();
    }

    // Use the instance to call getExperts
    List<CallTracker> fetchedCalls = await _authAPI.getCalls(token);

    if (fetchedCalls.isNotEmpty) {
      // If experts were successfully fetched, assign them to the expertList
      this.callList = fetchedCalls;
    } else {
      // If the list is empty (indicating an error or no data), use the sample list
      await createSampleAvailableExperts();
    }

    // Use the instance to call getExperts
    User user = await _authAPI.getUser(token);

    this.currentUser = user;
    // Notify any listeners that the expert list might have been updated
    notifyListeners();
  }

  Future<void> onUserLogout() async {
    // Clear the expert list and other user-specific data on logout
    expertList = [];
    callList = [];
    currentUser =
        User(id: "", fullName: "", email: "", password: "", organizationID: "");
    // Notify any listeners that the user has logged out
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    expertList = [];
  }

  Map<String, Map<String, bool>> _activeFilters = {};

  void setFilter(String attribute, String value, bool isActive) {
    _activeFilters[attribute] ??= {};
    _activeFilters[attribute]![value] = isActive;
    notifyListeners();
  }

  bool isFilterOn(String attribute, String value) {
    return _activeFilters[attribute]?[value] ?? false;
  }

  bool applyFilters(AvailableExpert expert) {
    for (String attribute in _activeFilters.keys) {
      for (String value in _activeFilters[attribute]!.keys) {
        bool isActive = _activeFilters[attribute]![value]!;
        // If the filter is active and the expert doesn't match, return false
        if (isActive && !expertMatchesFilter(expert, attribute, value)) {
          return false;
        }
      }
    }
    // If all active filters match, return true
    return true;
  }

  bool expertMatchesFilter(
      AvailableExpert expert, String attribute, String value) {
    switch (attribute) {
      case 'Geography':
        return expert.geography == value;
      case 'Company':
        return expert.company == value;
      case 'Status':
        return expert.status == value;
      case 'Availability':
        return expert.availability == value;
      // Add more cases as necessary for other attributes you want to filter by
      default:
        return false;
    }
  }

  void toggleFavorite(AvailableExpert expert) {
    int index = expertList.indexOf(expert);
    if (index != -1) {
      // Assuming favorite is a boolean. Toggle its value.
      expertList[index].favorite = !expertList[index].favorite;

      // Here you might want to save the updated expertList to persistent storage
      // For example, you could call _saveAvailableExpertsToPreferences here
      // _saveAvailableExpertsToPreferences(expertList, 'token');

      notifyListeners(); // Notify all listening widgets to rebuild
    }
  }

  Future<void> _saveAvailableExpertsToPreferences(
      List<AvailableExpert> experts, String token) async {
    List<String> jsonList = experts
        .map((expert) => json.encode({
              'expert_id': expert.expertId,
              'name': expert.name,
              'title': expert.title,
              'company': expert.company,
              'yearsAtCompany': expert.yearsAtCompany,
              'description': expert.description,
              'geography': expert.geography,
              'angle': expert.angle,
              'status': expert.status,
              'AIAssessment': expert.AIAssessment,
              'comments': expert.comments,
              'availability': expert.availability,
              'expertNetworkName': expert.expertNetworkName,
              'cost': expert.cost,
              'screeningQuestions': expert.screeningQuestions,

              // Add other fields as needed
            }))
        .toList();

    var prefList = <AvailableExpert>[];

    for (var jsonAvailableExpert in jsonList) {
      var userMap = jsonDecode(jsonAvailableExpert);
      var tempAvailableExpert = AvailableExpert.fromJson(userMap);
      prefList.add(tempAvailableExpert);
    }

    expertList = prefList;
  }
}
