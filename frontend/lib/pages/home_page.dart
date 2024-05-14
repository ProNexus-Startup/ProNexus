import 'package:admin/pages/components/top_menu.dart';
import 'package:admin/pages/components/cards/project_card.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/global_bloc.dart';

class HomePage extends StatefulWidget {
  final String token;
  static const routeName = '/home';

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthAPI _authAPI = AuthAPI();

  // Currently selected project
  String? _selectedProject;

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

  void _showRegisterProjectDialog(
      BuildContext context, List<Project> projects) {
    DateTime? dateOnboarded;
    final List<String> projectNames =
        projects.map((project) => project.name).toList();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateOnboarded ??
            DateTime.now(), // Use current date if no date has been picked
        firstDate: DateTime(1960), // Adjust based on your requirement
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != dateOnboarded) {
        // Update the state with the new selected date
        (context as Element).markNeedsBuild();
        dateOnboarded = picked;
      }
    }

    String printProjectId(String name) {
      // Search for the project with the given name
      Project? project = projects.firstWhere((p) => p.name == name,
          orElse: () => throw Exception("Project not found"));

      return project.projectId!;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Register for Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width:
                    double.infinity, // Makes the dropdown take the full width
                child: DropdownButton<String>(
                  value: _selectedProject,
                  hint: Text(
                      'Select Project'), // Hint text shown when no project is selected

                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProject = newValue;
                    });
                    Navigator.of(context)
                        .pop(); // Close the dialog after selection
                    _showRegisterProjectDialog(context,
                        projects); // Re-open the dialog with updated selection
                  },
                  items: projectNames
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              InkWell(
                onTap: () {
                  _selectDate(context).then((_) {
                    // Update UI after date selection
                    setState(() {});
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: Text(
                    dateOnboarded == null
                        ? "Select Start Date"
                        : "${dateOnboarded!.month}/${dateOnboarded!.day}/${dateOnboarded!.year}",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String selection = printProjectId(_selectedProject.toString());
                _authAPI.changeProjects(
                    widget.token, selection, dateOnboarded!);
                Navigator.of(context).pop();
              },
              child: Text('Register'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    List<Project> userProjectList = globalBloc.userProjectList;
    String? currentId = globalBloc.currentUser.projectId;
    List<Project> totalProjectList = globalBloc.projectList;

    if (globalBloc.currentUser.projectId != null) {
      List<Project> filteredProjects = totalProjectList
          .where((project) => currentId!.contains(project.projectId!))
          .toList();

      if (filteredProjects.isNotEmpty) {
        Project projectToAdd = filteredProjects[0];
        // Check if the project is not already in the userProjectList before adding
        bool isAlreadyAdded = userProjectList
            .any((project) => project.projectId == projectToAdd.projectId);
        if (!isAlreadyAdded) {
          userProjectList.add(projectToAdd);
        }
      }
    }

    print("currentId: ${currentId}");
    print("past ids: ${globalBloc.currentUser.pastProjectIDs}");
    print(globalBloc.currentUser.admin);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: TopMenu(),
        ),
        body: ListView.builder(
          itemCount: userProjectList.length,
          itemBuilder: (context, index) {
            return ProjectTile(
              project: userProjectList[index],
              token: widget.token,
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ElevatedButton(
          onPressed: () {
            _showRegisterProjectDialog(context, totalProjectList);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text('+ Register for project', style: TextStyle(fontSize: 16)),
        ));
  }
}
