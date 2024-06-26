import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/expert_filter_model.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/models/user.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';

class GlobalBloc with ChangeNotifier {
  // Singleton instance
  static final GlobalBloc _singleton = GlobalBloc._internal();

  factory GlobalBloc() {
    return _singleton;
  }

  GlobalBloc._internal() {
    expertList = [];
    callList = [];
    unfilteredExpertList = [];
    unfilteredCallList = [];
    projectList = [];
    userProjectList = [];
    userList = [];
    currentUser = User.defaultUser();
  }

  // All experts list
  List<AvailableExpert> _allExperts = [];

  // Filtered experts list based on the filters applied
  List<AvailableExpert> filteredExperts = [];
  String benchProject = '';

  // Get all experts list
  List<AvailableExpert> get allExperts => _allExperts;

  // List of filters to be applied
  List<ExpertFilterModel> filters = [
    ExpertFilterModel(filterValues: [], heading: 'Status'),
    ExpertFilterModel(filterValues: [], heading: 'Favorite'),
    ExpertFilterModel(filterValues: [], heading: 'Angle'),
    ExpertFilterModel(filterValues: [], heading: 'Geography'),
    ExpertFilterModel(filterValues: [], heading: 'Expert Network'),
  ];

  // Example filter variables
  bool favoriteFilter = false;
  String geographyFilter = '';
  String availabilityFilter = '';
  String projectIdFilter = '';

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

  late List<Project> projectList;
  late List<Project> userProjectList;
  late List<User> userList;
  late List<AvailableExpert> expertList;
  late List<AvailableExpert> unfilteredExpertList;
  late List<CallTracker> callList;
  late List<CallTracker> unfilteredCallList;
  late User currentUser;

  List<AvailableExpert> get expertListStream => expertList;
  List<AvailableExpert> get unfilteredExpertListStream => unfilteredExpertList;

  List<CallTracker> get callListStream => callList;
  List<CallTracker> get unfilteredCallListStream => unfilteredCallList;

  List<Project> get projectListStream => projectList;
  List<Project> get userProjectListStream => userProjectList;
  List<User> get userListStream => userList;

