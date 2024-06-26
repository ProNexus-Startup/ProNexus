import 'package:admin/pages/project_creation_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/pages/components/header.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthAPI _authAPI = AuthAPI();
  late List<Project> userProjectList = [];
  late List<Project> totalProjectList = [];
  bool _isMounted = false;
  late String token = '';

  String? _selectedProject;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadData();
    _saveContext(HomePage.routeName);
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _saveContext(String route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', route);
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    token = await SecureStorage().read('token');

    if (token.isNotEmpty) {
      try {
        await globalBloc.onUserLogin();
      } catch (e) {
        print('Error during user login: $e');
      }
    }

    print(globalBloc.currentUser.pastProjects);
    print('new info here');

    print(globalBloc.projectList.first.projectId);
    print(globalBloc.currentUser.pastProjects.first.projectId);

    setState(() {
      userProjectList = globalBloc.projectList
          .where((project) => globalBloc.currentUser.pastProjects
              .any((proj) => proj.projectId == project.projectId))
          .toList();

      totalProjectList = globalBloc.projectList;
    });
    print(userProjectList);
  }

  void _showRegisterProjectDialog(
      BuildContext context, List<Project> projects) {
    DateTime? dateOnboarded;
    final List<String> projectNames =
        projects.map((project) => project.name).toList();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateOnboarded ?? DateTime.now(),
        firstDate: DateTime(1960),
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != dateOnboarded) {
        if (_isMounted) {
          setState(() {
            dateOnboarded = picked;
          });
        }
      }
    }

    String getProjectID(String name) {
      Project? project = projects.firstWhere((p) => p.name == name);
      return project.projectId ?? '';
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
                width: double.infinity,
                child: DropdownButton<String>(
                  value: _selectedProject,
                  hint: Text('Select Project'),
                  onChanged: (String? newValue) {
                    if (_isMounted) {
                      setState(() {
                        _selectedProject = newValue;
                      });
                    }
                    Navigator.of(context).pop();
                    _showRegisterProjectDialog(context, projects);
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
                  _selectDate(context);
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
                        : "${dateOnboarded?.month}/${dateOnboarded?.day}/${dateOnboarded?.year}",
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
              onPressed: () async {
                if (_selectedProject != null && dateOnboarded != null) {
                  String selection = getProjectID(_selectedProject!);
                  try {
                    await _authAPI.changeProjects(
                        token, selection, dateOnboarded!);
                    await _authAPI.refreshToken(token);
                    await _loadData();
                    if (_isMounted) {
                      setState(() {});
                    }
                  } catch (e) {
                    print('Error during project registration: $e');
                  }
                  Navigator.of(context).pop();
                } else {
                  String message = '';
                  if (_selectedProject == null) {
                    message += 'Please select a project. ';
                  }
                  if (dateOnboarded == null) {
                    message += 'Please select a date onboarded.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message.trim())),
                  );
                }
              },
              child: Text('Register'),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    if (status == 'Open') return Colors.green;
    if (status == 'Closed') return Colors.grey;
    return primaryBlue;
  }

  Widget _buildProjectTable(GlobalBloc globalBloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'All Projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Tooltip(
                message:
                    "You need to be registered for a project for automatic expert uploading to work. Experts received while marked on the bench will be sent to the 'Expert Lost & Found' tab.",
                child: Icon(Icons.info_outline, color: Colors.grey),
              ),
            ],
          ),
        ),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
              columns: const <DataColumn>[
                DataColumn(label: Text('Start date')),
                DataColumn(label: Text('Project name')),
                DataColumn(label: Text('Target')),
                DataColumn(label: Text('Calls completed')),
                DataColumn(label: Text('Status')),
              ],
              rows: globalBloc.currentUser.pastProjects.map<DataRow>((proj) {
                final project = globalBloc.projectList.firstWhere(
                    (p) => p.projectId == proj.projectId,
                    orElse: () => Project.defaultProject(''));
                final color =
                    globalBloc.currentUser.pastProjects.indexOf(proj) % 2 == 0
                        ? Colors.white
                        : Colors.black12;
                return DataRow(
                  color: WidgetStateProperty.all(color),
                  cells: <DataCell>[
                    DataCell(Text(proj.start.toIso8601String())),
                    DataCell(Text(project.name)),
                    DataCell(Text(project.targetCompany)),
                    DataCell(Text(project.callsCompleted.toString())),
                    DataCell(
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(project.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          project.status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: TextButton.icon(
            onPressed: () {
              _showRegisterProjectDialog(context, globalBloc.projectList);
            },
            icon: const Icon(Icons.add),
            label: const Text('Register for new project'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: TopMenu(),
      ),
      body: Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
        if (totalProjectList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey),
                Text(
                  'You have no projects, make a new project',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(
                      context,
                      ProjectCreationPage.routeName,
                      arguments: ScreenArguments(token),
                    );
                    _saveContext(ProjectCreationPage.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child:
                      Text('Start new project', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        } else if (userProjectList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late, size: 80, color: Colors.grey),
                Text(
                  'You are not registered for any projects',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showRegisterProjectDialog(context, totalProjectList);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text('Register for a Project',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        } else {
          return _buildProjectTable(globalBloc);
        }
      }),
    );
  }
}
