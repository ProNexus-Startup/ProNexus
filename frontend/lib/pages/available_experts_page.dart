import 'package:admin/pages/components/expert_table.dart';
import 'package:admin/pages/components/sidebar.dart';
import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/pages/components/header.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/expert_filter_model.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvailableExpertsDashboard extends StatefulWidget {
  static const routeName = '/experts';

  final String token;

  const AvailableExpertsDashboard({Key? key, required this.token})
      : super(key: key);

  @override
  _AvailableExpertsDashboardState createState() =>
      _AvailableExpertsDashboardState();
}

class _AvailableExpertsDashboardState extends State<AvailableExpertsDashboard> {
  bool isAnySelected = false;
  final GlobalKey<ExpertTableState> _expertTableKey =
      GlobalKey<ExpertTableState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  // Update this based on checkbox changes
  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  void exportToCSV(BuildContext context) {
    final state = _expertTableKey.currentState;
    if (state != null) {
      state.exportToCSV();
    } else {
      print("Could not find ExpertTable state.");
    }
  }

  Future<void> _showAddExpertDialog(BuildContext context, String orgId) async {
    final AuthAPI _authAPI = AuthAPI();

    SecureStorage secureStorage = SecureStorage();
    String projectId = await secureStorage.read('projectId');

    TextEditingController nameController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController companyController = TextEditingController();
    TextEditingController companyTypeController = TextEditingController();
    DateTime startDateController = DateTime.now();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController geographyController = TextEditingController();
    TextEditingController angleController = TextEditingController();
    TextEditingController statusController = TextEditingController();
    TextEditingController commentsController = TextEditingController();
    TextEditingController costController = TextEditingController();
    List<String> screeningQuestions = [];
    bool isSelected = false;
    bool favorite = false;

    Future<void> _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          startDateController = picked;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Expert'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    try {
                      double cost = double.parse(costController.text);

                      AvailableExpert newExpert = AvailableExpert(
                        isSelected: isSelected,
                        favorite: favorite,
                        expertId:
                            '', // This should be generated or handled elsewhere
                        name: nameController.text,
                        organizationId: orgId,
                        projectId: projectId,
                        profession: titleController.text,
                        company: companyController.text,
                        companyType: companyTypeController.text,
                        startDate: startDateController,
                        description: descriptionController.text,
                        geography: geographyController.text,
                        angle: angleController.text,
                        status: statusController.text,
                        aiAssessment: 0, // Set default or handle elsewhere
                        aiAnalysis: '', // Set or handle
                        comments: commentsController.text,
                        availabilities: [], // Set default or provide a selection
                        expertNetworkName: '', // Set or handle
                        cost: cost,
                        screeningQuestionsAndAnswers: screeningQuestions
                            .map((q) => Question(question: q, answer: ''))
                            .toList(),
                        addedExpertBy: '', // Set or handle
                        dateAddedExpert: DateTime.now(),
                        trends: '', // Set or handle
                      );
                      _authAPI.makeExpert(newExpert, widget.token);
                      //_loadData();
                      Navigator.of(context).pop();
                    } catch (e) {
                      // Handle any parsing errors here
                      // For instance, show a dialog or a message to the user
                      print('Error parsing cost: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: TopMenu(),
      ),
      body: Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
        return Column(
          children: [
            SubMenu(
              token: widget.token,
            ),
            Row(
              children: [
                const SizedBox(width: 55),
                Text(
                  '${globalBloc.filteredExperts.length} Experts found',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),

                const SizedBox(width: 20),
                /*ActionCard(
                  title: 'Search Live Projects',
                  leadingIcon: Image.asset('assets/icons/search.png',
                      height: 24, width: 24),
                ),*/
                const Spacer(),
                ElevatedButton(
                  child: Text('Download Experts'),
                  onPressed: () {
                    exportToCSV(context);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddExpertDialog(
                        context, globalBloc.currentUser.organizationId);
                  },
                  child: Text('Add Expert'),
                ),
                const SizedBox(width: 20), // Add spacing if needed
              ],
            ),
            const SizedBox(height: 26),
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 55),
                  SizedBox(
                    width: 310,
                    child: Sidebar(
                      onFilterValueSelected:
                          (ExpertFilterValues filterValue, bool isSelected) {
                        setState(() {
                          filterValue.isSelected = isSelected;
                          globalBloc.updateExpertFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ExpertTable(
                      key: _expertTableKey,
                      experts: globalBloc.filteredExperts,
                      onFavoriteChange: (val, expert) {
                        setState(() {
                          expert.favorite = val;
                          globalBloc.updateExpertFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