  Future<void> onUserLogin() async {
    String token = await SecureStorage().read('token');

    AuthAPI _authAPI = AuthAPI();

    try {
      // Fetching data
      List<AvailableExpert> fetchedExperts = await _authAPI.getExperts(token);
      List<CallTracker> fetchedCalls = await _authAPI.getCalls(token);
      List<Project> fetchedProjects = await _authAPI.getProjects(token);
      List<User> fetchedUsers = await _authAPI.getUsers(token);

      // Assigning project list
      projectList = fetchedProjects;

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
      this.userList = fetchedUsers;
      this.unfilteredExpertList = fetchedExperts;
      this.unfilteredCallList = fetchedCalls;

      // Fetch current user and apply user-specific filters
      User user = await _authAPI.getUser(token);
      this.currentUser = user;

      this.benchProject = projectList
              .where((project) => project.name == 'bench')
              .toList()
              .first
              .projectId ??
          '';

      var uniqueProjectIds = <String>{};

      for (var project in user.pastProjects) {
        uniqueProjectIds.add(project.projectId);
      }

      List<String> idsToFilter = uniqueProjectIds.toList();
      List<Project> filteredProjects = projectList
          .where((project) => idsToFilter.contains(project.projectId))
          .toList();

      this.userProjectList = filteredProjects;

      // Additional expert filtering
      _allExperts = fetchedExperts;
      filteredExperts.clear();
      filteredExperts.addAll(_allExperts);
      updateExpertFilters();
      filterExperts();

      notifyListeners();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> filterAvailableExpert(List<ExpertFilterModel> filters) async {
    // Filter the experts based on the filters
    // filteredExperts = allExperts.where((expert) => applyFilters(expert)).toList();
    notifyListeners();
  }

  Future<void> onUserLogout() async {
    expertList = [];
    callList = [];
    projectList = [];
    userList = [];
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
        return (expert.geography) == value;
      case 'Company':
        return (expert.company) == value;
      case 'Status':
        return (expert.status) == value;
      case 'Availabilities':
        return (expert.availabilities) == value;
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

  void toggleScheduled(CallTracker call) {
    int index = callList.indexOf(call);
    if (index != -1) {
      callList[index].favorite = !(callList[index].favorite);
      notifyListeners();
    }
  }

  Future<void> filterExperts() async {
    filteredExperts.clear();
    List<AvailableExpert> allExpertA = [..._allExperts];
    _removeExtraExpert(allExpertA, filters[0],
        (expert, filterValue) => expert.status == filterValue.value);
    _removeExtraExpert(
        allExpertA,
        filters[1],
        (expert, filterValue) =>
            (expert.favorite ? "Favorite" : "Not Favorite") ==
            filterValue.value);
    _removeExtraExpert(allExpertA, filters[2],
        (expert, filterValue) => expert.angle == filterValue.value);
    _removeExtraExpert(allExpertA, filters[3],
        (expert, filterValue) => expert.geography == filterValue.value);
    _removeExtraExpert(allExpertA, filters[4],
        (expert, filterValue) => expert.expertNetworkName == filterValue.value);

    // Add projectId filter
    if (projectIdFilter.isNotEmpty) {
      allExpertA.retainWhere((expert) => expert.projectId == projectIdFilter);
    }

    filteredExperts.clear();
    filteredExperts.addAll(allExpertA);
    notifyListeners();
  }

  void _removeExtraExpert(
      List<AvailableExpert> allExpertA,
      ExpertFilterModel filterModel,
      bool Function(AvailableExpert, ExpertFilterValues) condition) {
    if (filterModel.filterValues.any((ExpertFilterValues e) => e.isSelected)) {
      for (ExpertFilterValues filterValue in filterModel.filterValues) {
        if (!filterValue.isSelected) {
          allExpertA.removeWhere((expert) => condition(expert, filterValue));
        }
      }
    }
  }

  Future<void> updateExpertFilters() async {
    filterExperts();
    // Update state of filters
    List<ExpertFilterModel> expertFiltersTemp = [];
    expertFiltersTemp.addAll(filters.map((e) => e.copyWith()));

    expertFiltersTemp[0].filterValues = _updateSingleFilters(
      expertFiltersTemp[0],
      (expert) => expert.status!,
    );
    expertFiltersTemp[1].filterValues = _updateSingleFilters(
      expertFiltersTemp[1],
      (expert) => expert.favorite ? "Favorite" : "Not Favorite",
    );
    expertFiltersTemp[2].filterValues = _updateSingleFilters(
      expertFiltersTemp[2],
      (expert) => expert.angle!,
    );
    expertFiltersTemp[3].filterValues = _updateSingleFilters(
      expertFiltersTemp[3],
      (expert) => expert.geography!,
    );
    expertFiltersTemp[4].filterValues = _updateSingleFilters(
      expertFiltersTemp[4],
      (expert) => expert.expertNetworkName!,
    );

    // Update state of filters
    for (ExpertFilterModel filter in expertFiltersTemp) {
      filter.filterValues = filter.filterValues
          .map((e) => e.copyWith(
              isSelected: _isFilterSelected(filter.heading, e.value)))
          .toList();
    }
    filters = expertFiltersTemp;
    notifyListeners();
  }

  List<ExpertFilterValues> _updateSingleFilters(
    ExpertFilterModel filter,
    String Function(AvailableExpert) toElement,
  ) {
    // Update state of filters
    filter.filterValues = _allExperts
        .map(toElement)
        .toSet()
        .map((status) => ExpertFilterValues(
            value: status,
            isSelected: false,
            count: filteredExperts
                .where((expert) => toElement(expert) == status)
                .length
                .toString()))
        .toList();
    return filter.filterValues;
  }

  bool _isFilterSelected(String filterName, String value) {
    try {
      return filters
          .firstWhere((element) => element.heading == filterName)
          .filterValues
          .firstWhere((element) => element.value == value)
          .isSelected;
    } catch (e) {
      return false;
    }
  }
}
