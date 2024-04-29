import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/models/user.dart';
import 'package:flutter/material.dart';
import 'BaseAPI.dart';
import "models/available_expert.dart";

class GlobalBloc with ChangeNotifier {
  // Example filter variables
  bool favoriteFilter = false;
  String geographyFilter = '';
  String availabilityFilter = '';
  // Adding a projectId filter variable
  String projectIdFilter = '';

  // Dummy filter maps added to define statusFilters, angleFilters, geographyFilters, and expertNetworkFilters
  // Adjust these maps according to your actual filters' requirements
  Map<String, bool> statusFilters = {};
  Map<String, bool> angleFilters = {};
  Map<String, bool> geographyFilters = {};
  Map<String, bool> expertNetworkFilters = {};

  void setFavoriteFilter(bool value) {
    favoriteFilter = value;
    notifyListeners();
  }

  void setGeographyFilter(String value) {
    geographyFilter = value;
    notifyListeners();
  }

  void setAvailabilityFilter(String value) {
    availabilityFilter = value;
    notifyListeners();
  }

  // Method to set the projectIdFilter
  void setProjectIdFilter(String value) {
    projectIdFilter = value;
    notifyListeners();
  }

/*
  bool applyFilters(AvailableExpert expert) {
    bool statusMatch = statusFilters[expert.status] ?? false;
    bool favoriteMatch = favoriteFilter ? expert.favorite : true;
    bool angleMatch = angleFilters.entries
        .any((entry) => entry.value && expert.angle.contains(entry.key));
    bool geographyMatch = geographyFilters.entries
        .any((entry) => entry.value && expert.geography.contains(entry.key));
    bool networkMatch = expertNetworkFilters.entries.any(
        (entry) => entry.value && expert.expertNetworkName.contains(entry.key));

    return statusMatch &&
        favoriteMatch &&
        angleMatch &&
        geographyMatch &&
        networkMatch;
  }
*/
  static final GlobalBloc _singleton = GlobalBloc._internal();

  factory GlobalBloc() {
    return _singleton;
  }

  GlobalBloc._internal() {
    expertList = [];
    callList = [];
    projectList = [];
    currentUser = User.defaultUser();
  }

  late List<Project> projectList;
  late List<AvailableExpert> expertList;
  late List<CallTracker> callList;
  late User currentUser;

  List<AvailableExpert> get expertListStream => expertList;
  List<CallTracker> get callListStream => callList;
  List<Project> get projectListStream => projectList;

  Future<void> onUserLogin(String token) async {
    AuthAPI _authAPI = AuthAPI();

    // Fetching data from the API
    List<AvailableExpert> fetchedExperts = await _authAPI.getExperts(token);
    List<CallTracker> fetchedCalls = await _authAPI.getCalls(token);
    List<Project> fetchedProjects = await _authAPI.getProjects(token);

    // Apply filtering based on the projectId
    if (projectIdFilter.isNotEmpty) {
      fetchedExperts = fetchedExperts
          .where((expert) => expert.projectId == projectIdFilter)
          .toList();
      fetchedCalls = fetchedCalls
          .where((call) => call.projectId == projectIdFilter)
          .toList();
    }

    // Assigning filtered lists to the global state
    this.expertList = fetchedExperts;
    this.callList = fetchedCalls;
    this.projectList = fetchedProjects;

    User user = await _authAPI.getUser(token);
    this.currentUser = user;

    notifyListeners();
  }

  Future<void> onUserLogout() async {
    expertList = [];
    callList = [];
    projectList = [];
    currentUser = User.defaultUser();
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
      default:
        return false;
    }
  }

  void toggleFavorite(AvailableExpert expert) {
    int index = expertList.indexOf(expert);
    if (index != -1) {
      expertList[index].favorite = !(expertList[index].favorite);
      notifyListeners();
    }
  }
}
